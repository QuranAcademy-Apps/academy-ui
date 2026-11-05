import 'package:flutter/cupertino.dart';

import '../../theme/academy_theme.dart';
import 'academy_sf_image.dart';

/// The one chevron of the library.
///
/// The default is the SF symbol of grouped rows: small, in the tertiary label
/// color, optionally rotated. [AcademyChevron.right] and [AcademyChevron.left]
/// draw Quran's heavier stroked shape, mirrored in RTL.
class AcademyChevron extends StatelessWidget {
  const AcademyChevron({super.key, this.turns = 0, double? size, this.color})
    : _symbolSize = size,
      _strokeSize = null,
      strokeWidth = 0,
      _pointsRight = true;

  const AcademyChevron.right({
    super.key,
    required Color this.color,
    Size size = const Size(7, 12),
    this.strokeWidth = 2.3,
  }) : turns = 0,
       _symbolSize = 0,
       _strokeSize = size,
       _pointsRight = true;

  const AcademyChevron.left({
    super.key,
    required Color this.color,
    Size size = const Size(7, 12),
    this.strokeWidth = 2.3,
  }) : turns = 0,
       _symbolSize = 0,
       _strokeSize = size,
       _pointsRight = false;

  final double turns;

  /// Default: the tertiary label color.
  final Color? color;
  final double strokeWidth;
  final double? _symbolSize;
  final Size? _strokeSize;
  final bool _pointsRight;

  @override
  Widget build(BuildContext context) {
    final strokeSize = _strokeSize;
    if (strokeSize != null) {
      return Transform.flip(
        flipX: Directionality.of(context) == TextDirection.rtl,
        child: SizedBox.fromSize(
          size: strokeSize,
          child: CustomPaint(
            painter: _StrokeChevronPainter(
              color: color!,
              strokeWidth: strokeWidth,
              pointsRight: _pointsRight,
            ),
          ),
        ),
      );
    }
    final symbolSize = _symbolSize ?? AcademyTheme.of(context).sizes.chevron;
    return AnimatedRotation(
      turns: turns,
      duration: MediaQuery.disableAnimationsOf(context)
          ? Duration.zero
          : AcademyTokens.motion,
      child: SizedBox(
        width: symbolSize * 4 / 7,
        height: symbolSize,
        child: FittedBox(
          fit: BoxFit.contain,
          child: AcademySfIcon(
            AcademyTheme.of(context).icons.forward,
            size: symbolSize,
            color: color ?? AcademyTheme.of(context).colorScheme.labelTertiary,
          ),
        ),
      ),
    );
  }
}

class _StrokeChevronPainter extends CustomPainter {
  const _StrokeChevronPainter({
    required this.color,
    required this.strokeWidth,
    required this.pointsRight,
  });

  final Color color;
  final double strokeWidth;
  final bool pointsRight;

  @override
  void paint(Canvas canvas, Size size) {
    final inset = strokeWidth / 2;
    final startX = pointsRight ? inset : size.width - inset;
    final endX = pointsRight ? size.width - inset : inset;
    final path = Path()
      ..moveTo(startX, inset)
      ..lineTo(endX, size.height / 2)
      ..lineTo(startX, size.height - inset);

    canvas.drawPath(
      path,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );
  }

  @override
  bool shouldRepaint(covariant _StrokeChevronPainter oldDelegate) {
    return oldDelegate.color != color ||
        oldDelegate.strokeWidth != strokeWidth ||
        oldDelegate.pointsRight != pointsRight;
  }
}
