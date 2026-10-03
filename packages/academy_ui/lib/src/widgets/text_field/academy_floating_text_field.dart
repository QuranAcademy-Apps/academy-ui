import 'package:flutter/cupertino.dart';

import '../form/academy_field_decoration.dart';
import 'academy_text_input.dart';

/// An additional input style with an animated label inside the field.
/// Empty, unfocused fields show the label as a placeholder. Focusing or entering
/// text moves it above the value; clearing and leaving the field restores it.
class AcademyFloatingTextField extends StatelessWidget {
  const AcademyFloatingTextField({
    super.key,
    required this.label,
    this.controller,
    this.focusNode,
    this.help,
    this.error,
    this.trailing,
    this.onChanged,
    this.onSubmitted,
    this.enabled = true,
    this.readOnly = false,
    this.obscureText = false,
    this.autofocus = false,
    this.clearable = true,
    this.keyboardType,
    this.textInputAction = TextInputAction.done,
  });

  final String label;
  final String? help, error;
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final Widget? trailing;
  final ValueChanged<String>? onChanged, onSubmitted;
  final bool enabled, readOnly, obscureText, autofocus, clearable;
  final TextInputType? keyboardType;
  final TextInputAction textInputAction;

  @override
  Widget build(BuildContext context) => AcademyFieldDecoration(
    help: help,
    error: error,
    child: AcademyTextInput(
      floatingLabel: label,
      semanticLabel: label,
      controller: controller,
      focusNode: focusNode,
      trailing: trailing,
      onChanged: onChanged,
      onSubmitted: onSubmitted,
      enabled: enabled,
      readOnly: readOnly,
      obscureText: obscureText,
      autofocus: autofocus,
      clearable: clearable,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
    ),
  );
}
