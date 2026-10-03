import 'package:flutter/widgets.dart';

@immutable
class AcademySelectOption<T extends Object> {
  const AcademySelectOption({
    required this.value,
    required this.label,
    this.subtitle,
    this.leading,
    this.group,
    this.enabled = true,
  });
  final T value;
  final String label;
  final String? subtitle, group;
  final Widget? leading;
  final bool enabled;
}
