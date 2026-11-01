import 'package:academy_ui/academy_ui.dart' show AcademySfIcon;
import 'package:flutter/widgets.dart';

/// Quran's SF Symbol glyph: [AcademySfIcon] that follows the system text scale
/// and leaves right-to-left glyph handling to the font (no back/forward swap).
class AppSfIcon extends StatelessWidget {
  const AppSfIcon(
    this.icon, {
    super.key,
    this.fontSize,
    this.size,
    this.boxSize,
    this.paintExtent,
    this.fontWeight,
    this.color,
    this.shadows,
    this.textDirection,
    this.semanticsLabel,
  });

  final IconData icon;
  final double? fontSize;
  final double? size;
  final double? boxSize;
  final double? paintExtent;
  final FontWeight? fontWeight;
  final Color? color;
  final List<Shadow>? shadows;
  final TextDirection? textDirection;
  final String? semanticsLabel;

  @override
  Widget build(BuildContext context) => AcademySfIcon(
    icon,
    fontSize: fontSize,
    size: size,
    boxSize: boxSize,
    paintExtent: paintExtent,
    fontWeight: fontWeight,
    color: color,
    shadows: shadows,
    textDirection: textDirection,
    semanticsLabel: semanticsLabel,
    scaleWithText: true,
    mirrorInRtl: false,
  );
}
