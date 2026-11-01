// Ported from quran_flutter AppChevron.
import 'package:flutter/widgets.dart';

class AcademyStrokeChevron extends StatelessWidget {
  const AcademyStrokeChevron.right({
    super.key,
    required this.color,
    this.size = const Size(7, 12),
    this.strokeWidth = 2.3,
  }) : _pointsRight = true;

  const AcademyStrokeChevron.left({
    super.key,
    required this.color,
    this.size = const Size(7, 12),
    this.strokeWidth = 2.3,
  }) : _pointsRight = false;

  final Color color;
  final Size size;
  final double strokeWidth;
  final bool _pointsRight;

  @override
  Widget build(BuildContext context) {
    return Transform.flip(
      flipX: Directionality.of(context) == TextDirection.rtl,
      child: SizedBox.fromSize(
        size: size,
        child: CustomPaint(
          painter: _AcademyStrokeChevronPainter(
            color: color,
            strokeWidth: strokeWidth,
            pointsRight: _pointsRight,
          ),
        ),
      ),
    );
  }
}

class _AcademyStrokeChevronPainter extends CustomPainter {
  const _AcademyStrokeChevronPainter({
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
  bool shouldRepaint(covariant _AcademyStrokeChevronPainter oldDelegate) {
    return oldDelegate.color != color ||
        oldDelegate.strokeWidth != strokeWidth ||
        oldDelegate.pointsRight != pointsRight;
  }
}
