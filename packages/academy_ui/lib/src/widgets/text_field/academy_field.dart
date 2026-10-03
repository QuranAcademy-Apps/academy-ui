import '../form/academy_field_decoration.dart';
import 'academy_text_input.dart';

import 'package:flutter/cupertino.dart';

/// Input with a visible header and optional help/error below it.
class AcademyField extends StatelessWidget {
  const AcademyField({
    super.key,
    required this.label,
    this.help,
    this.error,
    this.placeholder,
    this.enabled = true,
    this.readOnly = false,
    this.obscureText = false,
    this.autofocus = false,
    this.clearable = true,
    this.onChanged,
    this.onSubmitted,
    this.keyboardType,
    this.textInputAction = TextInputAction.done,
    this.controller,
    this.focusNode,
    this.leading,
    this.trailing,
    this.cornerRadius,
    this.padding,
  });
  final String label;
  final String? help, error, placeholder;
  final bool enabled, readOnly, obscureText, autofocus, clearable;
  final ValueChanged<String>? onChanged, onSubmitted;
  final TextInputType? keyboardType;
  final TextInputAction textInputAction;
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final Widget? leading, trailing;
  final double? cornerRadius;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) => AcademyFieldDecoration(
    label: label,
    help: help,
    error: error,
    child: AcademyTextInput(
      semanticLabel: label,
      controller: controller,
      focusNode: focusNode,
      onChanged: onChanged,
      onSubmitted: onSubmitted,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      placeholder: placeholder,
      leading: leading,
      trailing: trailing,
      enabled: enabled,
      readOnly: readOnly,
      obscureText: obscureText,
      autofocus: autofocus,
      clearable: clearable,
      cornerRadius: cornerRadius,
      padding: padding,
    ),
  );
}
