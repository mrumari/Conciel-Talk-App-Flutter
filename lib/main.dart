import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:concieltalk/config/app_config.dart';
import 'package:concieltalk/config/color_constants.dart';
import 'package:concieltalk/config/profile_constants.dart';
import 'package:concieltalk/widgets/auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:collection/collection.dart';
import 'package:flutter/services.dart';
import 'package:flutter_app_lock/flutter_app_lock.dart';
import 'package:google_maps_flutter_android/google_maps_flutter_android.dart';
import 'package:google_maps_flutter_platform_interface/google_maps_flutter_platform_interface.dart';
import 'package:hive/hive.dart';
import 'package:matrix/matrix.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:universal_html/html.dart' as html;

import 'package:concieltalk/utils/client_manager.dart';
import 'package:concieltalk/utils/platform_infos.dart';
import 'package:concieltalk/conciel_talk_app.dart';
import 'package:concieltalk/widgets/lock_screen.dart';

void main() async {
  // Background push uses Firebase isolate to accesses flutter internals
  // early in the startup proccess. This is to make sure that the parts of
  // flutter needed are started up already, we need to ensure that the
  // widget bindings are initialized already.
  SystemChrome.setSystemUIOverlayStyle(
    SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      systemNavigationBarColor: personalColorScheme.background,
      systemNavigationBarDividerColor: personalColorScheme.background,
      systemNavigationBarContrastEnforced: false,
      systemStatusBarContrastEnforced: false,
      systemNavigationBarIconBrightness: Brightness.light,
      statusBarIconBrightness: Brightness.light, // Android (dark icons)
      statusBarBrightness: Brightness.dark,
    ),
  );

  final GoogleMapsFlutterPlatform mapsImplementation =
      GoogleMapsFlutterPlatform.instance;

  if (mapsImplementation is GoogleMapsFlutterAndroid) {
    mapsImplementation.useAndroidViewSurface = true;
    AndroidMapRenderer mapRenderer = AndroidMapRenderer.platformDefault;
    WidgetsFlutterBinding.ensureInitialized();
    try {
      mapRenderer = await mapsImplementation
          .initializeWithRenderer(AndroidMapRenderer.latest);
      Logs().i('[MAPS] renderer obtained: ${mapRenderer.name}');
    } catch (e) {
      Logs().e('[MAPS] renderer error: $e');
    }
  } else {
    WidgetsFlutterBinding.ensureInitialized();
  }

  // Initialize Firebase for background notifications
  await Firebase.initializeApp();

  Logs().nativeColors = !PlatformInfos.isIOS;
  final clients = await ClientManager.getClients();

  // Preload first client
  final firstClient = clients.firstOrNull;
  await firstClient?.roomsLoading;
  await firstClient?.accountDataLoading;

  /*
  if (PlatformInfos.isMobile) {
    BackgroundNotifications.clientOnly(clients.first);
  }
  */

  final queryParameters = <String, String>{};
  if (kIsWeb) {
    queryParameters
        .addAll(Uri.parse(html.window.location.href).queryParameters);
  }

  // Setup and wait for persistentent local data storage and local db storage
  // ignore: unused_local_variable
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  await initializeHive();
// Register specific image and file noSql DB handlers
  Hive.registerAdapter(HiveFileAdapter());
  Hive.registerAdapter(MandatoryAdapter());
  Hive.registerAdapter(AddressAdapter());
  await Hive.openBox(Conciel.fileDB);
  Logs().v('Local noSQL storage: ${Conciel.fileDB}');

  final bool settingsReady = await Hive.boxExists(Conciel.settingsDB);
  if (!settingsReady) {
    // First time so make sure default settings are valid and ready
    final box = await Hive.openBox(Conciel.settingsDB);
//    box.put(messagingToken, token);
    box.put(register, true);
    box.put(stayLoggedIn, true);
    Logs().v('New account, registration needed: ${Conciel.settingsDB}');
  } else {
    // ignore: unused_local_variable
    final box = await Hive.openBox(Conciel.settingsDB);
    box.put(swipeBack, true);
    Logs().v(
      box.get(register)
          ? 'Registration needed: ${Conciel.settingsDB}'
          : 'Settings opened: ${Conciel.settingsDB}',
    );
    // box.put(register, true); // - only for debug purposes
  }
  final ConcielTalkApp concielTalkApp = ConcielTalkApp(
    clients: clients,
    queryParameters: queryParameters,
  );
  runApp(
    ChangeNotifierProvider<MatrixAuthService>(
      create: (_) => MatrixAuthService(),
      child: PlatformInfos.isMobile
          ? AppLock(
              builder: (args) => concielTalkApp,
              lockScreen: const LockScreen(),
              enabled: false,
            )
          : concielTalkApp,
    ),
  );
}

Future<void> initializeHive() async {
  final directories =
      await getExternalStorageDirectories(type: StorageDirectory.documents);
  final directory = directories!.first;
  final hiveDirectory = Directory('${directory.path}/conciel/hive');
  if (!await hiveDirectory.exists()) {
    await hiveDirectory.create(recursive: true);
  }
  Hive.init(hiveDirectory.path);
}
