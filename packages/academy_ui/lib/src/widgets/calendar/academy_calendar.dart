import 'dart:math' as math;

import 'package:flutter/cupertino.dart';

import '../../foundation/interaction/academy_tappable.dart';
import '../../foundation/localizations/academy_localizations.dart';
import '../../theme/academy_theme.dart';
import '../icon/academy_sf_image.dart';
import '../surface/academy_surface.dart';

DateTime academyDateOnly(DateTime date) =>
    DateTime(date.year, date.month, date.day);

@immutable
class AcademyDateRange {
  AcademyDateRange(DateTime start, DateTime end)
    : start = academyDateOnly(start),
      end = academyDateOnly(end) {
    if (this.end.isBefore(this.start)) {
      throw ArgumentError('End must be on or after start.');
    }
  }
  final DateTime start, end;
  @override
  bool operator ==(Object other) =>
      other is AcademyDateRange && start == other.start && end == other.end;
  @override
  int get hashCode => Object.hash(start, end);
}

/// Controlled Gregorian calendar. Localized labels come from Cupertino.
class AcademyCalendar extends StatelessWidget {
  const AcademyCalendar({
    super.key,
    required this.value,
    required this.onChanged,
    this.initialMonth,
    this.firstDate,
    this.lastDate,
    this.selectableDayPredicate,
  });
  final DateTime? value, initialMonth, firstDate, lastDate;
  final ValueChanged<DateTime>? onChanged;
  final bool Function(DateTime)? selectableDayPredicate;
  @override
  Widget build(BuildContext context) => _Calendar(
    value: value,
    initialMonth: initialMonth,
    firstDate: firstDate,
    lastDate: lastDate,
    selectableDayPredicate: selectableDayPredicate,
    onChanged: onChanged,
  );
}

/// Range selection keeps only an unfinished gesture locally; complete values
/// are owned by the caller. Disabled interior dates cannot enter a range.
class AcademyRangeCalendar extends StatefulWidget {
  const AcademyRangeCalendar({
    super.key,
    required this.value,
    required this.onChanged,
    this.firstDate,
    this.lastDate,
    this.selectableDayPredicate,
  });
  final AcademyDateRange? value;
  final ValueChanged<AcademyDateRange>? onChanged;
  final DateTime? firstDate, lastDate;
  final bool Function(DateTime)? selectableDayPredicate;
  @override
  State<AcademyRangeCalendar> createState() => _AcademyRangeCalendarState();
}

class _AcademyRangeCalendarState extends State<AcademyRangeCalendar> {
  DateTime? _start;
  @override
  void didUpdateWidget(AcademyRangeCalendar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value ||
        oldWidget.firstDate != widget.firstDate ||
        oldWidget.lastDate != widget.lastDate ||
        oldWidget.selectableDayPredicate != widget.selectableDayPredicate ||
        widget.onChanged == null) {
      _start = null;
    }
  }

  @override
  Widget build(BuildContext context) => _Calendar(
    value: _start ?? widget.value?.start,
    rangeEnd: _start == null ? widget.value?.end : null,
    firstDate: widget.firstDate,
    lastDate: widget.lastDate,
    selectableDayPredicate: widget.selectableDayPredicate,
    onChanged: widget.onChanged == null
        ? null
        : (day) {
            if (_start == null) {
              setState(() => _start = day);
              return;
            }
            final start = day.isBefore(_start!) ? day : _start!;
            final end = day.isBefore(_start!) ? _start! : day;
            for (
              var d = start;
              !d.isAfter(end);
              d = DateTime(d.year, d.month, d.day + 1)
            ) {
              if (!(widget.selectableDayPredicate?.call(d) ?? true)) {
                setState(() => _start = day);
                return;
              }
            }
            setState(() => _start = null);
            widget.onChanged!(AcademyDateRange(start, end));
          },
  );
}

class _Calendar extends StatefulWidget {
  const _Calendar({
    required this.value,
    required this.onChanged,
    this.rangeEnd,
    this.initialMonth,
    this.firstDate,
    this.lastDate,
    this.selectableDayPredicate,
  });
  final DateTime? value, rangeEnd, initialMonth, firstDate, lastDate;
  final ValueChanged<DateTime>? onChanged;
  final bool Function(DateTime)? selectableDayPredicate;
  @override
  State<_Calendar> createState() => _CalendarState();
}

class _CalendarState extends State<_Calendar> {
  late DateTime _month;
  DateTime get _first => academyDateOnly(widget.firstDate ?? DateTime(1900));
  DateTime get _last =>
      academyDateOnly(widget.lastDate ?? DateTime(2100, 12, 31));
  @override
  void initState() {
    super.initState();
    _show(widget.initialMonth ?? widget.value ?? DateTime.now());
  }

  void _show(DateTime date) {
    if (_last.isBefore(_first)) {
      throw ArgumentError('lastDate precedes firstDate');
    }
    final clamped = date.isBefore(_first)
        ? _first
        : date.isAfter(_last)
        ? _last
        : date;
    _month = DateTime(clamped.year, clamped.month);
  }

  @override
  void didUpdateWidget(covariant _Calendar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value && widget.value != null) {
      _show(widget.value!);
    }
    if (oldWidget.firstDate != widget.firstDate ||
        oldWidget.lastDate != widget.lastDate) {
      _show(_month);
    }
  }

  bool _enabled(DateTime day) =>
      widget.onChanged != null &&
      !day.isBefore(_first) &&
      !day.isAfter(_last) &&
      (widget.selectableDayPredicate?.call(day) ?? true);
  @override
  Widget build(BuildContext context) {
    final theme = AcademyTheme.of(context);
    final strings = AcademyLocalizations.of(context);
    final local = CupertinoLocalizations.of(context);
    final cellSize = math.max(
      44.0,
      MediaQuery.textScalerOf(context).scale(18) + 24,
    );
    final offset = (_month.weekday - DateTime.monday) % 7;
    final days = DateTime(_month.year, _month.month + 1, 0).day;
    final rows = ((offset + days) / 7).ceil();
    final previous = DateTime(_month.year, _month.month, 0);
    final next = DateTime(_month.year, _month.month + 1);
    return AcademySurface(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              CupertinoButton(
                padding: EdgeInsets.zero,
                onPressed: previous.isBefore(_first)
                    ? null
                    : () => setState(() => _show(previous)),
                child: AcademySfIcon(
                  AcademyTheme.of(context).icons.back,
                  size: 18,
                  semanticsLabel: strings.previousMonth,
                ),
              ),
              Expanded(
                child: Text(
                  '${local.datePickerStandaloneMonth(_month.month)} ${local.datePickerYear(_month.year)}',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.titleMedium,
                ),
              ),
              CupertinoButton(
                padding: EdgeInsets.zero,
                onPressed: next.isAfter(_last)
                    ? null
                    : () => setState(() => _show(next)),
                child: AcademySfIcon(
                  AcademyTheme.of(context).icons.forward,
                  size: 18,
                  semanticsLabel: strings.nextMonth,
                ),
              ),
            ],
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SizedBox(
              width: cellSize * 7,
              child: Column(
                children: [
                  Row(
                    children: [
                      for (final day in strings.weekdaysShort)
                        SizedBox(
                          width: cellSize,
                          child: Center(
                            child: Text(day, style: theme.textTheme.bodySmall),
                          ),
                        ),
                    ],
                  ),
                  for (var row = 0; row < rows; row++)
                    Row(
                      children: [
                        for (var column = 0; column < 7; column++)
                          Builder(
                            builder: (context) {
                              final number = row * 7 + column - offset + 1;
                              if (number < 1 || number > days) {
                                return SizedBox.square(dimension: cellSize);
                              }
                              final day = DateTime(
                                _month.year,
                                _month.month,
                                number,
                              );
                              final start = widget.value == null
                                  ? null
                                  : academyDateOnly(widget.value!);
                              final selected =
                                  start != null &&
                                  (day == start ||
                                      (widget.rangeEnd != null &&
                                          !day.isBefore(start) &&
                                          !day.isAfter(
                                            academyDateOnly(widget.rangeEnd!),
                                          )));
                              return SizedBox.square(
                                dimension: cellSize,
                                child: AcademyTappable(
                                  label: local.datePickerMediumDate(day),
                                  selected: selected,
                                  onPressed: _enabled(day)
                                      ? () => widget.onChanged!(day)
                                      : null,
                                  borderRadius: BorderRadius.circular(
                                    theme.radii.tableBadge,
                                  ),
                                  builder: (_, states) => DecoratedBox(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(
                                        theme.radii.tableBadge,
                                      ),
                                      color: selected
                                          ? theme.colorScheme.primaryContainer
                                          : states.contains(WidgetState.hovered)
                                          ? theme
                                                .colorScheme
                                                .surfaceContainerHighest
                                          : null,
                                    ),
                                    child: Center(
                                      child: ExcludeSemantics(
                                        child: Text(
                                          local.datePickerDayOfMonth(number),
                                          style: theme.textTheme.bodyLarge
                                              .copyWith(
                                                color: selected
                                                    ? theme
                                                          .colorScheme
                                                          .onPrimaryContainer
                                                    : _enabled(day)
                                                    ? theme
                                                          .colorScheme
                                                          .onSurface
                                                    : theme
                                                          .colorScheme
                                                          .onSurfaceVariant,
                                              ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                      ],
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Explicit finite window; does not assume fixed 24-hour days across DST.
class AcademyLineCalendar extends StatelessWidget {
  const AcademyLineCalendar({
    super.key,
    required this.firstDate,
    required this.dayCount,
    required this.value,
    required this.onChanged,
  }) : assert(dayCount > 0);
  final DateTime firstDate;
  final int dayCount;
  final DateTime? value;
  final ValueChanged<DateTime>? onChanged;
  @override
  Widget build(BuildContext context) {
    final theme = AcademyTheme.of(context);
    final local = CupertinoLocalizations.of(context);
    final height = math.max(
      64.0,
      MediaQuery.textScalerOf(context).scale(18) * 2 + 24,
    );
    return AcademySurface(
      child: SizedBox(
        height: height,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: dayCount,
          separatorBuilder: (_, _) => const SizedBox(width: 8),
          itemBuilder: (context, index) {
            final day = DateTime(
              firstDate.year,
              firstDate.month,
              firstDate.day + index,
            );
            final selected = value != null && academyDateOnly(value!) == day;
            return AcademyTappable(
              selected: selected,
              onPressed: onChanged == null ? null : () => onChanged!(day),
              builder: (_, _) => Container(
                constraints: const BoxConstraints(minWidth: 64),
                padding: theme.paddings.field,
                decoration: BoxDecoration(
                  color: selected
                      ? theme.colorScheme.primaryContainer
                      : theme.colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(theme.radii.tableBadge),
                ),
                alignment: Alignment.center,
                child: Text(
                  local.datePickerMediumDate(day),
                  style: theme.textTheme.bodyMedium.copyWith(
                    color: selected
                        ? theme.colorScheme.onPrimaryContainer
                        : theme.colorScheme.onSurface,
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
