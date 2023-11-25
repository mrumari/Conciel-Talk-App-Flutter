import 'dart:math';

import 'package:concieltalk/config/color_constants.dart';
import 'package:concieltalk/utils/ui/central_buttons.dart';
import 'package:concieltalk/utils/ui/conciel_ring.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class OuterDrawerRing extends StatefulWidget {
  final BuildContext context;
  final bool interactive;
  final bool left;
  final double diameter;
  final Color trackColor;
  final Color progressColor;
  final Function(DragUpdateDetails)? onDrag;
  final VoidCallback? onTap;
  final bool? isAnimate;
  final Function(DragStartDetails)? onPanStart;
  final Function(DragEndDetails)? onPanEnd;

  const OuterDrawerRing({
    Key? key,
    required this.context,
    required this.diameter,
    required this.trackColor,
    required this.progressColor,
    required this.interactive,
    this.onDrag,
    this.onTap,
    this.isAnimate,
    this.onPanStart,
    this.onPanEnd,
    required this.left,
  }) : super(key: key);
  @override
  State<OuterDrawerRing> createState() => OuterDrawerRingState();
}

class OuterDrawerRingState extends State<OuterDrawerRing> {
  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      ignoring: !widget.interactive,
      child: ConcielRingDraw(
        width: widget.diameter,
        height: widget.diameter,
        progress: 0,
        barWidth: 36.r,
        startAngle: 0,
        sweepAngle: 360,
        strokeCap: StrokeCap.butt,
        trackColor: widget.trackColor,
        progressColor: widget.progressColor,
        dashWidth: 0.5,
        dashGap: 1,
        animDurationMillis: 1000,
        animation: widget.isAnimate ?? widget.interactive,
        interactive: widget.interactive,
        onPanUpdate: widget.onDrag,
        onTap: widget.onTap,
        onPanStart: widget.onPanStart,
        onPanEnd: widget.onPanEnd,
      ),
    );
  }
}

class InnerDrawerRing extends StatefulWidget {
  final BuildContext context;
  final bool interactive;
  final bool? isAnimate;
  final bool left;
  final double diameter;
  final Color trackColor;
  final Color progressColor;
  const InnerDrawerRing({
    Key? key,
    required this.context,
    required this.diameter,
    required this.trackColor,
    required this.progressColor,
    required this.interactive,
    required this.left,
    this.isAnimate,
  }) : super(key: key);
  @override
  State<InnerDrawerRing> createState() => InnerDrawerRingState();
}

class InnerDrawerRingState extends State<InnerDrawerRing> {
  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      ignoring: !widget.interactive,
      child: OverflowBox(
        alignment: Alignment.center,
        maxWidth: double.infinity,
        child: ConcielRingDraw(
          width: widget.diameter,
          height: widget.diameter,
          progress: 100,
          barWidth: 4,
          startAngle: 10,
          sweepAngle: 270,
          strokeCap: StrokeCap.butt,
          trackColor: widget.trackColor,
          progressColor: widget.progressColor,
          dashWidth: 52.5,
          dashGap: 1,
          animDurationMillis: 1000,
          animation: widget.isAnimate ?? widget.interactive,
          interactive: widget.interactive,
        ),
      ),
    );
  }
}

class RingSpline extends StatefulWidget {
  final BuildContext context;
  final bool interactive;
  final double angle;
  final double diameter;
  final Color color;
  const RingSpline({
    Key? key,
    required this.context,
    required this.angle,
    required this.diameter,
    required this.color,
    required this.interactive,
  }) : super(key: key);
  @override
  State<RingSpline> createState() => RingSplineState();
}

class RingSplineState extends State<RingSpline> {
  @override
  Widget build(BuildContext context) {
    return ConcielRingDraw(
      height: widget.diameter * 2,
      width: widget.diameter * 2,
      progress: 0,
      barWidth: widget.diameter * .5 - 10,
      startAngle: widget.angle,
      sweepAngle: 10,
      strokeCap: StrokeCap.butt,
      trackColor: widget.color,
      progressColor: widget.color,
      dashWidth: 0.75,
      dashGap: 1,
      animDurationMillis: 250,
      animation: widget.interactive,
      interactive: widget.interactive,
    );
  }
}

/*
class DrawerLine extends StatelessWidget {
  final Offset start;
  final Offset end;
  final double width;
  final Color color;

  const DrawerLine({
    super.key,
    required this.start,
    required this.end,
    required this.width,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final width = (end.dx - start.dx).abs();
    final height = (end.dy - start.dy).abs();
    final size = Size(width, height);
    return Center(
      child: CustomPaint(
        size: MediaQuery.sizeOf(context),
        painter: LinePainter(
          start: start,
          end: end,
          size: size,
          width: width,
          color: color,
        ),
      ),
    );
  }
}
*/

class LinePainter extends CustomPainter {
  final Offset start;
  final Offset end;
  final Size size;
  final double width;
  final Color color;

  const LinePainter({
    required this.start,
    required this.end,
    required this.size,
    required this.width,
    required this.color,
  });

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }

  @override
  void paint(Canvas canvas, Size size) {
    final p1 = start;
    final p2 = end;
    final paint = Paint()
      ..color = color
      ..strokeWidth = width;
    canvas.drawLine(p1, p2, paint);
  }
}

class DrawerArcButton extends StatefulWidget {
  final IconData icon;
  final double startAngle;
  final double sweepAngle;
  final bool left;
  final double radius;
  final VoidCallback? onPressed;
  final GestureDragUpdateCallback? onPanUpdate;

  const DrawerArcButton({
    Key? key,
    required this.icon,
    required this.startAngle,
    required this.sweepAngle,
    required this.radius,
    required this.left,
    this.onPressed,
    this.onPanUpdate,
  }) : super(key: key);

  @override
  DrawerArcButtonState createState() => DrawerArcButtonState();
}

class DrawerArcButtonState extends State<DrawerArcButton> {
  @override
  Widget build(BuildContext context) {
    return OverflowBox(
      alignment: Alignment.centerLeft,
      maxWidth: double.infinity,
      child: ArcButton(
        startAngle: widget.startAngle,
        sweepAngle: widget.sweepAngle,
        radius: widget.radius,
        strokeWidth: 20,
        child: IconButton(
          onPressed: widget.onPressed,
          icon: Icon(
            widget.icon,
            size: 28,
          ),
        ),
      ),
    );
  }
}

class LinesSplines extends StatelessWidget {
  const LinesSplines({
    super.key,
    required this.context,
    required this.height,
    required this.width,
    required this.itemHeight,
    required this.color,
  });

  final BuildContext context;
  final double height;
  final double width;
  final double itemHeight;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      ignoring: true,
      child: Stack(
        children: [
          // Blue spline top
          CustomPaint(
            size: Size(width, height),
            painter: LinePainter(
              start: Offset(0, height * .5 - itemHeight * .5),
              end: Offset(220.w, height * .5 - itemHeight * .5),
              size: Size(1.sw, 2.h),
              width: 1.w,
              color: color,
            ),
          ),

          // Blue spline bottom
          CustomPaint(
            size: Size(width, height),
            painter: LinePainter(
              start: Offset(0, height * .5 + itemHeight * .5),
              end: Offset(220.w, height * .5 + itemHeight * .5),
              size: Size(1.sw, 2.h),
              width: 1.w,
              color: color,
            ),
          ),

          // Top spline
          CustomPaint(
            size: Size(width, height),
            painter: LinePainter(
              start: Offset(0, height * .5 - itemHeight * 1.5),
              end: Offset(176.w, height * .5 - itemHeight * 1.5),
              size: Size(1.sw, 2.h),
              width: 1.w,
              color: personalColorScheme.surfaceTint,
            ),
          ),

          // Bottom spline
          CustomPaint(
            size: Size(width, height),
            painter: LinePainter(
              start: Offset(0, height * .5 + itemHeight * 1.5),
              end: Offset(176.w, height * .5 + itemHeight * 1.5),
              size: Size(1.sw, 2.h),
              width: 1.w,
              color: personalColorScheme.surfaceTint,
            ),
          ),

          // Top angle spline
          CustomPaint(
            size: Size(width, height),
            painter: LinePainter(
              start: Offset(176.w, height * .5 - itemHeight * 1.5),
              end: Offset(
                1.sw,
                height * .5 -
                    itemHeight * 1.5 +
                    itemHeight * 2.5 * tan(pi / 6) -
                    4,
              ),
              size: Size(1.sw, 2.h),
              width: 1.w,
              color: personalColorScheme.surfaceTint,
            ),
          ),

          // Bottom angle spline
          CustomPaint(
            size: Size(width, height),
            painter: LinePainter(
              start: Offset(176.w, height * .5 + itemHeight * 1.5),
              end: Offset(
                1.sw,
                height * .5 +
                    itemHeight * 1.5 -
                    itemHeight * 2.5 * tan(pi / 6) -
                    4,
              ),
              size: Size(1.sw, 2.h),
              width: 1.w,
              color: personalColorScheme.surfaceTint,
            ),
          ),
        ],
      ),
    );
  }
}
