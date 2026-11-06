import 'package:flutter/cupertino.dart';

import 'academy_table.dart';
import '../../theme/academy_theme.dart';
import '../../foundation/surface/academy_surface_mask.dart';
import '../../foundation/table/academy_table_row_scope.dart';

class AcademyTableSection {
  const AcademyTableSection({
    this.title,
    this.footer,
    required this.rows,
    this.header,
    this.headerTrailing,
    this.footerWidget,
    this.headerStyle,
    this.footerStyle,
    this.cornerRadius,
    this.showSeparators = true,
    this.separatorBuilder,
    this.subtitle,
    this.spacingBefore,
    this.headerPadding,
    this.bodyPadding,
    this.footerPadding,
    this.separatorStart,
    this.separatorEnd,
    this.insetCustomRows = false,
    this.clip = false,
  });
  final String? title, footer;
  final List<Widget> rows;
  final Widget? header, headerTrailing, footerWidget;
  final TextStyle? headerStyle, footerStyle;
  final double? cornerRadius;
  final bool showSeparators;
  final Widget Function(BuildContext, int)? separatorBuilder;

  /// Explanation under [title].
  final String? subtitle;

  /// Extra space above this section, after the table's section spacing.
  final double? spacingBefore;
  final EdgeInsetsGeometry? headerPadding, bodyPadding, footerPadding;

  /// See [AcademyTableBody].
  final double? separatorStart, separatorEnd;
  final bool insetCustomRows, clip;

  AcademyTableSection _laidOut({
    required TextStyle? headerStyle,
    required EdgeInsetsGeometry headerPadding,
    required double? spacingBefore,
    required double? cornerRadius,
    required EdgeInsetsGeometry bodyPadding,
    required double? separatorStart,
    required double? separatorEnd,
    required EdgeInsetsGeometry footerPadding,
  }) => AcademyTableSection(
    title: title,
    footer: footer,
    rows: rows,
    header: header,
    headerTrailing: headerTrailing,
    footerWidget: footerWidget,
    headerStyle: this.headerStyle ?? headerStyle,
    footerStyle: footerStyle,
    cornerRadius: this.cornerRadius ?? cornerRadius,
    showSeparators: showSeparators,
    separatorBuilder: separatorBuilder,
    subtitle: subtitle,
    spacingBefore: spacingBefore,
    headerPadding: headerPadding,
    bodyPadding: bodyPadding,
    footerPadding: footerPadding,
    separatorStart: this.separatorStart ?? separatorStart,
    separatorEnd: this.separatorEnd ?? separatorEnd,
    insetCustomRows: true,
    clip: true,
  );
}

/// Inline by default; scrolling ownership may instead be delegated to the table.
class AcademyGroupedTable extends StatelessWidget {
  const AcademyGroupedTable({
    super.key,
    required this.sections,
    this.padding,
    this.sectionSpacing = 24,
    this.scrollable = false,
    this.controller,
    this.physics,
    this.hideEmptySections = true,
    this.animated = false,
    this.lazyRows = false,
    this.alignFirstSection = true,
  }) : themed = false,
       firstHeaderTop = null,
       headerTop = null,
       headerBottom = null,
       footerBottom = null,
       headerStyle = null,
       cornerRadius = null,
       separatorStart = null;

  /// Spacing, corners and separators come from
  /// [AcademyTableTheme.sectionLayout]; the named values adjust this table.
  const AcademyGroupedTable.themed({
    super.key,
    required this.sections,
    this.firstHeaderTop,
    this.headerTop,
    this.headerBottom,
    this.footerBottom,
    this.headerStyle,
    this.cornerRadius,
    this.separatorStart,
  }) : themed = true,
       padding = null,
       sectionSpacing = 0,
       scrollable = false,
       controller = null,
       physics = null,
       hideEmptySections = false,
       animated = false,
       lazyRows = false,
       alignFirstSection = false;
  final bool themed;

  /// Header top of the first section.
  final double? firstHeaderTop;
  final double? headerTop, headerBottom, footerBottom;
  final TextStyle? headerStyle;
  final double? cornerRadius, separatorStart;
  final List<AcademyTableSection> sections;
  final EdgeInsetsGeometry? padding;
  final double sectionSpacing;
  final bool scrollable, hideEmptySections;

  /// Sections resize smoothly as rows come and go, and a row with a new key
  /// fades in. Give rows stable keys. Ignored with [lazyRows].
  final bool animated;

  /// Builds only the rows in view, for long lists. Needs [scrollable].
  final bool lazyRows;

  /// Applies the table theme's [AcademyTableTheme.leadingHeaderReserve] above a
  /// first section without a title.
  final bool alignFirstSection;
  final ScrollController? controller;
  final ScrollPhysics? physics;

  EdgeInsetsGeometry _padding(
    BuildContext context,
    List<AcademyTableSection> visible,
  ) {
    final theme = AcademyTheme.of(context);
    final base = padding ?? theme.paddings.groupedTable;
    final reserve = theme.table.leadingHeaderReserve;
    final headerless =
        visible.isEmpty ||
        visible.first.title == null && visible.first.header == null;
    return alignFirstSection && reserve > 0 && headerless
        ? base.add(EdgeInsets.only(top: reserve))
        : base;
  }

  Widget _lazyList(BuildContext context, List<AcademyTableSection> visible) {
    final items = <Widget Function(BuildContext)>[];
    for (var s = 0; s < visible.length; s++) {
      final section = visible[s];
      if (s > 0) items.add((_) => SizedBox(height: sectionSpacing));
      if (section.header != null || section.title != null) {
        items.add(
          (_) =>
              section.header ??
              AcademyTableHeader(
                title: section.title!,
                subtitle: section.subtitle,
                trailing: section.headerTrailing,
                style: section.headerStyle,
                padding: section.headerPadding,
              ),
        );
      }
      for (var r = 0; r < section.rows.length; r++) {
        items.add((context) => _LazyRow(section: section, index: r));
      }
      if (section.footerWidget != null || section.footer != null) {
        items.add(
          (_) =>
              section.footerWidget ??
              AcademyTableFooter(
                text: section.footer!,
                style: section.footerStyle,
                padding: section.footerPadding,
              ),
        );
      }
    }
    return ListView.builder(
      controller: controller,
      physics: physics,
      addRepaintBoundaries: !ModalSheetSurfaceScope.isInModalSheet(context),
      padding: _padding(context, visible),
      itemCount: items.length,
      itemBuilder: (context, index) => items[index](context),
    );
  }

  Widget _themed(BuildContext context) {
    final table = AcademyTheme.of(context).table;
    final layout = table.sectionLayout;
    final top = layout.fixedHeaderTop
        ? layout.headerTop
        : headerTop ?? layout.headerTop;
    final footer = layout.fixedFooterBottom
        ? layout.footerBottom
        : footerBottom ?? layout.footerBottom;
    return AcademyGroupedTable(
      padding: EdgeInsets.zero,
      sectionSpacing: 0,
      hideEmptySections: false,
      alignFirstSection: false,
      sections: [
        for (var i = 0; i < sections.length; i++)
          sections[i]._laidOut(
            headerStyle: headerStyle,
            headerPadding: EdgeInsets.fromLTRB(
              layout.sideInset,
              i == 0 ? firstHeaderTop ?? top : top,
              layout.sideInset,
              sections[i].subtitle != null
                  ? 0
                  : headerBottom ?? layout.headerBottom,
            ),
            spacingBefore:
                sections[i].spacingBefore ??
                (i > 0 && layout.spacingBetweenSections != null
                    ? (sections[i].headerTrailing == null
                          ? layout.spacingBetweenSections
                          : 0)
                    : null),
            cornerRadius: cornerRadius,
            bodyPadding: EdgeInsets.symmetric(vertical: layout.bodyVertical),
            separatorStart: separatorStart,
            separatorEnd: table.separatorEnd,
            footerPadding: EdgeInsets.fromLTRB(
              layout.sideInset,
              layout.footerTop,
              layout.sideInset,
              footer,
            ),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    if (themed) return _themed(context);
    final visible = sections
        .where((section) => !hideEmptySections || section.rows.isNotEmpty)
        .toList();
    if (lazyRows && scrollable) return _lazyList(context, visible);
    Widget section(int index) =>
        AcademyTableSectionView(section: visible[index], animated: animated);

    if (scrollable) {
      return ListView.separated(
        padding: _padding(context, visible),
        controller: controller,
        physics: physics,
        addRepaintBoundaries: !ModalSheetSurfaceScope.isInModalSheet(context),
        itemCount: visible.length,
        itemBuilder: (_, index) => section(index),
        separatorBuilder: (_, _) => SizedBox(height: sectionSpacing),
      );
    }
    return Padding(
      padding: _padding(context, visible),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (var i = 0; i < visible.length; i++) ...[
            if (i > 0) SizedBox(height: sectionSpacing),
            section(i),
          ],
        ],
      ),
    );
  }
}

/// One row as its own list item, with the section's corners on its ends.
class _LazyRow extends StatelessWidget {
  const _LazyRow({required this.section, required this.index});
  final AcademyTableSection section;
  final int index;
  @override
  Widget build(BuildContext context) {
    final theme = AcademyTheme.of(context);
    final first = index == 0, last = index == section.rows.length - 1;
    final r = Radius.circular(section.cornerRadius ?? theme.radii.table);
    final radius = BorderRadius.vertical(
      top: first ? r : Radius.zero,
      bottom: last ? r : Radius.zero,
    );
    final row = section.rows[index];
    final content = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AcademyTableRowScope(child: row),
        if (!last)
          AcademyTableSeparator(
            start:
                section.separatorStart ??
                (row is AcademyTableRowGeometry
                    ? (row as AcademyTableRowGeometry).separatorStart(context)
                    : theme.paddings.tableRow.left),
            end: section.separatorEnd,
          ),
      ],
    );
    if (ModalSheetSurfaceScope.isInModalSheet(context)) {
      return ModalSheetMaskedFill(
        color: theme.colorScheme.surface,
        borderRadius: radius,
        child: RepaintBoundary(child: content),
      );
    }
    return ClipRRect(
      borderRadius: radius,
      child: ColoredBox(color: theme.colorScheme.surface, child: content),
    );
  }
}
