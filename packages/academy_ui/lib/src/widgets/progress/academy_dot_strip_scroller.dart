// Ported from quran_flutter DotStripScroller.
import '../../theme/academy_theme.dart';

import 'package:flutter/cupertino.dart';

/// Узкая полоса точек у правого края с быстрым скроллом по вертикальному драгу.
///
/// Драг квантуется в шаг `0..[steps]-1` и отдаётся через [onProgress] как
/// квантованный прогресс `0..1` — только при смене шага и с хаптиком. Визуал
/// точек повторяет полосу из списка глав. Используется и списком глав
/// (`ChapterSliderView`), и листом аятов суры.
class AcademyDotStripScroller extends StatefulWidget {
  const AcademyDotStripScroller({
    super.key,
    required this.steps,
    required this.onProgress,
    this.gestureWidth = stripWidth,
    this.fillAvailableHeight = false,
    this.dotsTipBuilder,
    this.dotColor,
  });

  /// Color of the dots.
  final Color? dotColor;

  /// Число дискретных позиций (и верхняя граница числа точек). Должно быть > 0.
  final int steps;

  /// Квантованный прогресс `0..1`; вызывается только при смене шага.
  final ValueChanged<double> onProgress;

  /// Ширина зоны жеста. Сами точки всегда прижаты к правому краю на [stripWidth];
  /// более широкая зона даёт удобное попадание, не сдвигая точки.
  final double gestureWidth;

  /// Uses all available height between the strip's vertical padding.
  final bool fillAvailableHeight;

  /// Оборачивает узкую полосу точек (для онбординг-подсказки списка глав).
  final Widget Function(BuildContext context, Widget dots)? dotsTipBuilder;

  /// Ширина видимой полосы точек (точка 2pt + правый отступ 5pt + воздух).
  static const double stripWidth = 24;

  @override
  State<AcademyDotStripScroller> createState() =>
      _AcademyDotStripScrollerState();
}

class _AcademyDotStripScrollerState extends State<AcademyDotStripScroller> {
  int? _lastStep;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final height = constraints.maxHeight.isFinite
            ? constraints.maxHeight
            : MediaQuery.sizeOf(context).height;
        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onVerticalDragStart: (d) => _handleDrag(d.localPosition.dy, height),
          onVerticalDragUpdate: (d) => _handleDrag(d.localPosition.dy, height),
          onVerticalDragEnd: (_) => _lastStep = null,
          child: SizedBox(
            width: widget.gestureWidth,
            height: height,
            // Точки прижаты к правому краю; жест остаётся на всю ширину для
            // удобного попадания.
            child: Align(
              alignment: Alignment.centerRight,
              child: SizedBox(
                width: AcademyDotStripScroller.stripWidth,
                height: height,
                child: _wrapDots(_buildDots(height)),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _wrapDots(Widget dots) {
    final builder = widget.dotsTipBuilder;
    if (builder == null) return dots;
    return builder(context, dots);
  }

  void _handleDrag(double localY, double height) {
    if (widget.steps <= 0 || height <= 0) return;
    final progress = localY.clamp(0.0, height) / height;
    final maxIndex = widget.steps > 1 ? widget.steps - 1 : 0;
    final step = maxIndex == 0
        ? 0
        : (progress * maxIndex).round().clamp(0, maxIndex);
    if (_lastStep == step) return;
    _lastStep = step;
    widget.onProgress(maxIndex == 0 ? 0.0 : step / maxIndex);
    AcademyTheme.of(context).interaction.selectionClick();
  }

  Widget _buildDots(double height) {
    const pointSize = 2.0;
    const desiredSpacing = 15.0;
    const verticalPadding = 8.0;
    final points = widget.fillAvailableHeight
        ? _pointsForAvailableHeight(
            height: height,
            pointSize: pointSize,
            desiredSpacing: desiredSpacing,
            verticalPadding: verticalPadding,
          )
        : _adaptivePointCount(
            height: height,
            pointSize: pointSize,
            spacing: desiredSpacing,
          );
    final dotColor =
        widget.dotColor ?? AcademyTheme.of(context).colorScheme.onSurface;

    return SizedBox.expand(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: verticalPadding),
        child: Column(
          mainAxisAlignment: widget.fillAvailableHeight
              ? MainAxisAlignment.spaceBetween
              : MainAxisAlignment.center,
          children: [
            for (var i = 0; i < points; i++) ...[
              Align(
                alignment: Alignment.centerRight,
                child: Container(
                  width: pointSize,
                  height: pointSize,
                  margin: const EdgeInsets.only(right: 5),
                  decoration: BoxDecoration(
                    color: dotColor,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              if (!widget.fillAvailableHeight && i < points - 1)
                const SizedBox(height: desiredSpacing),
            ],
          ],
        ),
      ),
    );
  }

  int _pointsForAvailableHeight({
    required double height,
    required double pointSize,
    required double desiredSpacing,
    required double verticalPadding,
  }) {
    if (widget.steps <= 0) return 0;
    final availableHeight = (height - verticalPadding * 2)
        .clamp(0.0, double.infinity)
        .toDouble();
    return ((availableHeight + desiredSpacing) / (pointSize + desiredSpacing))
        .floor()
        .clamp(1, widget.steps);
  }

  int _adaptivePointCount({
    required double height,
    required double pointSize,
    required double spacing,
  }) {
    final maxPoints = widget.steps.clamp(0, 30);
    final calculated = ((height + spacing - 24) / (pointSize + spacing))
        .floor();
    final visible = calculated.clamp(0, maxPoints);
    return visible <= 0 ? 5 : visible;
  }
}
