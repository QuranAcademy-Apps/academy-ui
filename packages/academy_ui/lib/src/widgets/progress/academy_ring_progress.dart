import '../../theme/academy_theme.dart';
import '../../foundation/localizations/academy_localizations.dart';

import 'dart:math' as math;

import 'package:flutter/cupertino.dart';

class AcademyRingProgress extends StatelessWidget {
  /// A labelled 36 pt ring in the theme's primary color.
  const AcademyRingProgress({super.key, required this.value})
    : size = 36,
      color = null,
      _inset = 2,
      _trackOpacity = .2,
      _curve = Curves.linear,
      _labelled = true;

  /// A ring that fills the space given by its parent, drawn in [color]
  /// (the theme's primary color when null): 1.5 pt inset, 22% track, eased.
  const AcademyRingProgress.fill({super.key, required this.value, this.color})
    : size = null,
      _inset = 1.5,
      _trackOpacity = .22,
      _curve = Curves.easeOut,
      _labelled = false;

  final double value;
  final double? size;
  final Color? color;
  final double _inset, _trackOpacity;
  final Curve _curve;
  final bool _labelled;

  @override
  Widget build(BuildContext context) {
    final ring = TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: value.clamp(0, 1)),
      duration: MediaQuery.disableAnimationsOf(context)
          ? Duration.zero
          : AcademyTokens.progressMotion,
      curve: _curve,
      builder: (context, v, child) => CustomPaint(
        painter: _Ring(
          v,
          color ?? CupertinoTheme.of(context).primaryColor,
          _inset,
          _trackOpacity,
        ),
      ),
    );
    final sized = size == null
        ? ring
        : SizedBox.square(dimension: size, child: ring);
    if (!_labelled) return sized;
    return Semantics(
      label: AcademyLocalizations.of(context).progress,
      value: '${(value.clamp(0, 1) * 100).round()}%',
      child: sized,
    );
  }
}

class _Ring extends CustomPainter {
  _Ring(this.value, this.color, this.inset, this.trackOpacity);
  final double value, inset, trackOpacity;
  final Color color;
  @override
  void paint(Canvas canvas, Size size) {
    final rect = (Offset.zero & size).deflate(inset);
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round
      ..color = color.withValues(alpha: trackOpacity);
    canvas.drawOval(rect, paint);
    paint.color = color;
    canvas.drawArc(rect, -math.pi / 2, 2 * math.pi * value, false, paint);
  }

  @override
  bool shouldRepaint(_Ring old) =>
      old.value != value ||
      old.color != color ||
      old.inset != inset ||
      old.trackOpacity != trackOpacity;
}
