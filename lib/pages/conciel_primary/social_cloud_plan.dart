import 'package:concieltalk/config/app_config.dart';
import 'package:concieltalk/config/color_constants.dart';
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

class SocialPlanCloud extends StatefulWidget {
  const SocialPlanCloud({Key? key}) : super(key: key);

  @override
  SCPController createState() => SCPController();
}

class SCPController extends State<SocialPlanCloud>
    with TickerProviderStateMixin {
  final GlobalKey<BaseRingState> ringWidgetKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    final wwwRoute = VRouter.of(context).queryParameters['route'];

    return Scaffold(
      body: Stack(
        alignment: Alignment.center,
        children: [
          HomePageDevice(
            route: '/talk',
            appBar: (context) => DefaultHeaderWidget(
              route: '/talk',
              onBackPress: () {
                VRouter.of(context).to('/talk');
              },
              onSearchPress: () {
                Scaffold.of(context).openDrawer();
              },
            ),
            ringKey: ringWidgetKey,
            drawer: RotatingDrawer(
              corner: false,
              drawer: SearchDrawer(
                context: context,
                route: 'socialplancloud',
              ),
            ),
            endDrawer: const SizedBox.shrink(),
            children: [
              Transform.scale(
                scale: AppConfig.cubeRingScale,
                child: Stack(
                  alignment: AlignmentDirectional.center,
                  children: <Widget>[
                    switch (wwwRoute) {
                      'social' => const SocialView(),
                      'cloud' => const CloudView(),
                      'plan' => const PlanView(),
                      _ => const SocialView(),
                    },
                  ],
                ),
              ),
            ],
          ),
          PrimaryBottomBar(
            concielApp: ConcielApp.talk,
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
                  // Talk notifier pressed
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
    );
  }
}

class PlanView extends StatefulWidget {
  const PlanView({Key? key}) : super(key: key);

  @override
  PlanViewState createState() => PlanViewState();
}

class PlanViewState extends State<PlanView> with TickerProviderStateMixin {
  bool animateNow = false;
  final GlobalKey<BaseRingState> ringWidgetKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    final double width = 1.sw;
    final double height = 1.sh;
    final items = AppConfig.planItems.length;
    if (planIndex == 99) {
      reset(planProgress, 0);
    }

    final onTap = List.generate(6, (i) {
      return () {
        setState(() {
          reset(planProgress, 0);
          planProgress[i] = 100;
          planIndex = i;
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
              personalColorScheme.primary.withOpacity(0.5),
              personalColorScheme.primary.withOpacity(0.5),
              planProgress,
              planIndex,
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
                  text: AppConfig.planItems[index],
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
                      color: personalColorScheme.primary,
                    ),
                    sides: 6,
                  ),
                ),
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      if (planIndex != 99) {
                        final current = wwwState.value;
                        current['plan'] = true;
                        wwwState.value = current;
                        updateData(current);
//                        planText = AppConfig.planItems[planIndex];
                      }
                    });
                    VRouter.of(context).to(
                      '/talk',
                    );
                  },
                  child: Text(
                    'PLAN',
                    style: TextStyle(
                      fontSize: 16,
                      letterSpacing: 2,
                      color: personalColorScheme.primary,
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

class CloudView extends StatefulWidget {
  const CloudView({Key? key}) : super(key: key);

  @override
  CloudViewState createState() => CloudViewState();
}

class CloudViewState extends State<CloudView> with TickerProviderStateMixin {
  bool animateNow = false;
  final GlobalKey<BaseRingState> ringWidgetKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    final double width = 1.sw;
    final double height = 1.sh;
    final items = AppConfig.cloudItems.length;
    if (cloudIndex == 99) {
      reset(cloudProgress, 0);
    }

    final onTap = List.generate(6, (i) {
      return () {
        setState(() {
          reset(cloudProgress, 0);
          cloudProgress[i] = 100;
          cloudIndex = i;
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
              personalColorScheme.primary.withOpacity(0.5),
              personalColorScheme.primary.withOpacity(0.5),
              cloudProgress,
              cloudIndex,
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
                  text: AppConfig.cloudItems[index],
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
                      color: personalColorScheme.primary,
                    ),
                    sides: 6,
                  ),
                ),
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      if (cloudIndex != 99) {
                        final current = wwwState.value;
                        current['cloud'] = true;
                        wwwState.value = current;
                        updateData(current);
//                        cloudText = AppConfig.cloudItems[cloudIndex];
                      }
                    });
                    VRouter.of(context).pop();
                  },
                  child: Text(
                    'CLOUD',
                    style: TextStyle(
                      fontSize: 16,
                      letterSpacing: 2,
                      color: personalColorScheme.primary,
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

class SocialView extends StatefulWidget {
  const SocialView({Key? key}) : super(key: key);

  @override
  SocialViewState createState() => SocialViewState();
}

class SocialViewState extends State<SocialView> with TickerProviderStateMixin {
  bool animateNow = false;
  final GlobalKey<BaseRingState> ringWidgetKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    final double width = 1.sw;
    final double height = 1.sh;
    final items = AppConfig.socialItems.length;
    if (socialIndex == 99) {
      reset(socialProgress, 0);
    }

    final onTap = List.generate(6, (i) {
      return () {
        setState(() {
          reset(socialProgress, 0);
          socialProgress[i] = 100;
          socialIndex = i;
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
              personalColorScheme.primary.withOpacity(0.5),
              personalColorScheme.surfaceTint,
              socialProgress,
              socialIndex,
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
                  text: AppConfig.socialItems[index],
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
                      color: personalColorScheme.primary,
                    ),
                    sides: 6,
                  ),
                ),
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      if (socialIndex != 99) {
                        final current = wwwState.value;
                        current['social'] = true;
                        wwwState.value = current;
                        updateData(current);
//                        socialText = AppConfig.socialItems[socialIndex];
                      }
                    });
                    VRouter.of(context).to(
                      '/talk',
                    );
                  },
                  child: Text(
                    'SOCIAL',
                    style: TextStyle(
                      fontSize: 16,
                      letterSpacing: 2,
                      color: personalColorScheme.primary,
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
