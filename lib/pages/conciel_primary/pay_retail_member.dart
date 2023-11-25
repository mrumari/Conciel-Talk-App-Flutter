import 'package:concieltalk/config/app_config.dart';
import 'package:concieltalk/config/color_constants.dart';
import 'package:concieltalk/drawers/conciel_menu_drawer.dart';
import 'package:concieltalk/drawers/rotating_drawer.dart';
import 'package:concieltalk/drawers/search_drawer.dart';
import 'package:concieltalk/utils/ui/central_buttons.dart';
import 'package:concieltalk/utils/ui/header_footer.dart';
import 'package:concieltalk/utils/ui/page_template.dart';
import 'package:concieltalk/utils/ui/ring_widgets.dart';
import 'package:concieltalk/widgets/base_ring_state.dart';
import 'package:concieltalk/widgets/debouncer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vrouter/vrouter.dart';

class PayRetailMember extends StatefulWidget {
  const PayRetailMember({Key? key}) : super(key: key);

  @override
  PRMController createState() => PRMController();
}

class PRMController extends State<PayRetailMember>
    with TickerProviderStateMixin {
  final GlobalKey<BaseRingState> ringWidgetKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    final double width = 1.sw;
    final double height = 1.sh;
    final wwwRoute = VRouter.of(context).queryParameters['route'];

    return Scaffold(
      body: SizedBox(
        width: width,
        child: Stack(
          alignment: Alignment.center,
          children: [
            HomePageDevice(
              route: '/shop',
              appBar: (context) => DefaultHeaderWidget(
                route: '/shop',
                onBackPress: () {
                  VRouter.of(context).to('/shop');
                },
                onSearchPress: () {
                  Scaffold.of(context).openEndDrawer();
                },
              ),
              ringKey: ringWidgetKey,
              drawer: RotatingDrawer(
                corner: false,
                drawer: ConcielDrawer(context: context),
              ),
              endDrawer: RotatingEndDrawer(
                drawer: SearchDrawer(
                  context: context,
                  route: 'payretailmember',
                ),
              ),
              children: [
                Transform.scale(
                  scale: AppConfig.cubeRingScale,
                  child: SizedBox(
                    width: width,
                    height: height - ScreenUtil().statusBarHeight,
                    child: Stack(
                      alignment: AlignmentDirectional.center,
                      children: <Widget>[
                        switch (wwwRoute) {
                          'payments' => const PayView(),
                          'retail' => const RetailView(),
                          'member' => const MembershipView(),
                          _ => const PayView(),
                        },
                      ],
                    ),
                  ),
                ),
              ],
            ),
            PrimaryBottomBar(
              concielApp: ConcielApp.shop,
              onTap: (value) {
                switch (value) {
                  case 0:
                    // Share pressed
                    VRouter.of(context).to('fileshare');
                    break;
                  case 1:
                    // Book notifier pressed
                    break;
                  case 2:
                    // Message notifier pressed
                    break;
                  case 3:
                    // Shop notifier pressed
                    break;
                  case 4:
                    // Contacts pressed
                    VRouter.of(context).to('/localcontacts');
                    break;
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}

class PayView extends StatefulWidget {
  const PayView({Key? key}) : super(key: key);

  @override
  PayViewState createState() => PayViewState();
}

class PayViewState extends State<PayView> with TickerProviderStateMixin {
  bool animateNow = false;
  final GlobalKey<BaseRingState> ringWidgetKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    final double width = 1.sw;
    final double height = 1.sh;
    final items = AppConfig.payItems.length;
    if (payIndex == 99) {
      reset(payProgress, 0);
    }

    final onTap = List.generate(6, (i) {
      return () {
        setState(() {
          reset(payProgress, 0);
          payProgress[i] = 100;
          payIndex = i;
        });
      };
    });

    return SizedBox(
      width: width,
      height: height,
      child: Stack(
        alignment: AlignmentDirectional.center,
        children: <Widget>[
          IgnorePointer(
            ignoring: true,
            child: wwwRings(
              1,
              context,
              personalColorScheme.secondary.withOpacity(0.5),
              personalColorScheme.surfaceTint,
              payProgress,
              payIndex,
              360 / items,
            ),
          ),
          for (var index = 0; index < items; index++)
            ArcButton(
              startAngle: 0 + index * 360 / items,
              sweepAngle: 360 / items,
              radius: 105.w,
              strokeWidth: 35.r,
              onTap: () {
                debounce(Conciel.debouncer, () {
                  setState(() {
                    onTap[index]();
                  });
                });
              },
              child: IgnorePointer(
                ignoring: true,
                child: ConcielArcText(
                  color: personalColorScheme.outline,
                  fontSize: 14,
                  radius: 105.w,
                  sweep: 360 / items,
                  start: 180 + (360 / items / 2) + index * 360 / items,
                  text: AppConfig.payItems[index],
                ),
              ),
            ),
          Stack(
            children: <Widget>[
              Container(
                alignment: Alignment.center,
                width: 96.r,
                decoration: ShapeDecoration(
                  shape: StarBorder.polygon(
                    side: BorderSide(
                      color: personalColorScheme.secondary,
                    ),
                    sides: 6,
                  ),
                ),
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      if (payIndex != 99) {
                        final current = wwwState.value;
                        current['payments'] = true;
                        wwwState.value = current;
                        updateData(current);
//                        planText = AppConfig.planItems[payIndex];
                      }
                    });
                    VRouter.of(context).to(
                      '/shop',
                    );
                  },
                  child: Text(
                    'PAYING',
                    style: TextStyle(
                      fontSize: 16,
                      letterSpacing: 2,
                      color: personalColorScheme.secondary,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class RetailView extends StatefulWidget {
  const RetailView({Key? key}) : super(key: key);

  @override
  RetailViewState createState() => RetailViewState();
}

class RetailViewState extends State<RetailView> with TickerProviderStateMixin {
  bool animateNow = false;
  final GlobalKey<BaseRingState> ringWidgetKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    final double width = 1.sw;
    final double height = 1.sh;
    final items = AppConfig.retailItems.length;
    if (retailIndex == 99) {
      reset(retailProgress, 0);
    }

    final onTap = List.generate(6, (i) {
      return () {
        setState(() {
          reset(retailProgress, 0);
          retailProgress[i] = 100;
          retailIndex = i;
        });
      };
    });
    return SizedBox(
      width: width,
      height: height,
      child: Stack(
        alignment: AlignmentDirectional.center,
        children: <Widget>[
          IgnorePointer(
            ignoring: true,
            child: wwwRings(
              1,
              context,
              personalColorScheme.secondary.withOpacity(0.5),
              personalColorScheme.surfaceTint,
              retailProgress,
              retailIndex,
              360 / items,
            ),
          ),
          for (var index = 0; index < items; index++)
            ArcButton(
              startAngle: 0 + index * 360 / items,
              sweepAngle: 360 / items,
              radius: 105.w,
              strokeWidth: 35.r,
              onTap: () {
                debounce(Conciel.debouncer, () {
                  setState(() {
                    onTap[index]();
                  });
                });
              },
              child: IgnorePointer(
                ignoring: true,
                child: ConcielArcText(
                  color: personalColorScheme.outline,
                  fontSize: 14,
                  radius: 105.w,
                  sweep: 360 / items,
                  start: 180 + (360 / items / 2) + index * 360 / items,
                  text: AppConfig.retailItems[index],
                ),
              ),
            ),
          Stack(
            children: <Widget>[
              Container(
                alignment: Alignment.center,
                width: 96.r,
                decoration: ShapeDecoration(
                  shape: StarBorder.polygon(
                    side: BorderSide(
                      color: personalColorScheme.secondary,
                    ),
                    sides: 6,
                  ),
                ),
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      if (retailIndex != 99) {
                        final current = wwwState.value;
                        current['retail'] = true;
                        wwwState.value = current;
                        updateData(current);
//                        cloudText = AppConfig.retailItems[retailIndex];
                      }
                    });
                    VRouter.of(context).to(
                      '/shop',
                    );
                  },
                  child: Text(
                    'RETAIL',
                    style: TextStyle(
                      fontSize: 16,
                      letterSpacing: 2,
                      color: personalColorScheme.secondary,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class MembershipView extends StatefulWidget {
  const MembershipView({Key? key}) : super(key: key);

  @override
  MembershipViewState createState() => MembershipViewState();
}

class MembershipViewState extends State<MembershipView>
    with TickerProviderStateMixin {
  bool animateNow = false;
  final GlobalKey<BaseRingState> ringWidgetKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    final double width = 1.sw;
    final double height = 1.sh;
    final items = AppConfig.memberItems.length;
    if (memberIndex == 99) {
      reset(memberProgress, 0);
    }

    final onTap = List.generate(6, (i) {
      return () {
        setState(() {
          reset(memberProgress, 0);
          memberProgress[i] = 100;
          memberIndex = i;
        });
      };
    });

    return SizedBox(
      width: width,
      height: height,
      child: Stack(
        alignment: AlignmentDirectional.center,
        children: <Widget>[
          IgnorePointer(
            ignoring: true,
            child: wwwRings(
              1,
              context,
              personalColorScheme.secondary.withOpacity(0.5),
              personalColorScheme.surfaceTint,
              memberProgress,
              memberIndex,
              360 / items,
            ),
          ),
          for (var index = 0; index < items; index++)
            ArcButton(
              startAngle: 0 + index * 360 / items,
              sweepAngle: 360 / items,
              radius: 105.w,
              strokeWidth: 35.r,
              onTap: () {
                debounce(Conciel.debouncer, () {
                  setState(() {
                    onTap[index]();
                  });
                });
              },
              child: IgnorePointer(
                ignoring: true,
                child: ConcielArcText(
                  color: personalColorScheme.outline,
                  fontSize: 14,
                  radius: 105.w,
                  sweep: 360 / items,
                  start: 180 + (360 / items / 2) + index * 360 / items,
                  text: AppConfig.memberItems[index],
                ),
              ),
            ),
          Stack(
            children: <Widget>[
              Container(
                alignment: Alignment.center,
                width: 96.r,
                decoration: ShapeDecoration(
                  shape: StarBorder.polygon(
                    side: BorderSide(
                      color: personalColorScheme.secondary,
                    ),
                    sides: 6,
                  ),
                ),
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      if (memberIndex != 99) {
                        final current = wwwState.value;
                        current['member'] = true;
                        wwwState.value = current;
                        updateData(current);
//                        memberText = AppConfig.memberItems[memberIndex];
                      }
                    });
                    VRouter.of(context).to(
                      '/shop',
                    );
                  },
                  child: Text(
                    'MEMBER',
                    style: TextStyle(
                      fontSize: 16,
                      letterSpacing: 2,
                      color: personalColorScheme.secondary,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
