import 'dart:math';

import 'package:concieltalk/config/color_constants.dart';
import 'package:concieltalk/widgets/layouts/shape_painter.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_arc_text/flutter_arc_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CubeOutline extends StatelessWidget {
  final double size;
  const CubeOutline({
    super.key,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}

class WhenArcText extends StatelessWidget {
  final String text;
  final double radius;
  final double start;
  final double stretch;

  const WhenArcText({
    super.key,
    required this.text,
    required this.start,
    required this.stretch,
    required this.radius,
  });

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: ArcText(
        placement: Placement.middle,
        radius: radius,
        stretchAngle: pi / stretch,
        startAngle: -pi / start,
        text: text,
        textStyle: TextStyle(
          letterSpacing: 2,
          fontSize: 18,
          color: personalColorScheme.outline,
        ),
      ),
    );
  }
}

class ConcielArcText extends StatelessWidget {
  final String text;
  final double start;
  final double sweep;
  final double radius;
  final Color color;
  final double fontSize;

  const ConcielArcText({
    super.key,
    required this.text,
    required this.start,
    required this.sweep,
    required this.radius,
    required this.color,
    required this.fontSize,
  });

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      ignoring: true,
      child: ArcText(
        placement: Placement.middle,
        direction: start > 240 && start < 450
            ? Direction.clockwise
            : start == 0
                ? Direction.clockwise
                : Direction.counterClockwise,
        radius: radius,
        startAngleAlignment: StartAngleAlignment.center,
        startAngle: start * pi / 180,
        interLetterAngle: sweep / 60 * pi / 180,
        text: text,
        textStyle:
            TextStyle(letterSpacing: 0, fontSize: fontSize, color: color),
      ),
    );
  }
}

class WWWArcText extends StatelessWidget {
  final String text;
  final double radius;
  final double start;
  final double stretch;
  final double fontSize;

  const WWWArcText({
    super.key,
    required this.text,
    required this.start,
    required this.stretch,
    required this.radius,
    required this.fontSize,
  });

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: ArcText(
        direction: start > 90 || start < 270
            ? Direction.counterClockwise
            : Direction.clockwise,
        placement: Placement.middle,
        radius: radius,
        stretchAngle: stretch * pi / 180,
        startAngle: start * pi / 180,
        text: text,
        textStyle: TextStyle(
          fontSize: fontSize,
          color: personalColorScheme.outline,
        ),
      ),
    );
  }
}

class TopCubeButton extends StatelessWidget {
  final VoidCallback onTap;
  final Function(DragUpdateDetails)? onPanUpdate;
  final VoidCallback? onLongPress;
  final String assetName;
  final String buttonLabel;

  const TopCubeButton({
    super.key,
    required this.onTap,
    required this.assetName,
    required this.buttonLabel,
    this.onPanUpdate,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
//      top: 0,
      //    left: 3,
      height: 74.h,
      width: 122.2.w,
      child: Stack(
        children: [
          GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: onTap,
            onPanUpdate: onPanUpdate,
            onLongPress: onLongPress,
            child: CustomPaint(
              painter: InnerButtonTop(),
              child: Container(),
            ),
          ),
          Center(
            child: IgnorePointer(ignoring: true, child: Container()),
          ),
        ],
      ),
    );
  }
}

class LeftCubeButton extends StatelessWidget {
  final VoidCallback onTap;
  final Function(DragUpdateDetails)? onHorizontalDragUpdate;
  final Function(DragUpdateDetails)? onVerticalDragUpdate;
  final VoidCallback? onLongPress;
  final String assetName;
  final String buttonLabel;

  const LeftCubeButton({
    super.key,
    required this.onTap,
    required this.assetName,
    required this.buttonLabel,
    this.onHorizontalDragUpdate,
    this.onVerticalDragUpdate,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 36.8.h,
      left: 3,
      height: 104.h,
      width: 61.4.w,
      child: Stack(
        children: [
          GestureDetector(
            onTap: onTap,
            onHorizontalDragUpdate: onHorizontalDragUpdate,
            onVerticalDragUpdate: onVerticalDragUpdate,
            onLongPress: onLongPress,
            child: CustomPaint(
              painter: InnerButtonLeft(),
              child: Container(),
            ),
          ),
          Center(
            child: IgnorePointer(
              ignoring: true,
              child: Container(),
            ),
          ),
        ],
      ),
    );
  }
}

class RightCubeButton extends StatelessWidget {
  final VoidCallback onTap;
  final Function(DragUpdateDetails)? onHorizontalDragUpdate;
  final Function(DragUpdateDetails)? onVerticalDragUpdate;
  final VoidCallback? onLongPress;
  final String assetName;
  final String buttonLabel;

  const RightCubeButton({
    super.key,
    required this.onTap,
    required this.assetName,
    required this.buttonLabel,
    this.onHorizontalDragUpdate,
    this.onVerticalDragUpdate,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 36.8.h,
      left: 62.528.w,
      height: 104.h,
      width: 62.528.w,
      child: Stack(
        children: [
          GestureDetector(
            onTap: onTap,
            onHorizontalDragUpdate: onHorizontalDragUpdate,
            onVerticalDragUpdate: onVerticalDragUpdate,
            onLongPress: onLongPress,
            child: CustomPaint(
              painter: InnerButtonRight(),
              child: Container(),
            ),
          ),
          Center(
            child: IgnorePointer(ignoring: true, child: Container()),
          ),
        ],
      ),
    );
  }
}

class ArcButton extends SingleChildRenderObjectWidget {
  final double startAngle;
  final double sweepAngle;
  final double radius;
  final double strokeWidth;
  final VoidCallback? onTap;
  final GestureDragUpdateCallback? onPanUpdate;

  const ArcButton({
    Key? key,
    required this.startAngle,
    required this.sweepAngle,
    required this.radius,
    required this.strokeWidth,
    required Widget child,
    this.onTap,
    this.onPanUpdate,
  }) : super(key: key, child: child);

  @override
  RenderObject createRenderObject(BuildContext context) {
    return ArcHitTestRenderBox(
      startAngle: startAngle * (pi / 180),
      sweepAngle: sweepAngle * (pi / 180),
      radius: radius,
      strokeWidth: strokeWidth,
      onTap: onTap,
      onPanUpdate: onPanUpdate,
    );
  }

  @override
  void updateRenderObject(
    BuildContext context,
    ArcHitTestRenderBox renderObject,
  ) {
    renderObject
      ..startAngle = startAngle * (pi / 180)
      ..sweepAngle = sweepAngle * (pi / 180)
      ..radius = radius
      ..strokeWidth = strokeWidth
      ..onTap = onTap
      ..onPanUpdate = onPanUpdate;
  }
}

class ArcHitTestRenderBox extends RenderProxyBox {
  double startAngle;
  double sweepAngle;
  double radius;
  double strokeWidth;
  VoidCallback? onTap;
  GestureDragUpdateCallback? onPanUpdate;

  ArcHitTestRenderBox({
    required this.startAngle,
    required this.sweepAngle,
    required this.radius,
    required this.strokeWidth,
    required this.onTap,
    required this.onPanUpdate,
  });

  @override
  bool hitTest(BoxHitTestResult result, {required Offset position}) {
    final center = Offset(size.width / 2, size.height / 2);
    final distance = (position - center).distance;
    if (distance >= radius - strokeWidth / 2 &&
        distance <= radius + strokeWidth / 2) {
      var angle =
          atan2(position.dy - center.dy, position.dx - center.dx) - pi / 2;
      if (angle < 0) angle += 2 * pi;
      if (angle >= startAngle && angle <= startAngle + sweepAngle) {
        return result.addWithRawTransform(
          transform: Matrix4.identity(),
          position: position,
          hitTest: (BoxHitTestResult result, Offset position) {
            if (result.path
                .any((entry) => entry.target is RenderPointerListener)) {
              return false;
            }
            onTap?.call();
            return false;
          },
        );
      }
    }
    return super.hitTest(result, position: position);
  }
}

class ArcPainter extends CustomPainter {
  final double startAngle;
  final double sweepAngle;
  final double radius;
  final bool left;
  final Color color;
  final Color borderColor;
  final Color splineColor;
  final Color iconColor;
  final double width;
  final double iconSize;
  final IconData icon;

  ArcPainter({
    required this.startAngle,
    required this.sweepAngle,
    required this.radius,
    required this.left,
    required this.color,
    required this.borderColor,
    required this.splineColor,
    required this.iconColor,
    required this.width,
    required this.icon,
    required this.iconSize,
  });

  Size _canvasSize = Size.zero;

  @override
  paint(Canvas canvas, Size size) {
    _canvasSize = size;
    final center = Offset(size.width / 2, size.height / 2);
    // final rect = Rect.fromCircle(center: center, radius: radius);
    final arcPaintrect = Rect.fromCircle(center: center, radius: radius - 16.r);

    final borderRect = Rect.fromCircle(center: center, radius: radius + 24.r);
    // Create a Paint object for the border
    final borderPaint = Paint()
      ..color = borderColor // Set the border color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4;

    // Create a Paint object for the splines
    final splinePaint = Paint()
      ..color = splineColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    // Create a Paint object for the arc
    final arcPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = width;

    final correctAngle = startAngle;
    final startRadians = correctAngle * (pi / 180);
    final sweepRadians = sweepAngle * (pi / 180);
    final p2 = Offset(
      center.dx + cos(startRadians + sweepRadians) * (radius + 24.r),
      center.dy + sin(startRadians + sweepRadians) * (radius + 24.r),
    );

    // Draw the border
    canvas.drawArc(
      borderRect,
      startRadians,
      sweepRadians,
      false,
      borderPaint,
    );

    // Draw the splines
    canvas.drawLine(center, p2, splinePaint);

    // Draw the arc
    canvas.drawArc(
      arcPaintrect,
      startRadians,
      sweepRadians,
      false,
      arcPaint,
    );

    // Calculate icon position
    final midAngle = (correctAngle + sweepAngle / 2) * (pi / 180);
    final iconX = center.dx + cos(midAngle) * (radius - 22.r);
    final iconY = center.dy + sin(midAngle) * (radius - 22.r);
    final iconCenter = Offset(iconX, iconY);

    // Draw icon
    final TextPainter textPainter =
        TextPainter(textDirection: TextDirection.rtl);
    textPainter.text = TextSpan(
      text: String.fromCharCode(icon.codePoint),
      style: TextStyle(
        fontFamily: icon.fontFamily,
        fontSize: iconSize,
        color: iconColor,
      ),
    );
    textPainter.layout();
    canvas.translate(iconCenter.dx, iconCenter.dy);
    canvas.rotate(30 * pi / 180);
    canvas.translate(-iconCenter.dx, -iconCenter.dy);
/*    textPainter.paint(canvas, iconCenter);*/

    final double rotationAngle = ((startAngle + (left ? 0 : 180)) / 180) * pi;
    canvas.save();
    canvas.translate(iconCenter.dx, iconCenter.dy);
    canvas.rotate(rotationAngle);
    textPainter.paint(
      canvas,
      -Offset(
        left ? textPainter.width - 20 : textPainter.width - 5,
        textPainter.height / 2,
      ),
    );
    canvas.restore();
  }

  @override
  bool hitTest(Offset position) {
    // Convert position to polar coordinates
    final center = Offset(_canvasSize.width / 2, _canvasSize.height / 2);
    final dx = position.dx - center.dx;
    final dy = position.dy - center.dy;
    final r = sqrt(dx * dx + dy * dy) * .6;

    // Calculate angle using vector math
    var theta = atan2(dy, dx);
    theta =
        (theta < 0) ? theta + 2 * pi : theta; // ensure theta is always positive

    // Convert start and end angles to radians
    final startRadians = startAngle * (pi / 180);
    final endRadians = (startAngle + sweepAngle) * (pi / 180);

    // Check if position is within the painted arc
    if (r <= radius && theta >= startRadians && theta <= endRadians) {
      return true;
    }

    return false;
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

final arcRadius = 64.r;
final arcWidth = 80.r;

class RingButton extends StatelessWidget {
  final ArcPainter painter;
  final VoidCallback? onTap;
  final double size;

  const RingButton({
    Key? key,
    required this.painter,
    required this.onTap,
    required this.size,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (details) {
        if (painter.hitTest(details.localPosition)) {
          if (onTap != null) {
            onTap!();
          }
        }
      },
      child: CustomPaint(
        painter: painter,
        size: Size(size, size),
      ),
    );
  }
}
