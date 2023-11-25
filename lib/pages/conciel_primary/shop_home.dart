import 'dart:math';

import 'package:concieltalk/config/app_config.dart';
import 'package:concieltalk/config/color_constants.dart';
import 'package:concieltalk/config/conciel_icons.dart';
import 'package:concieltalk/pages/chat/chat_send_actions.dart';
import 'package:concieltalk/pages/chat_list/chat_share_view.dart';
import 'package:concieltalk/utils/ui/central_buttons.dart';
import 'package:concieltalk/utils/ui/page_template.dart';
import 'package:concieltalk/utils/ui/page_transitions.dart';
import 'package:concieltalk/utils/ui/ring_widgets.dart';
import 'package:concieltalk/drawers/rotating_drawer.dart';

import 'package:concieltalk/drawers/search_drawer.dart';
import 'package:concieltalk/widgets/base_ring_state.dart';
import 'package:concieltalk/utils/ui/header_footer.dart';
import 'package:concieltalk/widgets/debouncer.dart';
import 'package:concieltalk/widgets/matrix.dart';
import 'package:cubixd/cubixd.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:matrix/matrix.dart';
import 'package:vibration/vibration.dart';
import 'package:vrouter/vrouter.dart';

class ShopHomePage extends StatefulWidget {
  final bool wcontext;
  const ShopHomePage({Key? key, required this.wcontext}) : super(key: key);

  @override
  ShopController createState() => ShopController();
}

class ShopController extends State<ShopHomePage> with TickerProviderStateMixin {
  final GlobalKey<BaseRingState> _ringWidgetKey = GlobalKey();
  final ChatShareController chatShareController = ChatShareController();
  late AnimationController _cubeAnimCtl;
  String _cubeFace = 'none';
  AnimationController? _slidePage;
  late CurvedAnimation _xCurve;
  late CurvedAnimation _yCurve;
  Tween<double>? _xTween;
  Tween<double>? _yTween;
  Color _innerRingColor = personalColorScheme.secondary.withOpacity(0.5);
  bool _contacts = false;

  late UserProfile userProfile;
  late bool _contextChange;
  late double x = 0;
  late double y = 0;
  late double yEnd = 35;
  Color cubeFaceLt = cubeFaceLeft;
  Color cubeFaceBm = cubeFaceBottom;
  Color cubeFaceBk = cubeFaceBack;

  void _cubeFaceSelect(String newFace) {
    setState(() {
      _cubeFace = newFace;
    });
  }

  @override
  void initState() {
    _contextChange = widget.wcontext;
    final cubeData = initCube(this, 500);
    _cubeAnimCtl = cubeData[0];
    _xCurve = cubeData[1];
    _yCurve = cubeData[2];
    _contextChange ? yEnd = -145 : yEnd = 35;
    _contextChange ? y = 35 : y = -145;
    _xTween = Tween<double>(begin: x * pi / 180, end: 45 * pi / 180);
    _yTween = Tween<double>(begin: y * pi / 180, end: yEnd * pi / 180);
    _cubeAnimCtl.forward();
    super.initState();

    _slidePage = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      _ringWidgetKey.currentState?.animateColors();
    });
  }

  @override
  void dispose() {
// Dispose of the AnimationController to properly dispose of the Ticker
    _cubeAnimCtl.dispose();
    super.dispose();
  }

  void contextChange() {
    setState(() {
      _ringWidgetKey.currentState?.animateColors();
      HapticFeedback.mediumImpact();
      _contextChange = !_contextChange;
      _contextChange ? yEnd = -145 : yEnd = 35;
      _contextChange ? y = 35 : y = -145;
      _innerRingColor = _contextChange
          ? personalColorScheme.surfaceTint
          : personalColorScheme.secondary.withOpacity(0.5);
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

  @override
  Widget build(BuildContext context) {
    final slideAnimation =
        Tween(begin: 0.0, end: 1.sw / 2).animate(_slidePage!);
    final matrix = Matrix.of(context);

    if (!matrix.client.isLogged()) VRouter.of(context).to('/biometrics');
    setState(() {
      _contacts = false;
    });

    return Scaffold(
      body: Stack(
        alignment: Alignment.center,
        children: [
          HomePageDevice(
            route: '/biometrics',
            ringKey: _ringWidgetKey,
            appBar: (context) => DefaultHeaderWidget(
              route: '/biometrics',
              onSearchPress: () => Scaffold.of(context).openDrawer(),
            ),
            endDrawer: Container(),
            drawer: RotatingDrawer(
              corner: false,
              drawer: SearchDrawer(
                context: context,
                route: 'shop',
              ),
            ),
            children: [
              Transform.scale(
                scale: AppConfig.cubeRingScale,
                child: AnimatedBuilder(
                  animation: slideAnimation,
                  builder: (context, child) {
                    return Transform.translate(
                      offset:
                          Offset(slideAnimation.value, _contacts ? -0.2 : -0.1),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          RingWidget(
                            animateNow: false,
                            key: _ringWidgetKey,
                            trackColor: personalColorScheme.surfaceVariant,
                            innerRingColor: _innerRingColor,
                          ),
                          // WHERE and RETAIL
                          ArcButton(
                            startAngle: 0,
                            sweepAngle: 120,
                            radius: 96.r,
                            strokeWidth: 50,
                            onTap: () {
                              _ringWidgetKey.currentState?.animateColors();
                              debounce(Conciel.debouncer, () {
                                _contextChange
                                    ? VRouter.of(context).to(
                                        'wherewhenwhat',
                                        queryParameters: {'route': 'where'},
                                      )
                                    : VRouter.of(context).to(
                                        'payretailmember',
                                        queryParameters: {'route': 'retail'},
                                      );
                              });
                            },
                            child: _contextChange
                                ? ConcielArcText(
                                    radius: 96.r,
                                    start: -120,
                                    sweep: 120,
                                    text: whereText,
                                    color: personalColorScheme.secondary,
                                    fontSize: 18,
                                  )
                                : ConcielArcText(
                                    radius: 96.r,
                                    start: -120,
                                    sweep: 120,
                                    text: ConcielTalkBase
                                        .instance!.callKeepBaseConfig.retail,
                                    color: personalColorScheme.outline,
                                    fontSize: 18,
                                  ),
                          ),
                          // WHAT and PAYMENTS
                          ArcButton(
                            startAngle: 120,
                            sweepAngle: 120,
                            radius: 96.r,
                            strokeWidth: 50,
                            onTap: () {
                              _ringWidgetKey.currentState?.animateColors();
                              debounce(Conciel.debouncer, () {
                                _contextChange
                                    ? VRouter.of(context).to(
                                        'wherewhenwhat',
                                        queryParameters: {'route': 'what'},
                                      )
                                    : VRouter.of(context).to(
                                        'payretailmember',
                                        queryParameters: {'route': 'payments'},
                                      );
                              });
                            },
                            child: _contextChange
                                ? ConcielArcText(
                                    radius: 96.r,
                                    start: 0,
                                    sweep: 120,
                                    text: whatText,
                                    color: personalColorScheme.tertiary,
                                    fontSize: 18,
                                  )
                                : ConcielArcText(
                                    radius: 96.r,
                                    start: 0,
                                    sweep: 120,
                                    text: ConcielTalkBase
                                        .instance!.callKeepBaseConfig.payments,
                                    color: personalColorScheme.outline,
                                    fontSize: 18,
                                  ),
                          ),
                          // WHEN and MEMBER
                          ArcButton(
                            startAngle: 240,
                            sweepAngle: 120,
                            radius: 96.r,
                            strokeWidth: 50,
                            onTap: () {
                              _ringWidgetKey.currentState?.animateColors();
                              debounce(Conciel.debouncer, () {
                                _contextChange
                                    ? VRouter.of(context).to(
                                        'wherewhenwhat',
                                        queryParameters: {'route': 'when'},
                                      )
                                    : VRouter.of(context).to(
                                        'payretailmember',
                                        queryParameters: {'route': 'member'},
                                      );
                              });
                            },
                            child: _contextChange
                                ? ConcielArcText(
                                    radius: 96.r,
                                    start: 120,
                                    sweep: 120,
                                    text: whenText,
                                    color: personalColorScheme.primary,
                                    fontSize: 18,
                                  )
                                : ConcielArcText(
                                    radius: 96.r,
                                    start: 120,
                                    sweep: 120,
                                    text: ConcielTalkBase
                                        .instance!.callKeepBaseConfig.member,
                                    color: personalColorScheme.outline,
                                    fontSize: 18,
                                  ),
                          ),
                          GestureDetector(
                            behavior: HitTestBehavior.translucent,
                            onDoubleTap: () => contextChange(),
                            onTap: () async {
                              switch (_cubeFace) {
                                case 'none':
                                  // Do nothing
                                  break;
                                case 'top':
                                  // SEARCH selected
                                  VRouter.of(context).to(
                                    'cubeview',
                                    queryParameters: {'bookshop': 'shop'},
                                  );
                                  await _slidePage!.reverse();
                                  _cubeFaceSelect('none');
                                  break;
                                case 'bottom':
                                  // Do something else
                                  _cubeFaceSelect('none');
                                  break;
                                case 'left':
                                  // Do something else
                                  _cubeFaceSelect('none');
                                  break;
                                case 'right':
                                  // SHOPS selected
                                  VRouter.of(context).to(
                                    'cubeview',
                                    queryParameters: {'bookshop': 'shop'},
                                  );
                                  await _slidePage!.reverse();
                                  _cubeFaceSelect('none');
                                  break;
                                case 'front':
                                  // SHIPPING selected
                                  VRouter.of(context).to(
                                    'cubeview',
                                    queryParameters: {'bookshop': 'shop'},
                                  );
                                  await _slidePage!.reverse();
                                  _cubeFaceSelect('none');
                                  break;
                                case 'back':
                                  // Do something else
                                  _cubeFaceSelect('none');
                                  break;
                              }
                            },
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                Container(
                                  width: 96.w,
                                  height: 96.w,
                                  decoration: const ShapeDecoration(
                                    color: Colors.transparent,
                                    shape: StarBorder.polygon(sides: 6),
                                  ),
                                ),
                                ValueListenableBuilder(
                                  valueListenable: wwwState,
                                  builder: (context, value, child) {
                                    cubeFaceBk = value['when'] == true
                                        ? personalColorScheme.primary
                                        : cubeFaceBack;
                                    cubeFaceBm = value['what'] == true
                                        ? personalColorScheme.tertiary
                                        : cubeFaceBottom;
                                    cubeFaceLt = value['where'] == true
                                        ? personalColorScheme.secondary
                                        : cubeFaceLeft;
                                    _cubeAnimCtl.reset();
                                    _cubeAnimCtl.forward();
                                    return AnimatedCubixD(
                                      stars: false,
                                      size: 89.6.w,
                                      onPanUpdate: () {
                                        // ignore: prefer_const_declarations
                                        final bool haptic = true;
                                        _ringWidgetKey.currentState
                                            ?.animateColors();
                                        if (haptic) {
                                          HapticFeedback.vibrate();
                                        }
                                      },
                                      afterSelDel: const Duration(seconds: 2),
                                      shadow: false,
                                      advancedXYposAnim: AnimRequirements(
                                        controller: _cubeAnimCtl,
                                        xAnimation: _xTween!.animate(_xCurve),
                                        yAnimation: _yTween!.animate(_yCurve),
                                      ),
                                      onSelected: (SelectedSide opt) {
                                        Vibration.vibrate(
                                          pattern: [0, 90, 25, 125],
                                        );
                                        switch (opt) {
                                          case SelectedSide.none:
                                            _ringWidgetKey.currentState
                                                ?.animateColors();
                                            _cubeFaceSelect('none');
                                            return false;
                                          case SelectedSide.top: // CHAT
                                            _cubeFaceSelect('top');
                                            y = 0;
                                            x = 45;
                                            _contextChange
                                                ? contextChange()
                                                : null;
                                            return true;
                                          case SelectedSide.bottom:
                                            setState(() {
                                              resetAllWWW();
                                            });
                                            _ringWidgetKey.currentState
                                                ?.animateColors();
                                            _cubeFaceSelect('bottom');
                                            !_contextChange
                                                ? contextChange()
                                                : null;
                                            return true;
                                          case SelectedSide.left:
                                            setState(() {
                                              resetAllWWW();
                                            });
                                            _ringWidgetKey.currentState
                                                ?.animateColors();
                                            _cubeFaceSelect('left');
                                            !_contextChange
                                                ? contextChange()
                                                : null;
                                            return true;
                                          case SelectedSide.right: // PHONE
                                            _ringWidgetKey.currentState
                                                ?.animateColors();
                                            _cubeFaceSelect('right');
                                            x = 90;
                                            y = 35;
                                            _contextChange
                                                ? contextChange()
                                                : null;
                                            return true;
                                          case SelectedSide.front: // EMAIL
                                            _ringWidgetKey.currentState
                                                ?.animateColors();
                                            _cubeFaceSelect('front');
                                            x = -45;
                                            y = 35;
                                            _contextChange
                                                ? contextChange()
                                                : null;
                                            return true;
                                          case SelectedSide.back:
                                            setState(() {
                                              resetAllWWW();
                                            });
                                            _ringWidgetKey.currentState
                                                ?.animateColors();
                                            _cubeFaceSelect('back');
                                            !_contextChange
                                                ? contextChange()
                                                : null;
                                            return true;
                                        }
                                      },
                                      left: cubeFace(
                                        // WHERE
                                        0,
                                        ConcielIcons.blank,
                                        personalColorScheme.outline,
                                        cubeFaceLt,
                                        cubeFaceLt,
                                      ),
                                      front: cubeFace(
                                        0,
                                        Icons.local_shipping_outlined,
                                        personalColorScheme.outline,
                                        personalColorScheme.secondary
                                            .withOpacity(0.5),
                                        cubeFaceFront,
                                      ),
                                      back: cubeFace(
                                        // WHEN
                                        0,
                                        ConcielIcons.blank,
                                        personalColorScheme.outline,
                                        cubeFaceBk,
                                        cubeFaceBk,
                                      ),
                                      top: cubeFace(
                                        -45 * pi / 180,
                                        ConcielIcons.search,
                                        personalColorScheme.outline,
                                        personalColorScheme.secondary
                                            .withOpacity(0.5),
                                        cubeFaceTop,
                                      ),
                                      bottom: cubeFace(
                                        // WHAT
                                        0,
                                        ConcielIcons.blank,
                                        personalColorScheme.outline,
                                        cubeFaceBm,
                                        cubeFaceBm,
                                      ),
                                      right: cubeFace(
                                        0,
                                        ConcielIcons.shop,
                                        personalColorScheme.outline,
                                        personalColorScheme.secondary
                                            .withOpacity(0.5),
                                        cubeFaceRight,
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
          PrimaryBottomBar(
            concielApp: ConcielApp.shop,
            onTap: (value) async {
              switch (value) {
                case 0:
                  // Share pressed
                  sendFileAction(
                    context,
                    null,
                  );
                  break;
                case 1:
                  // TALK notifier pressed
                  VRouter.of(context).to('/talk');
                  break;
                case 2:
                  // Message notifier pressed
                  final unreadCount = Matrix.of(context)
                      .client
                      .rooms
                      .where((r) => (r.isDirectChat != true))
                      .where(
                        (r) =>
                            (r.isUnread || r.membership == Membership.invite),
                      )
                      .length;
                  unreadCount != 0 ? VRouter.of(context).to('/rooms') : null;
                  break;
                case 3:
                  // BOOK notifier pressed
                  VRouter.of(context).to('/book');
                  break;
                case 4:
                  // Contacts pressed
                  setState(() {
                    _contacts = true;
                  });
                  await _slidePage!.forward();
                  VRouter.of(context).to(
                    '/localcontacts',
                    queryParameters: {
                      'route': _contextChange ? 'wherewhenwhat' : 'book',
                    },
                  );
                  break;
              }
            },
          ),
        ],
      ),
    );
  }
}
