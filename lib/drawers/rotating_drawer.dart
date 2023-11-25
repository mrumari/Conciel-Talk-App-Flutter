import 'dart:math';
import 'package:concieltalk/config/app_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class RotatingDrawer extends StatefulWidget {
  final bool corner;
  final Widget drawer;

  const RotatingDrawer({Key? key, required this.drawer, required this.corner})
      : super(key: key);

  @override
  RotatingDrawerState createState() => RotatingDrawerState();
}

class RotatingDrawerState extends State<RotatingDrawer> {
  @override
  Widget build(BuildContext context) {
    return Transform.scale(
      scale: AppConfig.cubeRingScale,
      child: Transform.translate(
        offset: widget.corner
            ? Offset(-106.r, 0)
            : Offset(
                -192.r,
                18.h,
              ),
        child: widget.drawer,
      ),
    );
  }
}

class RotatingEndDrawer extends StatefulWidget {
  final Widget drawer;

  const RotatingEndDrawer({
    Key? key,
    required this.drawer,
  }) : super(key: key);

  @override
  RotatingEndDrawerState createState() => RotatingEndDrawerState();
}

class RotatingEndDrawerState extends State<RotatingEndDrawer> {
  @override
  Widget build(BuildContext context) {
    return Transform.scale(
      scale: AppConfig.cubeRingScale,
      child: Transform.translate(
        offset: Offset(200.r, 0),
        child: Container(
          color: Colors.transparent,
          height: 300.r,
          width: 300.r,
          child: widget.drawer,
        ),
      ),
    );
  }
}

double angleBetweenPoints(Offset center, Offset p1, Offset p2) {
  final double v1x = p1.dx - center.dx;
  final double v1y = p1.dy - center.dy;
  final double v2x = p2.dx - center.dx;
  final double v2y = p2.dy - center.dy;
  return atan2(v2y, v2x) - atan2(v1y, v1x);
}

class HexAvatarImage extends StatelessWidget {
  final ImageProvider image;
  final double size;

  const HexAvatarImage({
    super.key,
    required this.image,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      clipBehavior: Clip.hardEdge,
      decoration: const ShapeDecoration(shape: CircleBorder()),
      child: Image(
        image: image,
        fit: BoxFit.cover,
      ),
    );
  }
}

class HexAvatarLetters extends StatelessWidget {
  final String name;
  final double size;

  const HexAvatarLetters({
    super.key,
    required this.name,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    final fbLetters = name.length > 1
        ? name.substring(0, 1).toUpperCase() +
            name.substring(1, 2).toUpperCase() +
            (name.length > 2 ? name.substring(2, 3).toLowerCase() : '')
        : name.substring(0, 1).toUpperCase();

    return Container(
      alignment: Alignment.center,
      width: size,
      height: size,
      clipBehavior: Clip.hardEdge,
      decoration: const ShapeDecoration(
        color: Colors.blueGrey,
        shape: CircleBorder(),
      ),
      child: Text(
        fbLetters,
        style: const TextStyle(color: Colors.white, fontSize: 16),
      ),
    );
  }
}
