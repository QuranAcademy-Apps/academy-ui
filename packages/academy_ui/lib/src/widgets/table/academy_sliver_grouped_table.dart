import 'package:flutter/cupertino.dart';

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
  });
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

  @override
  Widget build(BuildContext context) {
    final theme = AcademyTheme.of(context);
    final corner = Radius.circular(cornerRadius ?? theme.radii.table);
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

            return DecoratedBox(
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: radius,
              ),
              child: ClipRRect(
                borderRadius: radius,
                child: Padding(
                  padding: EdgeInsets.only(
                    top: first ? edgePadding : 0,
                    bottom: last ? edgePadding : 0,
                  ),
                  child: Column(
                    children: [
                      if (!first)
                        AcademyTableSeparator(
                          start: start(),
                          end: separatorEnd,
                        ),
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
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
