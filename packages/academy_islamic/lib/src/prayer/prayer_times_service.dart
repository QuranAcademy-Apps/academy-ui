import 'package:flutter/foundation.dart';

import 'prayer_settings.dart';
import 'prayer_table.dart';
import '../storage/key_value_store.dart';
import '../storage/persisted_json.dart';
import 'device_locator.dart';
import 'prayer_table_source.dart';
import 'prayer_tables_repository.dart';

/// Owns the prayer-times place, the chosen published table and calculation
/// settings (persisted). The times themselves are derived by `prayerSnapshot`
/// where they are shown: from the table where it covers the date, else
/// calculated.
class PrayerTimesService {
  PrayerTimesService(
    KeyValueStore store, {
    DeviceLocator? locator,
    PrayerTablesRepository? tables,
    String key = storageKey,
  }) : _settings = PersistedNotifier(
         store,
         key,
         const PrayerSettings(),
         toJson: (settings) => settings.toJson(),
       ),
       _locator = locator ?? GeolocatorDeviceLocator(),
       _tables = tables ?? PrayerTablesRepository(_NoTables());

  /// The key Zikro has always used; another app passes its own [key].
  static const storageKey = 'zikro.prayer.v1';

  final PersistedNotifier<PrayerSettings> _settings;
  final DeviceLocator _locator;
  final PrayerTablesRepository _tables;

  ValueListenable<PrayerSettings> get settings => _settings.listenable;

  /// Places that have a published table (empty until [load] has run).
  List<PrayerTablePlace> get tablePlaces => _tables.places;

  /// The place [id] among [tablePlaces], if any.
  PrayerTablePlace? tablePlace(String? id) =>
      id == null ? null : _tables.place(id);

  Future<void> load() async {
    final saved = await _settings.read();
    if (saved != null) _settings.value = PrayerSettings.fromJson(saved);
    await _tables.load();
    if (_settings.value.tableAuto) {
      await _followPlace();
      return;
    }
    final id = _settings.value.tableId;
    if (id == null) return;
    final table = await _tables.table(id);
    // A saved choice that no longer exists falls back to calculation.
    _settings.value = table == null
        ? _settings.value.copyWith(clearTable: true)
        : _settings.value.copyWith(table: table);
  }

  /// The table that «automatic» picks at the current place (null: no place,
  /// or nothing near).
  PrayerTablePlace? get nearestTablePlace {
    final location = _settings.value.location;
    return location == null ? null : _tables.nearest(location);
  }

  /// Chooses the published table of the place [id] (and moves the place to
  /// its coordinates), or [id] == null to go back to calculation. Either way
  /// the user has decided: «automatic» is off. The place of the times stays
  /// where it is when going back.
  Future<void> selectTable(String? id) async {
    if (id == null) {
      update((s) => s.copyWith(tableAuto: false, clearTable: true));
      return;
    }
    final place = _tables.place(id);
    final table = await _tables.table(id);
    if (place == null || table == null) return;
    update(
      (s) => s.copyWith(
        tableAuto: false,
        tableId: id,
        table: table,
        location: place.location,
      ),
    );
  }

  /// Switches «automatic» on: the table of the nearest place follows the
  /// user's place from now on.
  Future<void> useAutoTable() async {
    update((s) => s.copyWith(tableAuto: true));
    await _followPlace();
  }

  /// In «automatic» mode: the nearest table of the current place, or
  /// calculation when there is none. Never moves the user's place.
  Future<void> _followPlace() async {
    final place = nearestTablePlace;
    final table = place == null ? null : await _tables.table(place.id);
    if (!_settings.value.tableAuto) return; // the user chose meanwhile
    update(
      (s) => table == null
          ? s.copyWith(clearTable: true)
          : s.copyWith(tableId: place!.id, table: table),
    );
  }

  void update(PrayerSettings Function(PrayerSettings current) change) =>
      _settings.update(change);

  /// Reads the device position and stores it as the place for the times.
  Future<LocateResult> locate() async {
    final location = await _locator.locate();
    if (location == null) return _locator.failure;
    update((s) => s.copyWith(location: location));
    if (_settings.value.tableAuto) await _followPlace();
    return LocateResult.done;
  }

  Future<void> get flushed => _settings.flushed;

  void dispose() => _settings.dispose();
}

/// Stands in where no table repository is given (tests of the settings only).
class _NoTables implements PrayerTableSource {
  @override
  Future<List<PrayerTablePlace>> loadIndex() async => const [];

  @override
  Future<PrayerTable?> loadTable(PrayerTablePlace place) async => null;
}
