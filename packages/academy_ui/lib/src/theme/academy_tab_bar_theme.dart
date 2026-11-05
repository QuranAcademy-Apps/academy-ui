import 'package:flutter/widgets.dart';

/// Look and placement of the standard [AcademyFloatingTabBar] and of
/// [AcademyTabScaffold] for a whole app.
@immutable
class AcademyTabBarTheme {
  const AcademyTabBarTheme({
    this.fixedHeight = false,
    this.showShadow = true,
    this.pressedScale,
    this.selectedIconScale = 1,
    this.iconBoxSize = 30,
    this.iconWeight,
    this.selectedIconWeight,
    this.iconScalesWithText = false,
    this.labelStyle,
    this.labelWeight,
    this.selectedLabelWeight,
    this.labelPadding = 2,
    this.fitLabels = true,
    this.selectionDuration,
    this.sideMargin,
    this.avoidSideInsets = false,
    this.showBottomFade = false,
    this.bottomInsetOf,
  });

  /// Keeps the bar height when text is scaled.
  final bool fixedHeight;

  /// Lets [AcademyChromeMaterial.shadows] fall on the content under the bar.
  final bool showShadow;

  /// Items scale by this factor when pressed; default: they fade.
  final double? pressedScale;

  /// Enlarges the selected symbol.
  final double selectedIconScale;

  /// Square that centers a symbol, so glyphs share one baseline.
  final double iconBoxSize;
  final FontWeight? iconWeight;
  final FontWeight? selectedIconWeight;

  /// Grows symbols with the text scale.
  final bool iconScalesWithText;

  /// Label style; default: [AcademyTextTheme.tabLabel].
  final TextStyle? labelStyle;
  final FontWeight? labelWeight;
  final FontWeight? selectedLabelWeight;

  /// Horizontal padding of a label.
  final double labelPadding;

  /// Stops a label growing where its tab cannot hold it.
  final bool fitLabels;

  /// Slide of the selection; default: [AcademyTokens.pressMotion].
  final Duration? selectionDuration;

  /// Side margin of the bar in [AcademyTabScaffold]; default: the density's.
  final double? sideMargin;

  /// Moves the bar clear of landscape cutouts.
  final bool avoidSideInsets;

  /// Paints [AcademyChromeFadeMaterial] under the bar.
  final bool showBottomFade;

  /// Distance from the bottom edge; default: [academyChromeBottomOf].
  final double Function(BuildContext context)? bottomInsetOf;
}
