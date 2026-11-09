import 'dart:math' as math;

import 'package:flutter/foundation.dart';

import '../enum_by_name.dart';
import 'prayer_table.dart';

/// Calculation method presets. [auto] picks one from the user's place.
enum PrayerMethod {
  auto,
  muslimWorldLeague,
  russia,
  ummAlQura,
  egyptian,
  karachi,
  northAmerica,
  moonsighting,
  turkiye,
  dubai,
  kuwait,
  qatar,
  singapore,
  indonesian,
  tehran,
  jafari,
  france,
  morocco,
  algerian,
  tunisia,
  jordan,
  portugal,
}

/// Asr shadow length: standard (Shafi, Maliki, Hanbali) or Hanafi.
enum AsrSchool { standard, hanafi }

/// What to do where twilight never ends (high latitudes in summer).
/// [auto] follows the latitude.
enum PrayerHighLatitude { auto, middleOfTheNight, seventhOfTheNight, angle }

/// The six events of a day that the user can shift by minutes.
enum DayMoment { fajr, sunrise, dhuhr, asr, maghrib, isha }

/// The five daily prayers shown on Home.
enum Prayer { fajr, dhuhr, asr, maghrib, isha }

/// Largest manual shift of one event, in minutes.
const maxPrayerAdjustment = 30;

@immutable
class PrayerLocation {
  const PrayerLocation(this.latitude, this.longitude);

  final double latitude, longitude;

  /// Great-circle distance to [other] in kilometres (haversine).
  double distanceKmTo(PrayerLocation other) {
    double rad(double degrees) => degrees * math.pi / 180;
    final dLat = rad(other.latitude - latitude);
    final dLon = rad(other.longitude - longitude);
    final a =
        math.pow(math.sin(dLat / 2), 2) +
        math.cos(rad(latitude)) *
            math.cos(rad(other.latitude)) *
            math.pow(math.sin(dLon / 2), 2);
    return 2 * 6371.0 * math.asin(math.sqrt(a));
  }

  @override
  bool operator ==(Object other) =>
      other is PrayerLocation &&
      other.latitude == latitude &&
      other.longitude == longitude;

  @override
  int get hashCode => Object.hash(latitude, longitude);
}

/// Where and how prayer times are calculated. No location → no times.
@immutable
class PrayerSettings {
  const PrayerSettings({
    this.method = PrayerMethod.auto,
    this.asr = AsrSchool.standard,
    this.highLatitude = PrayerHighLatitude.auto,
    this.adjustments = const {},
    this.location,
    this.tableAuto = true,
    this.tableId,
    this.table,
  });

  factory PrayerSettings.fromJson(Map<String, dynamic> json) {
    const defaults = PrayerSettings();
    // The first version had no high-latitude rule and defaulted to MWL, so a
    // saved MWL there was the default, not a choice: it becomes «Auto».
    final firstVersion = !json.containsKey('highLatitude');
    final latitude = json['latitude'];
    final longitude = json['longitude'];
    final saved = json['adjustments'];
    return PrayerSettings(
      method: switch (enumByName(
        PrayerMethod.values,
        json['method'],
        defaults.method,
      )) {
        PrayerMethod.muslimWorldLeague when firstVersion => PrayerMethod.auto,
        final method => method,
      },
      asr: enumByName(AsrSchool.values, json['asr'], defaults.asr),
      highLatitude: enumByName(
        PrayerHighLatitude.values,
        json['highLatitude'],
        defaults.highLatitude,
      ),
      adjustments: {
        if (saved is Map)
          for (final moment in DayMoment.values)
            if (saved[moment.name] case final int minutes
                when minutes != 0 && minutes.abs() <= maxPrayerAdjustment)
              moment: minutes,
      },
      location:
          latitude is num &&
              longitude is num &&
              latitude.abs() <= 90 &&
              longitude.abs() <= 180
          ? PrayerLocation(latitude.toDouble(), longitude.toDouble())
          : null,
      // Saves of earlier builds have no such key: they follow the place too.
      tableAuto: json['tableAuto'] != false,
      tableId: switch (json['table']) {
        final String id when id.isNotEmpty => id,
        _ => null,
      },
    );
  }

  final PrayerMethod method;
  final AsrSchool asr;
  final PrayerHighLatitude highLatitude;

  /// Minutes added to an event; zero entries are never stored.
  final Map<DayMoment, int> adjustments;
  final PrayerLocation? location;

  /// True: the table follows the place (the nearest one, [tableId] is only the
  /// derived value). False: [tableId] is the user's own choice.
  final bool tableAuto;

  /// The place whose published table is used; null → calculation.
  /// Saved. The table itself ([table]) is loaded at start and not saved.
  final String? tableId;

  /// The decoded table of [tableId], once loaded. Where it covers a date it
  /// replaces the calculation.
  final PrayerTable? table;

  int adjustmentOf(DayMoment moment) => adjustments[moment] ?? 0;

  /// This settings with [moment] shifted to [minutes] (clamped).
  PrayerSettings adjusted(DayMoment moment, int minutes) {
    final value = minutes.clamp(-maxPrayerAdjustment, maxPrayerAdjustment);
    return copyWith(
      adjustments: {
        for (final entry in adjustments.entries)
          if (entry.key != moment) entry.key: entry.value,
        if (value != 0) moment: value,
      },
    );
  }

  PrayerSettings copyWith({
    PrayerMethod? method,
    AsrSchool? asr,
    PrayerHighLatitude? highLatitude,
    Map<DayMoment, int>? adjustments,
    PrayerLocation? location,
    bool? tableAuto,
    String? tableId,
    PrayerTable? table,
    bool clearTable = false,
  }) => PrayerSettings(
    method: method ?? this.method,
    asr: asr ?? this.asr,
    highLatitude: highLatitude ?? this.highLatitude,
    adjustments: adjustments ?? this.adjustments,
    location: location ?? this.location,
    tableAuto: tableAuto ?? this.tableAuto,
    tableId: clearTable ? null : tableId ?? this.tableId,
    table: clearTable ? null : table ?? this.table,
  );

  Map<String, dynamic> toJson() => {
    'method': method.name,
    'asr': asr.name,
    'highLatitude': highLatitude.name,
    if (adjustments.isNotEmpty)
      'adjustments': {
        for (final entry in adjustments.entries) entry.key.name: entry.value,
      },
    if (location case final location?) ...{
      'latitude': location.latitude,
      'longitude': location.longitude,
    },
    if (!tableAuto) 'tableAuto': false,
    'table': ?tableId,
  };

  @override
  bool operator ==(Object other) =>
      other is PrayerSettings &&
      other.method == method &&
      other.asr == asr &&
      other.highLatitude == highLatitude &&
      mapEquals(other.adjustments, adjustments) &&
      other.location == location &&
      other.tableAuto == tableAuto &&
      other.tableId == tableId &&
      other.table == table;

  @override
  int get hashCode => Object.hash(
    method,
    asr,
    highLatitude,
    Object.hashAllUnordered(
      adjustments.entries.map((e) => Object.hash(e.key, e.value)),
    ),
    location,
    tableAuto,
    tableId,
    table,
  );
}
