import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:cupertino_ui/cupertino_ui.dart';

import '../../foundation/surface/academy_surface_mask.dart';
import '../../foundation/table/academy_table_row_scope.dart';
import '../../theme/academy_theme.dart';
import 'academy_row.dart';

// Shared by AcademyTableBody and the lazy tables, so a row looks and behaves the
// same in all of them. Internal: not exported from the package.

/// Where a separator under [row] starts.
double academyTableRowStart(BuildContext context, Widget row) => switch (row) {
  final AcademyTableRowGeometry geometry => geometry.separatorStart(context),
  _ => AcademyTheme.of(context).paddings.tableRow.left,
};

/// A row paints its own opaque fill, so a modal table must not cache it apart
/// from the sheet's mask.
bool academyTableRowCachesGlyphs(Widget row) =>
    !(row is AcademyRow && row.paintsOwnBackground);

/// One row of a table: custom content is inset and centered, a row gets the
/// row scope. The row's key moves up here, where the column of rows can see it:
/// a row reordered or inserted among others then keeps its state. Without
/// [keyed], for a key its section repeats, the row stays matched by position.
Widget academyTableRowSlot(
  BuildContext context,
  Widget row, {
  required bool insetCustomRows,
  Widget? content,
  bool keyed = true,
}) {
  final child = content ?? row;
  final Widget slot = insetCustomRows && row is! AcademyTableRowGeometry
      ? Padding(
          padding: EdgeInsets.symmetric(
            horizontal: AcademyTheme.of(context).paddings.tableRow.left,
          ),
          // Custom content keeps its own width, centered.
          child: Center(heightFactor: 1, child: child),
        )
      : AcademyTableRowScope(child: child);
  final key = row.key;
  // A global key already finds its row wherever it moves, and may not be used
  // twice in the tree.
  return !keyed || key == null || key is GlobalKey
      ? slot
      // Wrapped, so looking the row up by its own key still finds only the row.
      : KeyedSubtree(key: ValueKey<Key>(key), child: slot);
}

/// A row as its own item of a scrolling list: the section's surface is painted
/// row by row, with the corners on its ends.
class AcademyTableListRow extends StatelessWidget {
  const AcademyTableListRow({
    super.key,
    required this.row,
    required this.first,
    required this.last,
    this.cornerRadius,
    this.padding,
    this.insetCustomRows = false,
    this.separatorBefore,
    this.separatorAfter,
  });
  final Widget row;
  final bool first, last, insetCustomRows;
  final double? cornerRadius;

  /// Inside the surface: the top applies to the first row and the bottom to the
  /// last. Default: the theme's table body padding.
  final EdgeInsetsGeometry? padding;
  final Widget? separatorBefore, separatorAfter;

  @override
  Widget build(BuildContext context) {
    final theme = AcademyTheme.of(context);
    final corner = Radius.circular(cornerRadius ?? theme.radii.table);
    final radius = BorderRadius.vertical(
      top: first ? corner : Radius.zero,
      bottom: last ? corner : Radius.zero,
    );
    final inset = (padding ?? theme.paddings.tableBody).resolve(
      Directionality.of(context),
    );
    final content = Padding(
      padding: EdgeInsets.fromLTRB(
        inset.left,
        first ? inset.top : 0,
        inset.right,
        last ? inset.bottom : 0,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ?separatorBefore,
          academyTableRowSlot(context, row, insetCustomRows: insetCustomRows),
          ?separatorAfter,
        ],
      ),
    );
    // A rounded clip over scrolling rows renders them offscreen on every frame,
    // and the mask of a sheet's corners repaints: cache the glyphs apart from it.
    if (ModalSheetSurfaceScope.isInModalSheet(context)) {
      return ModalSheetMaskedFill(
        color: theme.colorScheme.surface,
        borderRadius: radius,
        child: academyTableRowCachesGlyphs(row)
            ? RepaintBoundary(child: content)
            : content,
      );
    }
    final surface = DecoratedBox(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: radius,
      ),
      child: ClipRRect(borderRadius: radius, child: content),
    );
    final shadow = theme.table.surfaceShadow;
    if (shadow.isEmpty) return surface;
    return CustomPaint(
      painter: _RowShadowPainter(
        shadow: shadow,
        radius: radius,
        first: first,
        last: last,
      ),
      child: surface,
    );
  }
}

/// The part of the section's shadow beside one row: the rows share one
/// shadow, with no seams where they meet.
class _RowShadowPainter extends CustomPainter {
  const _RowShadowPainter({
    required this.shadow,
    required this.radius,
    required this.first,
    required this.last,
  });

  final List<BoxShadow> shadow;
  final BorderRadius radius;
  final bool first, last;

  @override
  void paint(Canvas canvas, Size size) {
    final reach = shadow.fold<double>(
      0,
      (most, s) =>
          math.max(most, s.blurRadius * 2 + s.spreadRadius + s.offset.distance),
    );
    // Inner rows cast as part of a taller surface and keep only their own
    // band, so the blur does not fade at every row edge.
    canvas
      ..save()
      ..clipRect(
        Rect.fromLTRB(
          -reach,
          first ? -reach : 0,
          size.width + reach,
          last ? size.height + reach : size.height,
        ),
      );
    final body = radius.toRRect(
      Rect.fromLTRB(
        0,
        first ? 0 : -reach,
        size.width,
        last ? size.height : size.height + reach,
      ),
    );
    for (final s in shadow) {
      canvas.drawRRect(body.shift(s.offset).inflate(s.spreadRadius), s.toPaint());
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(_RowShadowPainter old) =>
      !listEquals(old.shadow, shadow) ||
      old.radius != radius ||
      old.first != first ||
      old.last != last;
}
