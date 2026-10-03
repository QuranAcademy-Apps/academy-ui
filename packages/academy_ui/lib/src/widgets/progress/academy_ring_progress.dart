import '../../theme/academy_theme.dart';
import '../../foundation/localizations/academy_localizations.dart';

import 'dart:math' as math;

import 'package:flutter/cupertino.dart';

class AcademyRingProgress extends StatelessWidget {
  const AcademyRingProgress({super.key, required this.value});
  final double value;
  @override
  Widget build(BuildContext context) => Semantics(
    label: AcademyLocalizations.of(context).progress,
    value: '${(value.clamp(0, 1) * 100).round()}%',
    child: SizedBox.square(
      dimension: 36,
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0, end: value.clamp(0, 1)),
        duration: MediaQuery.disableAnimationsOf(context)
            ? Duration.zero
            : AcademyTokens.progressMotion,
        builder: (context, v, child) => CustomPaint(
          painter: _Ring(v, CupertinoTheme.of(context).primaryColor),
        ),
      ),
    ),
  );
}

class _Ring extends CustomPainter {
  _Ring(this.value, this.color);
  final double value;
  final Color color;
  @override
  void paint(Canvas canvas, Size size) {
    final rect = (Offset.zero & size).deflate(2);
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round
      ..color = color.withValues(alpha: .2);
    canvas.drawOval(rect, paint);
    paint.color = color;
    canvas.drawArc(rect, -math.pi / 2, 2 * math.pi * value, false, paint);
  }

  @override
  bool shouldRepaint(_Ring old) => old.value != value || old.color != color;
}
