import 'dart:math';

import 'package:concieltalk/config/color_constants.dart';
import 'package:concieltalk/drawers/drawer_components.dart';
import 'package:concieltalk/utils/ui/central_buttons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vibration/vibration.dart';

class TestSecStandardDrawer extends StatefulWidget {
  final BuildContext context;
  final bool left;
  final Color borderColor;
  final Color splineColor;
  final Color? iconColor;
  final Color? color;
  final bool showSplines;
  final List<IconData> icons;
  final List<VoidCallback> onTap;
  final Function(DragUpdateDetails)? onPanUpdate;

  const TestSecStandardDrawer({
    Key? key,
    required this.context,
    required this.left,
    required this.borderColor,
    required this.splineColor,
    this.iconColor,
    this.color,
    required this.icons,
    required this.onTap,
    this.onPanUpdate,
    required this.showSplines,
  }) : super(key: key);
  @override
  State<TestSecStandardDrawer> createState() => TestSecStandardDrawerState();
}

class TestSecStandardDrawerState extends State<TestSecStandardDrawer> {
  double _rotation = 0;
  double _startRotation = 0;
  late Offset _previousOffset;

  //*
  late double ringDiameter;
  late double arcRadius;
  late double arcWidth;
  late double angleIncrement;

  //*
  bool isRotationModeEnable = false;

  @override
  Widget build(BuildContext context) {
    ringDiameter = 288.r;
    arcRadius = 84.r;
    arcWidth = 72.r;
    angleIncrement = 360 / widget.icons.length;

    return InkWell(
      highlightColor: Colors.transparent,
      onLongPress: !isRotationModeEnable
          ? () {
              setState(() {
                isRotationModeEnable = true;
              });
            }
          : null,
      child: Stack(
        alignment: Alignment.center,
        children: [
          _outerDrawerRingView,
          _layoutBuilderView,
        ],
      ),
    );
  }

  Widget get _outerDrawerRingView => OuterDrawerRing(
        context: context,
        diameter: ringDiameter,
        trackColor: isRotationModeEnable
            ? personalColorScheme.primary.withOpacity(.3)
            : personalColorScheme.surfaceTint,
        progressColor: personalColorScheme.primary,
        interactive: true,
        left: widget.left,
        isAnimate: false,
        onPanStart: _onPanStart,
        onPanEnd: _onPanEnd,
        onDrag: _onPanUpdate,
        onTap: null, // () {},
      );

  Widget get _layoutBuilderView => LayoutBuilder(
        builder: (context, constraints) {
          return GestureDetector(
            // onPanStart: _checkRotationModeEnable(widgetOrFunction: _onPanStart),
            // onPanUpdate:
            //     _checkRotationModeEnable(widgetOrFunction: _onPanUpdate),
            // onPanEnd: _checkRotationModeEnable(widgetOrFunction: _onPanEnd),
            child: _tranformWidget,
          );
        },
      );

  void _onPanStart(details) {
    _startRotation = _rotation;
    _previousOffset = details.globalPosition;
  }

  // Step 2
  /// Get size of ConcielRingDraw with RenderBox.
  // Size _getSize(key key) {
  //   final RenderBox renderBox =
  //       key.currentContext!.findRenderObject() as RenderBox;
  //   final Size size = renderBox.size;
  //   return size;
  // }

  void _onPanUpdate(details) {
    Vibration.vibrate(duration: 125, amplitude: 5);
    // final Offset currentOffset = details.globalPosition;
    // final double angleDelta = angleBetweenPoints(
    //   Offset(
    //     160.r,
    //     160.r,
    //   ),
    //   _previousOffset,
    //   currentOffset,
    // );

    // Step 1
    final double dx = details.localPosition.dx;
    final double dy = details.localPosition.dy;
    final Size size = MediaQuery.of(context).size;
    final double centerX = size.width / 2.0;
    final double centerY = size.height / 2.0;
    final double angle = _getTouchedDegrees(centerX, dx, centerY, dy);

    setState(() {
      if (widget.left) {
        _rotation = angle / 5;

        // _rotation += -angleDelta * 2;
        // _previousOffset = currentOffset;
      }
      // else
      // {
      //   _rotation += angleDelta * 2;
      //   _previousOffset = currentOffset;
      // }
    });

    // setState(() {
    //   _rotation = _startRotation +
    //       details.delta.dx * 0.5; // Adjust sensitivity for rotation
    // });
  }

  // Step 4.
  /// Convert radians to degrees
  double _radiansToDegrees(double radians) => radians * 180 / pi;

  // Step 5
  /// Convert (x, y) coordinates to an angle.
  double _getTouchedDegrees(
    double centerX,
    double dx,
    double centerY,
    double dy,
  ) {
    return _radiansToDegrees(atan2(centerX - dx, dy - centerY));
  }

  void _onPanEnd(details) {
    setState(() {
      // Update the rotation to be 180 degrees will rotate three element
      // Update the rotation to be 300 degrees will rotate only one element

      // if (details.velocity.pixelsPerSecond.dy > 0) {
      //   // will rotate clockwise
      //   _rotation = _startRotation + 60 * (pi / 180);
      // } else {
      //   // will rotate anti-clockwise
      //   _rotation = _startRotation + 300 * (pi / 180);
      // }

      // _startRotation = _rotation;
    });
  }

  Widget get _tranformWidget => Transform.rotate(
        origin: const Offset(0, 0),
        angle: _rotation,
        child: _stack,
      );

  Widget get _stack => Stack(
        children: [
          for (var index = 0; index < widget.icons.length; index++)
            RingButton(
              painter: ArcPainter(
                icon: widget.icons[index],
                iconSize: 30.r,
                startAngle: angleIncrement > 60
                    ? (angleIncrement * index)
                    : (angleIncrement * index + 1) - 30,
                sweepAngle:
                    widget.showSplines ? angleIncrement - 1 : angleIncrement,
                radius: arcRadius,
                width: arcWidth,
                left: widget.left,
                color: widget.color ?? Colors.transparent,
                borderColor: widget.borderColor,
                splineColor: widget.splineColor,
                iconColor: widget.iconColor ?? personalColorScheme.outline,
              ),
              onTap: isRotationModeEnable ? null : () => widget.onTap[index](),

              // _checkRotationModeEnable(
              //   widgetOrFunction: () => widget.onTap[index](),
              // ),
              size: 282.r,
            ),
        ],
      );

  // When Rotation mode is not enable will return null.
  dynamic _checkRotationModeEnable({required dynamic widgetOrFunction}) {
    if (isRotationModeEnable) {
      return widgetOrFunction;
    } else {
      return null;
    }
  }
}
