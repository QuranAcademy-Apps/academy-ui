import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';

import '../../foundation/form/academy_owned_editing.dart';
import '../../foundation/overlay/academy_popover.dart';
import '../select/academy_option_results.dart';
import '../select/academy_select_option.dart';
import '../text_field/academy_text_form_field.dart';

/// Free text with optional suggestions. Use AcademySelect for restricted values.
class AcademyAutocomplete<T extends Object> extends StatefulWidget {
  const AcademyAutocomplete({
    super.key,
    required this.label,
    this.options = const [],
    this.loader,
    this.controller,
    this.focusNode,
    this.onChanged,
    this.onSelected,
    this.placeholder,
    this.help,
    this.placement = AcademyPopoverPlacement.auto,
    this.emptyMessage,
    this.emptyHint,
    this.enabled = true,
    this.validator,
    this.onSaved,
  });
  final String label;
  final List<AcademySelectOption<T>> options;
  final AcademyOptionLoader<T>? loader;
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final ValueChanged<String>? onChanged;
  final ValueChanged<T>? onSelected;
  final String? placeholder, help;
  final AcademyPopoverPlacement placement;
  final String? emptyMessage, emptyHint;
  final bool enabled;
  final FormFieldValidator<String>? validator;
  final FormFieldSetter<String>? onSaved;
  @override
  State<AcademyAutocomplete<T>> createState() => _AcademyAutocompleteState<T>();
}

class _AcademyAutocompleteState<T extends Object>
    extends State<AcademyAutocomplete<T>>
    with
        AcademyOwnedFocus<AcademyAutocomplete<T>>,
        AcademyOwnedController<AcademyAutocomplete<T>> {
  final _popover = AcademyPopoverController();
  final _inputKey = GlobalKey();
  final _resultsFocus = FocusScopeNode();
  TextEditingController get _controller => controller;
  FocusNode get _focus => focus;
  bool _committing = false;

  @override
  FocusNode? suppliedFocusNode(AcademyAutocomplete<T> widget) =>
      widget.focusNode;
  @override
  TextEditingController? suppliedController(AcademyAutocomplete<T> widget) =>
      widget.controller;

  @override
  void initState() {
    super.initState();
    attachController();
    attachFocus();
    _resultsFocus.addListener(onFocusChanged);
  }

  @override
  void onTextChanged() {
    if (!mounted) return;
    setState(() {});
    if (!_committing && widget.enabled && _focus.hasFocus) _popover.show();
  }

  @override
  void onFocusChanged() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (!widget.enabled || (!_focus.hasFocus && !_resultsFocus.hasFocus)) {
        _popover.hide();
      } else if (_focus.hasFocus && !_committing) {
        _popover.show();
      }
    });
  }

  @override
  void didUpdateWidget(covariant AcademyAutocomplete<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    updateController(oldWidget);
    updateFocus(oldWidget);
    if (!widget.enabled) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _popover.hide();
      });
    }
  }

  void _select(AcademySelectOption<T> option) {
    if (!widget.enabled) return;
    _committing = true;
    _controller.value = TextEditingValue(
      text: option.label,
      selection: TextSelection.collapsed(offset: option.label.length),
    );
    widget.onChanged?.call(option.label);
    widget.onSelected?.call(option.value);
    _focus.requestFocus();
    _popover.hide();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _committing = false;
    });
  }

  @override
  void dispose() {
    disposeController();
    disposeFocus();
    _resultsFocus.dispose();
    _popover.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AcademyPopover(
    controller: _popover,
    matchAnchorWidth: true,
    placement: widget.placement,
    anchorKey: _inputKey,
    requestFocus: false,
    consumeOutsideTaps: false,
    contentBuilder: (context, _) => FocusScope(
      node: _resultsFocus,
      child: AcademyOptionResults<T>(
        query: _controller.text,
        options: widget.options,
        loader: widget.loader,
        emptyMessage: widget.emptyMessage,
        emptyHint: widget.emptyHint,
        onSelected: _select,
      ),
    ),
    builder: (context, _) => CallbackShortcuts(
      bindings: {
        const SingleActivator(LogicalKeyboardKey.arrowDown): () {
          if (widget.enabled) {
            _popover.show();
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) _resultsFocus.nextFocus();
            });
          }
        },
      },
      child: AcademyTextFormField(
        inputKey: _inputKey,
        label: widget.label,
        help: widget.help,
        placeholder: widget.placeholder,
        controller: _controller,
        focusNode: _focus,
        enabled: widget.enabled,
        onChanged: widget.onChanged,
        validator: widget.validator,
        onSaved: widget.onSaved,
      ),
    ),
  );
}
