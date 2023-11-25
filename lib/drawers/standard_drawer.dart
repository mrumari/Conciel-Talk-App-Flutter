import 'dart:math';

import 'package:concieltalk/config/color_constants.dart';
import 'package:concieltalk/drawers/drawer_components.dart';
import 'package:concieltalk/drawers/rotating_drawer.dart';
import 'package:concieltalk/utils/ui/central_buttons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vibration/vibration.dart';

class StandardDrawer extends StatefulWidget {
  final BuildContext context;
  final bool left;
  final Color borderColor;
  final Color splineColor;
  final Color? iconColor;
  final Color? color;
  final bool showSplines;
  final List<IconData> icons;
  final List<VoidCallback> onTap;
  final Function(DragUpdateDetails)? onDrag;
  final VoidCallback? onRTap;

  const StandardDrawer({
    Key? key,
    required this.context,
    required this.left,
    required this.borderColor,
    required this.splineColor,
    this.iconColor,
    this.color,
    required this.icons,
    required this.onTap,
    this.onDrag,
    this.onRTap,
    required this.showSplines,
  }) : super(key: key);
  @override
  State<StandardDrawer> createState() => StandardDrawerState();
}

class StandardDrawerState extends State<StandardDrawer> {
  double _rotation = 0;
  double _startRotation = 0;
  late Offset _previousOffset;

  @override
  Widget build(BuildContext context) {
    final ringDiameter = 288.r;
    final arcRadius = 84.r;
    final arcWidth = 72.r;
    final angleIncrement = 360 / widget.icons.length;
    return Stack(
      alignment: Alignment.center,
      children: [
        OuterDrawerRing(
          context: context,
          diameter: ringDiameter,
          trackColor: personalColorScheme.surfaceTint,
          progressColor: personalColorScheme.primary,
          interactive: false,
          left: widget.left,
          onDrag: widget.onDrag,
        ),
        LayoutBuilder(
          builder: (context, constraints) {
            return GestureDetector(
              onPanStart: (details) {
                _startRotation = _rotation;
                _previousOffset = details.globalPosition;
              },
              onPanUpdate: (details) {
                Vibration.vibrate(duration: 125, amplitude: 5);
                final Offset currentOffset = details.globalPosition;
                final double angleDelta = angleBetweenPoints(
                  Offset(
                    160.r,
                    160.r,
                  ),
                  _previousOffset,
                  currentOffset,
                );
                setState(() {
                  if (widget.left) {
                    _rotation += angleDelta * 4;
                    _previousOffset = currentOffset;
                  } else {
                    _rotation += -angleDelta * 4;
                    _previousOffset = currentOffset;
                  }
                });
              },
              onPanEnd: (details) {
                setState(() {
                  _rotation = _startRotation +
                      180 *
                          (pi /
                              180); // Update the rotation to be 180 degrees from the starting point
                  _startRotation = _rotation;
                });
              },
              child: Transform.rotate(
                origin: const Offset(0, 0),
                angle: _rotation,
                child: Stack(
                  children: [
                    for (var index = 0; index < widget.icons.length; index++)
                      RingButton(
                        painter: ArcPainter(
                          icon: widget.icons[index],
                          iconSize: 30.r,
                          startAngle: angleIncrement > 60
                              ? (angleIncrement * index)
                              : (angleIncrement * index + 1) - 30,
                          sweepAngle: widget.showSplines
                              ? angleIncrement - 1
                              : angleIncrement,
                          radius: arcRadius,
                          width: arcWidth,
                          left: widget.left,
                          color: widget.color ?? Colors.transparent,
                          borderColor: widget.borderColor,
                          splineColor: widget.splineColor,
                          iconColor:
                              widget.iconColor ?? personalColorScheme.outline,
                        ),
                        onTap: () {
                          widget.onTap[index]();
                        },
                        size: 282.r,
                      ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
