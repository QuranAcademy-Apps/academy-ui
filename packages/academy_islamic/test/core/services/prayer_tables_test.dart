import 'package:flutter_test/flutter_test.dart';
import 'package:academy_islamic/academy_islamic.dart';

const _kazan = PrayerLocation(55.7887, 49.1221);

PrayerTablePlace _place({
  String id = 'a',
  int days = 2,
  String rev = '1',
  PrayerLocation location = _kazan,
  PrayerTableKind kind = PrayerTableKind.official,
}) => PrayerTablePlace(
  id: id,
  name: id.toUpperCase(),
  kind: kind,
  source: 'Test DUM',
  location: location,
  file: 'cities/$id.json',
  revision: rev,
  start: DateTime.utc(2026, 6),
  days: days,
);

/// Two days from 1 June 2026. Day 1: Isha at 00:30 belongs to the next day.
PrayerTable _table({String id = 'a'}) => PrayerTable(_place(id: id), const [
  120, 240, 780, 1020, 1230, 30, // 1 Jun
  125, 245, 780, 1020, 1228, 1350, // 2 Jun
]);

class _FakeSource implements PrayerTableSource {
  _FakeSource(this.places);

  final List<PrayerTablePlace> places;
  int loads = 0;

  @override
  Future<List<PrayerTablePlace>> loadIndex() async => places;

  @override
  Future<PrayerTable?> loadTable(PrayerTablePlace place) async {
    loads++;
    return PrayerTable(place, [
      for (var d = 0; d < place.days; d++) ...[120, 240, 780, 1020, 1230, 1350],
    ]);
  }
}

class _BrokenSource implements PrayerTableSource {
  @override
  Future<List<PrayerTablePlace>> loadIndex() async =>
      throw const FormatException('bad index');

  @override
  Future<PrayerTable?> loadTable(PrayerTablePlace place) async => null;
}

class _FixedLocator implements DeviceLocator {
  _FixedLocator(this.location);

  final PrayerLocation location;

  @override
  LocateResult get failure => LocateResult.unavailable;

  @override
  Future<PrayerLocation?> locate() async => location;
}

class _NoLocator implements DeviceLocator {
  @override
  LocateResult get failure => LocateResult.unavailable;

  @override
  Future<PrayerLocation?> locate() async => null;
}

void main() {
  group('PrayerTable', () {
    test('maps minutes to local times of the day', () {
      final day = _table().day(DateTime(2026, 6, 2, 15))!;
      expect(day[DayMoment.fajr], DateTime(2026, 6, 2, 2, 5));
      expect(day[DayMoment.dhuhr], DateTime(2026, 6, 2, 13));
      expect(day[DayMoment.isha], DateTime(2026, 6, 2, 22, 30));
    });

    test('an event before the previous one is after midnight', () {
      final day = _table().day(DateTime(2026, 6, 1))!;
      expect(day[DayMoment.maghrib], DateTime(2026, 6, 1, 20, 30));
      expect(day[DayMoment.isha], DateTime(2026, 6, 2, 0, 30));
    });

    test('null outside the covered days', () {
      expect(_table().day(DateTime(2026, 5, 31)), isNull);
      expect(_table().day(DateTime(2026, 6, 3)), isNull);
    });

    test('the number of values must match the days', () {
      expect(
        () => PrayerTable(_place(days: 2), const [1, 2, 3]),
        throwsFormatException,
      );
    });

    test('place and table parse from json', () {
      final place = PrayerTablePlace.fromJson({
        'id': 'казань',
        'name': 'Казань',
        'kind': 'calculated',
        'source': 'x',
        'lat': 55.8,
        'lon': 49.1,
        'file': 'cities/001.json',
        'rev': 'abc',
        'start': '2026-01-01',
        'days': 1,
      });
      expect(place.kind, PrayerTableKind.calculated);
      expect(place.start, DateTime.utc(2026));
      final table = PrayerTable.fromJson(place, {
        't': [1, 2, 3, 4, 5, 6],
      });
      expect(
        table.day(DateTime(2026, 1, 1))![DayMoment.isha],
        DateTime(2026, 1, 1, 0, 6),
      );
      expect(PrayerTableKind.parse('nonsense'), PrayerTableKind.unverified);
    });
  });

  group('PrayerSettings with a table', () {
    test('only the table id is saved and read back', () {
      final settings = PrayerSettings(
        location: _kazan,
        tableId: 'a',
        table: _table(),
      );
      final json = settings.toJson();
      expect(json['table'], 'a');
      final restored = PrayerSettings.fromJson(json);
      expect(restored.tableId, 'a');
      expect(restored.table, isNull);
    });

    test('clearTable drops both the id and the table', () {
      final settings = PrayerSettings(tableId: 'a', table: _table());
      final cleared = settings.copyWith(clearTable: true);
      expect(cleared.tableId, isNull);
      expect(cleared.table, isNull);
      expect(cleared.toJson().containsKey('table'), isFalse);
    });

    test('a loaded table makes the settings differ', () {
      const bare = PrayerSettings(tableId: 'a');
      expect(bare, isNot(bare.copyWith(table: _table())));
    });
  });

  group('calculator', () {
    final settings = PrayerSettings(
      location: _kazan,
      tableId: 'a',
      table: _table(),
    );

    test('the table wins where it covers the date', () {
      final day = dayTimes(settings, _kazan, DateTime(2026, 6, 2));
      expect(day[DayMoment.fajr], DateTime(2026, 6, 2, 2, 5));
    });

    test('shifts apply on top of the table', () {
      final shifted = settings.adjusted(DayMoment.dhuhr, 5);
      final day = dayTimes(shifted, _kazan, DateTime(2026, 6, 2));
      expect(day[DayMoment.dhuhr], DateTime(2026, 6, 2, 13, 5));
    });

    test('calculation takes over outside the table', () {
      final day = dayTimes(settings, _kazan, DateTime(2026, 6, 10));
      final calculated = dayTimes(
        settings.copyWith(clearTable: true),
        _kazan,
        DateTime(2026, 6, 10),
      );
      expect(day, calculated);
    });

    test('the night comes from the table', () {
      final night = nightTimes(settings, _kazan, DateTime(2026, 6, 1));
      // Maghrib 20:30 on 1 Jun, Fajr 02:05 on 2 Jun: 5 h 35 min.
      expect(night.middle, DateTime(2026, 6, 1, 23, 17, 30));
      expect(
        night.lastThird.difference(DateTime(2026, 6, 1, 20, 30)).inMinutes,
        223,
      );
    });

    test('the night of the last table day is calculated', () {
      final night = nightTimes(settings, _kazan, DateTime(2026, 6, 2));
      final calculated = nightTimes(
        settings.copyWith(clearTable: true),
        _kazan,
        DateTime(2026, 6, 2),
      );
      expect(night.middle, calculated.middle);
    });
  });

  group('PrayerTablesRepository', () {
    test('reads the index and loads a table once', () async {
      final source = _FakeSource([_place(), _place(id: 'b')]);
      final repository = PrayerTablesRepository(source);
      await repository.load();
      expect(repository.places.map((p) => p.id), ['a', 'b']);
      final first = await repository.table('a');
      final second = await repository.table('a');
      expect(identical(first, second), isTrue);
      expect(source.loads, 1);
      await repository.table('b');
      await repository.table('a');
      expect(source.loads, 3); // only the last table is kept
    });

    test('an unknown place has no table', () async {
      final repository = PrayerTablesRepository(_FakeSource([_place()]));
      await repository.load();
      expect(await repository.table('zzz'), isNull);
    });

    test('a broken index leaves no places', () async {
      final repository = PrayerTablesRepository(_BrokenSource());
      await repository.load();
      expect(repository.places, isEmpty);
    });
  });

  group('PrayerTimesService', () {
    PrayerTimesService build(KeyValueStore store) => PrayerTimesService(
      store,
      locator: _NoLocator(),
      tables: PrayerTablesRepository(_FakeSource([_place(), _place(id: 'b')])),
    );

    test('choosing a table sets the place and is saved', () async {
      final store = MemoryKeyValueStore();
      final service = build(store);
      await service.load();
      await service.selectTable('a');
      final settings = service.settings.value;
      expect(settings.tableId, 'a');
      expect(settings.table, isNotNull);
      expect(settings.location, _kazan);
      await service.flushed;

      final reopened = build(store);
      await reopened.load();
      expect(reopened.settings.value.tableId, 'a');
      expect(reopened.settings.value.table, isNotNull);
    });

    test('going back to calculation keeps the place', () async {
      final service = build(MemoryKeyValueStore());
      await service.load();
      await service.selectTable('a');
      await service.selectTable(null);
      expect(service.settings.value.tableId, isNull);
      expect(service.settings.value.table, isNull);
      expect(service.settings.value.location, _kazan);
    });

    test('a saved choice that no longer exists is dropped', () async {
      final store = MemoryKeyValueStore();
      final first = build(store);
      await first.load();
      await first.selectTable('a');
      await first.flushed;

      final gone = PrayerTimesService(
        store,
        locator: _NoLocator(),
        tables: PrayerTablesRepository(_FakeSource([_place(id: 'b')])),
      );
      await gone.load();
      expect(gone.settings.value.tableId, isNull);
    });

    test('an unknown id changes nothing', () async {
      final service = build(MemoryKeyValueStore());
      await service.load();
      await service.selectTable('nope');
      expect(service.settings.value.tableId, isNull);
    });
  });

  group('nearest table', () {
    // About 1.1 km per 0.01° of latitude.
    const here = PrayerLocation(55.8000, 49.1000);
    PrayerLocation north(double km) => PrayerLocation(55.8 + km / 111.2, 49.1);

    PrayerTablesRepository build(List<PrayerTablePlace> places) =>
        PrayerTablesRepository(_FakeSource(places));

    test('distance is the great-circle one', () {
      const moscow = PrayerLocation(55.7558, 37.6173);
      expect(moscow.distanceKmTo(_kazan), closeTo(719, 6));
      expect(moscow.distanceKmTo(moscow), 0);
    });

    test('the nearest within the radius wins', () async {
      final repository = build([
        _place(id: 'far', location: north(20)),
        _place(id: 'near', location: north(3)),
      ]);
      await repository.load();
      expect(repository.nearest(here)?.id, 'near');
    });

    test('nothing beyond the radius', () async {
      final repository = build([_place(id: 'far', location: north(45))]);
      await repository.load();
      expect(repository.nearest(here), isNull);
    });

    test('an official table beats a nearer calculated one', () async {
      final repository = build([
        _place(
          id: 'calc',
          location: north(1),
          kind: PrayerTableKind.calculated,
        ),
        _place(id: 'official', location: north(25)),
        _place(
          id: 'unknown',
          location: north(0),
          kind: PrayerTableKind.unverified,
        ),
      ]);
      await repository.load();
      expect(repository.nearest(here)?.id, 'official');
    });

    test('calculated beats unverified; an official one out of reach does not count', () async {
      final repository = build([
        _place(id: 'official', location: north(40)),
        _place(
          id: 'unknown',
          location: north(1),
          kind: PrayerTableKind.unverified,
        ),
        _place(
          id: 'calc',
          location: north(10),
          kind: PrayerTableKind.calculated,
        ),
      ]);
      await repository.load();
      expect(repository.nearest(here)?.id, 'calc');
    });
  });

  group('automatic table', () {
    const here = PrayerLocation(55.8000, 49.1000);
    const elsewhere = PrayerLocation(43.2, 76.9);

    PrayerTimesService build(
      KeyValueStore store, {
      PrayerLocation? gps,
      List<PrayerTablePlace>? places,
    }) => PrayerTimesService(
      store,
      locator: gps == null ? _NoLocator() : _FixedLocator(gps),
      tables: PrayerTablesRepository(
        _FakeSource(
          places ?? [_place(id: 'a'), _place(id: 'b', location: elsewhere)],
        ),
      ),
    );

    test('is on by default, also for saves of earlier builds', () {
      expect(const PrayerSettings().tableAuto, isTrue);
      final old = PrayerSettings.fromJson({
        'latitude': 55.8,
        'longitude': 49.1,
      });
      expect(old.tableAuto, isTrue);
      expect(old.toJson().containsKey('tableAuto'), isFalse);
      expect(old.copyWith(tableAuto: false).toJson()['tableAuto'], isFalse);
      expect(PrayerSettings.fromJson({'tableAuto': false}).tableAuto, isFalse);
    });

    test('picks the nearest table of a saved place at start', () async {
      final store = MemoryKeyValueStore({
        PrayerTimesService.storageKey: '{"latitude":55.8,"longitude":49.1}',
      });
      final service = build(store);
      await service.load();
      expect(service.settings.value.tableId, 'a');
      expect(service.settings.value.table, isNotNull);
      expect(service.settings.value.location, here);
    });

    test('follows the place after a new position, without moving it', () async {
      final service = build(MemoryKeyValueStore(), gps: elsewhere);
      await service.load();
      expect(service.settings.value.tableId, isNull);
      await service.locate();
      expect(service.settings.value.tableId, 'b');
      expect(service.settings.value.location, elsewhere);
    });

    test('no table near → calculation', () async {
      final service = build(
        MemoryKeyValueStore(),
        gps: const PrayerLocation(10, 10),
      );
      await service.load();
      await service.locate();
      expect(service.settings.value.tableId, isNull);
      expect(service.settings.value.table, isNull);
    });

    test(
      'a manual choice turns it off and stays across a new position',
      () async {
        final service = build(MemoryKeyValueStore(), gps: elsewhere);
        await service.load();
        await service.selectTable('a');
        expect(service.settings.value.tableAuto, isFalse);
        await service.locate();
        expect(service.settings.value.tableId, 'a');
        expect(service.settings.value.location, elsewhere);
      },
    );

    test('«calculation» chosen by hand also stays', () async {
      final service = build(MemoryKeyValueStore(), gps: here);
      await service.load();
      await service.locate();
      expect(service.settings.value.tableId, 'a');
      await service.selectTable(null);
      await service.locate();
      expect(service.settings.value.tableAuto, isFalse);
      expect(service.settings.value.tableId, isNull);
    });

    test('switching it back on resolves at once and is saved', () async {
      final store = MemoryKeyValueStore();
      final service = build(store, gps: here);
      await service.load();
      await service.selectTable(null);
      await service.locate();
      await service.useAutoTable();
      expect(service.settings.value.tableAuto, isTrue);
      expect(service.settings.value.tableId, 'a');
      await service.flushed;

      final reopened = build(store);
      await reopened.load();
      expect(reopened.settings.value.tableAuto, isTrue);
      expect(reopened.settings.value.tableId, 'a');
    });

    test('what automatic would pick is readable', () async {
      final service = build(MemoryKeyValueStore(), gps: here);
      await service.load();
      expect(service.nearestTablePlace, isNull); // no place yet
      await service.locate();
      expect(service.nearestTablePlace?.id, 'a');
    });
  });
}
