import 'package:flutter/cupertino.dart';

import '../../theme/academy_theme.dart';

class AcademyDivider extends StatelessWidget {
  const AcademyDivider({super.key});
  @override
  Widget build(BuildContext context) => Padding(
    padding: AcademyTheme.of(context).paddings.divider,
    child: Container(
      height: .5,
      color: AcademyTheme.of(context).colorScheme.outlineVariant,
    ),
  );
}

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
