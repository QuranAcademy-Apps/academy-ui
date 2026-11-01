part of '../grouped_table.dart';

sealed class GroupedTableAccessory {
  const GroupedTableAccessory();

  const factory GroupedTableAccessory.none() = _AppAccessoryNone;

  const factory GroupedTableAccessory.selected({bool isSelected}) =
      _AppAccessorySelected;

  const factory GroupedTableAccessory.disclosure({double? turns}) =
      _AppAccessoryDisclosure;

  const factory GroupedTableAccessory.trailingText(String text) =
      _AppAccessoryTrailingText;

  const factory GroupedTableAccessory.trailingTextDisclosure(String text) =
      _AppAccessoryTrailingTextDisclosure;

  const factory GroupedTableAccessory.toggle({
    required bool value,
    required ValueChanged<bool>? onChanged,
  }) = _AppAccessoryToggle;

  const factory GroupedTableAccessory.toggleWithButton({
    required bool value,
    required ValueChanged<bool>? onChanged,
    required VoidCallback? onButtonPressed,
  }) = _AppAccessoryToggleWithButton;

  const factory GroupedTableAccessory.menu({
    required String title,
    required List<Widget> Function(BuildContext context) itemBuilder,
    bool? useRootOverlay,
  }) = _AppAccessoryMenu;

  const factory GroupedTableAccessory.segmented({required Widget child}) =
      _AppAccessorySegmented;

  const factory GroupedTableAccessory.button({
    required Widget child,
    VoidCallback? onPressed,
    Size? size,
    String? semanticLabel,
    String? semanticHint,
  }) = _AppAccessoryButton;

  const factory GroupedTableAccessory.stepper({
    required VoidCallback? onDecrease,
    required VoidCallback? onIncrease,
  }) = _AppAccessoryStepper;

  const factory GroupedTableAccessory.dragHandle() = _AppAccessoryDragHandle;

  /// Escape hatch for one-off trailing layouts; prefer named factories above.
  const factory GroupedTableAccessory.custom(Widget child) =
      _AppAccessoryCustom;
}

class _AppAccessoryNone extends GroupedTableAccessory {
  const _AppAccessoryNone();
}

class _AppAccessorySelected extends GroupedTableAccessory {
  const _AppAccessorySelected({this.isSelected = true});

  final bool isSelected;
}

class _AppAccessoryDisclosure extends GroupedTableAccessory {
  const _AppAccessoryDisclosure({this.turns});

  final double? turns;
}

class _AppAccessoryTrailingText extends GroupedTableAccessory {
  const _AppAccessoryTrailingText(this.text);

  final String text;
}

class _AppAccessoryTrailingTextDisclosure extends GroupedTableAccessory {
  const _AppAccessoryTrailingTextDisclosure(this.text);

  final String text;
}

class _AppAccessoryToggle extends GroupedTableAccessory {
  const _AppAccessoryToggle({required this.value, required this.onChanged});

  final bool value;
  final ValueChanged<bool>? onChanged;
}

class _AppAccessoryToggleWithButton extends GroupedTableAccessory {
  const _AppAccessoryToggleWithButton({
    required this.value,
    required this.onChanged,
    required this.onButtonPressed,
  });

  final bool value;
  final ValueChanged<bool>? onChanged;
  final VoidCallback? onButtonPressed;
}

class _AppAccessoryMenu extends GroupedTableAccessory {
  const _AppAccessoryMenu({
    required this.title,
    required this.itemBuilder,
    this.useRootOverlay,
  });

  final String title;
  final List<Widget> Function(BuildContext context) itemBuilder;
  final bool? useRootOverlay;
}

class _AppAccessorySegmented extends GroupedTableAccessory {
  const _AppAccessorySegmented({required this.child});

  final Widget child;
}

class _AppAccessoryButton extends GroupedTableAccessory {
  const _AppAccessoryButton({
    required this.child,
    this.onPressed,
    this.size,
    this.semanticLabel,
    this.semanticHint,
  });

  final Widget child;
  final VoidCallback? onPressed;
  final Size? size;
  final String? semanticLabel;
  final String? semanticHint;
}

class _AppAccessoryStepper extends GroupedTableAccessory {
  const _AppAccessoryStepper({
    required this.onDecrease,
    required this.onIncrease,
  });

  final VoidCallback? onDecrease;
  final VoidCallback? onIncrease;
}

class _AppAccessoryDragHandle extends GroupedTableAccessory {
  const _AppAccessoryDragHandle();
}

class _AppAccessoryCustom extends GroupedTableAccessory {
  const _AppAccessoryCustom(this.child);

  final Widget child;
}
