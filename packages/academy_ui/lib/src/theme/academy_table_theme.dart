import 'package:flutter/widgets.dart';

/// How a pressed row reacts when it scales instead of fading.
@immutable
class AcademyRowPress {
  const AcademyRowPress({
    this.scale = 0.96,
    this.duration = const Duration(milliseconds: 210),
    this.delay = const Duration(milliseconds: 120),
  });
  final double scale;
  final Duration duration, delay;
}

/// App-wide look of [AcademyGroupedTable] and [AcademyRow]. Each value can also
/// be set on the widget; sizes and insets live in [AcademySizes] and
/// [AcademyPaddings].
@immutable
class AcademyTableTheme {
  const AcademyTableTheme({
    this.headerUppercase = false,
    this.headerStyle,
    this.footerStyle,
    this.rowTitleStyle,
    this.rowSubtitleStyle,
    this.rowTrailingStyle,
    this.showChevron = true,
    this.trailingSpacing = 12,
    this.leadingGap = 12,
    this.fixedLeadingColumn = true,
    this.paddingAroundText = false,
    this.separatorFollowsLeading = true,
    this.separatorEnd,
    this.leadingHeaderReserve = 0,
    this.clipSurface = false,
    this.press,
    this.chevronBuilder,
    this.accessoryIconColor,
  });

  /// Section titles in capitals.
  final bool headerUppercase;
  final TextStyle? headerStyle, footerStyle;
  final TextStyle? rowTitleStyle, rowSubtitleStyle, rowTrailingStyle;

  /// Whether a tappable row without [AcademyRow.trailing] shows a chevron.
  final bool showChevron;

  /// Gap before [AcademyRow.trailing].
  final double trailingSpacing;

  /// Gap after the leading content.
  final double leadingGap;

  /// True keeps every leading widget in a column of the row icon width; false
  /// lets it take its own width.
  final bool fixedLeadingColumn;

  /// True applies the row's vertical padding to its text only, so a tall leading
  /// widget or accessory does not grow the row further.
  final bool paddingAroundText;

  /// True starts a separator at the row's text; false at its leading edge.
  final bool separatorFollowsLeading;

  /// Separator end inset; default: the row's trailing padding.
  final double? separatorEnd;

  /// Extra space above a first section without a title, so its card lines up
  /// with screens that lead with a title.
  final double leadingHeaderReserve;

  /// Clips row content to the rounded surface in every table.
  final bool clipSurface;

  /// When set, tappable rows scale like this instead of fading.
  final AcademyRowPress? press;

  /// Symbols of row accessories, such as the reorder handle; default: the text
  /// color.
  final Color? accessoryIconColor;

  /// Draws the disclosure chevron; [turns] rotates it.
  final Widget Function(BuildContext context, double turns)? chevronBuilder;
}
