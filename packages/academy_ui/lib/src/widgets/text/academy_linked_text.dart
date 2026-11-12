import 'package:cupertino_ui/cupertino_ui.dart';

// Ported from Yalla's yalla_linked_text.dart (2026-11-02).
/// Inline links keep paragraph wrapping, selection metrics and tap semantics.
/// Flutter's text decoration has no baseline offset, so draw the dots from the
/// same paragraph's line metrics without changing the recognizers or content.
const _underlineWidth = 1.5;
const _underlineOffset = 4.0;

class AcademyLinkedText extends StatelessWidget {
  const AcademyLinkedText({
    super.key,
    required this.text,
    required this.style,
    required this.linkColor,
  });
  final TextSpan text;
  final TextStyle style;
  final Color linkColor;
  @override
  Widget build(BuildContext context) => CustomPaint(
    foregroundPainter: _LinkUnderlines(
      text: TextSpan(style: style, children: [text]),
      direction: Directionality.of(context),
      scale: MediaQuery.textScalerOf(context),
      color: linkColor,
    ),
    child: Text.rich(text, style: style),
  );
}

class _LinkUnderlines extends CustomPainter {
  const _LinkUnderlines({
    required this.text,
    required this.direction,
    required this.scale,
    required this.color,
  });
  final TextSpan text;
  final TextDirection direction;
  final TextScaler scale;
  final Color color;
  @override
  void paint(Canvas canvas, Size size) {
    final paragraph = TextPainter(
      text: text,
      textDirection: direction,
      textScaler: scale,
    )..layout(maxWidth: size.width);
    final lines = paragraph.computeLineMetrics();
    final paint = Paint()
      ..color = color
      ..strokeWidth = _underlineWidth
      ..strokeCap = StrokeCap.round;
    var offset = 0;
    void underline(TextSpan span) {
      final value = span.text ?? '';
      if (span.recognizer != null && value.isNotEmpty) {
        for (final box in paragraph.getBoxesForSelection(
          TextSelection(
            baseOffset: offset,
            extentOffset: offset + value.length,
          ),
        )) {
          final line = lines
              .where(
                (line) =>
                    line.baseline >= box.top && line.baseline <= box.bottom,
              )
              .firstOrNull;
          final y = (line?.baseline ?? box.bottom) + _underlineOffset;
          for (double x = box.left; x < box.right; x += 5) {
            canvas.drawLine(
              Offset(x, y),
              Offset((x + 1).clamp(box.left, box.right), y),
              paint,
            );
          }
        }
      }
      offset += value.length;
      for (final child in span.children ?? const <InlineSpan>[]) {
        if (child is TextSpan) underline(child);
      }
    }

    underline(text);
    paragraph.dispose();
  }

  @override
  bool shouldRepaint(_LinkUnderlines old) =>
      text != old.text ||
      direction != old.direction ||
      scale != old.scale ||
      color != old.color;
}
