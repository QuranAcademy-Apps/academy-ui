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
    this.mergeRowSemantics = false,
    this.press,
    this.chevronBuilder,
    this.accessoryIconColor,
    this.leadingExtent,
    this.pressedColor,
    this.navigationChevron,
    this.sectionLayout = const AcademyTableSectionLayout(),
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

  /// Announces a whole row as one screen-reader element.
  final bool mergeRowSemantics;

  /// When set, tappable rows scale like this instead of fading.
  final AcademyRowPress? press;

  /// Symbols of row accessories, such as the reorder handle; default: the text
  /// color.
  final Color? accessoryIconColor;

  /// Draws the disclosure chevron; [turns] rotates it.
  final Widget Function(BuildContext context, double turns)? chevronBuilder;

  /// Leading column width of a row; default: the row icon width.
  final double? leadingExtent;

  /// Row fill while pressed.
  final Color? pressedColor;

  /// Chevron of a navigation row; default: [chevronBuilder], then a symbol.
  final Widget? navigationChevron;

  /// Spacing of the themed grouped tables.
  final AcademyTableSectionLayout sectionLayout;
}

/// Spacing of [AcademyGroupedTable.themed] and [AcademySliverGroupedTable.themed]:
/// headings own the space above a section.
@immutable
class AcademyTableSectionLayout {
  const AcademyTableSectionLayout({
    this.sideInset = 16,
    this.headerTop = 24,
    this.headerBottom = 8,
    this.fixedHeaderTop = false,
    this.bodyVertical = 0,
    this.footerTop = 8,
    this.footerBottom = 16,
    this.fixedFooterBottom = false,
    this.spacingBetweenSections,
  });

  /// Side inset of headings and footers.
  final double sideInset;
  final double headerTop;

  /// Space under a heading without a subtitle.
  final double headerBottom;

  /// Ignores a table's own header top, keeping [headerTop].
  final bool fixedHeaderTop;

  /// Space inside the surface above the first and below the last row.
  final double bodyVertical;
  final double footerTop;
  final double footerBottom;

  /// Ignores a table's own footer bottom, keeping [footerBottom].
  final bool fixedFooterBottom;

  /// Space above a later section whose heading has no trailing control.
  final double? spacingBetweenSections;
}
