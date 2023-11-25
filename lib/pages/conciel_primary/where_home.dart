import 'package:concieltalk/config/color_constants.dart';
import 'package:concieltalk/utils/ui/central_buttons.dart';
import 'package:concieltalk/pages/conciel_primary/where_when_what.dart';
import 'package:concieltalk/config/app_config.dart';
import 'package:concieltalk/utils/ui/ring_widgets.dart';
import 'package:concieltalk/widgets/debouncer.dart';
import 'package:concieltalk/widgets/base_ring_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vrouter/vrouter.dart';

class WhereView extends StatefulWidget {
  final RingController wwwController;

  const WhereView(this.wwwController, {Key? key}) : super(key: key);

  @override
  WhereViewState createState() => WhereViewState();
}

class WhereViewState extends State<WhereView> with TickerProviderStateMixin {
  bool animateNow = false;
  final GlobalKey<BaseRingState> ringWidgetKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    if (whereIndex == 99) {
      reset(whereProgress, 0);
    }

    final onTap = List.generate(6, (i) {
      return () {
        setState(() {
          reset(whereProgress, 0);
          whereProgress[i] = 100;
          whereIndex = i;
        });
      };
    });
    return SizedBox(
      width: 1.sw,
      height: 1.sh,
      child: Stack(
        alignment: AlignmentDirectional.center,
        children: <Widget>[
          IgnorePointer(
            ignoring: true,
            child: wwwRings(
              1,
              context,
              personalColorScheme.secondary.withOpacity(.75),
              personalColorScheme.surfaceTint,
              whereProgress,
              whereIndex,
            ),
          ),
          for (var index = 0; index < AppConfig.whereItems.length; index++)
            ArcButton(
              startAngle: 0 + index * 60,
              sweepAngle: 60,
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
                  sweep: 60,
                  start: 210 + index * 60,
                  text: AppConfig.whereItems[index],
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
                      color: personalColorScheme.secondary,
                    ),
                    sides: 6,
                  ),
                ),
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      if (whereIndex != 99) {
                        final current = wwwState.value;
                        current['where'] = true;
                        wwwState.value = current;
                        updateData(current);
                        whereText = AppConfig.whereItems[whereIndex];
                      }
                    });
                    final thisRoute = VRouter.of(context).path;
                    final splitRoute = thisRoute.split('/');
                    String route;
                    if (splitRoute.length > 1) {
                      route = splitRoute[1];
                    } else {
                      route = thisRoute.substring(1);
                    }
                    if (whatIndex == 99) {
                      VRouter.of(context).to(
                        '/$route/wherewhenwhat',
                        queryParameters: {
                          'route': 'what',
                          'place': whereText,
                          'type': '',
                          'time': whenText,
                        },
                      );
                    } else if (whenIndex == 99) {
                      VRouter.of(context).to(
                        '/$route/wherewhenwhat',
                        queryParameters: {
                          'route': 'when',
                          'place': whereText,
                          'type': whatText,
                          'time': '',
                        },
                      );
                    } else {
                      VRouter.of(context).to(
                        '/$route/maps',
                        queryParameters: {
                          'route': 'when',
                          'place': whereText,
                          'type': whatText,
                          'time': whenText,
                        },
                      );
                    }
                  },
                  child: Text(
                    'WHERE',
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
