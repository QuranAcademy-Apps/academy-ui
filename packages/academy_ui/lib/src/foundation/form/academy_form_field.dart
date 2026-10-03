import 'package:flutter/widgets.dart';

/// Bridges an app-owned value to Flutter Form. Parent updates are not edits.
/// Reset requests the original value through onChanged; the app accepts it.
class AcademyFormField<T> extends FormField<T> {
  AcademyFormField({
    super.key,
    required this.value,
    required this.onChanged,
    required Widget Function(FormFieldState<T>, ValueChanged<T>) builder,
    super.validator,
    super.onSaved,
    super.forceErrorText,
    super.autovalidateMode,
    bool enabled = true,
  }) : super(
         initialValue: value,
         enabled: enabled && onChanged != null,
         builder: (state) => builder(
           state,
           (next) => (state as _AcademyFormFieldState<T>).change(next),
         ),
       );
  final T value;
  final ValueChanged<T>? onChanged;
  @override
  FormFieldState<T> createState() => _AcademyFormFieldState<T>();
}

class _AcademyFormFieldState<T> extends FormFieldState<T> {
  late final T _initial;
  @override
  void initState() {
    super.initState();
    _initial = field.value;
  }

  AcademyFormField<T> get field => widget as AcademyFormField<T>;
  @override
  void didUpdateWidget(covariant AcademyFormField<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    setValue(field.value);
  }

  void change(T next) {
    if (!widget.enabled) return;
    // Keep the parent as the sole owner, even when it rejects the request.
    didChange(field.value);
    field.onChanged?.call(next);
  }

  @override
  void reset() {
    super.reset();
    setValue(field.value);
    if (widget.enabled) field.onChanged?.call(_initial);
  }
}
