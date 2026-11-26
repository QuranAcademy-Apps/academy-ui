import 'package:flutter/foundation.dart';

import 'prayer_cities.dart';
import 'prayer_settings.dart';
import 'prayer_table.dart';
import '../storage/key_value_store.dart';
import '../storage/persisted_json.dart';
import 'device_locator.dart';
import 'prayer_table_source.dart';
import 'prayer_tables_repository.dart';

/// What came of looking for a saved city at the device's position.
enum NearestCityResult { selected, noneNear, denied, unavailable }

/// Owns the saved cities (persisted): each one's place, chosen published table
/// and calculation settings, and which city is selected. [settings] is the
/// selected city's, so whoever only needs «the times» listens to that. The
/// times themselves are derived by `prayerSnapshot` where they are shown: from
/// the table where it covers the date, else calculated.
class PrayerTimesService {
  PrayerTimesService(
    KeyValueStore store, {
    DeviceLocator? locator,
    PrayerTablesRepository? tables,
    String key = storageKey,
    DateTime Function()? clock,
  }) : _cities = PersistedNotifier(
         store,
         key,
         PrayerCities.single(const PrayerSettings()),
         toJson: (cities) => cities.toJson(),
       ),
       _locator = locator ?? GeolocatorDeviceLocator(),
       _tables = tables ?? PrayerTablesRepository(_NoTables()),
       _clock = clock ?? DateTime.now;

  /// The key Zikro has always used; another app passes its own [key].
  static const storageKey = 'zikro.prayer.v1';

  /// A saved city this far from the device is where the user is.
  static const cityRadiusKm = PrayerTablesRepository.nearestRadiusKm;

  final PersistedNotifier<PrayerCities> _cities;
  final _settings = ValueNotifier(const PrayerSettings());
  late final _all = ValueNotifier(_cities.value);
  final DeviceLocator _locator;
  final PrayerTablesRepository _tables;
  final DateTime Function() _clock;

  /// Every saved city; [settings] has already caught up when this changes.
  ValueListenable<PrayerCities> get cities => _all;

  /// The selected city's settings.
  ValueListenable<PrayerSettings> get settings => _settings;

  /// Places that have a published table (empty until [load] has run).
  List<PrayerTablePlace> get tablePlaces => _tables.places;

  /// The place [id] among [tablePlaces], if any.
  PrayerTablePlace? tablePlace(String? id) =>
      id == null ? null : _tables.place(id);

  Future<void> load() async {
    final saved = await _cities.read();
    if (saved != null) _restore(PrayerCities.fromJson(saved));
    await _tables.load();
    // Every city gets its table: switching and the widgets need them all.
    for (final city in _cities.value.all) {
      await _loadTable(city.id);
    }
  }

  Future<void> _loadTable(int cityId) async {
    final city = _cities.value.byId(cityId);
    if (city == null) return;
    if (city.settings.tableAuto) return _followPlace(cityId);
    final id = city.settings.tableId;
    if (id == null) return;
    final table = await _tables.table(id);
    final current = _cities.value.byId(cityId);
    if (current == null || current.settings.tableId != id) return;
    // A saved choice that no longer exists falls back to calculation.
    final loaded = table == null
        ? current.copyWith(
            settings: current.settings.copyWith(clearTable: true),
          )
        : current
              .copyWith(settings: current.settings.copyWith(table: table))
              .named(current.name ?? table.place.name);
    _restore(_cities.value.replace(loaded));
  }

  /// The table that «automatic» picks at the selected city's place (null: no
  /// place, or nothing near).
  PrayerTablePlace? get nearestTablePlace {
    final location = _settings.value.location;
    return location == null ? null : _tables.nearest(location);
  }

  /// Chooses the published table of the place [id] for the selected city (and
  /// moves the city to its coordinates), or [id] == null to go back to
  /// calculation. Either way the user has decided: «automatic» is off. The
  /// city stays where it is when going back.
  Future<void> selectTable(String? id) async {
    final cityId = _cities.value.selectedId;
    if (id == null) {
      _edit(cityId, (s) => s.copyWith(tableAuto: false, clearTable: true));
      return;
    }
    final place = _tables.place(id);
    final table = await _tables.table(id);
    final city = _cities.value.byId(cityId);
    if (place == null || table == null || city == null) return;
    final settings = city.settings.copyWith(
      tableAuto: false,
      tableId: id,
      table: table,
      location: place.location,
    );
    _save(
      _cities.value.replace(
        city.copyWith(settings: settings).named(place.name),
      ),
    );
  }

  /// Switches «automatic» on for the selected city: the table of the nearest
  /// place follows its place from now on.
  Future<void> useAutoTable() async {
    final cityId = _cities.value.selectedId;
    _edit(cityId, (s) => s.copyWith(tableAuto: true));
    await _followPlace(cityId);
  }

  /// In «automatic» mode: the nearest table of the city's place, or
  /// calculation when there is none. Never moves the place.
  Future<void> _followPlace(int cityId) async {
    final location = _cities.value.byId(cityId)?.settings.location;
    final place = location == null ? null : _tables.nearest(location);
    final table = place == null ? null : await _tables.table(place.id);
    final city = _cities.value.byId(cityId);
    // The user chose or moved meanwhile.
    if (city == null ||
        !city.settings.tableAuto ||
        city.settings.location != location) {
      return;
    }
    if (place == null || table == null) {
      final settings = city.settings.copyWith(clearTable: true);
      _save(_cities.value.replace(city.copyWith(settings: settings)));
      return;
    }
    final settings = city.settings.copyWith(tableId: place.id, table: table);
    _save(
      _cities.value.replace(
        city.copyWith(settings: settings).named(place.name),
      ),
    );
  }

  /// Changes the selected city's settings.
  void update(PrayerSettings Function(PrayerSettings current) change) =>
      _edit(_cities.value.selectedId, change);

  /// Reads the device position and stores it as the selected city's place.
  Future<LocateResult> locate() async {
    final cityId = _cities.value.selectedId;
    final location = await _locator.locate();
    if (location == null) return _locator.failure;
    final city = _cities.value.byId(cityId);
    if (city == null) return LocateResult.done;
    final moved = city.copyWith(
      settings: city.settings.copyWith(location: location),
    );
    final old = city.settings.location;
    // A name found for another place would be wrong now.
    final far = old == null || old.distanceKmTo(location) > cityRadiusKm;
    _save(_cities.value.replace(far ? moved.named(null) : moved));
    if (moved.settings.tableAuto) await _followPlace(cityId);
    return LocateResult.done;
  }

  /// Makes the saved city [id] the selected one.
  void selectCity(int id) => _save(_cities.value.select(id));

  /// Adds the city of the published table [tableId] and selects it. False when
  /// the list is full or the table cannot be read.
  Future<bool> addTableCity(String tableId) async {
    final place = _tables.place(tableId);
    final table = await _tables.table(tableId);
    if (place == null || table == null) return false;
    return _add(
      PrayerSettings(
        tableAuto: false,
        tableId: tableId,
        table: table,
        location: place.location,
      ),
      name: place.name,
    );
  }

  /// Adds a city at the device's position and selects it; its table is the
  /// nearest one, if any. Nothing is added when the list is full.
  Future<LocateResult> addCurrentCity() async {
    final location = await _locator.locate();
    if (location == null) return _locator.failure;
    if (_add(PrayerSettings(location: location))) {
      await _followPlace(_cities.value.selectedId);
    }
    return LocateResult.done;
  }

  bool _add(PrayerSettings settings, {String? name}) {
    final cities = _cities.value;
    if (cities.isEmpty) {
      // The lone city without a place takes it, keeping what was set up.
      final first = cities.selected;
      final placed = first.settings.copyWith(
        location: settings.location,
        tableAuto: settings.tableAuto,
        tableId: settings.tableId,
        table: settings.table,
      );
      _save(cities.replace(first.copyWith(settings: placed).named(name)));
      return true;
    }
    if (!cities.canAdd) return false;
    var id = _clock().millisecondsSinceEpoch;
    while (cities.byId(id) != null) {
      id++;
    }
    _save(cities.add(PrayerCity(id: id, name: name, settings: settings)));
    return true;
  }

  /// Removes the saved city [id]; the last one stays.
  void removeCity(int id) => _save(_cities.value.remove(id));

  /// Keeps [name] for the city [id] if it still has none.
  void nameCity(int id, String name) {
    final city = _cities.value.byId(id);
    if (city == null || city.name != null || name.isEmpty) return;
    _save(_cities.value.replace(city.named(name)));
  }

  /// Selects the saved city where the device is. No city's place changes.
  Future<NearestCityResult> selectNearestCity() async {
    final location = await _locator.locate();
    if (location == null) {
      return _locator.failure == LocateResult.denied
          ? NearestCityResult.denied
          : NearestCityResult.unavailable;
    }
    final city = _cities.value.nearest(location, cityRadiusKm);
    if (city == null) return NearestCityResult.noneNear;
    selectCity(city.id);
    return NearestCityResult.selected;
  }

  void _edit(int cityId, PrayerSettings Function(PrayerSettings) change) {
    final city = _cities.value.byId(cityId);
    if (city == null) return;
    _save(
      _cities.value.replace(city.copyWith(settings: change(city.settings))),
    );
  }

  void _save(PrayerCities next) {
    if (_cities.update((_) => next)) _publish();
  }

  /// Publishes restored or derived state without saving it.
  void _restore(PrayerCities next) {
    _cities.value = next;
    _publish();
  }

  void _publish() {
    final cities = _cities.value;
    _settings.value = cities.selected.settings;
    _all.value = cities;
  }

  Future<void> get flushed => _cities.flushed;

  void dispose() {
    _cities.dispose();
    _settings.dispose();
    _all.dispose();
  }
}

/// Stands in where no table repository is given (tests of the settings only).
class _NoTables implements PrayerTableSource {
  @override
  Future<List<PrayerTablePlace>> loadIndex() async => const [];

  @override
  Future<PrayerTable?> loadTable(PrayerTablePlace place) async => null;
}
