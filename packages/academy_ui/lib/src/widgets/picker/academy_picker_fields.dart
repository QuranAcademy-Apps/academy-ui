import 'dart:math' as math;

import 'package:flutter/cupertino.dart';

import '../../foundation/form/academy_form_field.dart';
import '../../foundation/interaction/academy_tappable.dart';
import '../../foundation/localizations/academy_localizations.dart';
import '../../theme/academy_theme.dart';
import '../calendar/academy_calendar.dart';
import '../form/academy_field_decoration.dart';
import '../icon/academy_sf_image.dart';
import '../modal/academy_modal.dart';
import '../navigation/chrome/academy_chrome_metrics.dart';

const _pickerWheelHeight = 216.0;

double _pickerSheetHeight(BuildContext context) {
  final theme = AcademyTheme.of(context);
  final buttonHeight = math.max(
    44.0,
    MediaQuery.textScalerOf(context).scale(17) * 1.3 + 32,
  );
  final view = View.of(context);
  return academyChromeHeightOf(context) +
      theme.paddings.chromeBottom.vertical +
      theme.paddings.modal.vertical +
      _pickerWheelHeight +
      buttonHeight +
      view.padding.bottom / view.devicePixelRatio;
}

/// A time of day without an invented calendar date or timezone conversion.
@immutable
class AcademyTime {
  const AcademyTime(this.hour, this.minute)
    : assert(hour >= 0 && hour < 24),
      assert(minute >= 0 && minute < 60);
  final int hour, minute;
  @override
  bool operator ==(Object other) =>
      other is AcademyTime && hour == other.hour && minute == other.minute;
  @override
  int get hashCode => Object.hash(hour, minute);
}

class AcademyDateField extends StatelessWidget {
  const AcademyDateField({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
    this.firstDate,
    this.lastDate,
    this.help,
    this.validator,
    this.onSaved,
  });
  final String label;
  final String? help;
  final DateTime? value, firstDate, lastDate;
  final ValueChanged<DateTime?>? onChanged;
  final FormFieldValidator<DateTime>? validator;
  final FormFieldSetter<DateTime>? onSaved;
  @override
  Widget build(BuildContext context) => AcademyFormField<DateTime?>(
    value: value,
    onChanged: onChanged,
    validator: validator,
    onSaved: onSaved,
    builder: (field, change) => AcademyFieldDecoration(
      label: label,
      help: help,
      error: field.errorText,
      child: AcademyPickerTrigger(
        label: label,
        value: value == null
            ? AcademyLocalizations.of(context).choose
            : CupertinoLocalizations.of(context).datePickerMediumDate(value!),
        icon: AcademySymbols.calendar,
        onPressed: onChanged == null
            ? null
            : () async {
                final first = academyDateOnly(firstDate ?? DateTime(1900));
                final last = academyDateOnly(
                  lastDate ?? DateTime(2100, 12, 31),
                );
                if (last.isBefore(first)) {
                  throw ArgumentError('lastDate precedes firstDate');
                }
                var draft = academyDateOnly(value ?? DateTime.now());
                if (draft.isBefore(first)) draft = first;
                if (draft.isAfter(last)) draft = last;
                final result = await showAcademyModal<DateTime>(
                  context,
                  title: label,
                  autoHeight: _pickerSheetHeight(context),
                  expandOnFocus: false,
                  builder: (context) => AcademyModalListView(
                    children: [
                      SizedBox(
                        height: _pickerWheelHeight,
                        child: CupertinoDatePicker(
                          mode: CupertinoDatePickerMode.date,
                          initialDateTime: draft,
                          minimumDate: first,
                          maximumDate: last,
                          onDateTimeChanged: (date) =>
                              draft = academyDateOnly(date),
                        ),
                      ),
                      CupertinoButton(
                        onPressed: () => closeAcademyModal(context, draft),
                        child: Text(AcademyLocalizations.of(context).done),
                      ),
                    ],
                  ),
                );
                if (field.mounted && result != null) change(result);
              },
      ),
    ),
  );
}

class AcademyTimeField extends StatelessWidget {
  const AcademyTimeField({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
    this.help,
    this.validator,
    this.onSaved,
  });
  final String label;
  final String? help;
  final AcademyTime? value;
  final ValueChanged<AcademyTime?>? onChanged;
  final FormFieldValidator<AcademyTime>? validator;
  final FormFieldSetter<AcademyTime>? onSaved;
  @override
  Widget build(BuildContext context) {
    final local = CupertinoLocalizations.of(context);
    return AcademyFormField<AcademyTime?>(
      value: value,
      onChanged: onChanged,
      validator: validator,
      onSaved: onSaved,
      builder: (field, change) => AcademyFieldDecoration(
        label: label,
        help: help,
        error: field.errorText,
        child: AcademyPickerTrigger(
          label: label,
          icon: AcademySymbols.clock,
          value: value == null
              ? AcademyLocalizations.of(context).choose
              : '${local.datePickerHour(value!.hour)}:${local.datePickerMinute(value!.minute)}',
          onPressed: onChanged == null
              ? null
              : () async {
                  var draft = value ?? const AcademyTime(12, 0);
                  final result = await showAcademyModal<AcademyTime>(
                    context,
                    title: label,
                    autoHeight: _pickerSheetHeight(context),
                    expandOnFocus: false,
                    builder: (context) => AcademyModalListView(
                      children: [
                        SizedBox(
                          height: _pickerWheelHeight,
                          child: CupertinoDatePicker(
                            mode: CupertinoDatePickerMode.time,
                            use24hFormat: true,
                            initialDateTime: DateTime(
                              2000,
                              1,
                              1,
                              draft.hour,
                              draft.minute,
                            ),
                            onDateTimeChanged: (date) =>
                                draft = AcademyTime(date.hour, date.minute),
                          ),
                        ),
                        CupertinoButton(
                          onPressed: () => closeAcademyModal(context, draft),
                          child: Text(AcademyLocalizations.of(context).done),
                        ),
                      ],
                    ),
                  );
                  if (field.mounted && result != null) change(result);
                },
        ),
      ),
    );
  }
}

/// Reusable, opaque trigger for picker-style fields.
class AcademyPickerTrigger extends StatelessWidget {
  const AcademyPickerTrigger({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
    this.onPressed,
  });
  final String label, value;
  final IconData icon;
  final VoidCallback? onPressed;
  @override
  Widget build(BuildContext context) {
    final theme = AcademyTheme.of(context);
    return AcademyTappable(
      label: label,
      onPressed: onPressed,
      focusColor: theme.colorScheme.textFieldFocusBorder,
      borderRadius: BorderRadius.circular(theme.radii.field),
      builder: (_, _) => Container(
        padding: theme.paddings.field,
        decoration: BoxDecoration(
          color: onPressed != null
              ? theme.colorScheme.textFieldBackground
              : theme.colorScheme.textFieldDisabledBackground,
          border: Border.all(
            color: MediaQuery.highContrastOf(context)
                ? AcademyContrast.foreground(
                    theme.colorScheme.textFieldDisabledBorder,
                    onPressed != null
                        ? theme.colorScheme.textFieldBackground
                        : theme.colorScheme.textFieldDisabledBackground,
                    minimum: 3,
                  )
                : onPressed == null
                ? theme.colorScheme.textFieldDisabledBorder
                : theme.colorScheme.textFieldBorder,
          ),
          borderRadius: BorderRadius.circular(theme.radii.field),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                value,
                style: theme.textTheme.bodyLarge.copyWith(
                  color: onPressed == null
                      ? theme.colorScheme.textFieldDisabledForeground
                      : theme.colorScheme.textFieldForeground,
                ),
              ),
            ),
            const SizedBox(width: 8),
            AcademySfIcon(
              icon,
              size: 18,
              color: onPressed == null
                  ? theme.colorScheme.textFieldDisabledForeground
                  : theme.colorScheme.textFieldSecondaryForeground,
            ),
          ],
        ),
      ),
    );
  }
}

/// A pure controlled wheel; confirmation and presentation stay with the caller.
class AcademyPicker<T extends Object> extends StatefulWidget {
  const AcademyPicker({
    super.key,
    required this.items,
    required this.value,
    required this.labelFor,
    required this.onChanged,
    this.height = 216,
  }) : assert(items.length > 0);
  final List<T> items;
  final T value;
  final String Function(T) labelFor;
  final ValueChanged<T>? onChanged;
  final double height;
  @override
  State<AcademyPicker<T>> createState() => _AcademyPickerState<T>();
}

class _AcademyPickerState<T extends Object> extends State<AcademyPicker<T>> {
  late final FixedExtentScrollController _controller;
  int get _index {
    final index = widget.items.indexOf(widget.value);
    if (index < 0) throw ArgumentError('value must occur in items');
    return index;
  }

  @override
  void initState() {
    super.initState();
    _controller = FixedExtentScrollController(initialItem: _index);
  }

  void _sync() {
    if (mounted &&
        _controller.hasClients &&
        _controller.selectedItem != _index) {
      _controller.jumpToItem(_index);
    }
  }

  @override
  void didUpdateWidget(covariant AcademyPicker<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    WidgetsBinding.instance.addPostFrameCallback((_) => _sync());
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => SizedBox(
    height: widget.height,
    child: Semantics(
      enabled: widget.onChanged != null,
      value: widget.onChanged == null ? widget.labelFor(widget.value) : null,
      child: ExcludeFocus(
        excluding: widget.onChanged == null,
        child: AbsorbPointer(
          absorbing: widget.onChanged == null,
          child: ExcludeSemantics(
            excluding: widget.onChanged == null,
            child: NotificationListener<ScrollEndNotification>(
              onNotification: (_) {
                WidgetsBinding.instance.addPostFrameCallback((_) => _sync());
                return false;
              },
              child: CupertinoPicker(
                scrollController: _controller,
                itemExtent: (MediaQuery.textScalerOf(context).scale(18) + 20)
                    .clamp(44, double.infinity),
                onSelectedItemChanged: (index) {
                  if (widget.items[index] != widget.value) {
                    widget.onChanged?.call(widget.items[index]);
                  }
                },
                children: [
                  for (final item in widget.items)
                    Center(
                      child: Text(
                        widget.labelFor(item),
                        style: AcademyTheme.of(context).textTheme.bodyLarge,
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    ),
  );
}
