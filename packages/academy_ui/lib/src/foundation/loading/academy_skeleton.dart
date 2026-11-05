import 'package:flutter/cupertino.dart';

import '../../theme/academy_theme.dart';

// Ported from Yalla's yalla_skeleton.dart (2026-11-02).
/// One gentle moving highlight per group, with no animated layout or blur.
class AcademySkeletonPulse extends StatefulWidget {
  const AcademySkeletonPulse({super.key, required this.child});
  final Widget child;

  @override
  State<AcademySkeletonPulse> createState() => _AcademySkeletonPulseState();
}

class _AcademySkeletonPulseState extends State<AcademySkeletonPulse>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1800),
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.disableAnimationsOf(context)) {
      _controller.stop();
      _controller.value = .5;
    } else if (!_controller.isAnimating) {
      _controller.repeat();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => _SkeletonPulseScope(
    phase: _controller,
    child: RepaintBoundary(child: widget.child),
  );
}

class _SkeletonPulseScope extends InheritedWidget {
  const _SkeletonPulseScope({required this.phase, required super.child});
  final Animation<double> phase;

  @override
  bool updateShouldNotify(_SkeletonPulseScope oldWidget) =>
      phase != oldWidget.phase;
}

class AcademySkeletonBlock extends StatelessWidget {
  const AcademySkeletonBlock({
    super.key,
    this.width,
    required this.height,
    this.radius = 8,
  });

  final double? width;
  final double height, radius;

  @override
  Widget build(BuildContext context) {
    final colors = AcademyTheme.of(context).colorScheme;
    final pulse = context
        .dependOnInheritedWidgetOfExactType<_SkeletonPulseScope>();
    return SizedBox(
      width: width ?? double.infinity,
      height: height,
      child: CustomPaint(
        painter: _SkeletonHighlightPainter(
          phase: pulse?.phase,
          base: colors.surfaceContainerHighest,
          highlight: Color.lerp(
            colors.surfaceContainerHighest,
            colors.onSurface,
            AcademyTheme.of(context).brightness == Brightness.dark ? .12 : .08,
          )!,
          radius: radius,
        ),
      ),
    );
  }
}

class _SkeletonHighlightPainter extends CustomPainter {
  _SkeletonHighlightPainter({
    required this.phase,
    required this.base,
    required this.highlight,
    required this.radius,
  }) : super(repaint: phase);

  final Animation<double>? phase;
  final Color base, highlight;
  final double radius;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final paint = Paint()..color = base;
    if (phase != null) {
      final center = -2 + 4 * phase!.value;
      paint.shader = LinearGradient(
        begin: Alignment(center - 1, 0),
        end: Alignment(center + 1, 0),
        colors: [base, highlight, base],
        stops: const [0, .5, 1],
      ).createShader(rect);
    }
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, Radius.circular(radius)),
      paint,
    );
  }

  @override
  bool shouldRepaint(_SkeletonHighlightPainter oldDelegate) =>
      phase != oldDelegate.phase ||
      base != oldDelegate.base ||
      highlight != oldDelegate.highlight ||
      radius != oldDelegate.radius;
}

/// Reserve content font metrics, including system text scaling.
class AcademySkeletonText extends StatelessWidget {
  const AcademySkeletonText({
    super.key,
    required this.style,
    this.sample = 'Загрузка',
    this.widthFactor = .7,
  });
  final TextStyle style;
  final String sample;
  final double widthFactor;

  @override
  Widget build(BuildContext context) => Stack(
    children: [
      Opacity(opacity: 0, child: Text(sample, style: style, maxLines: 1)),
      Positioned.fill(
        child: Align(
          alignment: AlignmentDirectional.centerStart,
          child: FractionallySizedBox(
            widthFactor: widthFactor,
            heightFactor: .65,
            child: const AcademySkeletonBlock(height: 1),
          ),
        ),
      ),
    ],
  );
}

class AcademyContentSkeleton extends StatelessWidget {
  const AcademyContentSkeleton({
    super.key,
    this.label = 'Загрузка данных',
    this.rows = 3,
  });

  final String label;
  final int rows;

  @override
  Widget build(BuildContext context) => Semantics(
    label: label,
    child: AcademySkeletonPulse(
      child: ExcludeSemantics(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (var index = 0; index < rows; index++)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: AcademyTheme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(
                      AcademyTheme.of(context).radii.skeleton,
                    ),
                  ),
                  child: const Padding(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        FractionallySizedBox(
                          widthFactor: .65,
                          child: AcademySkeletonBlock(height: 17),
                        ),
                        SizedBox(height: 10),
                        FractionallySizedBox(
                          widthFactor: .85,
                          child: AcademySkeletonBlock(height: 13),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    ),
  );
}
