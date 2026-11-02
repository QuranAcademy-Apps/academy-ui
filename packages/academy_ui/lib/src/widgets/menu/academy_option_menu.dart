import '../../foundation/table/academy_table_row_scope.dart';
import '../../theme/academy_theme.dart';

import 'academy_menu.dart';
import 'academy_menu_item.dart';

import 'package:flutter/cupertino.dart';

/// Quran AppMenuAnchor + AppMenuCheckmark pattern. A short selection stays
/// anchored to its trigger and never opens a modal route.
class AcademyOptionMenu extends StatelessWidget
    implements AcademyTableRowGeometry {
  const AcademyOptionMenu({
    super.key,
    required this.label,
    required this.value,
    required this.options,
    required this.onSelected,
    this.icon,
    this.activation = AcademyMenuActivation.row,
    this.menuWidth,
    this.menuMaxHeight,
    this.useRootOverlay,
  });
  final String label, value;
  final List<String> options;
  final ValueChanged<String> onSelected;
  final IconData? icon;
  final AcademyMenuActivation activation;
  final double? menuWidth, menuMaxHeight;
  final bool? useRootOverlay;
  @override
  double separatorStart(BuildContext context) =>
      AcademyTheme.of(context).paddings.tableRow.left +
      (icon != null
          ? AcademyTokens.tableIconExtent + AcademyTokens.inlineGap
          : 0);

  @override
  Widget build(BuildContext context) => AcademyMenuRow(
    label: label,
    value: value,
    icon: icon,
    activation: activation,
    menuWidth: menuWidth,
    menuMaxHeight: menuMaxHeight,
    useRootOverlay: useRootOverlay,
    items: [
      for (final option in options)
        AcademyMenuItem(
          title: option,
          checked: option == value,
          actsWhenChecked: false,
          onPressed: () => onSelected(option),
        ),
    ],
  );
}
