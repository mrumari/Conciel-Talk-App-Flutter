import 'dart:math';
import 'package:concieltalk/config/app_config.dart';
import 'package:concieltalk/config/color_constants.dart';
import 'package:concieltalk/config/conciel_icons.dart';
import 'package:concieltalk/config/profile_constants.dart';
import 'package:concieltalk/utils/ui/page_transitions.dart';
import 'package:concieltalk/utils/ui/ring_widgets.dart';

import 'package:concieltalk/widgets/auth.dart';
import 'package:concieltalk/widgets/base_ring_state.dart';
import 'package:cubixd/cubixd.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hive/hive.dart';
import 'package:local_auth/local_auth.dart';
import 'package:vibration/vibration.dart';

class BiometricPage extends StatefulWidget {
  final Function(bool) authenticated;

  const BiometricPage({
    Key? key,
    required this.authenticated,
  }) : super(key: key);

  @override
  BiometricPageState createState() => BiometricPageState();
}

class BiometricPageState extends State<BiometricPage>
    with SingleTickerProviderStateMixin {
  final GlobalKey<BaseRingState> _ringWidgetKey = GlobalKey();
  late final AnimationController _cubeAnimCtl;
  late final CurvedAnimation _xCurve;
  late final CurvedAnimation _yCurve;

  LocalAuthentication localAuthentication = LocalAuthentication();
  bool canAuthBio = false;
  bool loggedOut = true;
  late double x = 0;
  late double y = 0;
  late double yEnd = 35;
  Tween<double>? _xTween;
  Tween<double>? _yTween;

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
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    _cubeAnimCtl.dispose();
    super.dispose();
  }

  void _cubeFaceSelect(String newFace) {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      primary: true,
      body: SafeArea(
        child: Stack(
          alignment: AlignmentDirectional.center,
          children: [
            IgnorePointer(
              ignoring: true,
              child: RingWidget(
                animateNow: false,
                key: _ringWidgetKey,
                trackColor: personalColorScheme.background,
                innerRingColor: personalColorScheme.background,
              ),
            ),
            Hive.box(Conciel.settingsDB).get(register)
                ? Positioned(
                    top: 0,
                    width: 213.33.w,
                    child: const Column(
                      children: [
                        Text(
                          'Welcome to Conciel',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 18, color: primaryColor),
                        ),
                        Text(
                          '',
                          textAlign: TextAlign.center,
                        ),
                        Text(
                          'Please press the Cube below to begin Biometric verification',
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  )
                : Container(),
            GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: () async {
                _ringWidgetKey.currentState?.animateColors();
                final bool isUserIn = await AuthService.authenticateUser();
                if (isUserIn) {
                  setState(() {
                    widget.authenticated(true);
                  });
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
                      return true;
                    case SelectedSide.bottom:
                      _ringWidgetKey.currentState?.animateColors();
                      _cubeFaceSelect('bottom');
                      return true;
                    case SelectedSide.left:
                      _ringWidgetKey.currentState?.animateColors();
                      _cubeFaceSelect('left');
                      return true;
                    case SelectedSide.right: // PHONE
                      _ringWidgetKey.currentState?.animateColors();
                      _cubeFaceSelect('right');
                      x = 90;
                      y = 35;
                      return true;
                    case SelectedSide.front: // EMAIL
                      _ringWidgetKey.currentState?.animateColors();
                      _cubeFaceSelect('front');
                      x = -45;
                      y = 35;
                      return true;
                    case SelectedSide.back:
                      _ringWidgetKey.currentState?.animateColors();
                      _cubeFaceSelect('back');
                      return true;
                  }
                },
                top: cubeFace(
                  -45 * pi / 180,
                  ConcielIcons.blank,
                  personalColorScheme.primary,
                  cubeFaceTop,
                  cubeFaceTop,
                ),
                bottom: cubeFace(
                  45 * pi / 180,
                  ConcielIcons.blank,
                  personalColorScheme.tertiary,
                  cubeFaceTop,
                  cubeFaceTop,
                ),
                front: cubeFace(
                  0,
                  ConcielIcons.blank,
                  personalColorScheme.tertiary.withOpacity(0.3),
                  cubeFaceLeft,
                  cubeFaceLeft,
                ),
                back: cubeFace(
                  0,
                  ConcielIcons.blank,
                  personalColorScheme.primary,
                  cubeFaceLeft,
                  cubeFaceLeft,
                ),
                right: cubeFace(
                  0,
                  ConcielIcons.blank,
                  personalColorScheme.secondary.withOpacity(0.3),
                  cubeFaceRight.withOpacity(0.5),
                  cubeFaceRight.withOpacity(0.5),
                ),
                left: cubeFace(
                  0,
                  ConcielIcons.blank,
                  personalColorScheme.secondary,
                  cubeFaceRight.withOpacity(0.5),
                  cubeFaceRight.withOpacity(0.5),
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
          items: const [
            BottomNavigationBarItem(
              icon: Icon(ConcielIcons.share, color: Colors.transparent),
              label: "",
            ),
            BottomNavigationBarItem(
              icon: Icon(
                ConcielIcons.settings,
                color: Colors.transparent,
              ),
              label: "",
            ),
            BottomNavigationBarItem(
              icon: Icon(ConcielIcons.users, color: Colors.transparent),
              label: "",
            ),
          ],
        ),
      ),
    );
  }
}
