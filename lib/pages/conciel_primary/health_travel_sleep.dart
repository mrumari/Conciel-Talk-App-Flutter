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

class HealthTravelSleep extends StatefulWidget {
  const HealthTravelSleep({Key? key}) : super(key: key);

  @override
  HTSController createState() => HTSController();
}

class HTSController extends State<HealthTravelSleep>
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
              route: '/book',
              appBar: (context) => DefaultHeaderWidget(
                route: '/book',
                onBackPress: () {
                  VRouter.of(context).to('/book');
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
                  route: 'healthtravelsleep',
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
                          'health' => const HealthView(),
                          'travel' => const TravelView(),
                          'sleep' => const SleepView(),
                          _ => const TravelView(),
                        },
                      ],
                    ),
                  ),
                ),
              ],
            ),
            PrimaryBottomBar(
              concielApp: ConcielApp.book,
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

class HealthView extends StatefulWidget {
  const HealthView({Key? key}) : super(key: key);

  @override
  HealthViewState createState() => HealthViewState();
}

class HealthViewState extends State<HealthView> with TickerProviderStateMixin {
  bool animateNow = false;
  final GlobalKey<BaseRingState> ringWidgetKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    final double width = 1.sw;
    final double height = 1.sh;
    final items = AppConfig.healthItems.length;
    if (healthIndex == 99) {
      reset(healthProgress, 0);
    }

    final onTap = List.generate(6, (i) {
      return () {
        setState(() {
          reset(healthProgress, 0);
          healthProgress[i] = 100;
          healthIndex = i;
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
              personalColorScheme.tertiary.withOpacity(0.5),
              personalColorScheme.surfaceTint,
              healthProgress,
              healthIndex,
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
                  text: AppConfig.healthItems[index],
                ),
              ),
            ),
          Stack(
            children: <Widget>[
              Container(
                alignment: Alignment.center,
                width: 96.w,
                decoration: ShapeDecoration(
                  shape: StarBorder.polygon(
                    side: BorderSide(
                      color: personalColorScheme.tertiary,
                    ),
                    sides: 6,
                  ),
                ),
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      if (healthIndex != 99) {
                        final current = wwwState.value;
                        current['healthments'] = true;
                        wwwState.value = current;
                        updateData(current);
//                        planText = AppConfig.planItems[healthIndex];
                      }
                    });
                    VRouter.of(context).to(
                      '/book',
                    );
                  },
                  child: Text(
                    'HEALTH',
                    style: TextStyle(
                      fontSize: 16,
                      letterSpacing: 2,
                      color: personalColorScheme.tertiary,
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

class TravelView extends StatefulWidget {
  const TravelView({Key? key}) : super(key: key);

  @override
  TravelViewState createState() => TravelViewState();
}

class TravelViewState extends State<TravelView> with TickerProviderStateMixin {
  bool animateNow = false;
  final GlobalKey<BaseRingState> ringWidgetKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    final double width = 1.sw;
    final double height = 1.sh;
    final items = AppConfig.travelItems.length;
    if (travelIndex == 99) {
      reset(travelProgress, 0);
    }

    final onTap = List.generate(6, (i) {
      return () {
        setState(() {
          reset(travelProgress, 0);
          travelProgress[i] = 100;
          travelIndex = i;
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
              personalColorScheme.tertiary.withOpacity(0.5),
              personalColorScheme.surfaceTint,
              travelProgress,
              travelIndex,
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
                  text: AppConfig.travelItems[index],
                ),
              ),
            ),
          Stack(
            children: <Widget>[
              Container(
                alignment: Alignment.center,
                width: 96.w,
                decoration: ShapeDecoration(
                  shape: StarBorder.polygon(
                    side: BorderSide(
                      color: personalColorScheme.tertiary,
                    ),
                    sides: 6,
                  ),
                ),
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      if (travelIndex != 99) {
                        final current = wwwState.value;
                        current['travel'] = true;
                        wwwState.value = current;
                        updateData(current);
//                        cloudText = AppConfig.travelItems[travelIndex];
                      }
                    });
                    VRouter.of(context).to(
                      '/book',
                    );
                  },
                  child: Text(
                    'TRAVEL',
                    style: TextStyle(
                      fontSize: 16,
                      letterSpacing: 2,
                      color: personalColorScheme.tertiary,
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

class SleepView extends StatefulWidget {
  const SleepView({Key? key}) : super(key: key);

  @override
  SleepViewState createState() => SleepViewState();
}

class SleepViewState extends State<SleepView> with TickerProviderStateMixin {
  bool animateNow = false;
  final GlobalKey<BaseRingState> ringWidgetKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    final double width = 1.sw;
    final double height = 1.sh;
    final items = AppConfig.sleepItems.length;
    if (sleepIndex == 99) {
      reset(sleepProgress, 0);
    }

    final onTap = List.generate(6, (i) {
      return () {
        setState(() {
          reset(sleepProgress, 0);
          sleepProgress[i] = 100;
          sleepIndex = i;
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
              personalColorScheme.tertiary.withOpacity(0.5),
              personalColorScheme.surfaceTint,
              sleepProgress,
              sleepIndex,
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
                  text: AppConfig.sleepItems[index],
                ),
              ),
            ),
          Stack(
            children: <Widget>[
              Container(
                alignment: Alignment.center,
                width: 96.w,
                decoration: ShapeDecoration(
                  shape: StarBorder.polygon(
                    side: BorderSide(
                      color: personalColorScheme.tertiary,
                    ),
                    sides: 6,
                  ),
                ),
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      if (sleepIndex != 99) {
                        final current = wwwState.value;
                        current['sleep'] = true;
                        wwwState.value = current;
                        updateData(current);
//                        sleepText = AppConfig.sleepItems[sleepIndex];
                      }
                    });
                    VRouter.of(context).to(
                      '/book',
                    );
                  },
                  child: Text(
                    'SLEEP',
                    style: TextStyle(
                      fontSize: 16,
                      letterSpacing: 2,
                      color: personalColorScheme.tertiary,
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
