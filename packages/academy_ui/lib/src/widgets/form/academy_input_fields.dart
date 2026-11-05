import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';

import '../../foundation/localizations/academy_localizations.dart';
import '../../foundation/table/academy_table_row_scope.dart';
import '../../theme/academy_theme.dart';
import '../button/academy_button.dart';
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
                    AcademySymbols.lockOutline,
                    size: 16,
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
    required this.controller,
    this.enabled = true,
    this.error,
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
    this.minimumHeight = 48,
    this.cornerRadius = 12,
    this.focusedBorderWidth = 1,
  });
  final String label;
  final TextEditingController controller;
  final bool enabled, obscure;
  final String? error;
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
  final double minimumHeight, cornerRadius, focusedBorderWidth;

  @override
  State<AcademyFloatingInput> createState() => _AcademyFloatingInputState();
}

class _AcademyFloatingInputState extends State<AcademyFloatingInput> {
  late FocusNode _focus = widget.focusNode ?? FocusNode();
  void _refresh() => setState(() {});

  @override
  void initState() {
    super.initState();
    _focus.addListener(_refresh);
    widget.controller.addListener(_refresh);
  }

  @override
  void didUpdateWidget(covariant AcademyFloatingInput oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller.removeListener(_refresh);
      widget.controller.addListener(_refresh);
    }
    if (oldWidget.focusNode != widget.focusNode) {
      _focus.removeListener(_refresh);
      if (oldWidget.focusNode == null) _focus.dispose();
      _focus = widget.focusNode ?? FocusNode();
      _focus.addListener(_refresh);
    }
    if (!widget.enabled) _focus.unfocus();
  }

  @override
  void dispose() {
    widget.controller.removeListener(_refresh);
    _focus.removeListener(_refresh);
    if (widget.focusNode == null) _focus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = AcademyTheme.of(context);
    final colors = theme.colorScheme;
    final raised =
        _focus.hasFocus ||
        widget.controller.text.isNotEmpty ||
        widget.placeholder != null;
    final duration = MediaQuery.disableAnimationsOf(context)
        ? Duration.zero
        : const Duration(milliseconds: 180);
    final labelStyle = theme.textTheme.bodySmall.copyWith(
      fontSize: 12,
      height: 1.2,
    );
    final valueStyle = (widget.valueStyle ?? theme.textTheme.bodyLarge)
        .copyWith(height: 1.2);
    final canClear =
        widget.enabled &&
        widget.allowClear &&
        widget.controller.text.isNotEmpty &&
        (!widget.clearOnlyWhenFocused || _focus.hasFocus);
    final labelHeight =
        MediaQuery.textScalerOf(context).scale(labelStyle.fontSize ?? 13) *
        (labelStyle.height ?? 1.2);
    final verticalInset = (widget.minimumHeight - 48) / 2;
    final borderWidth = _focus.hasFocus || widget.highlight
        ? widget.focusedBorderWidth
        : 1.0;
    // Decoration consumes the border width; keep the editable origin fixed.
    final borderCompensation = 1 - borderWidth;
    return _FieldError(
      error: widget.error,
      child: Stack(
        children: [
          Semantics(
            label: widget.label,
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: widget.minimumHeight),
              child: CupertinoTextField(
                controller: widget.controller,
                focusNode: _focus,
                enabled: widget.enabled,
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
                onSubmitted: (_) => _focus.unfocus(),
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
                suffix:
                    widget.suffix ??
                    (canClear || widget.reserveClearSpace
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
                                            widget.controller.clear();
                                            _focus.requestFocus();
                                          },
                                    child: AcademySfIcon(
                                      AcademySymbols.clear,
                                      size: 18,
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
                    padding: EdgeInsets.fromLTRB(
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

Color _fieldOutline(BuildContext context) =>
    AcademyTheme.of(context).brightness == Brightness.dark
    ? const Color(0xFF48484A)
    : const Color(0xFFC2C8D0);

BoxDecoration _fieldDecoration(
  BuildContext context, {
  required bool enabled,
  String? error,
  bool focused = false,
  double cornerRadius = 12,
  double borderWidth = 1,
}) {
  final colors = AcademyTheme.of(context).colorScheme;
  return BoxDecoration(
    color: enabled ? colors.surface : colors.surfaceContainerHighest,
    borderRadius: BorderRadius.circular(cornerRadius),
    border: Border.all(
      width: borderWidth,
      color: error != null
          ? colors.error
          : focused
          ? colors.primary
          : MediaQuery.highContrastOf(context)
          ? colors.onSurfaceVariant
          : _fieldOutline(context),
    ),
  );
}

class _FieldError extends StatelessWidget {
  const _FieldError({required this.child, this.error});
  final Widget child;
  final String? error;
  @override
  Widget build(BuildContext context) => Column(
    mainAxisSize: MainAxisSize.min,
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      child,
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
                    padding: const EdgeInsets.only(top: 1, right: 4),
                    child: AcademySfIcon(
                      AcademySymbols.exclamationmarkCircle,
                      size: 12,
                      boxSize: 14,
                      color: AcademyTheme.of(context).colorScheme.error,
                    ),
                  ),
                Expanded(
                  child: Text(
                    error!,
                    style: AcademyTheme.of(context).textTheme.bodySmall
                        .copyWith(
                          fontSize: 12,
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
    this.error,
  });
  final String label;
  final String? value, error;
  final IconData icon;
  final VoidCallback? onPressed;
  @override
  Widget build(BuildContext context) {
    final theme = AcademyTheme.of(context);
    return _FieldError(
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
            minimumSize: const Size(44, 46),
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
                            style: theme.textTheme.bodySmall.copyWith(
                              fontSize: 12,
                              height: 1.2,
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
                    size: 22,
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
    this.error,
  });
  final String label;
  final DateTime? value;
  final ValueChanged<DateTime>? onChanged;
  final String? error;
  @override
  State<AcademyDateInput> createState() => _AcademyDateInputState();
}

class _AcademyDateInputState extends State<AcademyDateInput> {
  Future<void> _pick() async {
    FocusManager.instance.primaryFocus?.unfocus();
    var draft = widget.value ?? DateTime.now();
    final first = DateTime(1900);
    final last = DateTime(2100, 12, 31);
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
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: CupertinoDatePicker(
                  mode: CupertinoDatePickerMode.date,
                  initialDateTime: draft,
                  minimumDate: first,
                  maximumDate: last,
                  onDateTimeChanged: (date) =>
                      draft = DateTime(date.year, date.month, date.day),
                ),
              ),
              const SizedBox(height: 16),
              AcademyButton(
                label: 'Готово',
                onPressed: () => Navigator.of(context).pop(draft),
              ),
            ],
          ),
        ),
      ),
    );
    if (mounted && result != null) widget.onChanged?.call(result);
  }

  @override
  Widget build(BuildContext context) => AcademyPickerInput(
    label: widget.label,
    value: widget.value == null
        ? null
        : '${widget.value!.day.toString().padLeft(2, '0')}.'
              '${widget.value!.month.toString().padLeft(2, '0')}.'
              '${widget.value!.year.toString().padLeft(4, '0')}',
    icon: AcademySymbols.calendar,
    error: widget.error,
    onPressed: widget.onChanged == null ? null : _pick,
  );
}
