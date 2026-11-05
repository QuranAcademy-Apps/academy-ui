import 'dart:math' as math;

import 'package:flutter/cupertino.dart';

import '../../foundation/form/academy_form_field.dart';
import '../../foundation/localizations/academy_localizations.dart';
import '../../theme/academy_theme.dart';
import '../form/academy_input_fields.dart';
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
      builder: (field, change) => AcademyPickerInput(
        label: label,
        icon: AcademyTheme.of(context).icons.clock,
        value: value == null
            ? null
            : '${local.datePickerHour(value!.hour)}:${local.datePickerMinute(value!.minute)}',
        help: help,
        error: field.errorText,
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
    this.diameterRatio = 1.07,
    this.changeReportingBehavior = ChangeReportingBehavior.onScrollUpdate,
  }) : assert(items.length > 0);
  final List<T> items;
  final T value;
  final String Function(T) labelFor;
  final ValueChanged<T>? onChanged;
  final double height;

  /// See [CupertinoPicker.diameterRatio].
  final double diameterRatio;

  /// Use [ChangeReportingBehavior.onScrollEnd] when [onChanged] does real work.
  final ChangeReportingBehavior changeReportingBehavior;
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
              child: CupertinoPicker.builder(
                scrollController: _controller,
                diameterRatio: widget.diameterRatio,
                changeReportingBehavior: widget.changeReportingBehavior,
                itemExtent: (MediaQuery.textScalerOf(context).scale(18) + 20)
                    .clamp(44, double.infinity),
                onSelectedItemChanged: (index) {
                  if (widget.items[index] != widget.value) {
                    widget.onChanged?.call(widget.items[index]);
                  }
                },
                childCount: widget.items.length,
                itemBuilder: (context, index) => Center(
                  child: Text(
                    widget.labelFor(widget.items[index]),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AcademyTheme.of(context).textTheme.bodyLarge,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    ),
  );
}
