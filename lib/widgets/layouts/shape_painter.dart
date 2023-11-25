import 'package:flutter/material.dart';

class InnerButtonTop extends CustomPainter {
  Path path = Path();

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = Colors.green.withOpacity(0.2)
      ..strokeWidth = 0.0;

    path.lineTo(size.width * 0.98, size.height * 0.46);
    path.cubicTo(
      size.width * 0.98,
      size.height * 0.46,
      size.width * 0.55,
      size.height * 0.02,
      size.width * 0.55,
      size.height * 0.02,
    );
    path.cubicTo(
      size.width * 0.54,
      size.height * 0.01,
      size.width * 0.52,
      size.height * 0.01,
      size.width * 0.51,
      size.height * 0.01,
    );
    path.cubicTo(
      size.width / 2,
      size.height * 0.01,
      size.width * 0.48,
      size.height * 0.01,
      size.width * 0.47,
      size.height * 0.02,
    );
    path.cubicTo(
      size.width * 0.47,
      size.height * 0.02,
      size.width * 0.04,
      size.height * 0.46,
      size.width * 0.04,
      size.height * 0.46,
    );
    path.cubicTo(
      size.width * 0.02,
      size.height * 0.47,
      size.width * 0.02,
      size.height * 0.49,
      size.width * 0.01,
      size.height * 0.51,
    );
    path.cubicTo(
      size.width * 0.01,
      size.height * 0.51,
      size.width * 0.51,
      size.height,
      size.width * 0.51,
      size.height,
    );
    path.cubicTo(
      size.width * 0.51,
      size.height,
      size.width * 0.8,
      size.height * 0.72,
      size.width * 0.8,
      size.height * 0.72,
    );
    path.cubicTo(
      size.width * 0.8,
      size.height * 0.72,
      size.width,
      size.height * 0.51,
      size.width,
      size.height * 0.51,
    );
    path.cubicTo(
      size.width,
      size.height * 0.49,
      size.width,
      size.height * 0.47,
      size.width * 0.98,
      size.height * 0.46,
    );
    path.cubicTo(
      size.width * 0.98,
      size.height * 0.46,
      size.width * 0.98,
      size.height * 0.46,
      size.width * 0.98,
      size.height * 0.46,
    );
    path.cubicTo(
      size.width * 0.98,
      size.height * 0.46,
      size.width * 0.98,
      size.height * 0.46,
      size.width * 0.98,
      size.height * 0.46,
    );

    canvas.drawPath(path, paint);
  }

  @override
  bool hitTest(Offset position) {
    return path.contains(position);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}

class InnerButtonLeft extends CustomPainter {
  Path path = Path();

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = Colors.red.withOpacity(0.2)
      ..strokeWidth = 0.0;

    path.lineTo(size.width * 0.03, size.height * 0.01);
    path.cubicTo(
      size.width * 0.02,
      size.height * 0.02,
      size.width * 0.01,
      size.height * 0.04,
      size.width * 0.01,
      size.height * 0.05,
    );
    path.cubicTo(
      size.width * 0.01,
      size.height * 0.05,
      size.width * 0.01,
      size.height * 0.64,
      size.width * 0.01,
      size.height * 0.64,
    );
    path.cubicTo(
      size.width * 0.01,
      size.height * 0.65,
      size.width * 0.02,
      size.height * 0.67,
      size.width * 0.03,
      size.height * 0.68,
    );
    path.cubicTo(
      size.width * 0.04,
      size.height * 0.69,
      size.width * 0.06,
      size.height * 0.7,
      size.width * 0.08,
      size.height * 0.71,
    );
    path.cubicTo(
      size.width * 0.08,
      size.height * 0.71,
      size.width * 0.93,
      size.height,
      size.width * 0.93,
      size.height,
    );
    path.cubicTo(
      size.width * 0.96,
      size.height,
      size.width * 0.98,
      size.height,
      size.width,
      size.height,
    );
    path.cubicTo(
      size.width,
      size.height,
      size.width,
      size.height * 0.35,
      size.width,
      size.height * 0.35,
    );
    path.cubicTo(
      size.width,
      size.height * 0.35,
      size.width * 0.03,
      size.height * 0.01,
      size.width * 0.03,
      size.height * 0.01,
    );
    path.cubicTo(
      size.width * 0.03,
      size.height * 0.01,
      size.width * 0.03,
      size.height * 0.01,
      size.width * 0.03,
      size.height * 0.01,
    );

    canvas.drawPath(path, paint);
  }

  @override
  bool hitTest(Offset position) {
    return path.contains(position);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}

class InnerButtonRight extends CustomPainter {
  Path path = Path();

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = Colors.blue.withOpacity(0.2)
      ..strokeWidth = 0.0;

    path.lineTo(size.width, size.height * 0.01);
    path.cubicTo(
      size.width,
      size.height * 0.01,
      size.width * 0.02,
      size.height * 0.35,
      size.width * 0.02,
      size.height * 0.35,
    );
    path.cubicTo(
      size.width * 0.02,
      size.height * 0.35,
      size.width * 0.02,
      size.height,
      size.width * 0.02,
      size.height,
    );
    path.cubicTo(
      size.width * 0.04,
      size.height,
      size.width * 0.07,
      size.height,
      size.width * 0.09,
      size.height,
    );
    path.cubicTo(
      size.width * 0.09,
      size.height,
      size.width * 0.94,
      size.height * 0.71,
      size.width * 0.94,
      size.height * 0.71,
    );
    path.cubicTo(
      size.width * 0.97,
      size.height * 0.7,
      size.width * 0.98,
      size.height * 0.69,
      size.width,
      size.height * 0.68,
    );
    path.cubicTo(
      size.width,
      size.height * 0.67,
      size.width * 1.02,
      size.height * 0.65,
      size.width * 1.02,
      size.height * 0.64,
    );
    path.cubicTo(
      size.width * 1.02,
      size.height * 0.64,
      size.width * 1.02,
      size.height * 0.06,
      size.width * 1.02,
      size.height * 0.06,
    );
    path.cubicTo(
      size.width * 1.02,
      size.height * 0.04,
      size.width,
      size.height * 0.03,
      size.width,
      size.height * 0.01,
    );
    path.cubicTo(
      size.width,
      size.height * 0.01,
      size.width,
      size.height * 0.01,
      size.width,
      size.height * 0.01,
    );

    canvas.drawPath(path, paint);
  }

  @override
  bool hitTest(Offset position) {
    return path.contains(position);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
