import 'package:cupertino_ui/cupertino_ui.dart';

import '../../foundation/surface/academy_surface_mask.dart';
import '../../theme/academy_theme.dart';
import 'academy_table.dart';
import 'academy_table_row_slot.dart';

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
    this.edgePadding,
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

  /// Space above the first and below the last row, inside the surface. Default:
  /// the theme's table body padding.
  final double? edgePadding;

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
    final inModal = ModalSheetSurfaceScope.isInModalSheet(context);
    // A separator starts where the previous row's content does. Remembering
    // that spares building the previous row a second time just to ask it.
    final rowStarts = <int, double>{};
    final padding = edgePadding;
    return SliverMainAxisGroup(
      slivers: [
        if (header != null) SliverToBoxAdapter(child: header),
        SliverList.builder(
          itemCount: itemCount,
          addRepaintBoundaries: !inModal,
          itemBuilder: (context, index) {
            final row = itemBuilder(context, index);
            rowStarts[index] = academyTableRowStart(context, row);
            final first = index == 0;
            return AcademyTableListRow(
              row: row,
              first: first,
              last: index == itemCount - 1,
              cornerRadius: cornerRadius,
              padding: padding == null
                  ? null
                  : EdgeInsets.symmetric(vertical: padding),
              insetCustomRows: insetCustomRows,
              separatorBefore: first
                  ? null
                  : AcademyTableSeparator(
                      start:
                          separatorStart ??
                          rowStarts[index - 1] ??
                          academyTableRowStart(
                            context,
                            itemBuilder(context, index - 1),
                          ),
                      end: separatorEnd,
                    ),
            );
          },
        ),
      ],
    );
  }
}
