import 'package:flutter/foundation.dart';

import 'prayer_settings.dart';
import 'prayer_table.dart';
import 'prayer_table_source.dart';

/// The list of places with published tables and the table of one chosen place.
/// Only the index is read at start; a table is loaded when a place is chosen
/// (and for the saved choice), and the previous one is dropped.
class PrayerTablesRepository {
  PrayerTablesRepository(this._source);

  final PrayerTableSource _source;
  List<PrayerTablePlace> _places = const [];
  PrayerTable? _current;

  List<PrayerTablePlace> get places => _places;

  /// Reads the index. A missing or broken index leaves the list empty: the
  /// app then works on calculation alone.
  Future<void> load() async {
    try {
      _places = await _source.loadIndex();
    } on Object catch (error) {
      debugPrint('Prayer tables: index not loaded: $error');
      _places = const [];
    }
  }

  /// How far a table may be from the user's place to be used automatically
  /// (≈ 2 minutes of sunrise / noon shift at 55°N).
  static const nearestRadiusKm = 30.0;

  /// The table to use at [location]: among the places within
  /// [nearestRadiusKm] an official table beats a calculated one and that
  /// beats an unverified one; within one kind the nearest wins. Null when
  /// nothing is near.
  PrayerTablePlace? nearest(PrayerLocation location) {
    PrayerTablePlace? best;
    var bestDistance = double.infinity;
    for (final place in _places) {
      final distance = place.location.distanceKmTo(location);
      if (distance > nearestRadiusKm) continue;
      final better =
          best == null ||
          place.kind.index < best.kind.index ||
          (place.kind == best.kind && distance < bestDistance);
      if (better) {
        best = place;
        bestDistance = distance;
      }
    }
    return best;
  }

  PrayerTablePlace? place(String id) =>
      _places.where((place) => place.id == id).firstOrNull;

  /// The table of the place [id], or null when there is none.
  Future<PrayerTable?> table(String id) async {
    if (_current?.place.id == id) return _current;
    final place = this.place(id);
    if (place == null) return null;
    try {
      final table = await _source.loadTable(place);
      if (table != null) _current = table;
      return table;
    } on Object catch (error) {
      debugPrint('Prayer tables: ${place.id} not loaded: $error');
      return null;
    }
  }
}
