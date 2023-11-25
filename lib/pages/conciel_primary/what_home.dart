import 'package:concieltalk/config/app_config.dart';
import 'package:concieltalk/config/color_constants.dart';
import 'package:concieltalk/pages/conciel_primary/what_views.dart';
import 'package:concieltalk/utils/ui/central_buttons.dart';
import 'package:concieltalk/pages/conciel_primary/where_when_what.dart';
import 'package:concieltalk/utils/ui/ring_widgets.dart';
import 'package:concieltalk/widgets/base_ring_state.dart';
import 'package:concieltalk/widgets/debouncer.dart';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vrouter/vrouter.dart';

class WhatView extends StatefulWidget {
  final RingController wwwController;

  const WhatView(this.wwwController, {Key? key}) : super(key: key);

  @override
  WhatViewState createState() => WhatViewState();
}

class WhatViewState extends State<WhatView> with TickerProviderStateMixin {
  bool animateNow = false;
  final GlobalKey<BaseRingState> ringWidgetKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    if (whatIndex == 99) {
      reset(whatProgress, 0);
    }

    final onTap = List.generate(AppConfig.whatItems.length, (i) {
      return () {
        setState(() {
          reset(whatProgress, 0);
          whatProgress[i] = 100;
          whatIndex = i;
        });
      };
    });

    return SizedBox(
      width: 1.sw,
      height: 1.sh,
      child: Stack(
        alignment: AlignmentDirectional.center,
        children: <Widget>[
          whatIndex == 4
              ? const IgnorePointer()
              : IgnorePointer(
                  ignoring: true,
                  child: Opacity(
                    opacity: whatIndex == 99 ? 1.0 : 0.5,
                    child: wwwRings(
                      1,
                      context,
                      personalColorScheme.tertiary,
                      whatIndex == 99
                          ? personalColorScheme.surfaceTint
                          : Colors.transparent,
                      whatProgress,
                      whatIndex,
                    ),
                  ),
                ),
          (whatIndex == 99)
              ? Container()
              : switch (whatIndex) {
                  4 => WhatDetailView(widget.wwwController, 4),
                  _ => Container(),
                },
          for (var index = 0; index < AppConfig.whatItems.length; index++)
            whatIndex == 4
                ? const IgnorePointer()
                : ArcButton(
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
                      child: Opacity(
                        opacity: whatIndex == 99
                            ? 1.0
                            : index == whatIndex
                                ? 1.0
                                : 0.5,
                        child: ConcielArcText(
                          color: personalColorScheme.outline,
                          fontSize: 14,
                          radius: 105.w,
                          sweep: 60,
                          start: 210 + index * 60,
                          text: AppConfig.whatItems[index],
                        ),
                      ),
                    ),
                  ),
          whatIndex == 4
              ? const IgnorePointer()
              : Stack(
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
                            if (whatIndex != 99) {
                              final current = wwwState.value;
                              current['what'] = true;
                              wwwState.value = current;
                              updateData(current);
                              whatText = AppConfig.whatItems[whatIndex];
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
                          if (whereIndex == 99) {
                            VRouter.of(context).to(
                              '/$route/wherewhenwhat',
                              queryParameters: {
                                'route': 'where',
                                'place': '',
                                'type': whatText,
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
                          'WHAT',
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
