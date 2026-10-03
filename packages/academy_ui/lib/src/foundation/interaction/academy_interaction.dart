import 'package:flutter/semantics.dart';
import 'package:flutter/widgets.dart';

/// Share one named, focusable action node with the native button underneath.
class AcademyActionSemantics extends StatelessWidget {
  const AcademyActionSemantics({
    super.key,
    required this.label,
    required this.enabled,
    required this.child,
    this.value,
    this.selected,
    this.expanded,
    this.customActions,
  });
  final String label;
  final bool enabled;
  final Widget child;
  final String? value;
  final bool? selected, expanded;
  final Map<CustomSemanticsAction, VoidCallback>? customActions;
  @override
  Widget build(BuildContext context) => !enabled
      ? AcademyInteractionBlocker(
          enabled: false,
          label: label,
          value: value,
          button: true,
          selected: selected,
          expanded: expanded,
          child: child,
        )
      : MergeSemantics(
          child: Semantics(
            label: label,
            value: value,
            button: true,
            enabled: enabled,
            selected: selected,
            expanded: expanded,
            customSemanticsActions: enabled ? customActions : null,
            child: child,
          ),
        );
}

/// Disabled composite controls block pointer, keyboard and accessibility actions.
class AcademyInteractionBlocker extends StatelessWidget {
  const AcademyInteractionBlocker({
    super.key,
    required this.enabled,
    required this.label,
    required this.child,
    this.value,
    this.button = false,
    this.checked,
    this.selected,
    this.expanded,
  });
  final bool enabled, button;
  final bool? checked, selected, expanded;
  final String label;
  final String? value;
  final Widget child;
  @override
  Widget build(BuildContext context) => enabled
      ? child
      : Semantics(
          label: label,
          value: value,
          enabled: false,
          button: button,
          checked: checked,
          selected: selected,
          expanded: expanded,
          excludeSemantics: true,
          child: ExcludeFocus(child: AbsorbPointer(child: child)),
        );
}
