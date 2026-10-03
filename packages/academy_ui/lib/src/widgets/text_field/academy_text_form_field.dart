import 'package:flutter/cupertino.dart';

import 'academy_text_input.dart';
import '../form/academy_field_decoration.dart';

/// Flutter Form integration. External controllers and focus nodes stay owned by
/// the caller. Omitting a controller uses the initialValue owned by this field.
class AcademyTextFormField extends FormField<String> {
  AcademyTextFormField({
    super.key,
    this.controller,
    String? initialValue,
    this.onChanged,
    Key? inputKey,
    FocusNode? focusNode,
    String? label,
    bool floatingLabel = false,
    String? help,
    String? placeholder,
    bool readOnly = false,
    bool obscureText = false,
    Widget? leading,
    Widget? trailing,
    TextInputType? keyboardType,
    TextInputAction textInputAction = TextInputAction.done,
    super.enabled,
    super.validator,
    super.onSaved,
    super.onReset,
    super.forceErrorText,
    super.autovalidateMode,
  }) : assert(controller == null || initialValue == null),
       super(
         initialValue: controller?.text ?? initialValue ?? '',
         builder: (field) {
           final state = field as _AcademyTextFormFieldState;
           return AcademyFieldDecoration(
             label: floatingLabel ? null : label,
             help: help,
             error: state.errorText,
             child: AcademyTextInput(
               key: inputKey,
               controller: state.controller,
               focusNode: focusNode,
               semanticLabel: label,
               floatingLabel: floatingLabel ? label : null,
               placeholder: placeholder,
               enabled: enabled,
               readOnly: readOnly,
               obscureText: obscureText,
               leading: leading,
               trailing: trailing,
               keyboardType: keyboardType,
               textInputAction: textInputAction,
               onChanged: onChanged,
             ),
           );
         },
       );
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  @override
  FormFieldState<String> createState() => _AcademyTextFormFieldState();
}

class _AcademyTextFormFieldState extends FormFieldState<String> {
  TextEditingController? _owned;
  AcademyTextFormField get field => widget as AcademyTextFormField;
  TextEditingController get controller => field.controller ?? _owned!;
  @override
  void initState() {
    super.initState();
    if (field.controller == null) _owned = TextEditingController(text: value);
    controller.addListener(_changed);
  }

  void _changed() {
    if (value != controller.text) didChange(controller.text);
  }

  @override
  void didUpdateWidget(covariant AcademyTextFormField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != field.controller) {
      final old = oldWidget.controller ?? _owned!;
      old.removeListener(_changed);
      if (field.controller == null) {
        _owned = TextEditingController.fromValue(old.value);
      } else {
        _owned?.dispose();
        _owned = null;
      }
      setValue(controller.text);
      controller.addListener(_changed);
    }
  }

  @override
  void reset() {
    // Avoid treating a reset as user interaction.
    controller.removeListener(_changed);
    controller.text = widget.initialValue ?? '';
    super.reset();
    controller.addListener(_changed);
    field.onChanged?.call(controller.text);
  }

  @override
  void dispose() {
    controller.removeListener(_changed);
    _owned?.dispose();
    super.dispose();
  }
}
