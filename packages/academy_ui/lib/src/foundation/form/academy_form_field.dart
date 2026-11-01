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
  int _changeRevision = 0;
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
    final revision = ++_changeRevision;
    field.onChanged?.call(next);
    // Let the controlled parent rebuild before Form.onChanged reads/saves us.
    // A rejected request still marks interaction, using the parent's value.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && revision == _changeRevision) didChange(field.value);
    });
    WidgetsBinding.instance.ensureVisualUpdate();
  }

  @override
  void reset() {
    ++_changeRevision;
    super.reset();
    setValue(field.value);
    if (widget.enabled) field.onChanged?.call(_initial);
  }
}
