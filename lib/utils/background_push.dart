// ignore_for_file: unused_element

import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter/material.dart';

import 'package:flutter_gen/gen_l10n/l10n.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as http;
import 'package:matrix/matrix.dart';
import 'package:unifiedpush/unifiedpush.dart';
import 'package:vrouter/vrouter.dart';

import 'package:concieltalk/utils/matrix_sdk_extensions/client_stories_extension.dart';
import 'package:concieltalk/utils/push_helper.dart';
import 'package:concieltalk/config/app_config.dart';
import 'package:concieltalk/config/setting_keys.dart';
import 'package:concieltalk/utils/local_storage.dart';
import 'package:concieltalk/utils/platform_infos.dart';

import 'package:firebase_messaging/firebase_messaging.dart';

class NoTokenException implements Exception {
  String get cause => 'Cannot get firebase token';
}

class BackgroundNotifications {
  static BackgroundNotifications? _instance;
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  Client client;
  BuildContext? context;
  GlobalKey<VRouterState>? router;
  String? _fcmToken;
  void Function(String errorMsg, {Uri? link})? onFcmError;
  L10n? l10n;
  Store? _store;
  Store get store => _store ??= Store();
  Future<void> loadLocale() async {
    // inspired by _lookupL10n in .dart_tool/flutter_gen/gen_l10n/l10n.dart
    l10n ??= (context != null ? L10n.of(context!) : null) ??
        (await L10n.delegate.load(PlatformDispatcher.instance.locale));
  }

  final pendingTests = <String, Completer<void>>{};

  final dynamic firebase = FirebaseMessaging.instance;

  DateTime? lastReceivedPush;

  bool upAction = false;

  BackgroundNotifications._(this.client) {
    onRoomSync ??= client.onSync.stream
        .where((s) => s.hasRoomUpdate)
        .listen((s) => _onClearingPush(getFromServer: false));
    firebase?.setListeners(
      onMessage: (message) => pushHelper(
        PushNotification.fromJson(
          Map<String, dynamic>.from(message['data'] ?? message),
        ),
        client: client,
        l10n: l10n,
        activeRoomId: router?.currentState?.pathParameters['roomid'],
        onSelectNotification: goToRoom,
      ),
    );
  }

  factory BackgroundNotifications.clientOnly(Client client) {
    _instance ??= BackgroundNotifications._(client);
    Logs().v(
      'this is the instance - ${client.clientName}, ${_instance!._fcmToken}',
    );
    return _instance!;
  }

  factory BackgroundNotifications(
    Client client,
    BuildContext context,
    GlobalKey<VRouterState>? router, {
    final void Function(String errorMsg, {Uri? link})? onFcmError,
  }) {
    final instance = BackgroundNotifications.clientOnly(client);
    instance.context = context;
    // ignore: prefer_initializing_formals
    instance.router = router;
    // ignore: prefer_initializing_formals
    instance.onFcmError = onFcmError;
    return instance;
  }

  StreamSubscription<SyncUpdate>? onRoomSync;

  Future<void> showNotification(
    Message message,
  ) async {
    final notification = FlutterLocalNotificationsPlugin();
    await notification.initialize(
      const InitializationSettings(
        android: AndroidInitializationSettings('notifications_icon'),
        iOS: DarwinInitializationSettings(),
      ),
      onDidReceiveNotificationResponse: (details) => goToRoom(details),
    );

    await notification.show(
      10101,
      'Conciel',
      '$message from ${message.person}',
      const NotificationDetails(
        iOS: DarwinNotificationDetails(),
        android: AndroidNotificationDetails(
          AppConfig.pushNotificationsChannelId,
          AppConfig.pushNotificationsChannelName,
          audioAttributesUsage: AudioAttributesUsage.notificationRingtone,
          colorized: true,
          color: AppConfig.chatColor,
          channelDescription: AppConfig.pushNotificationsChannelDescription,
          importance: Importance.max,
          priority: Priority.max,
          largeIcon: DrawableResourceAndroidBitmap('banner'),

          /*actions: <AndroidNotificationAction>[
            AndroidNotificationAction(
              'ok',
              'Answer',
              icon: DrawableResourceAndroidBitmap('phone_answer'),
            ),
            AndroidNotificationAction(
              'cancel',
              'Reject',
              icon: DrawableResourceAndroidBitmap('phone_hangup'),
            ),
          ],*/
          fullScreenIntent: true,
        ),
      ),
    );
  }

  Future<void> setupPusher({
    String? gatewayUrl,
    String? token,
    Set<String?>? oldTokens,
    bool useDeviceSpecificAppId = false,
  }) async {
    if (PlatformInfos.isIOS) {
      await firebase?.requestPermission();
    }
    final clientName = PlatformInfos.clientName;
    oldTokens ??= <String>{};
    final pushers = await (client.getPushers().catchError((e) {
          Logs().w('[Push] Unable to request pushers', e);
          return <Pusher>[];
        })) ??
        [];
    // ignore: prefer_final_in_for_each
    for (var pusher in pushers) {
      Logs().i(
        '[PUSH] - here are the pushers ${pusher.appId} - ${pusher.pushkey} - ${pusher.data.format} - ${pusher.data.url} - ${pusher.data.additionalProperties} - ${pusher.kind} - ${pusher.profileTag}',
      );
    }
    var setNewPusher = false;
    // Just the plain app id, we add the .data_message suffix later
    const appId = AppConfig.pushNotificationsAppId;
    // we need the deviceAppId to remove potential legacy UP pusher
    var deviceAppId = '$appId.${client.deviceID}';
    // appId may only be up to 64 chars as per spec
    if (deviceAppId.length > 64) {
      deviceAppId = deviceAppId.substring(0, 64);
    }
    /*if (!useDeviceSpecificAppId && PlatformInfos.isAndroid) {
      appId += '.data_message';
    }*/
    final thisAppId = useDeviceSpecificAppId ? deviceAppId : appId;
    if (gatewayUrl != null && token != null) {
      final currentPushers = pushers.where((pusher) => pusher.pushkey == token);
      if (currentPushers.length == 1 &&
          currentPushers.first.kind == 'http' &&
          currentPushers.first.appId == thisAppId &&
          currentPushers.first.appDisplayName == clientName &&
          currentPushers.first.deviceDisplayName == client.deviceName &&
          currentPushers.first.lang == 'en' &&
          currentPushers.first.data.url.toString() == gatewayUrl &&
          currentPushers.first.data.format ==
              AppConfig.pushNotificationsPusherFormat) {
        if (!pusherLogDone) {
          Logs().i('[Push] Pusher already set - $token');
          pusherLogDone = true;
        }
      } else {
        Logs().i('Need to set new pusher');
        oldTokens.add(token);
        if (client.isLogged()) {
          setNewPusher = true;
        }
      }
    } else {
      Logs().w('[Push] Missing required push credentials');
    }
    for (final pusher in pushers) {
      if ((token != null &&
              pusher.pushkey != token &&
              deviceAppId == pusher.appId) ||
          oldTokens.contains(pusher.pushkey)) {
        try {
          await client.deletePusher(pusher);
          Logs().i('[Push] Removed legacy pusher for this device');
        } catch (err) {
          Logs().w('[Push] Failed to remove old pusher', err);
        }
      }
    }
    if (setNewPusher) {
      try {
        await client.postPusher(
          Pusher(
            pushkey: token!,
            appId: thisAppId,
            appDisplayName: clientName,
            deviceDisplayName: client.deviceName!,
            lang: 'en',
            data: PusherData(
              url: Uri.parse(gatewayUrl!),
              format: AppConfig.pushNotificationsPusherFormat,
            ),
            kind: 'http',
          ),
          append: false,
        );
        Logs().i('[Push] Pusher successfully set - $token');
        pusherLogDone = true;
      } catch (e, s) {
        Logs().e('[Push] Unable to set pushers', e, s);
      }
    }
  }

  // ignore: prefer_final_fields
  bool _wentToRoomOnStartup = false;

  Future<void> setupPush() async {
    Logs().d("SetupPush");
    if (client.onLoginStateChanged.value != LoginState.loggedIn ||
        !PlatformInfos.isMobile ||
        context == null) {
      return;
    }
    // Do not setup unifiedpush if this has been initialized by
    // an unifiedpush action
    // Below is all related to specific Unified Push approach - this is not
    // being used currently.
    /*
    if (upAction) {
      return;
    }
    
    if (!PlatformInfos.isIOS &&
        (await UnifiedPush.getDistributors()).isNotEmpty) {
      await setupUp();
    } else {
      await setupFirebase();
    }
    */
    await setupFirebase();

    // ignore: unawaited_futures
    _flutterLocalNotificationsPlugin
        .getNotificationAppLaunchDetails()
        .then((details) {
      if (details == null ||
          !details.didNotificationLaunchApp ||
          _wentToRoomOnStartup ||
          router == null) {
        return;
      }
      // _wentToRoomOnStartup = true;
      // goToRoom(details.notificationResponse);
    });
  }

  Future<void> _noFcmWarning() async {
    if (context == null) {
      return;
    }
    if (await store.getItemBool(SettingKeys.showNoGoogle, true) == true) {
      return;
    }
    await loadLocale();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (PlatformInfos.isAndroid) {
        onFcmError?.call(
          l10n!.noGoogleServicesWarning,
          link: Uri.parse(
            AppConfig.enablePushTutorial,
          ),
        );
        return;
      }
      onFcmError?.call(l10n!.oopsPushError);
    });
  }

  Future<void> setupFirebase() async {
    Logs().v('Setup firebase');
    if (_fcmToken?.isEmpty ?? true) {
      try {
        _fcmToken = await firebase?.getToken();
        if (_fcmToken == null) throw ('PushToken is null');
      } catch (e, s) {
        Logs().w('[Push] cannot get token', e, e is String ? null : s);
        await _noFcmWarning();
        return;
      }
    }
    await setupPusher(
      gatewayUrl: AppConfig.pushNotificationsGatewayUrl,
      token: _fcmToken,
    );
  }

  Future<void> goToRoom(NotificationResponse? response) async {
    try {
      final roomId = response?.payload;
      Logs().v('[Push] Attempting to go to room $roomId...');
      if (router == null || roomId == null) {
        return;
      }
      await client.roomsLoading;
      await client.accountDataLoading;
      final isStory = client
              .getRoomById(roomId)
              ?.getState(EventTypes.RoomCreate)
              ?.content
              .tryGet<String>('type') ==
          ClientStoriesExtension.storiesRoomType;
      router!.currentState!.toSegments([isStory ? 'stories' : 'rooms', roomId]);
    } catch (e, s) {
      Logs().e('[Push] Failed to open room', e, s);
    }
  }

  Future<void> setupUp() async {
    await UnifiedPush.registerAppWithDialog(context!);
  }

  Future<void> _newUpEndpoint(String newEndpoint, String i) async {
    upAction = true;
    if (newEndpoint.isEmpty) {
      await _upUnregistered(i);
      return;
    }
    var endpoint = 'https://matrix.conciel.space/_matrix/push/v1/notify';
    try {
      final url = Uri.parse(newEndpoint)
          .replace(
            path: '/_matrix/push/v1/notify',
            query: '',
          )
          .toString()
          .split('?')
          .first;
      final res =
          json.decode(utf8.decode((await http.get(Uri.parse(url))).bodyBytes));
      if (res['gateway'] == 'matrix' ||
          (res['unifiedpush'] is Map &&
              res['unifiedpush']['gateway'] == 'matrix')) {
        endpoint = url;
      }
    } catch (e) {
      Logs().i(
        '[Push] No self-hosted unified push gateway present: $newEndpoint',
      );
    }
    Logs().i('[Push] UnifiedPush using endpoint $endpoint');
    final oldTokens = <String?>{};
    try {
      final fcmToken = await firebase?.getToken();
      oldTokens.add(fcmToken);
    } catch (_) {}
    await setupPusher(
      gatewayUrl: endpoint,
      token: newEndpoint,
      oldTokens: oldTokens,
      useDeviceSpecificAppId: true,
    );
    await store.setItem(SettingKeys.unifiedPushEndpoint, newEndpoint);
    await store.setItemBool(SettingKeys.unifiedPushRegistered, true);
  }

  Future<void> _upUnregistered(String i) async {
    upAction = true;
    Logs().i('[Push] Removing UnifiedPush endpoint...');
    final oldEndpoint = await store.getItem(SettingKeys.unifiedPushEndpoint);
    await store.setItemBool(SettingKeys.unifiedPushRegistered, false);
    await store.deleteItem(SettingKeys.unifiedPushEndpoint);
    if (oldEndpoint?.isNotEmpty ?? false) {
      // remove the old pusher
      await setupPusher(
        oldTokens: {oldEndpoint},
      );
    }
  }

  Future<void> _onUpMessage(Uint8List message, String i) async {
    upAction = true;
    final data = Map<String, dynamic>.from(
      json.decode(utf8.decode(message))['notification'],
    );
    // UP may strip the devices list
    data['devices'] ??= [];
    await pushHelper(
      PushNotification.fromJson(data),
      client: client,
      l10n: l10n,
      activeRoomId: router?.currentState?.pathParameters['roomid'],
    );
  }

  /// Workaround for the problem that local notification IDs must be int but we
  /// sort by [roomId] which is a String. To make sure that we don't have duplicated
  /// IDs we map the [roomId] to a number and store this number.
  late Map<String, int> idMap;
  Future<void> _loadIdMap() async {
    idMap = Map<String, int>.from(
      json.decode(
        (await store.getItem(SettingKeys.notificationCurrentIds)) ?? '{}',
      ),
    );
  }

  Future<int> mapRoomIdToInt(String roomId) async {
    await _loadIdMap();
    int? currentInt;
    try {
      currentInt = idMap[roomId];
    } catch (_) {
      currentInt = null;
    }
    if (currentInt != null) {
      return currentInt;
    }
    var nCurrentInt = 0;
    while (idMap.values.contains(currentInt)) {
      nCurrentInt++;
    }
    idMap[roomId] = nCurrentInt;
    await store.setItem(SettingKeys.notificationCurrentIds, json.encode(idMap));
    return nCurrentInt;
  }

  bool _clearingPushLock = false;
  Future<void> _onClearingPush({bool getFromServer = true}) async {
    if (_clearingPushLock) {
      return;
    }
    try {
      _clearingPushLock = true;
      late Iterable<String> emptyRooms;
      if (getFromServer) {
        Logs().v('[Push] Got new clearing push');
        var syncErrored = false;
        if (client.syncPending) {
          Logs().v('[Push] waiting for existing sync');
          // we need to catchError here as the Future might be in a different execution zone
          await client.oneShotSync().catchError((e) {
            syncErrored = true;
            Logs().v('[Push] Error one-shot syncing', e);
          });
        }
        if (!syncErrored) {
          Logs().v('[Push] single oneShotSync');
          // we need to catchError here as the Future might be in a different execution zone
          await client.oneShotSync().catchError((e) {
            syncErrored = true;
            Logs().v('[Push] Error one-shot syncing', e);
          });
          if (!syncErrored) {
            emptyRooms = client.rooms
                .where((r) => r.notificationCount == 0)
                .map((r) => r.id);
          }
        }
        if (syncErrored) {
          try {
            Logs().v(
              '[Push] failed to sync for fallback push, fetching notifications endpoint...',
            );
            final notifications = await client.getNotifications(limit: 20);
            final notificationRooms =
                notifications.notifications.map((n) => n.roomId).toSet();
            emptyRooms = client.rooms
                .where((r) => !notificationRooms.contains(r.id))
                .map((r) => r.id);
          } catch (e) {
            Logs().v(
              '[Push] failed to fetch pending notifications for clearing push, falling back...',
              e,
            );
            emptyRooms = client.rooms
                .where((r) => r.notificationCount == 0)
                .map((r) => r.id);
          }
        }
      } else {
        emptyRooms = client.rooms
            .where((r) => r.notificationCount == 0)
            .map((r) => r.id);
      }
      await _loadIdMap();
      var changed = false;
      for (final roomId in emptyRooms) {
        final id = idMap[roomId];
        if (id != null) {
          idMap.remove(roomId);
          changed = true;
          await _flutterLocalNotificationsPlugin.cancel(id);
        }
      }
      if (changed) {
        await store.setItem(
          SettingKeys.notificationCurrentIds,
          json.encode(idMap),
        );
      }
    } finally {
      _clearingPushLock = false;
    }
  }
}

@pragma('vm:entry-point')
Future<void> goToApp(
  NotificationResponse? response,
  GlobalKey<VRouterState> router,
  Client client,
  FlutterLocalNotificationsPlugin notification,
  CallSession callSession,
) async {
  try {
    final roomId = response?.payload;
    Logs().v('[Push] Attempting to go to room $roomId...');
    if (roomId == null) {
      return;
    }

    if (response?.payload != null) {
      debugPrint('notification payload: ${response?.actionId}');
    }
    if (response?.actionId == 'ok') {
      // Open the app and answer the call
      await client.roomsLoading;
      await client.accountDataLoading;
      final isStory = client
              .getRoomById(roomId)
              ?.getState(EventTypes.RoomCreate)
              ?.content
              .tryGet<String>('type') ==
          ClientStoriesExtension.storiesRoomType;
      router.currentState!.toSegments([
        isStory ? 'stories' : 'rooms',
      ]);
      callSession.answer();
    } else {
      // Send action to the app to stop the ongoing call
      await client.roomsLoading;
      await client.accountDataLoading;
      final isStory = client
              .getRoomById(roomId)
              ?.getState(EventTypes.RoomCreate)
              ?.content
              .tryGet<String>('type') ==
          ClientStoriesExtension.storiesRoomType;
      router.currentState!.toSegments([isStory ? 'stories' : 'rooms', roomId]);
    }
    // Cancel the notification
    await notification.cancel(0);
  } catch (e, s) {
    Logs().e('[Push] Failed to open room', e, s);
  }
}

Future<void> callNotification(
  CallSession callSession,
  GlobalKey<VRouterState> router,
  Client client,
) async {
  final notification = FlutterLocalNotificationsPlugin();
  await notification.initialize(
    const InitializationSettings(
      android: AndroidInitializationSettings('notifications_icon'),
      iOS: DarwinInitializationSettings(),
    ),
    onDidReceiveNotificationResponse: (details) => goToApp(
      details,
      router,
      client,
      notification,
      callSession,
    ),
  );
  final String callType =
      callSession.type == CallType.kVideo ? 'Video' : 'Voice';

  await notification.show(
    callSession.hashCode,
    'Conciel $callType call',
    callSession.room.getLocalizedDisplayname(),
    const NotificationDetails(
      iOS: DarwinNotificationDetails(),
      android: AndroidNotificationDetails(
        AppConfig.pushNotificationsChannelId,
        AppConfig.pushNotificationsChannelName,
        audioAttributesUsage: AudioAttributesUsage.notificationRingtone,
        colorized: true,
        color: AppConfig.chatColor,
        channelDescription: AppConfig.pushNotificationsChannelDescription,
        importance: Importance.max,
        priority: Priority.max,
        actions: <AndroidNotificationAction>[
          AndroidNotificationAction(
            'ok',
            'Answer',
            icon: DrawableResourceAndroidBitmap('phone_answer'),
            showsUserInterface: true,
            cancelNotification: true,
          ),
        ],
        fullScreenIntent: true,
      ),
    ),
  );
}

Future<void> closeNotifications() async {
  final notification = FlutterLocalNotificationsPlugin();
  await notification.initialize(
    const InitializationSettings(
      android: AndroidInitializationSettings('notifications_icon'),
      iOS: DarwinInitializationSettings(),
    ),
  );
  await notification.cancelAll();
}

Future<void> closeNotification(Room room) async {
  final notification = FlutterLocalNotificationsPlugin();
  await notification.initialize(
    const InitializationSettings(
      android: AndroidInitializationSettings('notifications_icon'),
      iOS: DarwinInitializationSettings(),
    ),
  );

  await notification.cancel(room.hashCode);
}

Future<void> msgNotification(
  GlobalKey<VRouterState> router,
  Room room,
  int count,
) async {
  final notification = FlutterLocalNotificationsPlugin();
  await notification.initialize(
    const InitializationSettings(
      android: AndroidInitializationSettings('notifications_icon'),
      iOS: DarwinInitializationSettings(),
    ),
    onDidReceiveNotificationResponse: (response) => goToChat(
      response,
      router,
      room,
      notification,
    ),
  );
  final l10n = (await L10n.delegate.load(PlatformDispatcher.instance.locale));

  final roomid = router.currentState!.pathParameters['roomid'];
  Logs().i('[NOTIFY] ... room ... $roomid ');
  if (roomid != room.id) {
    await notification.show(
      room.hashCode,
      l10n.newMessageInConcielTalk,
      'from ${room.getLocalizedDisplayname()}',
      NotificationDetails(
        iOS: const DarwinNotificationDetails(),
        android: AndroidNotificationDetails(
          AppConfig.pushNotificationsChannelId,
          AppConfig.pushNotificationsChannelName,
          audioAttributesUsage: AudioAttributesUsage.notificationRingtone,
          colorized: true,
          number: count,
          ticker: l10n.unreadChats(count),
          color: AppConfig.chatColor,
          channelDescription: AppConfig.pushNotificationsChannelDescription,
          importance: Importance.max,
          priority: Priority.max,
        ),
      ),
      payload: room.id,
    );
  }
}

@pragma('vm:entry-point')
Future<void> goToChat(
  NotificationResponse? response,
  GlobalKey<VRouterState> router,
  Room room,
  FlutterLocalNotificationsPlugin notification,
) async {
  if (response?.actionId == 'ok') {
    // Open the app and go to specific room
    final isStory =
        room.getState(EventTypes.RoomCreate)?.content.tryGet<String>('type') ==
            ClientStoriesExtension.storiesRoomType;
    router.currentState!.toSegments([isStory ? 'stories' : 'rooms', room.id]);
  } else {
    // Open the app and go to the rooms list
    final isStory =
        room.getState(EventTypes.RoomCreate)?.content.tryGet<String>('type') ==
            ClientStoriesExtension.storiesRoomType;
    router.currentState!.toSegments([
      isStory ? 'stories' : 'rooms',
    ]);
  }
  // Cancel the notification
  await notification.cancel(0);
}
