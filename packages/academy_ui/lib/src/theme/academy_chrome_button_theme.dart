import 'package:flutter/widgets.dart';

/// Look of [AcademyChromeButton], [AcademyChromeGroup] and the title capsule
/// for a whole app.
@immutable
class AcademyChromeButtonTheme {
  const AcademyChromeButtonTheme({
    this.symbolFrame = 36,
    this.symbolSize = 18,
    this.symbolWeight = FontWeight.w600,
    this.symbolBoxed = true,
    this.symbolScalesWithText = false,
    this.symbolMirrorsInRtl = true,
    this.animatesSymbol = true,
    this.pressScalesSymbolOnly = false,
    this.disabledForeground,
    this.groupDividerWidth = .5,
    this.backIcon,
    this.backIconRtl,
    this.titleStyle,
    this.compactTitleStyle,
    this.subtitleStyle,
    this.compactTarget = 44,
    this.compactForeground,
    this.compactWeight,
    this.compactPressEffect = true,
  });

  /// Square that centers the symbol; also the tap area when pressing scales
  /// only the symbol.
  final double symbolFrame;
  final double symbolSize;
  final FontWeight symbolWeight;

  /// Lays the glyph out in a square of its size, so symbols share one center.
  final bool symbolBoxed;
  final bool symbolScalesWithText;
  final bool symbolMirrorsInRtl;

  /// Crossfades when the symbol changes.
  final bool animatesSymbol;

  /// Keeps the surface still under the finger, scaling just the symbol.
  final bool pressScalesSymbolOnly;

  /// Symbol without an action; default: a contrast-fixed secondary color.
  final Color? disabledForeground;
  final double groupDividerWidth;

  /// Back symbol; default: [AcademyIcons.back], mirrored by the symbol.
  final IconData? backIcon;
  final IconData? backIconRtl;

  /// Single-line title; default: [AcademyTextTheme.titleMedium].
  final TextStyle? titleStyle;

  /// Title above a subtitle; default: [titleStyle].
  final TextStyle? compactTitleStyle;

  /// Default: [AcademyTextTheme.bodySmall].
  final TextStyle? subtitleStyle;

  /// Hit area of [AcademyCompactIconButton]; it also takes this much layout.
  final double compactTarget;

  /// Default: a secondary text color.
  final Color? compactForeground;
  final FontWeight? compactWeight;

  /// Dims the button under the finger.
  final bool compactPressEffect;
}
