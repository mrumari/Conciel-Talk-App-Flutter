import 'dart:async';

import 'package:concieltalk/config/app_config.dart';
import 'package:concieltalk/config/color_constants.dart';
import 'package:concieltalk/utils/platform_infos.dart';
import 'package:concieltalk/utils/ui/page_transitions.dart';
import 'package:concieltalk/utils/url_launcher.dart';
import 'package:concieltalk/widgets/auth.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:flutter_gen/gen_l10n/l10n.dart';
import 'package:matrix/matrix.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';
import 'package:uni_links/uni_links.dart';
import 'package:vrouter/vrouter.dart';

import 'package:concieltalk/config/routes.dart';
import 'package:concieltalk/config/themes.dart';
import 'package:concieltalk/widgets/theme_builder.dart';
import 'utils/custom_scroll_behaviour.dart';
import 'widgets/matrix.dart';

class ConcielTalkApp extends StatefulWidget {
  final Widget? testWidget;
  final List<Client> clients;
  final Map<String, String>? queryParameters;
  static GlobalKey<VRouterState> routerKey = GlobalKey<VRouterState>();
  static GlobalKey<MatrixState> matrixKey = GlobalKey<MatrixState>();
  const ConcielTalkApp({
    Key? key,
    this.testWidget,
    required this.clients,
    this.queryParameters,
  }) : super(key: key);

  /// getInitialLink may rereturn the value multiple times if this view is
  /// opened multiple times for example if the user logs out after they logged
  /// in with qr code or magic link.
  static bool gotInitialLink = false;

  @override
  ConcielTalkAppState createState() => ConcielTalkAppState();
}

class ConcielTalkAppState extends State<ConcielTalkApp> {
  bool? columnMode;
  String? _initialUrl;
  StreamSubscription? _intentDataStreamSubscription;
  StreamSubscription? _intentFileStreamSubscription;
  StreamSubscription? _intentUriStreamSubscription;

  @override
  void initState() {
    _initReceiveSharingIntent();
    super.initState();
    _initialUrl = '/biometrics';
  }

  @override
  void dispose() {
    _intentDataStreamSubscription?.cancel();
    _intentFileStreamSubscription?.cancel();
    _intentUriStreamSubscription?.cancel();
    super.dispose();
  }

  void _processIncomingUris(String? text) async {
    if (text == null) return;
    VRouter.of(context).to('/rooms');
    WidgetsBinding.instance.addPostFrameCallback((_) {
      UrlLauncher(context, text).openMatrixToUrl();
    });
  }

  void _processIncomingSharedFiles(List<SharedMediaFile> files) async {
    final VRouterState? vRouter = ConcielTalkApp.routerKey.currentState;
    if (files.isEmpty) return;
    //final file = File(files.first.path.replaceFirst('file://', ''));
    final List<String?> filePaths = files.map((file) => file.path).toList();
    Logs().e('[SHARE: FILE] - ${files.first.path}');
    final path = vRouter?.url;
    Logs().e('[SHARE: ROUTE] - $path');
    if (path == '/biometrics') {
      final bool isUserIn = await AuthService.authenticateUser();
      if (!isUserIn) {
        return;
      }
      vRouter?.to(
        '/talk/fileshare',
        queryParameters: {'files': filePaths.join(',')},
      );
      return;
    }
    vRouter?.to(
      'fileshare',
      queryParameters: {'files': filePaths.join(',')},
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

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(320, 695.1),
      minTextAdapt: true,
      child: ThemeBuilder(
        builder: (context, themeMode, primaryColor) => LayoutBuilder(
          builder: (context, constraints) {
            final isColumnMode =
                ConcielThemes.isColumnModeByWidth(constraints.maxWidth);
            if (isColumnMode != columnMode) {
              Logs().v('Set Column Mode = $isColumnMode');
              WidgetsBinding.instance.addPostFrameCallback((_) {
                setState(() {
                  columnMode = isColumnMode;
                });
              });
            }
            return VRouter(
              key: ConcielTalkApp.routerKey,
              title: AppConfig.applicationName,
              debugShowCheckedModeBanner: false,
              themeMode: themeMode,
              theme: ThemeData(
                fontFamily: 'Exo',
                textTheme: Typography.englishLike2021.apply(
                  fontSizeFactor: 1.sp,
                ),
                useMaterial3: true,
                colorScheme: personalColorScheme,
                splashColor:
                    personalColorScheme.surfaceVariant.withOpacity(0.8),
                highlightColor: personalColorScheme.surfaceTint,
                pageTransitionsTheme: const PageTransitionsTheme(
                  builders: {
                    TargetPlatform.android: CustomTransitionBuilder(),
                    TargetPlatform.iOS: CustomTransitionBuilder(),
                  },
                ),
              ),
              scrollBehavior: CustomScrollBehavior(),
              logs: kReleaseMode ? VLogs.none : VLogs.info,
              localizationsDelegates: L10n.localizationsDelegates,
              supportedLocales: L10n.supportedLocales,
              initialUrl: _initialUrl ?? '/',
              routes: AppRoutes(columnMode ?? false).routes,
              builder: (context, child) {
                return Matrix(
                  key: ConcielTalkApp.matrixKey,
                  context: context,
                  router: ConcielTalkApp.routerKey,
                  clients: widget.clients,
                  child: child,
                );
              },
            );
          },
        ),
      ),
    );
  }
}
