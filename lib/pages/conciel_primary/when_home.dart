import 'package:concieltalk/config/color_constants.dart';
import 'package:concieltalk/utils/ui/central_buttons.dart';
import 'package:concieltalk/pages/conciel_primary/where_when_what.dart';
import 'package:concieltalk/config/app_config.dart';
import 'package:concieltalk/utils/ui/ring_widgets.dart';
import 'package:concieltalk/widgets/debouncer.dart';
import 'package:concieltalk/widgets/base_ring_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:vrouter/vrouter.dart';

class WhenView extends StatefulWidget {
  final RingController wwwController;
  const WhenView(this.wwwController, {Key? key}) : super(key: key);

  @override
  WhenViewState createState() => WhenViewState();
}

class WhenViewState extends State<WhenView> with TickerProviderStateMixin {
  bool animateNow = false;
  final GlobalKey<BaseRingState> ringWidgetKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    if (whenIndex == 99) {
      reset(whenProgress, 0);
    }

    final onTap = List.generate(6, (i) {
      return () {
        setState(() {
          reset(whenProgress, 0);
          whenProgress[i] = 100;
          whenIndex = i;
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
              personalColorScheme.primary,
              personalColorScheme.surfaceTint,
              whenProgress,
              whenIndex,
            ),
          ),
          for (var index = 0; index < AppConfig.whenItems.length; index++)
            ArcButton(
              startAngle: 0 + index * 60,
              sweepAngle: 60,
              radius: 105.w,
              strokeWidth: 35.r,
              onTap: () async {
                debounce(Conciel.debouncer, () {
                  onTap[index]();
                });
                whenDateTime = [
                  DateTime.now(),
                  DateTime.now(),
                  DateTime.now(),
                ];
                switch (whenIndex) {
                  case 0: // THIS WEEK
                    whenDateTime = [
                      DateTime.now(),
                      whenDateTime[0].add(const Duration(days: 7)),
                      DateTime.now(),
                    ];
                    setState(() {
                      whenText = 'THIS WEEK';
                    });
                    break;
                  case 1: // THIS MONTH
                    whenDateTime = [
                      DateTime.now(),
                      DateTime(
                        whenDateTime[0].year,
                        whenDateTime[1].month + 1,
                        0,
                      ),
                      DateTime.now(),
                    ];
                    setState(() {
                      whenText = 'THIS MONTH';
                    });
                    break;
                  case 2: // DATE
                    whenDateTime[1] = DateTime(whenDateTime[0].year + 1, 1, 0);
                    whenDateTime[2] = (await showDateTimePicker(
                      dateSelected: false,
                      context: context,
                      initialDate: whenDateTime[0],
                      firstDate: whenDateTime[0],
                      lastDate: whenDateTime[1],
                    ))!;
                    setState(() {
                      whenText =
                          DateFormat('ddMMM - HH:mm').format(whenDateTime[2]);
                    });
                  case 3: // NOW
                    whenText =
                        DateFormat('ddMMM - HH:mm').format(whenDateTime[2]);
                    break;
                  case 4: // TODAY
                    whenDateTime[2] = (await showDateTimePicker(
                      dateSelected: true,
                      context: context,
                      initialDate: whenDateTime[0],
                      firstDate: whenDateTime[0],
                      lastDate: whenDateTime[1],
                    ))!;
                    setState(() {
                      whenText =
                          DateFormat('ddMMM - HH:mm').format(whenDateTime[2]);
                    });
                    break;
                  case 5: // TOMORROW
                    whenDateTime = [
                      DateTime.now().add(const Duration(days: 1)),
                      DateTime.now().add(const Duration(days: 1)),
                      DateTime.now().add(const Duration(days: 1)),
                    ];
                    whenDateTime[2] = (await showDateTimePicker(
                      dateSelected: true,
                      context: context,
                      initialDate: whenDateTime[0],
                      firstDate: whenDateTime[0],
                      lastDate: whenDateTime[1],
                    ))!;
                    setState(() {
                      whenText =
                          DateFormat('ddMMM - HH:mm').format(whenDateTime[2]);
                    });
                    break;
                  default:
                    break;
                }
              },
              child: IgnorePointer(
                ignoring: true,
                child: ConcielArcText(
                  color: personalColorScheme.outline,
                  fontSize: 14,
                  radius: 105.w,
                  sweep: 60,
                  start: 210 + index * 60,
                  text: AppConfig.whenItems[index],
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
                      if (whenIndex != 99) {
                        final current = wwwState.value;
                        current['when'] = true;
                        wwwState.value = current;
                        updateData(current);
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
                    } else if (whereIndex == 99) {
                      VRouter.of(context).to(
                        '/$route/wherewhenwhat',
                        queryParameters: {
                          'route': 'where',
                          'place': '',
                          'type': whatText,
                          'time': whenText,
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
                    'WHEN',
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

Future<DateTime?> showDateTimePicker({
  required BuildContext context,
  required bool dateSelected,
  DateTime? initialDate,
  DateTime? firstDate,
  DateTime? lastDate,
}) async {
  initialDate ??= DateTime.now();
  firstDate ??= initialDate.subtract(const Duration(days: 365 * 100));
  lastDate ??= firstDate.add(const Duration(days: 365 * 200));

  final DateTime? selectedDate;

  if (!dateSelected) {
    selectedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: lastDate,
    );
    if (selectedDate == null) return null;
  } else {
    selectedDate = initialDate;
  }

  if (!context.mounted) return selectedDate;

  final TimeOfDay? selectedTime = await showTimePicker(
    context: context,
    initialTime: TimeOfDay.fromDateTime(selectedDate),
  );

  return selectedTime == null
      ? selectedDate
      : DateTime(
          selectedDate.year,
          selectedDate.month,
          selectedDate.day,
          selectedTime.hour,
          selectedTime.minute,
        );
}
