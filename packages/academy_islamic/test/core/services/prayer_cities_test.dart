import 'package:academy_islamic/academy_islamic.dart';
import 'package:flutter_test/flutter_test.dart';

const _kazan = PrayerLocation(55.7887, 49.1221);
const _ufa = PrayerLocation(54.7351, 55.9587);
const _grozny = PrayerLocation(43.3180, 45.6987);
const _nowhere = PrayerLocation(10, 10);

PrayerTablePlace _place(String id, PrayerLocation location) => PrayerTablePlace(
  id: id,
  name: id.toUpperCase(),
  kind: PrayerTableKind.official,
  source: 'Test DUM',
  location: location,
  file: 'cities/$id.json',
  revision: '1',
  start: DateTime.utc(2026, 6),
  days: 1,
);

class _Source implements PrayerTableSource {
  @override
  Future<List<PrayerTablePlace>> loadIndex() async => [
    _place('kazan', _kazan),
    _place('ufa', _ufa),
    _place('grozny', _grozny),
  ];

  @override
  Future<PrayerTable?> loadTable(PrayerTablePlace place) async =>
      PrayerTable(place, const [120, 240, 780, 1020, 1230, 1350]);
}

class _Locator implements DeviceLocator {
  PrayerLocation? location;

  @override
  LocateResult failure = LocateResult.denied;

  @override
  Future<PrayerLocation?> locate() async => location;
}

void main() {
  late MemoryKeyValueStore store;
  late _Locator locator;
  var now = DateTime(2026, 6);

  setUp(() {
    store = MemoryKeyValueStore();
    locator = _Locator();
  });

  Future<PrayerTimesService> service() async {
    final result = PrayerTimesService(
      store,
      locator: locator,
      tables: PrayerTablesRepository(_Source()),
      clock: () => now = now.add(const Duration(seconds: 1)),
    );
    await result.load();
    return result;
  }

  String? name(PrayerTimesService s) => s.cities.value.selected.name;

  test('a save of an earlier build becomes the only city', () async {
    store.values[PrayerTimesService.storageKey] =
        '{"method":"karachi","asr":"hanafi","highLatitude":"angle",'
        '"latitude":55.7887,"longitude":49.1221,"tableAuto":false,'
        '"table":"kazan"}';

    final s = await service();

    expect(s.cities.value.all, hasLength(1));
    expect(name(s), 'KAZAN');
    expect(s.settings.value.asr, AsrSchool.hanafi);
    expect(s.settings.value.table?.place.id, 'kazan');
  });

  test('the first city fills the empty one, the next ones are added', () async {
    final s = await service();
    s.update((v) => v.copyWith(asr: AsrSchool.hanafi));

    await s.addTableCity('kazan');
    expect(s.cities.value.all, hasLength(1));
    expect(s.settings.value.asr, AsrSchool.hanafi);

    await s.addTableCity('ufa');
    expect(s.cities.value.all.map((c) => c.name), ['KAZAN', 'UFA']);
    expect(name(s), 'UFA');
    expect(s.settings.value.location, _ufa);
    expect(s.settings.value.asr, AsrSchool.standard);
  });

  test('no more than three cities', () async {
    final s = await service();
    for (final id in ['kazan', 'ufa', 'grozny']) {
      expect(await s.addTableCity(id), isTrue);
    }

    expect(await s.addTableCity('kazan'), isFalse);
    expect(s.cities.value.all, hasLength(maxPrayerCities));
  });

  test('each city keeps its own source and shifts', () async {
    final s = await service();
    await s.addTableCity('kazan');
    final kazan = s.cities.value.selectedId;
    await s.addTableCity('ufa');
    s.update((v) => v.adjusted(DayMoment.fajr, 5));
    await s.selectTable(null);

    s.selectCity(kazan);

    expect(s.settings.value.tableId, 'kazan');
    expect(s.settings.value.table?.place.id, 'kazan');
    expect(s.settings.value.adjustmentOf(DayMoment.fajr), 0);
  });

  test('cities and the selection survive a restart, tables loaded', () async {
    final first = await service();
    await first.addTableCity('kazan');
    final kazan = first.cities.value.selectedId;
    await first.addTableCity('ufa');
    first.selectCity(kazan);
    await first.flushed;

    final s = await service();

    expect(s.cities.value.all.map((c) => c.name), ['KAZAN', 'UFA']);
    expect(s.cities.value.selectedId, kazan);
    expect(
      s.cities.value.all.map((c) => c.settings.table?.place.id),
      ['kazan', 'ufa'],
    );
  });

  test('settings has caught up when the cities change', () async {
    final s = await service();
    await s.addTableCity('kazan');
    final kazan = s.cities.value.selectedId;
    await s.addTableCity('ufa');
    final seen = <PrayerLocation?>[];
    s.cities.addListener(() => seen.add(s.settings.value.location));

    s.selectCity(kazan);

    expect(seen, [_kazan]);
  });

  test('removing the selected city selects another; the last stays', () async {
    final s = await service();
    await s.addTableCity('kazan');
    await s.addTableCity('ufa');

    s.removeCity(s.cities.value.selectedId);
    expect(name(s), 'KAZAN');
    expect(s.settings.value.location, _kazan);

    s.removeCity(s.cities.value.selectedId);
    expect(s.cities.value.all, hasLength(1));
  });

  test('a new city never takes the id of a removed one', () async {
    final s = await service();
    await s.addTableCity('kazan');
    await s.addTableCity('ufa');
    final removed = s.cities.value.selectedId;
    s.removeCity(removed);

    await s.addTableCity('grozny');

    expect(s.cities.value.selectedId, isNot(removed));
  });

  test('the nearest saved city is selected without moving any', () async {
    final s = await service();
    await s.addTableCity('kazan');
    await s.addTableCity('ufa');
    locator.location = const PrayerLocation(55.80, 49.10);

    expect(await s.selectNearestCity(), NearestCityResult.selected);

    expect(name(s), 'KAZAN');
    expect(s.settings.value.location, _kazan);
  });

  test('at the place of the selected city its source is not swapped', () async {
    final s = await service();
    await s.addTableCity('kazan');
    // The same city saved again by location, a little off the table's point.
    locator.location = const PrayerLocation(55.80, 49.12);
    await s.addCurrentCity();
    await s.selectTable(null);
    s.selectCity(s.cities.value.all.first.id);

    // The device stands exactly on the second entry.
    expect(await s.selectNearestCity(), NearestCityResult.selected);

    expect(s.cities.value.selectedId, s.cities.value.all.first.id);
    expect(s.settings.value.tableId, 'kazan');
  });

  test('far from every city the selection stays', () async {
    final s = await service();
    await s.addTableCity('kazan');
    await s.addTableCity('ufa');
    locator.location = _nowhere;

    expect(await s.selectNearestCity(), NearestCityResult.noneNear);
    expect(name(s), 'UFA');

    locator.location = null;
    expect(await s.selectNearestCity(), NearestCityResult.denied);
  });

  test('a city added by location takes the nearest table', () async {
    final s = await service();
    await s.addTableCity('kazan');
    locator.location = const PrayerLocation(54.74, 55.96);

    expect(await s.addCurrentCity(), LocateResult.done);

    expect(name(s), 'UFA');
    expect(s.settings.value.tableAuto, isTrue);
    expect(s.cities.value.all, hasLength(2));
  });

  test('a city away from every table is named later', () async {
    final s = await service();
    locator.location = _nowhere;
    await s.addCurrentCity();
    expect(name(s), isNull);

    s.nameCity(s.cities.value.selectedId, 'Деревня');
    await s.flushed;

    expect(name(await service()), 'Деревня');
  });

  test('updating the position of a city drops its stale name', () async {
    final s = await service();
    locator.location = _nowhere;
    await s.addCurrentCity();
    s.nameCity(s.cities.value.selectedId, 'Деревня');
    locator.location = const PrayerLocation(11, 11);

    await s.locate();

    expect(name(s), isNull);
  });

  test('a lone city is saved the way earlier builds read it', () async {
    final s = await service();
    await s.addTableCity('kazan');
    await s.flushed;

    final saved = await store.readJson(PrayerTimesService.storageKey);

    expect(saved!.containsKey('cities'), isFalse);
    expect(saved['table'], 'kazan');
  });
}
