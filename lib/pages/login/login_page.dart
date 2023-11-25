// ignore_for_file: unused_local_variable

import 'dart:math';
import 'dart:ui';
import 'package:concieltalk/config/color_constants.dart';
import 'package:concieltalk/config/conciel_icons.dart';
import 'package:concieltalk/config/profile_constants.dart';
import 'package:concieltalk/utils/platform_infos.dart';
import 'package:concieltalk/utils/ui/page_transitions.dart';
import 'package:concieltalk/utils/ui/ring_widgets.dart';

import 'package:concieltalk/widgets/auth.dart';
import 'package:concieltalk/widgets/base_ring_state.dart';
import 'package:concieltalk/config/app_config.dart';
import 'package:concieltalk/widgets/matrix.dart';
import 'package:concieltalk/widgets/request_permissions.dart';
import 'package:cubixd/cubixd.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hive/hive.dart';
import 'package:matrix/matrix.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:vibration/vibration.dart';

class LoginPage extends StatefulWidget {
  final Function(Cube) authenticated;
  const LoginPage({
    Key? key,
    required this.authenticated,
  }) : super(key: key);

  @override
  LoginPageState createState() => LoginPageState();
}

class LoginPageState extends State<LoginPage> with TickerProviderStateMixin {
  late TutorialCoachMark tutorialCoachMark;

  GlobalKey keyCubeFace1 = GlobalKey();
  GlobalKey keyCubeFace2 = GlobalKey();
  GlobalKey keyCubeFace3 = GlobalKey();
  GlobalKey keyCubeFace4 = GlobalKey();
  GlobalKey keyCubeFace5 = GlobalKey();
  GlobalKey keyCubeFace6 = GlobalKey();

  GlobalKey keyConcielIcon = GlobalKey();
  GlobalKey keyCube = GlobalKey();

  GlobalKey notifierKey = GlobalKey();
  GlobalKey shareKey = GlobalKey();
  GlobalKey usersKey = GlobalKey();

  final GlobalKey<BaseRingState> _ringWidgetKey = GlobalKey();
  late final AnimationController _cubeAnimCtl;
  late final AnimationController _unreadCtl;
  late ValueNotifier<int> _unreadCount;
  List<int> roomCount = [];
  late Client _matrixClient;
  late final CurvedAnimation _xCurve;
  late final CurvedAnimation _yCurve;
  late Size sizeP;

  bool loggedOut = true;
  bool _contextChange = true;
  late double x = 0;
  late double y = 0;
  late double yEnd = 35;
  Tween<double>? _xTween;
  Tween<double>? _yTween;
  String _cubeFace = 'none';
  Color shareColor = Colors.transparent;
  Color notifyColor = Colors.transparent;
  Color usersColor = Colors.transparent;

  @override
  void initState() {
    final cubeData = initCube(this, 1000);
    _cubeAnimCtl = cubeData[0];
    _xCurve = cubeData[1];
    _yCurve = cubeData[2];
    _xTween = Tween<double>(begin: x * pi / 180, end: 45 * pi / 180);
    _yTween = Tween<double>(begin: y * pi / 180, end: yEnd * pi / 180);
    _cubeAnimCtl.forward();
    super.initState();
    _unreadCtl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      sizeP = Size(1.sw, 1.sh);
      createTutorial();
      Hive.box(Conciel.settingsDB).get(register)
          ? Future.delayed(Duration.zero, showTutorial)
          : requestPermissions();
      ConcielTalkBase.initialize(context);
    });
    /*
    if (mounted) {
      setupPush(context);
    }
    */
    initIconNotifier();
  }

  void initIconNotifier() {
    _matrixClient = Matrix.of(context).client;
    _unreadCount = ValueNotifier<int>(0);
    for (int index = 0; index < _matrixClient.rooms.length; index++) {
      roomCount.add(0);
    }

    // Listen for changes in the unread count
    _matrixClient.onSync.stream.listen((e) {
      final int newUnreadCount =
          _matrixClient.rooms.where((r) => (r.isUnread)).length;
      if (newUnreadCount != _unreadCount.value) {
        _unreadCount.value = newUnreadCount;
      }
      if (newUnreadCount != 0) {
        for (int index = 0; index < _matrixClient.rooms.length; index++) {
          final room = _matrixClient.rooms[index];
          final count = room.notificationCount;
          if (index < roomCount.length) {
            if (count != roomCount[index]) {
              roomCount[index] = count;
              /*
              if (count > 0) {
                
                msgNotification(ConcielTalkApp.routerKey, room, count);
                
              }
              Logs().v(
                '[NOTIFICATION] - the unread count ... ${room.getLocalizedDisplayname()} - $count',
              );
              */
            }
          }
        }
      } else {
        /*
        closeNotifications();
        */
      }
    });
  }

  setupPush(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (mounted && !pusherLogDone) {
//        Matrix.of(context).backgroundPush?.setupPush();
      }
    });
  }

  @override
  void dispose() {
    _unreadCtl.dispose();
    _cubeAnimCtl.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  void contextChange() {
    setState(() {
      _ringWidgetKey.currentState?.animateColors();
      HapticFeedback.mediumImpact();
      _contextChange = !_contextChange;
      _contextChange ? yEnd = -145 : yEnd = 35;
      _contextChange ? y = 35 : y = -145;
      _xTween!.begin = 45 * pi / 180;
      _xTween!.end = 45 * pi / 180;
      _yTween!.begin = y * pi / 180;
      _yTween!.end = yEnd * pi / 180;
      // Reset and restart the animation with the new values
      _cubeAnimCtl.reset();
      _cubeAnimCtl.forward();
      HapticFeedback.mediumImpact();
    });
  }

  void _cubeFaceSelect(String newFace) {
    setState(() {
      _cubeFace = newFace;
    });
  }

  @override
  Widget build(BuildContext context) {
    final showTutorial = Hive.box(Conciel.settingsDB).get(register);

    return ValueListenableBuilder<int>(
      valueListenable: _unreadCount,
      builder: (context, value, child) {
        if (value > 0) {
          _unreadCtl.repeat(reverse: true);
        } else {
          _unreadCtl.stop();
        }
        return Scaffold(
          extendBodyBehindAppBar: true,
          drawerScrimColor: Colors.transparent,
          appBar: AppBar(
            toolbarHeight: ScreenUtil().statusBarHeight + 32.h,
            centerTitle: true,
            titleSpacing: 0,
            title: GestureDetector(
              key: keyConcielIcon,
              onTap: () => launchUrlString(AppConfig.privacyUrl),
              onLongPress: () => PlatformInfos.infoDialog(context),
              child: Image.asset(
                'assets/conciel-icon.png',
                fit: BoxFit.scaleDown,
                width: 48,
              ),
            ),
          ),
          primary: true,
          body: Transform.scale(
            scale: AppConfig.cubeRingScale,
            child: Stack(
              alignment: Alignment.center,
              children: [
                IgnorePointer(
                  ignoring: true,
                  child: RingWidget(
                    animateNow: false,
                    key: _ringWidgetKey,
                    trackColor: personalColorScheme.surfaceVariant,
                    innerRingColor: personalColorScheme.background,
                  ),
                ),
                GestureDetector(
                  key: keyCube,
                  behavior: HitTestBehavior.translucent,
                  onDoubleTap: () => contextChange(),
                  onTap: () async {
                    _ringWidgetKey.currentState?.animateColors();
                    switch (_cubeFace) {
                      case 'none':
                        // Do something
                        break;
                      case 'top':
                        // TALK selected
                        final bool isUserIn =
                            await AuthService.authenticateUser();
                        widget.authenticated(Cube.talk);
                        _cubeFaceSelect('none');
                        break;
                      case 'right':
                        // SHOP selected
                        final bool isUserIn =
                            await AuthService.authenticateUser();
                        widget.authenticated(Cube.shop);
                        _cubeFaceSelect('none');
                        break;
                      case 'front':
                        // BOOK selected
                        final bool isUserIn =
                            await AuthService.authenticateUser();
                        widget.authenticated(Cube.book);
                        _cubeFaceSelect('none');
                        break;
                      case 'bottom':
                        // WHAT selected
                        final bool isUserIn =
                            await AuthService.authenticateUser();
                        widget.authenticated(Cube.what);
                        _cubeFaceSelect('none');
                        break;
                      case 'left':
                        // WHERE selected
                        final bool isUserIn =
                            await AuthService.authenticateUser();
                        widget.authenticated(Cube.where);
                        _cubeFaceSelect('none');
                        break;
                      case 'back':
                        // WHEN selected
                        final bool isUserIn =
                            await AuthService.authenticateUser();
                        widget.authenticated(Cube.when);
                        _cubeFaceSelect('none');
                        break;
                    }
                  },
                  child: AnimatedCubixD(
                    advancedXYposAnim: AnimRequirements(
                      controller: _cubeAnimCtl,
                      xAnimation: _xTween!.animate(_xCurve),
                      yAnimation: _yTween!.animate(_yCurve),
                    ),
                    shadow: false,
                    stars: false,
                    size: 96.r,
                    onPanUpdate: () {
                      // ignore: prefer_const_declarations
                      final bool haptic = true;
                      _ringWidgetKey.currentState?.animateColors();
                      if (haptic) {
                        HapticFeedback.lightImpact();
                      }
                    },
                    afterSelDel: const Duration(milliseconds: 1000),
                    onSelected: (SelectedSide opt) {
                      Vibration.vibrate(pattern: [0, 90, 25, 125]);
                      switch (opt) {
                        case SelectedSide.none:
                          _ringWidgetKey.currentState?.animateColors();
                          _cubeFaceSelect('none');
                          return false;
                        case SelectedSide.top: // CHAT
                          _ringWidgetKey.currentState?.animateColors();
                          _cubeFaceSelect('top');
                          y = 0;
                          x = 45;
                          _contextChange ? contextChange() : null;
                          return true;
                        case SelectedSide.bottom:
                          _ringWidgetKey.currentState?.animateColors();
                          _cubeFaceSelect('bottom');
                          !_contextChange ? contextChange() : null;
                          return true;
                        case SelectedSide.left:
                          _ringWidgetKey.currentState?.animateColors();
                          _cubeFaceSelect('left');
                          !_contextChange ? contextChange() : null;
                          return true;
                        case SelectedSide.right: // PHONE
                          _ringWidgetKey.currentState?.animateColors();
                          _cubeFaceSelect('right');
                          x = 90;
                          y = 35;
                          _contextChange ? contextChange() : null;
                          return true;
                        case SelectedSide.front: // EMAIL
                          _ringWidgetKey.currentState?.animateColors();
                          _cubeFaceSelect('front');
                          x = -45;
                          y = 35;
                          _contextChange ? contextChange() : null;
                          return true;
                        case SelectedSide.back:
                          _ringWidgetKey.currentState?.animateColors();
                          _cubeFaceSelect('back');
                          !_contextChange ? contextChange() : null;
                          return true;
                      }
                    },
                    top: animatedCubeFace(
                      // TALK
                      -45 * pi / 180,
                      ConcielIcons.user,
                      personalColorScheme.primary,
                      cubeFaceTop,
                      cubeFaceTop,
                      _unreadCtl,
                      keyCubeFace1,
                    ),
                    bottom: cubeFace(
                      // WHAT
                      45 * pi / 180,
                      Icons.question_mark,
                      personalColorScheme.tertiary,
                      cubeFaceTop,
                      cubeFaceTop,
                      keyCubeFace2,
                    ),
                    front: cubeFace(
                      // BOOK
                      0,
                      ConcielIcons.book,
                      personalColorScheme.tertiary,
                      cubeFaceLeft,
                      cubeFaceLeft,
                      keyCubeFace3,
                    ),
                    back: cubeFace(
                      // WHEN
                      0,
                      Icons.question_mark,
                      personalColorScheme.primary,
                      cubeFaceLeft,
                      cubeFaceLeft,
                      keyCubeFace4,
                    ),
                    right: cubeFace(
                      // SHOP
                      0,
                      ConcielIcons.shop,
                      personalColorScheme.secondary,
                      cubeFaceRight.withOpacity(0.5),
                      cubeFaceRight.withOpacity(0.5),
                      keyCubeFace5,
                    ),
                    left: cubeFace(
                      // WHERE
                      0,
                      Icons.question_mark,
                      personalColorScheme.secondary,
                      cubeFaceRight.withOpacity(0.5),
                      cubeFaceRight.withOpacity(0.5),
                      keyCubeFace6,
                    ),
                  ),
                ),
              ],
            ),
          ),
          bottomNavigationBar: Theme(
            data: ThemeData(
              canvasColor: personalColorScheme.background,
              splashColor: personalColorScheme.background.withOpacity(0.2),
            ),
            child: BottomNavigationBar(
              enableFeedback: false,
              onTap: (value) {},
              selectedItemColor: personalColorScheme.secondary,
              unselectedItemColor: personalColorScheme.primary,
              selectedLabelStyle: const TextStyle(fontFamily: 'Exo'),
              unselectedLabelStyle: const TextStyle(fontFamily: 'Exo'),
              type: BottomNavigationBarType.fixed,
              items: [
                BottomNavigationBarItem(
                  icon: Icon(
                    ConcielIcons.share,
                    color: shareColor,
                    key: shareKey,
                  ),
                  label: "",
                ),
                BottomNavigationBarItem(
                  icon: Icon(
                    ConcielIcons.msg_notifier,
                    color: notifyColor,
                    key: notifierKey,
                  ),
                  label: "",
                ),
                BottomNavigationBarItem(
                  icon: Icon(
                    ConcielIcons.users,
                    color: usersColor,
                    key: usersKey,
                  ),
                  label: "",
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void showTutorial() {
    tutorialCoachMark.show(context: context);
  }

  void createTutorial() {
    tutorialCoachMark = TutorialCoachMark(
      targets: _createTargets(),
      colorShadow: personalColorScheme.tertiary,
      textSkip: "SKIP",
      paddingFocus: 10,
      opacityShadow: 0.5,
      imageFilter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
      onFinish: () {},
      onClickTarget: (target) async {
        switch (target.identify) {
          case 'Conciel':
            final permissionStatus = await requestPermissions();
          case 'Bottom 1':
            setState(() {
              shareColor = Colors.transparent;
              notifyColor = personalColorScheme.primary;
            });
            break;
          case 'Bottom 2':
            setState(() {
              notifyColor = Colors.transparent;
              usersColor = personalColorScheme.outline;
            });
            break;
          case 'Bottom 3':
            setState(() {
              usersColor = Colors.transparent;
            });
            break;
          case 'Cube T':
            break;
          case 'Cube B':
            break;
          case 'Cube S':
            contextChange();
            contextChange();
            break;
          case 'Cube Wt':
            break;
          case 'Cube Wn':
            break;
          case 'Cube Wr':
            contextChange();
            setState(() {
              shareColor = personalColorScheme.outline;
            });
            Hive.box(Conciel.settingsDB).put(register, false);
            break;
          default:
            break;
        }
      },
      onClickTargetWithTapPosition: (target, tapDetails) {},
      onClickOverlay: (target) {},
      // onSkip: () async {
      //   final permissionStatus = await requestPermissions();
      //   setState(() {
      //     notifyColor = Colors.transparent;
      //     shareColor = Colors.transparent;
      //     usersColor = Colors.transparent;
      //   });
      //   Hive.box(Conciel.settingsDB).put(register, false);
      // },
    );
  }

  List<TargetFocus> _createTargets() {
    final List<TargetFocus> targets = [];
    targets.add(
      TargetFocus(
        identify: "Conciel",
        keyTarget: keyConcielIcon,
        contents: [
          TargetContent(
            align: ContentAlign.bottom,
            builder: (context, controller) {
              return const Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  SizedBox(
                    height: 32,
                  ),
                  Text(
                    "WELCOME TO CONCIEL",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontSize: 24.0,
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: 64.0),
                    child: Text(
                      "It's your first time using Conciel",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: 32.0),
                    child: Text(
                      "We will walk you through",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: 32.0),
                    child: Text(
                      "Please allow the permissions to use TALK",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
    targets.add(
      TargetFocus(
        identify: "Cube",
        targetPosition: TargetPosition(
          Size(
            sizeP.width * .3,
            sizeP.width * .3,
          ),
          Offset(
            sizeP.width / 2 - (sizeP.width * .3 / 2),
            sizeP.height / 2 - (sizeP.width * .3 / 3),
          ),
        ),
        contents: [
          TargetContent(
            align: ContentAlign.top,
            builder: (context, controller) {
              return const Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Text(
                    "CONCIEL CUBE INTERFACE",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontSize: 20.0,
                    ),
                  ),
                  SizedBox(
                    height: 64,
                  ),
                ],
              );
            },
          ),
          TargetContent(
            builder: (context, controller) {
              return const Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.only(top: 16.0),
                    child: Text(
                      "Spin the cube to rotate it",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: 16.0),
                    child: Text(
                      "Choose the face you want & tap",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: 16.0),
                    child: Text(
                      "Continue the tutorial or skip...",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
    targets.add(
      TargetFocus(
        identify: "Cube T",
        targetPosition: TargetPosition(
          Size(
            sizeP.width * .2,
            sizeP.width * .2,
          ),
          Offset(
            sizeP.width / 2 - (sizeP.width * .2 / 2),
            sizeP.height / 2 - (sizeP.width * .2 * 2 / 3),
          ),
        ),
        color: personalColorScheme.primary,
        contents: [
          TargetContent(
            align: ContentAlign.top,
            builder: (context, controller) {
              return const Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Text(
                    "CONCIEL TALK",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontSize: 24.0,
                    ),
                  ),
                  SizedBox(
                    height: 64,
                  ),
                ],
              );
            },
          ),
          TargetContent(
            builder: (context, controller) {
              return const Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.only(top: 16.0),
                    child: Text(
                      "Communications, social networking and meetings",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: 16.0),
                    child: Text(
                      "A secure, private cloud service",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: 16.0),
                    child: Text(
                      "Designed to make your life simple",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
    targets.add(
      TargetFocus(
        identify: "Cube B",
        targetPosition: TargetPosition(
          Size(
            sizeP.width * .2,
            sizeP.width * .2,
          ),
          Offset(
            sizeP.width / 2 - (sizeP.width * .2),
            sizeP.height / 2,
          ),
        ),
        color: personalColorScheme.tertiary,
        contents: [
          TargetContent(
            align: ContentAlign.top,
            builder: (context, controller) {
              return const Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Text(
                    "CONCIEL BOOK",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontSize: 24.0,
                    ),
                  ),
                  SizedBox(
                    height: 64,
                  ),
                ],
              );
            },
          ),
          TargetContent(
            align: ContentAlign.bottom,
            builder: (context, controller) {
              return const Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.only(top: 16.0),
                    child: Text(
                      "Booking, travel, accommodations",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: 16.0),
                    child: Text(
                      "Restaurants and entertainment",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: 16.0),
                    child: Text(
                      "Health and wellness... all at your finger tip",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
    targets.add(
      TargetFocus(
        identify: "Cube S",
        targetPosition: TargetPosition(
          Size(
            sizeP.width * .2,
            sizeP.width * .2,
          ),
          Offset(
            sizeP.width / 2,
            sizeP.height / 2,
          ),
        ),
        color: personalColorScheme.secondary,
        focusAnimationDuration: const Duration(milliseconds: 500),
        unFocusAnimationDuration: const Duration(milliseconds: 500),
        contents: [
          TargetContent(
            align: ContentAlign.top,
            builder: (context, controller) {
              return const Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Text(
                    "CONCIEL SHOP",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontSize: 24.0,
                    ),
                  ),
                  SizedBox(
                    height: 64,
                  ),
                ],
              );
            },
          ),
          TargetContent(
            child: const Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.only(top: 16.0),
                  child: Text(
                    "Payments, banking, memberships",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(top: 16.0),
                  child: Text(
                    "Online and retail shopping",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(top: 16.0),
                  child: Text(
                    "One-stop shop for all your items",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(top: 16.0),
                  child: Text(
                    "No ads, no pop-ups",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
    targets.add(
      TargetFocus(
        identify: "Cube Wt",
        targetPosition: TargetPosition(
          Size(
            sizeP.width * .2,
            sizeP.width * .2,
          ),
          Offset(
            sizeP.width / 2 - (sizeP.width * .2 / 2),
            sizeP.height / 2 - (sizeP.width * .2 * 2 / 3),
          ),
        ),
        contents: [
          TargetContent(
            align: ContentAlign.top,
            builder: (context, controller) {
              return const Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Text(
                    "WHAT",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontSize: 24.0,
                    ),
                  ),
                  SizedBox(
                    height: 64,
                  ),
                ],
              );
            },
          ),
          TargetContent(
            child: const Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.only(top: 16.0),
                  child: Text(
                    "Personal search engine: WHAT",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(top: 16.0),
                  child: Text(
                    "Select what you wish to do",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
    targets.add(
      TargetFocus(
        identify: "Cube Wn",
        targetPosition: TargetPosition(
          Size(
            sizeP.width * .2,
            sizeP.width * .2,
          ),
          Offset(
            sizeP.width / 2,
            sizeP.height / 2,
          ),
        ),
        color: personalColorScheme.primary,
        contents: [
          TargetContent(
            align: ContentAlign.top,
            builder: (context, controller) {
              return const Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Text(
                    "WHEN",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontSize: 24.0,
                    ),
                  ),
                  SizedBox(
                    height: 64,
                  ),
                ],
              );
            },
          ),
          TargetContent(
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.only(top: 16.0),
                  child: Text(
                    "Your scheduling: WHEN",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(top: 16.0),
                  child: Text(
                    "Select the time and date",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
    targets.add(
      TargetFocus(
        identify: "Cube Wr",
        targetPosition: TargetPosition(
          Size(
            sizeP.width * .2,
            sizeP.width * .2,
          ),
          Offset(
            sizeP.width / 2 - (sizeP.width * .2),
            sizeP.height / 2,
          ),
        ),
        color: personalColorScheme.secondary,
        shape: ShapeLightFocus.Circle,
        contents: [
          TargetContent(
            align: ContentAlign.top,
            builder: (context, controller) {
              return const Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Text(
                    "WHERE",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontSize: 24.0,
                    ),
                  ),
                  SizedBox(
                    height: 64,
                  ),
                ],
              );
            },
          ),
          TargetContent(
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.only(top: 16.0),
                  child: Text(
                    "Your location service: WHERE",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(top: 16.0),
                  child: Text(
                    "Select the locality, location or destination",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
    targets.add(
      TargetFocus(
        identify: "Bottom 1",
        keyTarget: shareKey,
        alignSkip: Alignment.topRight,
        enableOverlayTab: true,
        contents: [
          TargetContent(
            align: ContentAlign.top,
            builder: (context, controller) {
              return const Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    "SHARE anything...",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontSize: 24.0,
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );

    targets.add(
      TargetFocus(
        identify: "Bottom 2",
        keyTarget: notifierKey,
        color: personalColorScheme.primary,
        alignSkip: Alignment.topRight,
        contents: [
          TargetContent(
            align: ContentAlign.top,
            builder: (context, controller) {
              return const Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    "TALK NOTIFIER",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontSize: 24.0,
                    ),
                  ),
                  SizedBox(
                    height: 64,
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: 16.0),
                    child: Text(
                      "The notifier BLINKS blue when",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: 16.0),
                    child: Text(
                      "you have new messages or missed calls.",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 64,
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
    targets.add(
      TargetFocus(
        identify: "Bottom 3",
        keyTarget: usersKey,
        alignSkip: Alignment.topRight,
        contents: [
          TargetContent(
            align: ContentAlign.top,
            builder: (context, controller) {
              return const Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    "USERS",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontSize: 24.0,
                    ),
                  ),
                  SizedBox(
                    height: 64,
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: 16.0),
                    child: Text(
                      "Access your contacts",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: 16.0),
                    child: Text(
                      "Connect to new friends +",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 64,
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
    return targets;
  }
}
