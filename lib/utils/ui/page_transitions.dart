import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter_screenutil/flutter_screenutil.dart';

class CustomTransitionBuilder extends PageTransitionsBuilder {
  const CustomTransitionBuilder();
  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    // ignore: unused_local_variable
    final tween =
        Tween(begin: 1.5, end: 1.0).chain(CurveTween(curve: Curves.ease));
    return FadeTransition(opacity: animation, child: child);
  }
}

class SlideFadeTransition extends PageTransitionsBuilder {
  const SlideFadeTransition();

  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    // Slide animation
    const begin = Offset(0.0, 0.0);
    const end = Offset(0.5, 0.0);
    const curve = Curves.easeOut;
    final tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
    final slideAnimation = animation.drive(tween);

    // Fade animation
    final fadeAnimation = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: animation,
        curve: const Interval(0.714, 1.0),
      ),
    );

    return SlideTransition(
      position: slideAnimation,
      child: FadeTransition(
        opacity: fadeAnimation,
        child: child,
      ),
    );
  }
}

Future<ui.Image> resizeImage(ui.Image image, double scale) async {
  final completer = Completer<ui.Image>();
  final width = (image.width * scale).round();
  final height = (image.height * scale).round();
  final pictureRecorder = ui.PictureRecorder();
  final canvas = Canvas(pictureRecorder);
  final paint = Paint()..isAntiAlias = false;
  canvas.drawImageRect(
    image,
    Rect.fromLTRB(0, 0, image.width.toDouble(), image.height.toDouble()),
    Rect.fromLTRB(0, 0, width.toDouble(), height.toDouble()),
    paint,
  );
  final picture = pictureRecorder.endRecording();
  picture.toImage(width, height).then((image) => completer.complete(image));
  return completer.future;
}

cubeFace(
  double angle,
  IconData asset,
  Color iconColor,
  Color borderColor,
  Color color, [
  GlobalKey? globalKey,
]) {
  return asset == Icons.check_box_outline_blank
      ? Container(
          foregroundDecoration: BoxDecoration(
            border: Border.symmetric(
              vertical: BorderSide(color: borderColor),
              horizontal: BorderSide(color: borderColor),
            ),
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: color,
            border: Border.symmetric(
              vertical: BorderSide(color: borderColor),
              horizontal: BorderSide(color: borderColor),
            ),
          ),
        )
      : Stack(
          alignment: Alignment.center,
          children: [
            Container(
              foregroundDecoration: BoxDecoration(
                border: Border.symmetric(
                  vertical: BorderSide(color: borderColor),
                  horizontal: BorderSide(color: borderColor),
                ),
              ),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: color,
                border: Border.symmetric(
                  vertical: BorderSide(color: borderColor),
                  horizontal: BorderSide(color: borderColor),
                ),
              ),
            ),
            Transform.rotate(
              angle: angle,
              child: Icon(
                asset,
                color: iconColor,
                size: (asset.fontFamily == 'MaterialIcons') ? 40.sp : 36.sp,
                key: globalKey,
              ),
            ),
          ],
        );
}

animatedCubeFace(
  double angle,
  IconData asset,
  Color iconColor,
  Color borderColor,
  Color color,
  AnimationController controller, [
  GlobalKey? globalKey,
]) {
  // Create an Animation that cycles the opacity from 0.5 to 1.0
  final Animation<double> animation = Tween<double>(
    begin: 1.0,
    end: 0.5,
  ).animate(controller);

  return asset == Icons.check_box_outline_blank
      ? Container(
          foregroundDecoration: BoxDecoration(
            border: Border.symmetric(
              vertical: BorderSide(color: borderColor),
              horizontal: BorderSide(color: borderColor),
            ),
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: color,
            border: Border.symmetric(
              vertical: BorderSide(color: borderColor),
              horizontal: BorderSide(color: borderColor),
            ),
          ),
        )
      : Stack(
          alignment: Alignment.center,
          children: [
            Container(
              foregroundDecoration: BoxDecoration(
                border: Border.symmetric(
                  vertical: BorderSide(color: borderColor),
                  horizontal: BorderSide(color: borderColor),
                ),
              ),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: color,
                border: Border.symmetric(
                  vertical: BorderSide(color: borderColor),
                  horizontal: BorderSide(color: borderColor),
                ),
              ),
            ),
            Transform.rotate(
              angle: angle,
              child:
                  // Use AnimatedBuilder to rebuild the Icon whenever the animation value changes
                  AnimatedBuilder(
                animation: animation,
                builder: (context, child) {
                  return Icon(
                    asset,
                    // Update the color of the Icon based on the current animation value
                    color: iconColor.withOpacity(animation.value),
                    size: 36.sp, key: globalKey,
                  );
                },
              ),
            ),
          ],
        );
}

List initCube(vsync, duration) {
  final cubeAnim = AnimationController(
    vsync: vsync,
    duration: Duration(milliseconds: duration),
  );
  final xCurve = CurvedAnimation(parent: cubeAnim, curve: Curves.fastOutSlowIn);
  final yCurve = CurvedAnimation(parent: cubeAnim, curve: Curves.fastOutSlowIn);
  cubeAnim.addStatusListener((status) {
    if (status == AnimationStatus.completed) {
//        _cubeAnimCtl.reverse();
    } else if (status == AnimationStatus.dismissed) {
//        _cubeAnimCtl.forward();
    }
  });

  return [cubeAnim, xCurve, yCurve];
}
