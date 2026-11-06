import 'dart:math' as math;

import 'package:flutter/cupertino.dart';

import '../../foundation/interaction/academy_interaction.dart';
import '../../foundation/motion/press_scale.dart';
import '../../theme/academy_theme.dart';
import '../icon/academy_sf_image.dart';
import '../navigation/chrome/academy_chrome.dart';

/// Round chrome counter (dhikr / tasbih): a progress ring around the current
/// count. The app owns the count, haptics and what happens on completion.
class AcademyCounterButton extends StatelessWidget {
  const AcademyCounterButton({
    super.key,
    required this.count,
    required this.total,
    required this.label,
    this.onPressed,
    this.onLongPress,
    this.size = 64,
    this.style,
    this.blurSigma,
  }) : assert(count >= 0),
       assert(total > 0),
       assert(size >= 44);
  final int count, total;

  /// Accessibility label of the action, e.g. «Счётчик».
  final String label;
  final VoidCallback? onPressed, onLongPress;
  final double size;
  final AcademyChromeStyle? style;
  final double? blurSigma;

  bool get completed => count >= total;

  @override
  Widget build(BuildContext context) {
    final theme = AcademyTheme.of(context);
    final accent = CupertinoTheme.of(context).primaryColor;
    final animate = !MediaQuery.disableAnimationsOf(context);
    final foreground = AcademyChrome.foregroundColor(
      context,
      completed ? accent : theme.colorScheme.onSurface,
      style: style,
      minimumContrast: 3,
    );
    return AcademyActionSemantics(
      label: label,
      value: '${math.min(count, total)} / $total',
      // A completed counter may only take a long press, which resets it.
      enabled: onPressed != null || onLongPress != null,
      child: PressScale(
        pressedScale: AcademyTheme.of(context).interaction.chromePressedScale,
        enabled: onPressed != null || onLongPress != null,
        onTap: onPressed,
        onLongPress: onLongPress,
        child: SizedBox.square(
          dimension: size,
          child: AcademyChrome(
            radius: size / 2,
            style: style,
            blurSigma: blurSigma,
            child: TweenAnimationBuilder<double>(
              tween: Tween(end: (count / total).clamp(0, 1).toDouble()),
              duration: animate ? AcademyTokens.motion : Duration.zero,
              builder: (context, value, child) => CustomPaint(
                painter: _CounterRing(
                  value,
                  accent,
                  theme.colorScheme.outlineVariant,
                ),
                child: child,
              ),
              child: ExcludeSemantics(
                child: Center(
                  child: AnimatedSwitcher(
                    duration: animate ? AcademyTokens.motion : Duration.zero,
                    child: completed
                        ? AcademySfIcon(
                            AcademyTheme.of(context).icons.checkmark,
                            key: const ValueKey('done'),
                            fontSize: size * .36,
                            fontWeight: FontWeight.w700,
                            color: foreground,
                          )
                        : _Count(
                            key: const ValueKey('count'),
                            count: count,
                            total: total,
                            size: size,
                            color: foreground,
                          ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Count extends StatelessWidget {
  const _Count({
    super.key,
    required this.count,
    required this.total,
    required this.size,
    required this.color,
  });
  final int count, total;
  final double size;
  final Color color;
  @override
  Widget build(BuildContext context) {
    final text = AcademyTheme.of(context).textTheme;
    return MediaQuery.withNoTextScaling(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '$count',
            style: text.titleMedium.copyWith(
              color: color,
              fontSize: size * .3,
              height: 1.05,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
          Text(
            '/ $total',
            style: text.caption.copyWith(
              color: color.withValues(alpha: .6),
              fontSize: size * .16,
              height: 1.1,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
        ],
      ),
    );
  }
}

class _CounterRing extends CustomPainter {
  _CounterRing(this.value, this.color, this.track);
  final double value;
  final Color color, track;
  @override
  void paint(Canvas canvas, Size size) {
    final rect = (Offset.zero & size).deflate(4);
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round
      ..color = track;
    canvas.drawOval(rect, paint);
    if (value <= 0) return;
    paint.color = color;
    canvas.drawArc(rect, -math.pi / 2, 2 * math.pi * value, false, paint);
  }

  @override
  bool shouldRepaint(_CounterRing old) =>
      old.value != value || old.color != color || old.track != track;
}
