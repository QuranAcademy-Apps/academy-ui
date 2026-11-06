import 'package:flutter/widgets.dart';

import '../../theme/academy_theme.dart';

/// Geometry that a row exposes to its enclosing table.
///
/// Implement this on a custom row, or wrap it in [AcademyTableRowLayout], so
/// separators can align with its content without knowing the row's widget type.
abstract interface class AcademyTableRowGeometry {
  double separatorStart(BuildContext context);
}

/// Where a row's separator starts: at its leading edge, or past its leading
/// content when the table theme has separators follow it.
double academyRowSeparatorStart(
  BuildContext context, {
  required bool hasLeading,
  double? start,
  double? leadingExtent,
  double? leadingGap,
}) {
  final theme = AcademyTheme.of(context);
  final inset = start ?? theme.paddings.tableRow.left;
  if (!hasLeading || !theme.table.separatorFollowsLeading) return inset;
  return inset +
      (leadingExtent ??
          theme.table.leadingExtent ??
          theme.sizes.rowIconExtent) +
      (leadingGap ?? theme.table.leadingGap);
}

/// Supplies the separator inset for an arbitrary composed row.
class AcademyTableRowLayout extends StatelessWidget
    implements AcademyTableRowGeometry {
  const AcademyTableRowLayout({
    super.key,
    required this.child,
    required this.separatorInset,
  }) : assert(separatorInset >= 0);

  final Widget child;
  final double separatorInset;

  @override
  double separatorStart(BuildContext context) => separatorInset;

  @override
  Widget build(BuildContext context) => child;
}

/// Provides table padding to rows without coupling it to a visual divider.
class AcademyTableRowScope extends InheritedWidget {
  const AcademyTableRowScope({super.key, required super.child});
  static bool contains(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<AcademyTableRowScope>() !=
      null;
  static double of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<AcademyTableRowScope>() == null
      ? 0
      : AcademyTheme.of(context).paddings.tableRow.left;
  @override
  bool updateShouldNotify(AcademyTableRowScope oldWidget) => false;
}
