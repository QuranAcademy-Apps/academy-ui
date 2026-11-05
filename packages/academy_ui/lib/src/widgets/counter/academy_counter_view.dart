import 'dart:math' as math;

import 'package:flutter/cupertino.dart';

import '../../foundation/interaction/academy_interaction.dart';
import '../../theme/academy_theme.dart';
import '../icon/academy_sf_image.dart';

/// Full-area tasbih counter: the whole surface is the tap target, a large
/// ring shows progress. For long counts (33, 100 …) where a small button is
/// tiring. The app owns the count, haptics and completion.
class AcademyCounterView extends StatelessWidget {
  const AcademyCounterView({
    super.key,
    required this.count,
    required this.total,
    required this.label,
    required this.onPressed,
    this.onLongPress,
    this.hint,
  }) : assert(total > 0);

  final int count, total;
  final String label;

  /// Small text under the ring, e.g. «Нажимайте в любом месте».
  final String? hint;
  final VoidCallback? onPressed, onLongPress;

  @override
  Widget build(BuildContext context) {
    final theme = AcademyTheme.of(context);
    final accent = CupertinoTheme.of(context).primaryColor;
    final completed = count >= total;
    final animate = !MediaQuery.disableAnimationsOf(context);
    return AcademyActionSemantics(
      label: label,
      value: '${math.min(count, total)} / $total',
      enabled: onPressed != null,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onPressed,
        onLongPress: onLongPress,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final size = math.min(
              280.0,
              math.min(constraints.maxWidth, constraints.maxHeight) * .7,
            );
            return Center(
              child: ExcludeSemantics(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox.square(
                      dimension: size,
                      child: TweenAnimationBuilder<double>(
                        tween: Tween(end: (count / total).clamp(0, 1)),
                        duration: animate
                            ? AcademyTokens.motion
                            : Duration.zero,
                        builder: (context, value, child) => CustomPaint(
                          painter: _BigRing(
                            value,
                            accent,
                            theme.colorScheme.surfaceContainerHighest,
                          ),
                          child: child,
                        ),
                        child: Center(
                          child: completed
                              ? AcademySfIcon(
                                  AcademyTheme.of(context).icons.checkmark,
                                  size: size * .3,
                                  fontWeight: FontWeight.w700,
                                  color: accent,
                                )
                              : MediaQuery.withNoTextScaling(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        '$count',
                                        style: theme.textTheme.titleLarge
                                            .copyWith(
                                              fontSize: size * .28,
                                              height: 1,
                                              fontWeight: FontWeight.w600,
                                              fontFeatures: const [
                                                FontFeature.tabularFigures(),
                                              ],
                                            ),
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        '/ $total',
                                        style: theme.textTheme.bodyLarge
                                            .copyWith(
                                              color: theme
                                                  .colorScheme
                                                  .onSurfaceVariant,
                                              fontFeatures: const [
                                                FontFeature.tabularFigures(),
                                              ],
                                            ),
                                      ),
                                    ],
                                  ),
                                ),
                        ),
                      ),
                    ),
                    if (hint case final hint?) ...[
                      const SizedBox(height: 24),
                      Text(
                        hint,
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodySmall.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _BigRing extends CustomPainter {
  _BigRing(this.value, this.color, this.track);
  final double value;
  final Color color, track;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = (Offset.zero & size).deflate(8);
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 10
      ..strokeCap = StrokeCap.round
      ..color = track;
    canvas.drawOval(rect, paint);
    if (value <= 0) return;
    paint.color = color;
    canvas.drawArc(rect, -math.pi / 2, 2 * math.pi * value, false, paint);
  }

  @override
  bool shouldRepaint(_BigRing old) =>
      old.value != value || old.color != color || old.track != track;
}
