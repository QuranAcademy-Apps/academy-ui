import 'package:flutter/cupertino.dart';

import '../../foundation/surface/academy_surface_mask.dart';
import '../../foundation/table/academy_table_row_scope.dart';
import '../../theme/academy_theme.dart';
import 'academy_table.dart';

/// A grouped section whose rows are built lazily in the enclosing scroll view,
/// for long histories. Short forms and settings use [AcademyGroupedTable].
///
/// Ported from Yalla's YallaSliverGroupedTable (2026-11-02).
class AcademySliverGroupedTable extends StatelessWidget {
  const AcademySliverGroupedTable({
    super.key,
    required this.itemCount,
    required this.itemBuilder,
    this.header,
    this.cornerRadius,
    this.edgePadding = 0,
    this.separatorStart,
    this.separatorEnd,
    this.insetCustomRows = false,
  }) : themed = false,
       title = null,
       subtitle = null,
       headerStyle = null,
       firstHeaderTop = null,
       headerTop = null,
       headerBottom = null;

  /// Heading, spacing and separators follow
  /// [AcademyTableTheme.sectionLayout], like [AcademyGroupedTable.themed].
  const AcademySliverGroupedTable.themed({
    super.key,
    required this.itemCount,
    required this.itemBuilder,
    this.title,
    this.subtitle,
    this.headerStyle,
    this.firstHeaderTop,
    this.headerTop,
    this.headerBottom,
    this.cornerRadius,
    this.separatorStart,
  }) : themed = true,
       header = null,
       edgePadding = 0,
       separatorEnd = null,
       insetCustomRows = true;
  final bool themed;
  final String? title, subtitle;
  final TextStyle? headerStyle;
  final double? firstHeaderTop, headerTop, headerBottom;
  final int itemCount;
  final IndexedWidgetBuilder itemBuilder;

  /// For example an [AcademyTableHeader].
  final Widget? header;
  final double? cornerRadius;

  /// Space above the first and below the last row, inside the surface.
  final double edgePadding;

  /// See [AcademyTableBody].
  final double? separatorStart, separatorEnd;
  final bool insetCustomRows;

  Widget _themed(BuildContext context) {
    final table = AcademyTheme.of(context).table;
    final layout = table.sectionLayout;
    final top = layout.fixedHeaderTop
        ? layout.headerTop
        : headerTop ?? layout.headerTop;
    return AcademySliverGroupedTable(
      itemCount: itemCount,
      itemBuilder: itemBuilder,
      header: title == null
          ? null
          : AcademyTableHeader(
              title: title!,
              subtitle: subtitle,
              style: headerStyle,
              padding: EdgeInsets.fromLTRB(
                layout.sideInset,
                firstHeaderTop ?? top,
                layout.sideInset,
                subtitle != null ? 0 : headerBottom ?? layout.headerBottom,
              ),
            ),
      cornerRadius: cornerRadius,
      edgePadding: layout.bodyVertical,
      separatorStart: separatorStart,
      separatorEnd: table.separatorEnd,
      insetCustomRows: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (themed) return _themed(context);
    final theme = AcademyTheme.of(context);
    final corner = Radius.circular(cornerRadius ?? theme.radii.table);
    final inModal = ModalSheetSurfaceScope.isInModalSheet(context);
    // A separator starts where the previous row's content does. Remembering
    // that spares building the previous row a second time just to ask it.
    final rowStarts = <int, double>{};
    double rowStart(BuildContext context, Widget row) =>
        row is AcademyTableRowGeometry
        ? (row as AcademyTableRowGeometry).separatorStart(context)
        : theme.paddings.tableRow.left;
    return SliverMainAxisGroup(
      slivers: [
        if (header != null) SliverToBoxAdapter(child: header),
        SliverList.builder(
          itemCount: itemCount,
          addRepaintBoundaries: !inModal,
          itemBuilder: (context, index) {
            final row = itemBuilder(context, index);
            rowStarts[index] = rowStart(context, row);
            final first = index == 0, last = index == itemCount - 1;
            final radius = BorderRadius.vertical(
              top: first ? corner : Radius.zero,
              bottom: last ? corner : Radius.zero,
            );
            double start() =>
                separatorStart ??
                rowStarts[index - 1] ??
                rowStart(context, itemBuilder(context, index - 1));

            final content = Padding(
              padding: EdgeInsets.only(
                top: first ? edgePadding : 0,
                bottom: last ? edgePadding : 0,
              ),
              child: Column(
                children: [
                  if (!first)
                    AcademyTableSeparator(start: start(), end: separatorEnd),
                  if (insetCustomRows && row is! AcademyTableRowGeometry)
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: theme.paddings.tableRow.left,
                      ),
                      // Custom content keeps its own width, centered.
                      child: Center(heightFactor: 1, child: row),
                    )
                  else
                    AcademyTableRowScope(child: row),
                ],
              ),
            );
            // A rounded clip over scrolling rows renders them offscreen on
            // every frame, and the mask of a sheet's corners repaints: cache
            // the glyphs apart from it.
            if (inModal) {
              return ModalSheetMaskedFill(
                color: theme.colorScheme.surface,
                borderRadius: radius,
                child: RepaintBoundary(child: content),
              );
            }
            return DecoratedBox(
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: radius,
              ),
              child: ClipRRect(borderRadius: radius, child: content),
            );
          },
        ),
      ],
    );
  }
}
