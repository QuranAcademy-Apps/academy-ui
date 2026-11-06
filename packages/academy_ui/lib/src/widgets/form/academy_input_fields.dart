import 'dart:math' as math;

import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';

import '../../foundation/form/academy_field_style.dart';
import '../../foundation/form/academy_owned_editing.dart';
import '../../foundation/localizations/academy_localizations.dart';
import '../../foundation/table/academy_table_row_scope.dart';
import '../../theme/academy_theme.dart';
import '../../foundation/form/academy_form_field.dart';
import '../button/academy_button.dart';
import '../calendar/academy_calendar.dart';
import '../icon/academy_sf_image.dart';
import '../modal/academy_modal.dart';
import '../table/academy_row.dart';

// Ported from Yalla's yalla_floating_fields.dart (2026-11-02), itself adapted
// from academy_text_input.dart, academy_select.dart and academy_picker_fields.
// Inline form fields of grouped forms: a saved value row, a floating-label
// input, a field-shaped picker trigger and a date field with a wheel sheet.
// Controllers and business values stay with the caller.
/// Saved values are grouped rows, with no input outline or editable affordance.
class AcademyReadOnlyField extends AcademyRow {
  const AcademyReadOnlyField({
    super.key,
    required this.label,
    required this.value,
    this.locked = false,
    this.stackTrailingForLargeText = false,
    super.trailing,
    super.detail,
  }) : super(title: label);
  final String label, value;
  final bool locked, stackTrailingForLargeText;
  @override
  Widget build(BuildContext context) {
    final theme = AcademyTheme.of(context);
    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: 58),
      child: Padding(
        padding: EdgeInsets.symmetric(
          vertical: 9,
          horizontal: AcademyTableRowScope.of(context),
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final text = Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  style: theme.textTheme.bodySmall.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                Text(value, style: theme.textTheme.bodyLarge),
                if (detail != null) ...[const SizedBox(height: 4), detail!],
              ],
            );
            if (trailing != null &&
                stackTrailingForLargeText &&
                MediaQuery.textScalerOf(context).scale(17) > 24) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  text,
                  const SizedBox(height: 8),
                  Align(
                    alignment: AlignmentDirectional.centerEnd,
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        maxWidth: constraints.maxWidth * .75,
                      ),
                      child: trailing!,
                    ),
                  ),
                ],
              );
            }
            return Row(
              children: [
                Expanded(child: text),
                if (trailing != null) ...[
                  const SizedBox(width: 12),
                  ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: constraints.maxWidth * .5,
                    ),
                    child: trailing!,
                  ),
                ] else if (locked) ...[
                  const SizedBox(width: 12),
                  AcademySfIcon(
                    AcademyTheme.of(context).icons.readOnly,
                    size: AcademyTheme.of(context).sizes.smallControlIcon,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ],
              ],
            );
          },
        ),
      ),
    );
  }
}

class AcademyFloatingInput extends StatefulWidget {
  const AcademyFloatingInput({
    super.key,
    required this.label,
    this.controller,
    this.enabled = true,
    this.readOnly = false,
    this.autofocus = false,
    this.help,
    this.error,
    this.onChanged,
    this.onSubmitted,
    this.textInputAction,
    this.keyboardType,
    this.inputFormatters,
    this.obscure = false,
    this.maxLines = 1,
    this.focusNode,
    this.placeholder,
    this.placeholderColor,
    this.autofillHints,
    this.suffix,
    this.valueOverlay,
    this.valueStyle,
    this.invalid = false,
    this.highlight = false,
    this.clearOnlyWhenFocused = false,
    this.allowClear = true,
    this.reserveClearSpace = true,
    this.minimumHeight,
    this.cornerRadius,
    this.focusedBorderWidth = 1,
  });
  final String label;

  /// Owned by the caller; omitted, the field owns one.
  final TextEditingController? controller;
  final bool enabled, readOnly, autofocus, obscure;

  /// Shown below the field while there is no [error].
  final String? help;
  final String? error;
  final ValueChanged<String>? onChanged, onSubmitted;
  final TextInputAction? textInputAction;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final int maxLines;
  final FocusNode? focusNode;
  final String? placeholder;
  final Color? placeholderColor;
  final Iterable<String>? autofillHints;
  final Widget? suffix, valueOverlay;
  final TextStyle? valueStyle;
  final bool invalid, highlight;
  final bool clearOnlyWhenFocused, allowClear;

  /// Keep the usual form geometry; compact columns may reclaim the hidden icon.
  final bool reserveClearSpace;
  final double focusedBorderWidth;

  /// Default: the theme's field height.
  final double? minimumHeight;

  /// Default: the theme's field radius.
  final double? cornerRadius;

  @override
  State<AcademyFloatingInput> createState() => _AcademyFloatingInputState();
}

class _AcademyFloatingInputState extends State<AcademyFloatingInput>
    with
        AcademyOwnedFocus<AcademyFloatingInput>,
        AcademyOwnedController<AcademyFloatingInput> {
  FocusNode get _focus => focus;
  TextEditingController get _controller => controller;

  @override
  FocusNode? suppliedFocusNode(AcademyFloatingInput widget) => widget.focusNode;
  @override
  TextEditingController? suppliedController(AcademyFloatingInput widget) =>
      widget.controller;
  @override
  void onFocusChanged() => setState(() {});
  @override
  void onTextChanged() => setState(() {});

  @override
  void initState() {
    super.initState();
    attachFocus();
    attachController();
  }

  @override
  void didUpdateWidget(covariant AcademyFloatingInput oldWidget) {
    super.didUpdateWidget(oldWidget);
    updateController(oldWidget);
    updateFocus(oldWidget);
    if (!widget.enabled) _focus.unfocus();
  }

  @override
  void dispose() {
    disposeController();
    disposeFocus();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = AcademyTheme.of(context);
    final colors = theme.colorScheme;
    final raised =
        _focus.hasFocus ||
        _controller.text.isNotEmpty ||
        widget.placeholder != null;
    final duration = MediaQuery.disableAnimationsOf(context)
        ? Duration.zero
        : const Duration(milliseconds: 180);
    final labelStyle = theme.textTheme.fieldLabel;
    final valueStyle = (widget.valueStyle ?? theme.textTheme.bodyLarge)
        .copyWith(height: 1.2);
    final canClear =
        widget.enabled &&
        !widget.readOnly &&
        widget.allowClear &&
        _controller.text.isNotEmpty &&
        (!widget.clearOnlyWhenFocused || _focus.hasFocus);
    final labelHeight =
        MediaQuery.textScalerOf(context).scale(labelStyle.fontSize ?? 13) *
        (labelStyle.height ?? 1.2);
    final minimumHeight = widget.minimumHeight ?? theme.sizes.fieldHeight;
    final verticalInset = (minimumHeight - 48) / 2;
    final borderWidth = _focus.hasFocus || widget.highlight
        ? widget.focusedBorderWidth
        : 1.0;
    // Decoration consumes the border width; keep the editable origin fixed.
    final borderCompensation = 1 - borderWidth;
    return _FieldError(
      help: widget.help,
      error: widget.error,
      child: Stack(
        children: [
          Semantics(
            label: widget.label,
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: minimumHeight),
              child: CupertinoTextField(
                controller: _controller,
                focusNode: _focus,
                enabled: widget.enabled,
                readOnly: widget.readOnly,
                autofocus: widget.autofocus,
                onChanged: widget.onChanged,
                textInputAction: widget.textInputAction,
                keyboardType: widget.keyboardType,
                inputFormatters: widget.inputFormatters,
                obscureText: widget.obscure,
                autofillHints: widget.autofillHints,
                placeholder: raised ? widget.placeholder : null,
                placeholderStyle: valueStyle.copyWith(
                  color: widget.placeholderColor ?? colors.onSurfaceVariant,
                ),
                maxLines: widget.maxLines,
                autocorrect: false,
                enableSuggestions: false,
                cursorColor: colors.primary,
                // The text input action decides where focus goes: «next» moves
                // on, «done» closes the keyboard.
                onSubmitted: widget.onSubmitted,
                style: valueStyle.copyWith(
                  color: widget.enabled
                      ? colors.onSurface
                      : colors.onSurfaceVariant,
                ),
                padding: EdgeInsets.fromLTRB(
                  16 + borderCompensation,
                  7 + labelHeight + verticalInset + borderCompensation,
                  16 + borderCompensation,
                  4 + verticalInset + borderCompensation,
                ),
                suffix: widget.suffix != null
                    ? ConstrainedBox(
                        constraints: const BoxConstraints(
                          minWidth: 44,
                          minHeight: 44,
                        ),
                        child: Center(
                          widthFactor: 1,
                          heightFactor: 1,
                          child: widget.suffix,
                        ),
                      )
                    : (canClear || widget.reserveClearSpace
                          ? SizedBox.square(
                              dimension: 44,
                              child: IgnorePointer(
                                ignoring: !canClear,
                                child: ExcludeSemantics(
                                  excluding: !canClear,
                                  child: AnimatedOpacity(
                                    opacity: canClear ? 1 : 0,
                                    duration: duration,
                                    child: CupertinoButton(
                                      padding: EdgeInsets.zero,
                                      minimumSize: const Size(44, 44),
                                      onPressed: !canClear
                                          ? null
                                          : () {
                                              _controller.clear();
                                              widget.onChanged?.call('');
                                              _focus.requestFocus();
                                            },
                                      child: AcademySfIcon(
                                        AcademyTheme.of(context).icons.clear,
                                        size: AcademyTheme.of(context)
                                            .sizes
                                            .controlIcon,
                                        color: colors.onSurfaceVariant,
                                        semanticsLabel: AcademyLocalizations.of(
                                          context,
                                        ).clearField(widget.label),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            )
                          : null),
                decoration: _fieldDecoration(
                  context,
                  enabled: widget.enabled,
                  error: widget.invalid ? '' : widget.error,
                  focused: _focus.hasFocus || widget.highlight,
                  cornerRadius: widget.cornerRadius,
                  borderWidth: borderWidth,
                ),
              ),
            ),
          ),
          if (widget.valueOverlay != null && raised)
            Positioned.fill(
              child: IgnorePointer(
                child: ExcludeSemantics(
                  child: Padding(
                    padding: EdgeInsetsDirectional.fromSTEB(
                      17,
                      8 + labelHeight + verticalInset,
                      61,
                      5 + verticalInset,
                    ),
                    child: Align(
                      alignment: AlignmentDirectional.centerStart,
                      child: widget.valueOverlay,
                    ),
                  ),
                ),
              ),
            ),
          Positioned.fill(
            child: IgnorePointer(
              child: ExcludeSemantics(
                child: Padding(
                  padding: EdgeInsetsDirectional.only(
                    start: 16,
                    end:
                        widget.reserveClearSpace ||
                            canClear ||
                            widget.suffix != null
                        ? 60
                        : 16,
                  ),
                  child: AnimatedAlign(
                    alignment: raised
                        ? AlignmentDirectional.topStart
                        : AlignmentDirectional.centerStart,
                    duration: duration,
                    curve: Curves.easeInOut,
                    child: AnimatedPadding(
                      duration: duration,
                      curve: Curves.easeInOut,
                      padding: EdgeInsets.only(
                        top: raised ? 5 + verticalInset : 0,
                      ),
                      child: AnimatedDefaultTextStyle(
                        duration: duration,
                        curve: Curves.easeInOut,
                        style: (raised ? labelStyle : valueStyle).copyWith(
                          color: colors.onSurfaceVariant,
                        ),
                        child: Text(
                          widget.label,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

BoxDecoration _fieldDecoration(
  BuildContext context, {
  required bool enabled,
  String? error,
  bool focused = false,
  double? cornerRadius,
  double borderWidth = 1,
}) {
  return BoxDecoration(
    color: academyFieldFillColor(context, enabled: enabled),
    borderRadius: BorderRadius.circular(
      cornerRadius ?? AcademyTheme.of(context).radii.field,
    ),
    border: Border.all(
      width: borderWidth,
      color: academyFieldBorderColor(
        context,
        enabled: enabled,
        focused: focused,
        invalid: error != null,
      ),
    ),
  );
}

class _FieldError extends StatelessWidget {
  const _FieldError({required this.child, this.help, this.error});
  final Widget child;
  final String? help, error;
  @override
  Widget build(BuildContext context) => Column(
    mainAxisSize: MainAxisSize.min,
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      child,
      if (error == null && help != null)
        Padding(
          padding: const EdgeInsets.fromLTRB(8, 4, 8, 0),
          child: Text(
            help!,
            style: AcademyTheme.of(context).textTheme.fieldMessage.copyWith(
              color: AcademyTheme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      if (error != null)
        Semantics(
          liveRegion: true,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(8, 4, 8, 0),
            // Errors always carry a symbol so they never read as accent text.
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (error!.isNotEmpty)
                  Padding(
                    padding: const EdgeInsetsDirectional.only(top: 1, end: 4),
                    child: AcademySfIcon(
                      AcademyTheme.of(context).icons.error,
                      size: AcademyTheme.of(context).sizes.fieldMessageIcon,
                      boxSize: 14,
                      color: AcademyTheme.of(context).colorScheme.error,
                    ),
                  ),
                Expanded(
                  child: Text(
                    error!,
                    style: AcademyTheme.of(context).textTheme.fieldMessage
                        .copyWith(
                          color: AcademyTheme.of(context).colorScheme.error,
                        ),
                  ),
                ),
              ],
            ),
          ),
        ),
    ],
  );
}

/// Field-shaped trigger shared by select and date controls.
class AcademyPickerInput extends StatelessWidget {
  const AcademyPickerInput({
    super.key,
    required this.label,
    required this.icon,
    this.value,
    this.onPressed,
    this.help,
    this.error,
  });
  final String label;
  final String? value, help, error;
  final IconData icon;
  final VoidCallback? onPressed;
  @override
  Widget build(BuildContext context) {
    final theme = AcademyTheme.of(context);
    return _FieldError(
      help: help,
      error: error,
      child: Semantics(
        label: label,
        value: value,
        button: true,
        enabled: onPressed != null,
        child: Container(
          decoration: _fieldDecoration(
            context,
            enabled: onPressed != null,
            error: error,
          ),
          child: CupertinoButton(
            onPressed: onPressed,
            padding: const EdgeInsets.fromLTRB(15, 5, 15, 4),
            minimumSize: Size(44, theme.sizes.fieldHeight - 2),
            child: ExcludeSemantics(
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (value != null) ...[
                          Text(
                            label,
                            style: theme.textTheme.fieldLabel.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(height: 2),
                        ],
                        Text(
                          value ?? label,
                          style: theme.textTheme.bodyLarge.copyWith(
                            height: 1.2,
                            color: value != null && onPressed != null
                                ? theme.colorScheme.onSurface
                                : theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  AcademySfIcon(
                    icon,
                    size: AcademyTheme.of(context).sizes.fieldIcon,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class AcademyDateInput extends StatefulWidget {
  const AcademyDateInput({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
    this.firstDate,
    this.lastDate,
    this.help,
    this.error,
    this.validator,
    this.onSaved,
  });
  final String label;
  final DateTime? value, firstDate, lastDate;
  final ValueChanged<DateTime>? onChanged;
  final String? help, error;
  final FormFieldValidator<DateTime>? validator;
  final FormFieldSetter<DateTime>? onSaved;
  @override
  State<AcademyDateInput> createState() => _AcademyDateInputState();
}

class _AcademyDateInputState extends State<AcademyDateInput> {
  Future<void> _pick(ValueChanged<DateTime?> change) async {
    FocusManager.instance.primaryFocus?.unfocus();
    final first = academyDateOnly(widget.firstDate ?? DateTime(1900));
    final last = academyDateOnly(widget.lastDate ?? DateTime(2100, 12, 31));
    if (last.isBefore(first)) {
      throw ArgumentError('lastDate precedes firstDate');
    }
    var draft = academyDateOnly(widget.value ?? DateTime.now());
    if (draft.isBefore(first)) draft = first;
    if (draft.isAfter(last)) draft = last;
    final result = await showAcademyModal<DateTime>(
      context,
      title: widget.label,
      grouped: true,
      enableDrag: false,
      autoHeight:
          420 +
          MediaQuery.paddingOf(context).bottom +
          (MediaQuery.textScalerOf(context).scale(17) - 17) * 3,
      builder: (context) => AcademyModalFit(
        child: LayoutBuilder(
          builder: (context, box) {
            const padding = EdgeInsets.fromLTRB(16, 12, 16, 16);
            final wheel = CupertinoDatePicker(
              mode: CupertinoDatePickerMode.date,
              initialDateTime: draft,
              minimumDate: first,
              maximumDate: last,
              onDateTimeChanged: (date) =>
                  draft = DateTime(date.year, date.month, date.day),
            );
            final done = AcademyButton(
              label: AcademyLocalizations.of(context).done,
              onPressed: () => Navigator.of(context).pop(draft),
            );
            final buttonHeight = math.max(
              52.0,
              MediaQuery.textScalerOf(context).scale(20) * 1.3 + 32,
            );
            // A landscape sheet cannot hold the wheel and the action: scroll.
            if (box.maxHeight < 216 + 16 + padding.vertical + buttonHeight) {
              return ListView(
                padding: padding,
                children: [
                  SizedBox(height: 216, child: wheel),
                  const SizedBox(height: 16),
                  done,
                ],
              );
            }
            return Padding(
              padding: padding,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(child: wheel),
                  const SizedBox(height: 16),
                  done,
                ],
              ),
            );
          },
        ),
      ),
    );
    if (mounted && result != null) change(result);
  }

  @override
  Widget build(BuildContext context) => AcademyFormField<DateTime?>(
    value: widget.value,
    // A form reset to an empty initial value leaves the caller's date alone.
    onChanged: widget.onChanged == null
        ? null
        : (date) {
            if (date != null) widget.onChanged!(date);
          },
    validator: widget.validator,
    onSaved: widget.onSaved,
    builder: (field, change) => AcademyPickerInput(
      label: widget.label,
      value: widget.value == null
          ? null
          : '${widget.value!.day.toString().padLeft(2, '0')}.'
                '${widget.value!.month.toString().padLeft(2, '0')}.'
                '${widget.value!.year.toString().padLeft(4, '0')}',
      icon: AcademyTheme.of(context).icons.calendar,
      help: widget.help,
      error: widget.error ?? field.errorText,
      onPressed: widget.onChanged == null ? null : () => _pick(change),
    ),
  );
}
