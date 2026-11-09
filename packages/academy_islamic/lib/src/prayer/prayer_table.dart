import 'package:flutter/foundation.dart';

import '../enum_by_name.dart';
import 'prayer_settings.dart';

/// Who stands behind the numbers of a published table.
enum PrayerTableKind {
  /// A table published by a muftiate, a DUM or a mosque.
  official,

  /// A ready-made table produced by a calculation (a method fitted to the
  /// local timetable).
  calculated,

  /// A table whose origin is not established.
  unverified;

  static PrayerTableKind parse(Object? name) =>
      enumByName(values, name, unverified);
}

/// One entry of the table index: where the place is and what its table is.
@immutable
class PrayerTablePlace {
  const PrayerTablePlace({
    required this.id,
    required this.name,
    required this.kind,
    required this.source,
    required this.location,
    required this.file,
    required this.revision,
    required this.start,
    required this.days,
  });

  factory PrayerTablePlace.fromJson(Map<String, dynamic> json) {
    final start = DateTime.parse(json['start'] as String);
    return PrayerTablePlace(
      id: json['id'] as String,
      name: json['name'] as String,
      kind: PrayerTableKind.parse(json['kind']),
      source: json['source'] as String,
      location: PrayerLocation(
        (json['lat'] as num).toDouble(),
        (json['lon'] as num).toDouble(),
      ),
      file: json['file'] as String,
      revision: json['rev'] as String,
      start: DateTime.utc(start.year, start.month, start.day),
      days: json['days'] as int,
    );
  }

  final String id;
  final String name;
  final PrayerTableKind kind;

  /// Who published (or produced) the table, as shown to the user.
  final String source;
  final PrayerLocation location;

  /// Where the days of this place are stored (relative to the source root).
  final String file;

  /// Changes whenever the numbers of the table change.
  final String revision;

  /// First covered calendar day (UTC midnight, only the date is meaningful).
  final DateTime start;
  final int days;

  @override
  bool operator ==(Object other) =>
      other is PrayerTablePlace && other.id == id && other.revision == revision;

  @override
  int get hashCode => Object.hash(id, revision);
}

/// The published times of one place: six [DayMoment]s for [PrayerTablePlace.days]
/// days from [PrayerTablePlace.start].
@immutable
class PrayerTable {
  PrayerTable(this.place, this._minutes) {
    if (_minutes.length != place.days * DayMoment.values.length) {
      throw FormatException(
        'Table ${place.id}: ${_minutes.length} values for ${place.days} days',
      );
    }
  }

  factory PrayerTable.fromJson(
    PrayerTablePlace place,
    Map<String, dynamic> json,
  ) =>
      PrayerTable(place, [for (final value in json['t'] as List) value as int]);

  final PrayerTablePlace place;

  /// Minutes after midnight, day after day in [DayMoment] order.
  final List<int> _minutes;

  /// Local times of the calendar day of [date], or null where the table does
  /// not reach. An event earlier than the one before it is after midnight
  /// (white nights: Isha at 00:20 belongs to the next day).
  ///
  /// shortcut: the times are the wall clock of the place's zone, shown as the
  /// device's local time. Right when the place is in the user's zone; upgrade
  /// path: convert with the `timezone` package.
  Map<DayMoment, DateTime>? day(DateTime date) {
    final index = DateTime.utc(
      date.year,
      date.month,
      date.day,
    ).difference(place.start).inDays;
    if (index < 0 || index >= place.days) return null;
    var carry = 0;
    int? previous;
    final times = <DayMoment, DateTime>{};
    for (final moment in DayMoment.values) {
      final minute = _minutes[index * DayMoment.values.length + moment.index];
      if (previous != null && minute < previous) carry++;
      previous = minute;
      times[moment] = DateTime(
        date.year,
        date.month,
        date.day + carry,
        minute ~/ 60,
        minute % 60,
      );
    }
    return times;
  }

  @override
  bool operator ==(Object other) =>
      other is PrayerTable && other.place == place;

  @override
  int get hashCode => place.hashCode;
}
