import 'dart:math';

import 'package:concieltalk/config/app_config.dart';
import 'package:concieltalk/config/color_constants.dart';
import 'package:concieltalk/config/conciel_icons.dart';
import 'package:concieltalk/config/profile.dart';
import 'package:concieltalk/config/profile_constants.dart';
import 'package:concieltalk/widgets/base_ring_state.dart';
import 'package:concieltalk/utils/ui/central_buttons.dart';
import 'package:concieltalk/utils/ui/header_footer.dart';
import 'package:concieltalk/utils/ui/page_template.dart';
import 'package:concieltalk/utils/ui/page_transitions.dart';
import 'package:concieltalk/utils/ui/ring_widgets.dart';

import 'package:concieltalk/widgets/debouncer.dart';
import 'package:concieltalk/widgets/matrix.dart';
import 'package:cubixd/cubixd.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hive/hive.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  FocusNode? _focusNode;
  TextEditingController? _passwordController;
  TextEditingController? _usernameController;
  final GlobalKey<BaseRingState> _ringWidgetKey = GlobalKey();

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {});
  }

  void userBasicProfileSheet(BuildContext context, Matrix matrix) {
    showModalBottomSheet(
      isScrollControlled: true,
      enableDrag: false,
      context: context,
      builder: (context) {
        final Box settingsDB = Hive.box(Conciel.settingsDB);
        settingsDB.put(useFingerprint, true);
        settingsDB.put(stayLoggedIn, false);
        settingsDB.put(haptix, true);
        settingsDB.put(dateTime, true);
        settingsDB.put(darkMode, true);
        settingsDB.put(notifications, true);
        settingsDB.put(language, 'English');
        settingsDB.put(firstName, '');
        settingsDB.put(surname, '');
        return profileLevel1(context);
      },
    );
  }

  @override
  void dispose() {
    _focusNode?.dispose();
    _passwordController?.dispose();
    _usernameController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final width = 1.sw;
    return Scaffold(
      body: Stack(
        children: [
          HomePageDevice(
            ringKey: _ringWidgetKey,
            route: 'register',
            appBar: (context) => DefaultHeaderWidget(
              route: 'register',
              showConciel: true,
              showSearch: false,
              onConcielPress: () {},
            ),
            drawer: Container(),
            endDrawer: Container(),
            children: [
              Positioned(
                top: 0,
                width: 213.33.w,
                child: Column(
                  children: [
                    Text(
                      'Registration - Level 1',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 18,
                        color: personalColorScheme.primary,
                      ),
                    ),
                    const Text(
                      '',
                      textAlign: TextAlign.center,
                    ),
                    const Text(
                      'Email and basic profile details',
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              RingWidget(
                animateNow: false,
                key: _ringWidgetKey,
                trackColor: personalColorScheme.background,
                innerRingColor: personalColorScheme.surfaceTint,
              ),
              ArcButton(
                startAngle: 120,
                sweepAngle: 120,
                radius: width * 0.3,
                strokeWidth: 50,
                onTap: () {
                  _ringWidgetKey.currentState?.animateColors();
                  debounce(Conciel.debouncer, () async {
/*
                    try {
                      var googleUser = await authProvider.handleGoogleSignIn();
                      if (googleUser != null) {
                        setState(() {
                          userBasicProfileSheet(context, googleUser);
                        });
                      }
                    } catch (e) {
                      Fluttertoast.showToast(
                          msg: 'Registration stopped',
                          toastLength: Toast.LENGTH_SHORT,
                          timeInSecForIosWeb: 1);

                    }
*/
                  });
                },
                child: ConcielArcText(
                  radius: 99.2.r,
                  start: -30,
                  sweep: 120,
                  text: 'Register',
                  color: personalColorScheme.primary,
                  fontSize: 18,
                ),
              ),
              ArcButton(
                startAngle: 240,
                sweepAngle: 120,
                radius: 96.r,
                strokeWidth: 50.r,
                onTap: () {
                  _ringWidgetKey.currentState?.animateColors();
                  debounce(Conciel.debouncer, () async {});
                },
                child: ConcielArcText(
                  radius: 99.2.r,
                  start: 90,
                  sweep: 120,
                  text: '',
                  color: personalColorScheme.outline,
                  fontSize: 18,
                ),
              ),
              ArcButton(
                startAngle: 0,
                sweepAngle: 120,
                radius: 96.r,
                strokeWidth: 50.r,
                onTap: () {
                  _ringWidgetKey.currentState?.animateColors();
                  debounce(Conciel.debouncer, () async {});
                },
                child: ConcielArcText(
                  radius: width * 0.31,
                  start: -150,
                  sweep: 120,
                  text: '',
                  color: personalColorScheme.outline,
                  fontSize: 18,
                ),
              ),
              AnimatedCubixD(
                simplePosAnim: SimpleAnimRequirements(
                  duration: const Duration(milliseconds: 500),
                  infinite: false,
                  xBegin: 0,
                  xEnd: 45 * pi / 180,
                  yBegin: 0,
                  yEnd: 35 * pi / 180,
                ),
                shadow: false,
                size: 213.33.w,
                top: cubeFace(
                  -45 * pi / 180,
                  ConcielIcons.blank,
                  personalColorScheme.primary,
                  cubeFaceTop,
                  cubeFaceTop,
                ),
                bottom: cubeFace(
                  -45 * pi / 180,
                  ConcielIcons.blank,
                  personalColorScheme.primary,
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
                  personalColorScheme.tertiary.withOpacity(0.3),
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
                  personalColorScheme.secondary.withOpacity(0.3),
                  cubeFaceRight.withOpacity(0.5),
                  cubeFaceRight.withOpacity(0.5),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
