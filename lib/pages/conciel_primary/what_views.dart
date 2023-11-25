import 'package:concieltalk/config/app_config.dart';
import 'package:concieltalk/config/color_constants.dart';
import 'package:concieltalk/utils/ui/central_buttons.dart';
import 'package:concieltalk/pages/conciel_primary/where_when_what.dart';
import 'package:concieltalk/utils/ui/ring_widgets.dart';
import 'package:concieltalk/widgets/base_ring_state.dart';
import 'package:concieltalk/widgets/debouncer.dart';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vrouter/vrouter.dart';

class WhatDetailView extends StatefulWidget {
  final RingController wwwController;
  final int vIndex;

  const WhatDetailView(
    this.wwwController,
    this.vIndex, {
    Key? key,
  }) : super(key: key);

  @override
  WhatDetailViewState createState() => WhatDetailViewState();
}

class WhatDetailViewState extends State<WhatDetailView>
    with TickerProviderStateMixin {
  bool animateNow = false;
  final GlobalKey<BaseRingState> ringWidgetKey = GlobalKey();

  bool listReset(List<int> list) {
    return list.every((element) => element == 99);
  }

  @override
  Widget build(BuildContext context) {
    final onTap = List.generate(AppConfig.whatDetailItems.length, (i) {
      return () {
        setState(() {
          whatDetailProgress[widget.vIndex][i] == 0.0
              ? whatDetailProgress[widget.vIndex][i] = 100.0
              : whatDetailProgress[widget.vIndex][i] = 0.0;
          whatDetailIndices[widget.vIndex] == i
              ? whatDetailIndices[widget.vIndex] = 99
              : whatDetailIndices[widget.vIndex] = i;
          (whatDetailProgress[widget.vIndex].every((element) => element == 0.0))
              ? whatText = 'WHAT'
              : whatText = 'NEXT';
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
              personalColorScheme.tertiary,
              personalColorScheme.surfaceTint,
              whatDetailProgress[widget.vIndex],
              whatDetailIndices[widget.vIndex],
            ),
          ),
          for (var index = 0;
              index < AppConfig.whatDetailItems[widget.vIndex].length;
              index++)
            ArcButton(
              startAngle: 0 + index * 60,
              sweepAngle: 60,
              radius: 105.w,
              strokeWidth: 35.r,
              onTap: () {
                debounce(Conciel.debouncer, () {
                  setState(() {
                    onTap[index]();
                    if (listReset(whatDetailIndices)) {
                      setState(() {
                        whatText = 'WHAT';
                      });
                    }
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
                  text: AppConfig.whatDetailItems[widget.vIndex][index],
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
                      if (whatIndex != 99) {
                        final current = wwwState.value;
                        current['what'] = true;
                        wwwState.value = current;
                        updateData(current);
                        whatText = AppConfig.whatDetailItems[whatIndex]
                            [whatDetailIndices[widget.vIndex]];
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
                          'type': 'RESTAURANT.$whatText',
                          'time': whenText,
                        },
                      );
                    } else if (whenIndex == 99) {
                      VRouter.of(context).to(
                        '/$route/wherewhenwhat',
                        queryParameters: {
                          'route': 'when',
                          'place': whereText,
                          'type': 'RESTAURANT.$whatText',
                          'time': '',
                        },
                      );
                    } else {
                      VRouter.of(context).to(
                        '/$route/maps',
                        queryParameters: {
                          'route': 'when',
                          'place': whereText,
                          'type': 'RESTAURANT.$whatText',
                          'time': whenText,
                        },
                      );
                    }
                  },
                  child: Text(
                    whatText != '' ? whatText : 'WHAT',
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
