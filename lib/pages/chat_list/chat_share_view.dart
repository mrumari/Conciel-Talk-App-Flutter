// ignore_for_file: unused_field

import 'dart:async';
import 'dart:io';

import 'package:concieltalk/config/color_constants.dart';
import 'package:concieltalk/pages/bootstrap/bootstrap_dialog.dart';
import 'package:concieltalk/pages/chat/send_file_dialog.dart';
import 'package:concieltalk/utils/local_storage.dart';
import 'package:concieltalk/utils/matrix_sdk_extensions/matrix_file_extension.dart';
import 'package:concieltalk/utils/matrix_sdk_extensions/matrix_locals.dart';
import 'package:concieltalk/utils/ui/header_footer.dart';
import 'package:concieltalk/utils/voip/callkeep_manager.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:animations/animations.dart';
import 'package:flutter_gen/gen_l10n/l10n.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:matrix/matrix.dart';

import 'package:concieltalk/pages/chat_list/chat_list.dart';
import 'package:concieltalk/utils/matrix_sdk_extensions/client_stories_extension.dart';
import 'package:concieltalk/utils/stream_extension.dart';
import 'package:concieltalk/widgets/avatar.dart';
import 'package:vrouter/vrouter.dart';
import 'package:concieltalk/widgets/matrix.dart';

class ChatShare extends StatefulWidget {
  const ChatShare({Key? key}) : super(key: key);

  @override
  ChatShareController createState() => ChatShareController();
}

class ChatShareController extends State<ChatShare>
    with TickerProviderStateMixin, RouteAware {
  Room? selectedRoom;
  StreamSubscription? _intentDataStreamSubscription;
  StreamSubscription? _intentFileStreamSubscription;
  StreamSubscription? _intentUriStreamSubscription;
  FilePickerResult? shareResult;
  String? searchServer;
  AnimationController? slidePage;
  Animation<Offset>? slideAnimation;
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  ActiveFilter activeFilter = ActiveFilter.allChats;

  /*
  void _processIncomingUris(String? text) async {
    if (text == null) return;
    VRouter.of(context).to('/rooms');
    WidgetsBinding.instance.addPostFrameCallback((_) {
      UrlLauncher(context, text).openMatrixToUrl();
    });
  }

  void _processIncomingSharedFiles(List<SharedMediaFile> files) {
    if (files.isEmpty) return;
    //final file = File(files.first.path.replaceFirst('file://', ''));

    final List<String?> filePaths = files.map((file) => file.path).toList();
    VRouter.of(context).to(
      'fileshare',
      queryParameters: {'files': filePaths.join(',')},
    );
    SendFileDialog(
      files: files
          .map(
            (file) => MatrixFile(
              bytes:
                  File(file.path.replaceFirst('file://', '')).readAsBytesSync(),
              name: file.path,
            ).detectFileType,
          )
          .toList(),
      room: selectedRoom!,
    );
    return;
  }

  void _processIncomingSharedText(String? text) {
    if (text == null) return;
    if (text.toLowerCase().startsWith(AppConfig.deepLinkPrefix) ||
        text.toLowerCase().startsWith(AppConfig.inviteLinkPrefix) ||
        (text.toLowerCase().startsWith(AppConfig.schemePrefix) &&
            !RegExp(r'\s').hasMatch(text))) {
      return _processIncomingUris(text);
    }
    Matrix.of(context).shareContent = {
      'msgtype': 'm.text',
      'body': text,
    };
    VRouter.of(context).to('/rooms');
  }

  void _initReceiveSharingIntent() {
    if (!PlatformInfos.isMobile) return;

    // For sharing images coming from outside the app while the app is in the memory
    _intentFileStreamSubscription = ReceiveSharingIntent.getMediaStream()
        .listen(_processIncomingSharedFiles, onError: print);

    // For sharing images coming from outside the app while the app is closed
    ReceiveSharingIntent.getInitialMedia().then(_processIncomingSharedFiles);

    // For sharing or opening urls/text coming from outside the app while the app is in the memory
    _intentDataStreamSubscription = ReceiveSharingIntent.getTextStream()
        .listen(_processIncomingSharedText, onError: print);

    // For sharing or opening urls/text coming from outside the app while the app is closed
    ReceiveSharingIntent.getInitialText().then(_processIncomingSharedText);

    // For receiving shared Uris
    _intentUriStreamSubscription = linkStream.listen(_processIncomingUris);
    if (ConcielTalkApp.gotInitialLink == false) {
      ConcielTalkApp.gotInitialLink = true;
      getInitialLink().then(_processIncomingUris);
    }
  }
  */

  bool waitForFirstSync = false;
  static const String _serverStoreNamespace = 'im.concieltalk.search.server';

  Future<void> _waitForFirstSync() async {
    final client = Matrix.of(context).client;
    await client.roomsLoading;
    await client.accountDataLoading;
    if (client.prevBatch == null) {
      await client.onSync.stream.first;

      // Display first login bootstrap if enabled
      if (client.encryption?.keyManager.enabled == true) {
        if (await client.encryption?.keyManager.isCached() == false ||
            await client.encryption?.crossSigning.isCached() == false ||
            client.isUnknownSession && !mounted) {
          await BootstrapDialog(client: client).show(context);
        }
      }
    }
    if (!mounted) return;
    setState(() {
      waitForFirstSync = true;
    });
  }

  @override
  void initState() {
    _waitForFirstSync();
    CallKeepManager().initialize();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (mounted) {
        searchServer = await Store().getItem(_serverStoreNamespace);
        // if (!pusherLogDone) Matrix.of(context).backgroundPush?.setupPush();
      }
    });

    super.initState();
    slidePage = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    slideAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(-0.5, 0),
    ).animate(slidePage!);
  }

  bool Function(Room) getRoomFilterByActiveFilter(ActiveFilter activeFilter) {
    switch (activeFilter) {
      case ActiveFilter.allChats:
        return (room) => !room.isSpace && !room.isStoryRoom;
      case ActiveFilter.groups:
        return (room) =>
            !room.isSpace && !room.isDirectChat && !room.isStoryRoom;
      case ActiveFilter.messages:
        return (room) =>
            !room.isSpace && room.isDirectChat && !room.isStoryRoom;
      case ActiveFilter.spaces:
        return (r) => r.isSpace;
    }
  }

  bool _sortLock = false;

  void _sortRooms(List<Room> rooms) {
    if (_sortLock || rooms.length < 2) return;
    _sortLock = true;
    rooms.sort(sortRoomsBy);
    _sortLock = false;
  }

  RoomSorter get sortRoomsBy => (a, b) => (a.isFavourite != b.isFavourite)
      ? (a.isFavourite ? -1 : 1)
      : (a.notificationCount != b.notificationCount)
          ? b.notificationCount.compareTo(a.notificationCount)
          : b.timeCreated.millisecondsSinceEpoch
              .compareTo(a.timeCreated.millisecondsSinceEpoch);

  List<Room> get filteredRooms {
    final List<Room> rooms = Matrix.of(context)
        .client
        .rooms
        .where(
          (room) => !room.isSpace && !room.isStoryRoom,
        )
        .toList();

    _sortRooms(rooms);

    return rooms;
  }

  final _roomSelector = Completer<Room>();

  Future<Room> getRoom() {
    return _roomSelector.future;
  }

  final ScrollController scrollController = ScrollController();
  @override
  Widget build(BuildContext context) {
    final client = Matrix.of(context).client;
    const dummyChatCount = 4;
    final titleColor = personalColorScheme.outline;
    final subtitleColor = personalColorScheme.outline;

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: ScreenUtil().statusBarHeight + 32.h,
        foregroundColor: personalColorScheme.outline,
        titleSpacing: 0,
        automaticallyImplyLeading: false,
        actions: <Widget>[Container()],
        clipBehavior: Clip.none,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Builder(
              builder: (context) => DefaultHeaderWidget(
                onBackPress: () async {
                  for (int i = 0; i < filteredRooms.length; i++) {
                    filteredRooms[i].stopStaleCallsChecker(
                      filteredRooms[i].id,
                    );
                  }
                  await slidePage!.forward();
                  VRouter.of(context).to('/talk');
                },
                onSearchPress: () {},
              ),
            ),
          ],
        ),
      ),
      body: Stack(
        alignment: Alignment.center,
        children: [
          PageTransitionSwitcher(
            transitionBuilder: (
              Widget child,
              Animation<double> primaryAnimation,
              Animation<double> secondaryAnimation,
            ) {
              return SharedAxisTransition(
                animation: primaryAnimation,
                secondaryAnimation: secondaryAnimation,
                transitionType: SharedAxisTransitionType.vertical,
                fillColor: Theme.of(context).scaffoldBackgroundColor,
                child: child,
              );
            },
            child: StreamBuilder(
              key: ValueKey(
                client.userID.toString(),
              ),
              stream: client.onSync.stream
                  .where((s) => s.hasRoomUpdate)
                  .rateLimit(const Duration(seconds: 1)),
              builder: (context, _) {
                final rooms = filteredRooms;
                return CustomScrollView(
                  physics: const BouncingScrollPhysics(),
                  controller: scrollController,
                  slivers: [
                    const SliverToBoxAdapter(
                      child: SizedBox(height: 60),
                    ),
                    SliverList(
                      delegate: SliverChildListDelegate(
                        [
                          if (client.prevBatch != null && rooms.isEmpty) ...[
                            Padding(
                              padding: const EdgeInsets.all(32.0),
                              child: Icon(
                                CupertinoIcons.chat_bubble_2,
                                size: 128,
                                color: Theme.of(context)
                                    .colorScheme
                                    .onInverseSurface,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    if (client.prevBatch == null)
                      SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, i) => Opacity(
                            opacity: (dummyChatCount - i) / dummyChatCount,
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: titleColor,
                                child: CircularProgressIndicator(
                                  strokeWidth: 1,
                                  color: Theme.of(context)
                                      .textTheme
                                      .bodyLarge!
                                      .color,
                                ),
                              ),
                              title: Row(
                                children: [
                                  Expanded(
                                    child: Container(
                                      height: 14,
                                      decoration: BoxDecoration(
                                        color: titleColor,
                                        borderRadius: BorderRadius.circular(3),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 36),
                                  Container(
                                    height: 14,
                                    width: 14,
                                    decoration: BoxDecoration(
                                      color: subtitleColor,
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Container(
                                    height: 14,
                                    width: 14,
                                    decoration: BoxDecoration(
                                      color: subtitleColor,
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                  ),
                                ],
                              ),
                              subtitle: Container(
                                decoration: BoxDecoration(
                                  color: subtitleColor,
                                  borderRadius: BorderRadius.circular(3),
                                ),
                                height: 12,
                                margin: const EdgeInsets.only(right: 22),
                              ),
                            ),
                          ),
                          childCount: dummyChatCount,
                        ),
                      ),
                    if (client.prevBatch != null)
                      SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (BuildContext context, int i) {
                            return SizedBox(
                              height: 60,
                              child: GestureDetector(
                                onTap: () async {
                                  final List<String> filePaths =
                                      VRouter.of(context)
                                              .queryParameters['files']
                                              ?.split(',') ??
                                          [];
                                  if (filePaths == []) {
                                  } else {
                                    final List<File> files = filePaths
                                        .map((path) => File(path))
                                        .toList();
                                    final List<PlatformFile> platformFiles = [];
                                    // ignore: prefer_final_in_for_each
                                    for (File file in files) {
                                      final Uint8List bytes =
                                          await file.readAsBytes();
                                      platformFiles.add(
                                        PlatformFile(
                                          name: file.path.split('/').last,
                                          path: file.path,
                                          bytes: bytes,
                                          size: bytes.length,
                                        ),
                                      );
                                    }
                                    await showDialog(
                                      context: context,
                                      useRootNavigator: false,
                                      builder: (c) => SendFileDialog(
                                        files: platformFiles
                                            .map(
                                              (xfile) => MatrixFile(
                                                bytes: xfile.bytes!,
                                                name: xfile.name,
                                              ).detectFileType,
                                            )
                                            .toList(),
                                        room: rooms[i],
                                      ),
                                    );
                                  }
                                  VRouter.of(context).toSegments(
                                    [
                                      'rooms',
                                      rooms[i].id,
                                    ],
                                    queryParameters: {
                                      'share': 'no-file',
                                    },
                                  );
                                },
                                child: Padding(
                                  padding:
                                      const EdgeInsets.symmetric(horizontal: 8),
                                  child: Column(
                                    children: [
                                      Row(
                                        children: [
                                          const SizedBox(
                                            width: 16.0,
                                          ),
                                          Stack(
                                            alignment: Alignment.topRight,
                                            children: [
                                              Container(
                                                width: Avatar.defaultSize,
                                                height: Avatar.defaultSize,
                                                clipBehavior: Clip.hardEdge,
                                                decoration: ShapeDecoration(
                                                  color: personalColorScheme
                                                      .primary,
                                                  shape: CircleBorder(
                                                    side: BorderSide(
                                                      strokeAlign: BorderSide
                                                          .strokeAlignOutside,
                                                      color: rooms[i]
                                                              .isFavourite
                                                          ? personalColorScheme
                                                              .tertiary
                                                          : personalColorScheme
                                                              .primary,
                                                      width: 2,
                                                    ),
                                                  ),
                                                ),
                                                child: Avatar(
                                                  mxContent: rooms[i].avatar,
                                                  name: rooms[i]
                                                      .getLocalizedDisplayname(
                                                    MatrixLocals(
                                                      L10n.of(context)!,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(
                                            width: 16.0,
                                          ),
                                          Expanded(
                                            child: Text(
                                              rooms[i].getLocalizedDisplayname(
                                                MatrixLocals(L10n.of(context)!),
                                              ),
                                              style: TextStyle(
                                                decoration: TextDecoration.none,
                                                color:
                                                    personalColorScheme.outline,
                                                fontSize: 16,
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              softWrap: false,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                          childCount: rooms.length,
                        ),
                      ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
