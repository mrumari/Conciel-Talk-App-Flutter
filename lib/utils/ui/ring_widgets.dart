import 'dart:math';

import 'package:concieltalk/config/app_config.dart';
import 'package:concieltalk/config/color_constants.dart';
import 'package:concieltalk/widgets/base_ring_state.dart';
import 'package:concieltalk/utils/ui/conciel_ring.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class InnerRing extends StatelessWidget {
  final double ringSize;
  final Color trackColor;
  final Color progressColor;
  final bool animation;

  const InnerRing({
    super.key,
    required this.trackColor,
    required this.progressColor,
    required this.animation,
    required this.ringSize,
  });

  @override
  Widget build(BuildContext context) {
    return ConcielRingDraw(
      height: ringSize,
      width: ringSize,
      progress: 0,
      barWidth: 2,
      startAngle: 1,
      sweepAngle: 360,
      strokeCap: StrokeCap.butt,
      trackColor: trackColor,
      progressColor: progressColor,
      dashWidth: 119,
      dashGap: 0,
      animDurationMillis: 1000,
      animation: animation,
      interactive: false,
    );
  }
}

class PrimaryDividers extends StatelessWidget {
  final double ringSize;
  final Color trackColor;
  final Color progressColor;
  final bool animation;

  const PrimaryDividers({
    super.key,
    required this.trackColor,
    required this.progressColor,
    required this.animation,
    required this.ringSize,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ConcielRingDraw(
          height: ringSize,
          width: ringSize,
          progress: 0,
          barWidth: 45.r,
          startAngle: -0.3,
          sweepAngle: 1,
          strokeCap: StrokeCap.butt,
          trackColor: trackColor,
          progressColor: progressColor,
          dashWidth: 1,
          dashGap: 120,
          animDurationMillis: 1000,
          animation: animation,
          interactive: false,
        ),
        ConcielRingDraw(
          height: ringSize,
          width: ringSize,
          progress: 0,
          barWidth: 45.r,
          startAngle: 120,
          sweepAngle: 1,
          strokeCap: StrokeCap.butt,
          trackColor: trackColor,
          progressColor: progressColor,
          dashWidth: 1,
          dashGap: 120,
          animDurationMillis: 1000,
          animation: animation,
          interactive: false,
        ),
        ConcielRingDraw(
          height: ringSize,
          width: ringSize,
          progress: 0,
          barWidth: 45.r,
          startAngle: 240,
          sweepAngle: 1,
          strokeCap: StrokeCap.butt,
          trackColor: trackColor,
          progressColor: progressColor,
          dashWidth: 1,
          dashGap: 120,
          animDurationMillis: 1000,
          animation: animation,
          interactive: false,
        ),
      ],
    );
  }
}

class RingDrawAnimate extends StatelessWidget {
  final double width;
  final double height;
  final double progress;
  final Color trackColor;
  final Color progressColor;
  final bool animation;
  final VoidCallback onEnd;

  const RingDrawAnimate({
    super.key,
    required this.progress,
    required this.trackColor,
    required this.progressColor,
    required this.animation,
    required this.onEnd,
    required this.width,
    required this.height,
  });
  @override
  Widget build(BuildContext context) {
    return ConcielRingDraw(
      width: width,
      height: height,
      progress: progress,
      barWidth: 30.r,
      startAngle: 0,
      sweepAngle: 360,
      strokeCap: StrokeCap.butt,
      trackColor: trackColor,
      progressColor: progressColor,
      dashWidth: 0.5,
      dashGap: 1,
      animDurationMillis: 860,
      animation: animation,
      onEnd: onEnd,
      interactive: false,
    );
  }
}

class RingWidget extends StatefulWidget {
  final Color trackColor;
  final Color innerRingColor;
  final bool animateNow;

  const RingWidget({
    required Key key,
    required this.trackColor,
    required this.innerRingColor,
    required this.animateNow,
  }) : super(key: key);

  @override
  BaseRingState createState() => RingWidgetState();
}

class RingWidgetState extends BaseRingState
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;
  ColorTween? _outerRingTween;
  // ignore: unused_field
  ColorTween? _innerRingTween;
  double _barProgress = 100;
  //personalColorScheme.surfaceTint.withOpacity(0.1);
  //personalColorScheme.primary.withOpacity(0.3);

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 860),
    );
    _animation = TweenSequence(
      <TweenSequenceItem<double>>[
        TweenSequenceItem<double>(
          tween: Tween<double>(begin: 0.0, end: 1.0)
              .chain(CurveTween(curve: Curves.easeIn)),
          weight: 40.0,
        ),
        TweenSequenceItem<double>(
          tween: Tween<double>(begin: 1.0, end: 0.0)
              .chain(CurveTween(curve: Curves.easeOut)),
          weight: 60.0,
        ),
      ],
    ).animate(_controller);
    _innerRingTween = ColorTween(
      begin: (widget as RingWidget).innerRingColor.withOpacity(0),
      end: (widget as RingWidget).innerRingColor.withOpacity(1.0),
    );
    _outerRingTween = ColorTween(
      begin: (widget as RingWidget).trackColor,
      end: (widget as RingWidget).innerRingColor.withOpacity(1.0),
    );
    _animation.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  void animateColors() {
    _controller.forward();
    Future.delayed(const Duration(milliseconds: 860), () {
      if (mounted) {
        _controller.reset();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    late final Color innerRingColor = (widget as RingWidget).innerRingColor;
    late final Color trackColor = (widget as RingWidget).trackColor;
    return SizedBox(
      width: 1.sw,
      height: 1.sh,
      child: Stack(
        alignment: AlignmentDirectional.center,
        children: <Widget>[
          InnerRing(
            ringSize: 240.r,
            trackColor: innerRingColor,
            progressColor: _outerRingTween!.evaluate(_animation) ?? trackColor,
            animation: (widget as RingWidget).animateNow,
          ),
          PrimaryDividers(
            ringSize: 236.8.r,
            trackColor: innerRingColor,
            progressColor: _outerRingTween!.evaluate(_animation) ?? trackColor,
            animation: (widget as RingWidget).animateNow,
          ),
          RingDrawAnimate(
            width: 300.8.r,
            height: 300.8.r,
            progress: _barProgress,
            trackColor: _outerRingTween!.evaluate(_animation) ?? trackColor,
            progressColor: _outerRingTween!.evaluate(_animation) ?? trackColor,
            animation: (widget as RingWidget).animateNow,
            onEnd: () {
              setState(() {
                if ((widget as RingWidget).animateNow) {
                  _barProgress = 100;
                } else {
                  _barProgress = 0;
                }
              });
            },
          ),
        ],
      ),
    );
  }
}

Widget wwwRings(
  int level,
  BuildContext context,
  Color progressColor,
  Color trackColor,
  List<double> segment,
  int i, [
  double? sweep,
]) {
  final double width = level == 1 ? 245.w : 175.w * level * .7;
  final double innerwidth = level == 1 ? 170.w : 175.w * level * .8;
  final index = i == 99 ? 0 : i;
  final progress = segment;
  final angle = sweep ?? 60;
  if (i == 99) {
    reset(progress, 0);
  }
  return Stack(
    alignment: Alignment.center,
    children: [
      // Inner ring - not segmented yet
      ConcielRingDraw(
        height: innerwidth,
        width: innerwidth,
        progress: 0,
        barWidth: 4.w,
        startAngle: index * angle,
        sweepAngle: 360,
        strokeCap: StrokeCap.butt,
        trackColor: trackColor,
        progressColor: progressColor,
        dashWidth: 60.w,
        dashGap: 0,
        animDurationMillis: 1000,
        animation: true,
        interactive: false,
      ),
      // outer segment lines
      for (var index = 0; index < progress.length; index++)
        ConcielRingDraw(
          height: width,
          width: width,
          progress: progress[index],
          barWidth: 35.w,
          startAngle: index * angle - 0.25,
          sweepAngle: 0.25,
          strokeCap: StrokeCap.butt,
          trackColor: personalColorScheme.outline.withOpacity(0.5),
          progressColor: progressColor,
          animDurationMillis: 1000,
          animation: false,
          interactive: false,
        ),
      //outer segment pieces
      for (var index = 0; index < progress.length; index++)
        ConcielRingDraw(
          height: width,
          width: width,
          progress: progress[index],
          barWidth: 35.w,
          startAngle: index * angle,
          sweepAngle: angle - 0.25,
          strokeCap: StrokeCap.butt,
          trackColor: personalColorScheme.surfaceTint.withOpacity(0.5),
          progressColor: progressColor,
          dashWidth: 120,
          dashGap: 0,
          animDurationMillis: 1000,
          animation: false,
          interactive: false,
        ),
    ],
  );
}

double stringToArc(String string, [double maxArc = 55.0]) {
  // Ensure the string is within the valid length range
  if (string.length < 3 || string.length > 10) {
    throw ArgumentError("String must be between 2 and 10 characters in length");
  }

  // Calculate the arc length based on the string length
  final double arcLength = log(string.length - 1) * (maxArc / log(9));

  return arcLength;
}
