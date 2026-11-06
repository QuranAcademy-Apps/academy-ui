import 'package:flutter/cupertino.dart';

import '../../foundation/table/academy_table_row_scope.dart';
import '../../theme/academy_theme.dart';
import '../icon/academy_sf_image.dart';
import 'academy_menu_anchor.dart';
import 'academy_menu_item.dart';

/// Settings row with the value beside its label, opening an anchored menu
/// below the row's trailing edge; label and value stack at narrow widths and
/// large text. Ported from Yalla's option menu (2026-11-02).
///
/// Quran AppMenuAnchor + AppMenuCheckmark pattern. A short selection stays
/// anchored to its trigger and never opens a modal route.
class AcademyInlineOptionMenu extends StatelessWidget
    implements AcademyTableRowGeometry {
  const AcademyInlineOptionMenu({
    super.key,
    required this.label,
    required this.value,
    required this.options,
    required this.onSelected,
    this.icon,
    this.optionLabel,
    this.menuConstraints,
  });
  final String label;
  final String value;
  final List<String> options;
  final ValueChanged<String> onSelected;
  final IconData? icon;

  /// Display names for stable option IDs. Selection always returns the ID.
  final String Function(String)? optionLabel;
  final BoxConstraints? menuConstraints;

  String _labelFor(String option) => optionLabel?.call(option) ?? option;

  @override
  double separatorStart(BuildContext context) =>
      academyRowSeparatorStart(context, hasLeading: icon != null);

  @override
  Widget build(BuildContext context) => AcademyMenuAnchor(
    consumeOutsideTaps: true,
    constraints: menuConstraints,
    menuChildren: [
      for (final option in options)
        AcademyMenuItem(
          key: optionLabel == null ? null : ValueKey(option),
          title: _labelFor(option),
          checked: option == value,
          actsWhenChecked: false,
          onPressed: () => onSelected(option),
        ),
    ],
    builder: (context, controller, child) => CupertinoButton(
      padding: EdgeInsets.symmetric(
        vertical: 12,
        horizontal: AcademyTableRowScope.of(context),
      ),
      onPressed: () {
        if (controller.isOpen) {
          controller.close();
        } else {
          final box = context.findRenderObject()! as RenderBox;
          controller.open(position: Offset(box.size.width, box.size.height));
        }
      },
      child: Row(
        children: [
          if (icon != null) ...[
            AcademySfIcon(
              icon!,
              size: AcademyTheme.of(context).sizes.rowIcon,
              boxSize: AcademyTheme.of(context).sizes.rowIconExtent,
            ),
            const SizedBox(width: 12),
          ],
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final theme = AcademyTheme.of(context);
                final valueText = Text(
                  _labelFor(value),
                  textAlign: TextAlign.end,
                  style: theme.textTheme.bodyLarge.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                );
                if (constraints.maxWidth < 180 ||
                    MediaQuery.textScalerOf(context).scale(17) > 22) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        label,
                        style: theme.textTheme.bodySmall.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _labelFor(value),
                        textAlign: TextAlign.end,
                        style: theme.textTheme.bodyLarge,
                      ),
                    ],
                  );
                }
                return Row(
                  children: [
                    ConstrainedBox(
                      constraints: BoxConstraints(
                        maxWidth: (constraints.maxWidth - 12) / 2,
                      ),
                      child: Text(label, style: theme.textTheme.bodyLarge),
                    ),
                    const SizedBox(width: 12),
                    Expanded(child: valueText),
                  ],
                );
              },
            ),
          ),
          const SizedBox(width: 8),
          AcademySfIcon(
            AcademyTheme.of(context).icons.down,
            size: AcademyTheme.of(context).sizes.indicatorIcon,
            color: AcademyTheme.of(context).colorScheme.labelTertiary,
          ),
        ],
      ),
    ),
  );
}
