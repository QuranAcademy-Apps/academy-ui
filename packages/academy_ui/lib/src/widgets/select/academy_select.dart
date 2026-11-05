import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';

import '../../foundation/form/academy_form_field.dart';
import '../../foundation/interaction/academy_tappable.dart';
import '../../foundation/localizations/academy_localizations.dart';
import '../../foundation/overlay/academy_popover.dart';
import '../../theme/academy_theme.dart';
import '../form/academy_field_decoration.dart';
import '../icon/academy_sf_image.dart';
import '../modal/academy_modal.dart';
import '../menu/academy_menu.dart';
import '../menu/academy_menu_item.dart';
import '../text_field/academy_text_input.dart';
import 'academy_option_results.dart';
import 'academy_select_option.dart';

enum AcademySelectPresentation {
  adaptive,
  sheet,
  popover,

  /// Pull-down menu for local options, without a search field. Multiple
  /// selections apply immediately and keep the menu open. A remote loader
  /// uses the searchable popover instead.
  menu,
}

String _selectionLabel<T extends Object>(
  T value,
  List<AcademySelectOption<T>> options,
  String Function(T)? labelFor,
) {
  for (final option in options) {
    if (option.value == value) return option.label;
  }
  return labelFor?.call(value) ?? value.toString();
}

class AcademySelect<T extends Object> extends StatelessWidget {
  const AcademySelect({
    super.key,
    required this.value,
    required this.onChanged,
    required this.options,
    required this.label,
    this.placeholder,
    this.help,
    this.enabled = true,
    this.searchable = false,
    this.loader,
    this.labelFor,
    this.presentation = AcademySelectPresentation.adaptive,
    this.placement = AcademyPopoverPlacement.auto,
    this.validator,
    this.onSaved,
    this.autovalidateMode = AutovalidateMode.disabled,
  });
  final T? value;
  final ValueChanged<T?>? onChanged;
  final List<AcademySelectOption<T>> options;
  final String label;
  final String? placeholder, help;
  final bool enabled, searchable;
  final AcademyOptionLoader<T>? loader;

  /// Formats selections absent from [options], for example remote results.
  final String Function(T)? labelFor;
  final AcademySelectPresentation presentation;
  final AcademyPopoverPlacement placement;
  final FormFieldValidator<T>? validator;
  final FormFieldSetter<T>? onSaved;
  final AutovalidateMode autovalidateMode;
  @override
  Widget build(BuildContext context) => AcademyFormField<T?>(
    value: value,
    onChanged: onChanged,
    enabled: enabled,
    validator: validator,
    onSaved: onSaved,
    autovalidateMode: autovalidateMode,
    builder: (field, change) => AcademyFieldDecoration(
      label: label,
      help: help,
      error: field.errorText,
      child: _SelectControl<T>(
        label: label,
        placeholder: placeholder,
        values: {if (value != null) value!},
        options: options,
        enabled: enabled && onChanged != null,
        searchable: searchable,
        loader: loader,
        labelFor: labelFor,
        presentation: presentation,
        placement: placement,
        multiple: false,
        onChanged: (values) => change(values.isEmpty ? null : values.first),
      ),
    ),
  );
}

class AcademyMultiSelect<T extends Object> extends StatelessWidget {
  const AcademyMultiSelect({
    super.key,
    required this.values,
    required this.onChanged,
    required this.options,
    required this.label,
    this.help,
    this.enabled = true,
    this.searchable = true,
    this.loader,
    this.labelFor,
    this.presentation = AcademySelectPresentation.adaptive,
    this.placement = AcademyPopoverPlacement.auto,
    this.validator,
    this.onSaved,
    this.autovalidateMode = AutovalidateMode.disabled,
  });
  final Set<T> values;
  final ValueChanged<Set<T>>? onChanged;
  final List<AcademySelectOption<T>> options;
  final String label;
  final String? help;
  final bool enabled, searchable;
  final AcademyOptionLoader<T>? loader;

  /// Formats selections absent from [options], for example remote results.
  final String Function(T)? labelFor;
  final AcademySelectPresentation presentation;
  final AcademyPopoverPlacement placement;
  final FormFieldValidator<Set<T>>? validator;
  final FormFieldSetter<Set<T>>? onSaved;
  final AutovalidateMode autovalidateMode;
  @override
  Widget build(BuildContext context) => AcademyFormField<Set<T>>(
    value: Set.unmodifiable(values),
    onChanged: onChanged,
    enabled: enabled,
    validator: validator,
    onSaved: onSaved,
    autovalidateMode: autovalidateMode,
    builder: (field, change) => AcademyFieldDecoration(
      label: label,
      help: help,
      error: field.errorText,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _SelectControl<T>(
            label: label,
            values: values,
            options: options,
            enabled: enabled && onChanged != null,
            searchable: searchable,
            loader: loader,
            labelFor: labelFor,
            presentation: presentation,
            placement: placement,
            multiple: true,
            onChanged: change,
          ),
          if (values.isNotEmpty)
            Wrap(
              spacing: 8,
              children: [
                for (final value in values)
                  CupertinoButton(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    onPressed: enabled && onChanged != null
                        ? () => change(
                            Set.unmodifiable({...values}..remove(value)),
                          )
                        : null,
                    child: Semantics(
                      label: AcademyLocalizations.of(
                        context,
                      ).removeItem(_selectionLabel(value, options, labelFor)),
                      excludeSemantics: true,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Flexible(
                            child: Text(
                              _selectionLabel(value, options, labelFor),
                            ),
                          ),
                          const SizedBox(width: 6),
                          const AcademySfIcon(AcademySymbols.close, size: 12),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
        ],
      ),
    ),
  );
}

class _SelectControl<T extends Object> extends StatefulWidget {
  const _SelectControl({
    required this.label,
    required this.values,
    required this.options,
    required this.enabled,
    required this.searchable,
    required this.presentation,
    required this.placement,
    required this.multiple,
    required this.onChanged,
    this.loader,
    this.labelFor,
    this.placeholder,
  });
  final String label;
  final String? placeholder;
  final Set<T> values;
  final List<AcademySelectOption<T>> options;
  final bool enabled, searchable, multiple;
  final AcademySelectPresentation presentation;
  final AcademyPopoverPlacement placement;
  final AcademyOptionLoader<T>? loader;
  final String Function(T)? labelFor;
  final ValueChanged<Set<T>> onChanged;
  @override
  State<_SelectControl<T>> createState() => _SelectControlState<T>();
}

class _SelectControlState<T extends Object> extends State<_SelectControl<T>> {
  final _popover = AcademyPopoverController();
  final _focus = FocusNode();
  @override
  void initState() {
    super.initState();
    _popover.addListener(_openChanged);
  }

  void _openChanged() => setState(() {});
  @override
  void didUpdateWidget(covariant _SelectControl<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!widget.enabled && _popover.isOpen) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _popover.hide();
      });
    }
  }

  bool get _sheet =>
      widget.presentation == AcademySelectPresentation.sheet ||
      (widget.presentation == AcademySelectPresentation.adaptive &&
          AcademyTheme.of(context).interaction.density == AcademyDensity.touch);
  Future<void> _open() async {
    if (!widget.enabled) return;
    _focus.requestFocus();
    if (!_sheet) {
      _popover.toggle();
      return;
    }
    final result = await showAcademyModal<Set<T>>(
      context,
      title: widget.label,
      builder: (context) => _SelectionPanel<T>(
        options: widget.options,
        selected: {...widget.values},
        multiple: widget.multiple,
        searchable: widget.searchable,
        loader: widget.loader,
        draft: true,
        onChanged: (values) => closeAcademyModal(context, values),
      ),
    );
    if (mounted && widget.enabled && result != null) {
      widget.onChanged(Set.unmodifiable(result));
    }
  }

  @override
  void dispose() {
    _popover.removeListener(_openChanged);
    _popover.dispose();
    _focus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = AcademyTheme.of(context);
    final strings = AcademyLocalizations.of(context);
    final text = widget.values.isEmpty
        ? widget.placeholder ?? strings.choose
        : widget.multiple
        ? strings.selectedCount(widget.values.length)
        : _selectionLabel(widget.values.first, widget.options, widget.labelFor);
    Widget trigger(VoidCallback open) => AcademyTappable(
      focusNode: _focus,
      focusColor: theme.colorScheme.textFieldFocusBorder,
      label: widget.label,
      borderRadius: BorderRadius.circular(theme.radii.field),
      onPressed: widget.enabled ? open : null,
      builder: (context, states) => Container(
        padding: theme.paddings.field,
        decoration: BoxDecoration(
          color: widget.enabled
              ? theme.colorScheme.textFieldBackground
              : theme.colorScheme.textFieldDisabledBackground,
          borderRadius: BorderRadius.circular(theme.radii.field),
          border: Border.all(
            color: MediaQuery.highContrastOf(context)
                ? AcademyContrast.foreground(
                    theme.colorScheme.textFieldDisabledBorder,
                    widget.enabled
                        ? theme.colorScheme.textFieldBackground
                        : theme.colorScheme.textFieldDisabledBackground,
                    minimum: 3,
                  )
                : !widget.enabled
                ? theme.colorScheme.textFieldDisabledBorder
                : theme.colorScheme.textFieldBorder,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                text,
                style: theme.textTheme.bodyLarge.copyWith(
                  color: widget.enabled
                      ? (widget.values.isEmpty
                            ? theme.colorScheme.textFieldSecondaryForeground
                            : theme.colorScheme.textFieldForeground)
                      : theme.colorScheme.textFieldDisabledForeground,
                ),
              ),
            ),
            const SizedBox(width: 8),
            AcademySfIcon(
              AcademySymbols.upDown,
              size: 16,
              color: widget.enabled
                  ? theme.colorScheme.textFieldSecondaryForeground
                  : theme.colorScheme.textFieldDisabledForeground,
            ),
          ],
        ),
      ),
    );

    if (widget.presentation == AcademySelectPresentation.menu &&
        widget.loader == null) {
      return AcademyMenu(
        width: (MediaQuery.sizeOf(context).width - 32).clamp(0, 320),
        maxHeight: 360,
        items: [
          for (final option in widget.options)
            AcademyMenuItem(
              title: option.label,
              subtitle: option.subtitle,
              leading: option.leading,
              checked: widget.values.contains(option.value),
              closeOnSelect: !widget.multiple,
              onPressed: widget.enabled && option.enabled
                  ? () {
                      final next = widget.multiple ? {...widget.values} : <T>{};
                      if (widget.multiple && next.contains(option.value)) {
                        next.remove(option.value);
                      } else {
                        next.add(option.value);
                      }
                      widget.onChanged(Set.unmodifiable(next));
                    }
                  : null,
            ),
        ],
        builder: (context, toggle) => trigger(() {
          _focus.requestFocus();
          toggle();
        }),
      );
    }
    return AcademyPopover(
      controller: _popover,
      matchAnchorWidth: true,
      placement: widget.placement,
      contentBuilder: (context, close) => _SelectionPanel<T>(
        options: widget.options,
        selected: widget.values,
        multiple: widget.multiple,
        searchable: widget.searchable,
        loader: widget.loader,
        draft: false,
        onChanged: (values) {
          if (!widget.enabled) return;
          widget.onChanged(Set.unmodifiable(values));
          if (!widget.multiple) close();
        },
      ),
      builder: (context, _) => trigger(_open),
    );
  }
}

class _SelectionPanel<T extends Object> extends StatefulWidget {
  const _SelectionPanel({
    required this.options,
    required this.selected,
    required this.multiple,
    required this.searchable,
    required this.draft,
    required this.onChanged,
    this.loader,
  });
  final List<AcademySelectOption<T>> options;
  final Set<T> selected;
  final bool multiple, searchable, draft;
  final AcademyOptionLoader<T>? loader;
  final ValueChanged<Set<T>> onChanged;
  @override
  State<_SelectionPanel<T>> createState() => _SelectionPanelState<T>();
}

class _SelectionPanelState<T extends Object> extends State<_SelectionPanel<T>> {
  final _search = TextEditingController();
  late Set<T> _draft = {...widget.selected};
  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final selected = widget.draft ? _draft : widget.selected;
    return Shortcuts(
      shortcuts: const {
        SingleActivator(LogicalKeyboardKey.arrowDown): NextFocusIntent(),
        SingleActivator(LogicalKeyboardKey.arrowUp): PreviousFocusIntent(),
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (widget.searchable)
            Padding(
              padding: AcademyTheme.of(context).paddings.field,
              child: AcademyTextInput(
                backgroundColor: AcademyTheme.of(context)
                    .colorScheme
                    .textFieldSecondaryBackground,
                highlightOnFocus: false,
                bordered: false,
                leading: AcademySfIcon(
                  AcademySymbols.search,
                  size: 18,
                  color: AcademyTheme.of(context)
                      .colorScheme
                      .textFieldSecondaryForeground,
                ),
                controller: _search,
                semanticLabel: AcademyLocalizations.of(context).search,
                placeholder: AcademyLocalizations.of(context).search,
                onChanged: (_) => setState(() {}),
              ),
            ),
          Flexible(
            child: AcademyOptionResults<T>(
              query: _search.text,
              options: widget.options,
              loader: widget.loader,
              selected: selected,
              onSelected: (option) {
                final next = <T>{};
                // Work on a fresh set; app-owned selections are never mutated.
                next.addAll(widget.multiple ? selected : <T>{});
                if (widget.multiple && next.contains(option.value)) {
                  next.remove(option.value);
                } else {
                  next.add(option.value);
                }
                if (widget.draft && widget.multiple) {
                  setState(() => _draft = next);
                } else {
                  widget.onChanged(next);
                }
              },
            ),
          ),
          if (widget.draft && widget.multiple)
            CupertinoButton(
              onPressed: () => widget.onChanged(_draft),
              child: Text(AcademyLocalizations.of(context).done),
            ),
        ],
      ),
    );
  }
}
