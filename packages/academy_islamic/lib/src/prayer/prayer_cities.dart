import 'package:flutter/foundation.dart';

import 'prayer_settings.dart';

/// How many cities a user may keep.
const maxPrayerCities = 3;

/// A saved place for the prayer times with its own source and shifts.
@immutable
class PrayerCity {
  const PrayerCity({required this.id, required this.settings, this.name});

  static PrayerCity? fromJson(Object? json) {
    if (json is! Map<String, dynamic>) return null;
    final id = json['id'];
    if (id is! int) return null;
    return PrayerCity(
      id: id,
      name: switch (json['name']) {
        final String name when name.isNotEmpty => name,
        _ => null,
      },
      settings: PrayerSettings.fromJson(json),
    );
  }

  /// Never reused: things remembered per city must not leak into a new one.
  final int id;

  /// The place's name: of its table, or the one the app found for it. Null
  /// while unknown.
  final String? name;
  final PrayerSettings settings;

  PrayerCity copyWith({PrayerSettings? settings}) =>
      PrayerCity(id: id, name: name, settings: settings ?? this.settings);

  PrayerCity named(String? name) =>
      PrayerCity(id: id, name: name, settings: settings);

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': ?name,
    ...settings.toJson(),
  };

  @override
  bool operator ==(Object other) =>
      other is PrayerCity &&
      other.id == id &&
      other.name == name &&
      other.settings == settings;

  @override
  int get hashCode => Object.hash(id, name, settings);
}

/// The saved cities, one of them selected. There is always at least one; only
/// a lone city may still have no place.
@immutable
class PrayerCities {
  PrayerCities(List<PrayerCity> all, {required this.selectedId})
    : assert(all.isNotEmpty && all.length <= maxPrayerCities),
      assert(all.any((city) => city.id == selectedId)),
      all = List.unmodifiable(all);

  PrayerCities.single(PrayerSettings settings, {String? name})
    : this([
        PrayerCity(id: firstId, name: name, settings: settings),
      ], selectedId: firstId);

  /// The id of the city that earlier builds kept as the only place.
  static const firstId = 1;

  /// Reads both the list and the single-place save of earlier builds. Broken
  /// entries are dropped; with none left the top-level fields are the city.
  factory PrayerCities.fromJson(Map<String, dynamic> json) {
    final saved = json['cities'];
    final ids = <int>{};
    final all = [
      if (saved is List)
        for (final city in saved.map(PrayerCity.fromJson).nonNulls)
          if (ids.add(city.id)) city,
    ].take(maxPrayerCities).toList();
    if (all.isEmpty) return PrayerCities.single(PrayerSettings.fromJson(json));
    final selected = json['selected'];
    return PrayerCities(
      all,
      selectedId: all.any((city) => city.id == selected)
          ? selected as int
          : all.first.id,
    );
  }

  final List<PrayerCity> all;
  final int selectedId;

  PrayerCity get selected => byId(selectedId)!;

  PrayerCity? byId(int id) => all.where((city) => city.id == id).firstOrNull;

  /// The only city, still waiting for its place: the next one added fills it.
  bool get isEmpty => all.length == 1 && selected.settings.location == null;

  bool get canAdd => all.length < maxPrayerCities;

  PrayerCities select(int id) =>
      byId(id) == null ? this : PrayerCities(all, selectedId: id);

  /// [city] in place of the one with its id.
  PrayerCities replace(PrayerCity city) => PrayerCities([
    for (final old in all) old.id == city.id ? city : old,
  ], selectedId: selectedId);

  /// [city] added and selected; unchanged when the list is full.
  PrayerCities add(PrayerCity city) => canAdd
      ? PrayerCities([...all, city], selectedId: city.id)
      : this;

  /// Without the city [id]; the last one stays. Removing the selected city
  /// selects the first remaining.
  PrayerCities remove(int id) {
    if (all.length == 1 || byId(id) == null) return this;
    final rest = [
      for (final city in all)
        if (city.id != id) city,
    ];
    return PrayerCities(
      rest,
      selectedId: id == selectedId ? rest.first.id : selectedId,
    );
  }

  /// Two saved cities this close are one place (the same city saved with two
  /// sources, or by its table and by location).
  static const samePlaceKm = 5.0;

  /// The nearest city within [radiusKm] of [location]. At the place of the
  /// selected city that one stays: it carries the user's choice of source.
  PrayerCity? nearest(PrayerLocation location, double radiusKm) {
    PrayerCity? best;
    var bestDistance = double.infinity;
    for (final city in all) {
      final place = city.settings.location;
      if (place == null) continue;
      final distance = place.distanceKmTo(location);
      if (distance > radiusKm) continue;
      if (distance < bestDistance) {
        best = city;
        bestDistance = distance;
      }
    }
    final chosen = selected.settings.location;
    final found = best?.settings.location;
    if (chosen != null &&
        found != null &&
        chosen.distanceKmTo(location) <= radiusKm &&
        chosen.distanceKmTo(found) <= samePlaceKm) {
      return selected;
    }
    return best;
  }

  /// A lone city the earlier format can hold is saved in it, so an older
  /// build still reads the place. Otherwise the selected city's fields stay on
  /// top for the same reason.
  Map<String, dynamic> toJson() {
    final lone =
        all.length == 1 &&
        selectedId == firstId &&
        (selected.name == null || selected.settings.tableId != null);
    return {
      ...selected.settings.toJson(),
      if (!lone) ...{
        'cities': [for (final city in all) city.toJson()],
        'selected': selectedId,
      },
    };
  }

  @override
  bool operator ==(Object other) =>
      other is PrayerCities &&
      other.selectedId == selectedId &&
      listEquals(other.all, all);

  @override
  int get hashCode => Object.hash(selectedId, Object.hashAll(all));
}
