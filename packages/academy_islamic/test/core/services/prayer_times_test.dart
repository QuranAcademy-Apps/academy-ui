import 'package:flutter_test/flutter_test.dart';
import 'package:academy_islamic/academy_islamic.dart';

class _FakeLocator implements DeviceLocator {
  _FakeLocator(this.location, [this.failure = LocateResult.unavailable]);

  final PrayerLocation? location;

  @override
  final LocateResult failure;

  @override
  Future<PrayerLocation?> locate() async => location;
}

const _makkah = PrayerLocation(21.4225, 39.8262);

void main() {
  final settings = const PrayerSettings(location: _makkah);
  final noon = DateTime(2026, 11, 1, 12);

  test('five prayers come in order', () {
    final day = prayerDay(settings, _makkah, noon);
    final times = Prayer.values.map((p) => day[p]!).toList();
    expect([...times]..sort(), times);
  });

  test('hanafi Asr is later than the standard one', () {
    final standard = prayerDay(settings, _makkah, noon)[Prayer.asr]!;
    final hanafi = prayerDay(
      settings.copyWith(asr: AsrSchool.hanafi),
      _makkah,
      noon,
    )[Prayer.asr]!;
    expect(hanafi.isAfter(standard), isTrue);
  });

  test('next prayer follows the clock and rolls over to tomorrow', () {
    final day = prayerDay(settings, _makkah, noon);
    final afterDhuhr = prayerSnapshot(
      settings,
      day[Prayer.dhuhr]!.add(const Duration(minutes: 1)),
    )!;
    expect(afterDhuhr.next, Prayer.asr);
    expect(afterDhuhr.day[Prayer.asr], day[Prayer.asr]);

    final afterIsha = prayerSnapshot(
      settings,
      day[Prayer.isha]!.add(const Duration(minutes: 1)),
    )!;
    expect(afterIsha.next, Prayer.fajr);
    expect(afterIsha.day[Prayer.fajr]!.isAfter(day[Prayer.isha]!), isTrue);
    expect(afterIsha.remaining, greaterThan(Duration.zero));
  });

  test('no location, no snapshot', () {
    expect(prayerSnapshot(const PrayerSettings(), noon), isNull);
  });

  test('settings survive a JSON round trip and ignore bad coordinates', () {
    const saved = PrayerSettings(
      method: PrayerMethod.russia,
      asr: AsrSchool.hanafi,
      highLatitude: PrayerHighLatitude.angle,
      adjustments: {DayMoment.fajr: -2, DayMoment.isha: 5},
      location: _makkah,
    );
    expect(PrayerSettings.fromJson(saved.toJson()), saved);
    expect(
      PrayerSettings.fromJson({'latitude': 120, 'longitude': 10}).location,
      isNull,
    );
  });

  test('settings saved by the first version load with the new defaults', () {
    final loaded = PrayerSettings.fromJson({
      'method': 'muslimWorldLeague',
      'asr': 'hanafi',
      'latitude': 21.4,
      'longitude': 39.8,
    });
    // MWL was the old default, not a choice; other methods are kept.
    expect(loaded.method, PrayerMethod.auto);
    expect(
      PrayerSettings.fromJson({'method': 'karachi'}).method,
      PrayerMethod.karachi,
    );
    expect(
      PrayerSettings.fromJson({
        'method': 'muslimWorldLeague',
        'highLatitude': 'auto',
      }).method,
      PrayerMethod.muslimWorldLeague,
    );
    expect(loaded.highLatitude, PrayerHighLatitude.auto);
    expect(loaded.adjustments, isEmpty);
    expect(const PrayerSettings().method, PrayerMethod.auto);
  });

  test('adjustments keep only sane non-zero minutes', () {
    final loaded = PrayerSettings.fromJson({
      'adjustments': {'fajr': 3, 'asr': 0, 'isha': 99, 'dhuhr': 'x', 'nope': 1},
    });
    expect(loaded.adjustments, {DayMoment.fajr: 3});

    final shifted = const PrayerSettings().adjusted(DayMoment.asr, 100);
    expect(shifted.adjustmentOf(DayMoment.asr), maxPrayerAdjustment);
    expect(shifted.adjusted(DayMoment.asr, 0).adjustments, isEmpty);
  });

  test('locate stores the place and persists it', () async {
    final store = MemoryKeyValueStore();
    final service = PrayerTimesService(store, locator: _FakeLocator(_makkah));
    expect(await service.locate(), LocateResult.done);
    service.update((s) => s.copyWith(method: PrayerMethod.karachi));
    await service.flushed;

    final restored = PrayerTimesService(store);
    await restored.load();
    expect(restored.settings.value.location, _makkah);
    expect(restored.settings.value.method, PrayerMethod.karachi);
    service.dispose();
    restored.dispose();
  });

  test('locate reports why it failed and keeps the old place', () async {
    final service = PrayerTimesService(
      MemoryKeyValueStore(),
      locator: _FakeLocator(null, LocateResult.denied),
    );
    expect(await service.locate(), LocateResult.denied);
    expect(service.settings.value.location, isNull);
    service.dispose();
  });

  group('day, month and night', () {
    test('six events of a day come in order', () {
      final times = dayTimes(settings, _makkah, noon);
      final ordered = DayMoment.values.map((m) => times[m]!).toList();
      expect([...ordered]..sort(), ordered);
    });

    test('a shift moves exactly that event', () {
      final base = dayTimes(settings, _makkah, noon);
      final shifted = dayTimes(
        settings.adjusted(DayMoment.asr, 5),
        _makkah,
        noon,
      );
      expect(
        shifted[DayMoment.asr]!.difference(base[DayMoment.asr]!),
        const Duration(minutes: 5),
      );
      expect(shifted[DayMoment.fajr], base[DayMoment.fajr]);
    });

    test('a month has one entry per day, equal to the single-day result', () {
      final february = monthTimes(settings, _makkah, 2028, 2);
      expect(february, hasLength(29));
      expect(february.last, dayTimes(settings, _makkah, DateTime(2028, 2, 29)));
      final noons = february.map((d) => d[DayMoment.dhuhr]!).toList();
      expect([...noons]..sort(), noons);
    });

    test('the night: Maghrib, middle, last third, then next Fajr', () {
      final today = dayTimes(settings, _makkah, noon);
      final night = nightTimes(settings, _makkah, noon);
      final fajr = dayTimes(
        settings,
        _makkah,
        noon.add(const Duration(days: 1)),
      )[DayMoment.fajr]!;
      expect(night.middle.isAfter(today[DayMoment.maghrib]!), isTrue);
      expect(night.lastThird.isAfter(night.middle), isTrue);
      expect(night.lastThird.isBefore(fajr), isTrue);
    });

    test('qibla bearing from New York is north-east', () {
      expect(
        qiblaBearing(const PrayerLocation(40.7128, -74.006)),
        inInclusiveRange(57, 60),
      );
    });
  });

  group('high latitudes', () {
    const moscow = PrayerLocation(55.7558, 37.6173);
    const tromso = PrayerLocation(69.65, 18.96);
    const ushuaia = PrayerLocation(-54.8, -68.3);
    final summer = DateTime(2026, 6, 21, 12);

    test('white nights still give six ordered times in Moscow', () {
      final times = dayTimes(const PrayerSettings(), moscow, summer);
      final ordered = DayMoment.values.map((m) => times[m]!).toList();
      expect([...ordered]..sort(), ordered);
    });

    test('the polar day does not break the calculation', () {
      expect(
        () => dayTimes(const PrayerSettings(), tromso, summer),
        returnsNormally,
      );
      expect(
        () => monthTimes(const PrayerSettings(), tromso, 2026, 6),
        returnsNormally,
      );
    });

    test('auto follows the latitude by magnitude, in both hemispheres', () {
      PrayerSettings with_(PrayerHighLatitude rule) =>
          PrayerSettings(highLatitude: rule);
      final winter = DateTime(2026, 12, 21, 12);
      expect(
        dayTimes(with_(PrayerHighLatitude.auto), ushuaia, winter),
        dayTimes(with_(PrayerHighLatitude.seventhOfTheNight), ushuaia, winter),
      );
      expect(
        dayTimes(with_(PrayerHighLatitude.auto), _makkah, winter),
        dayTimes(with_(PrayerHighLatitude.middleOfTheNight), _makkah, winter),
      );
    });
  });

  group('automatic method', () {
    const cities = <String, (double, double, PrayerMethod)>{
      'Moscow': (55.7558, 37.6173, PrayerMethod.russia),
      'Kazan': (55.79, 49.12, PrayerMethod.russia),
      'Ufa': (54.7388, 55.9721, PrayerMethod.russia),
      'Grozny': (43.3185, 45.6949, PrayerMethod.russia),
      'Saint Petersburg': (59.9311, 30.3609, PrayerMethod.russia),
      'Kaliningrad': (54.7104, 20.4522, PrayerMethod.russia),
      'Vladivostok': (43.1155, 131.8855, PrayerMethod.russia),
      'Makkah': (21.4225, 39.8262, PrayerMethod.ummAlQura),
      'Riyadh': (24.7136, 46.6753, PrayerMethod.ummAlQura),
      'Doha': (25.2854, 51.531, PrayerMethod.qatar),
      'Kuwait City': (29.3759, 47.9774, PrayerMethod.kuwait),
      'Dubai': (25.2048, 55.2708, PrayerMethod.dubai),
      'Istanbul': (41.0082, 28.9784, PrayerMethod.turkiye),
      'Cairo': (30.0444, 31.2357, PrayerMethod.egyptian),
      'Baghdad': (33.3152, 44.3661, PrayerMethod.egyptian),
      'Amman': (31.9539, 35.9106, PrayerMethod.jordan),
      'Tehran': (35.6892, 51.389, PrayerMethod.tehran),
      'Karachi': (24.8607, 67.0011, PrayerMethod.karachi),
      'Delhi': (28.6139, 77.209, PrayerMethod.karachi),
      'Jakarta': (-6.2088, 106.8456, PrayerMethod.indonesian),
      'Kuala Lumpur': (3.139, 101.6869, PrayerMethod.singapore),
      'New York': (40.7128, -74.006, PrayerMethod.northAmerica),
      'Casablanca': (33.5731, -7.5898, PrayerMethod.morocco),
      'Algiers': (36.7538, 3.0588, PrayerMethod.algerian),
      'Tunis': (36.8065, 10.1815, PrayerMethod.tunisia),
      'Paris': (48.8566, 2.3522, PrayerMethod.france),
      'Lisbon': (38.7223, -9.1393, PrayerMethod.portugal),
      'London': (51.5074, -0.1278, PrayerMethod.muslimWorldLeague),
      'Berlin': (52.52, 13.405, PrayerMethod.muslimWorldLeague),
      'Sydney': (-33.87, 151.2, PrayerMethod.muslimWorldLeague),
    };

    for (final MapEntry(key: city, value: (latitude, longitude, method))
        in cities.entries) {
      test('$city → ${method.name}', () {
        expect(
          resolvePrayerMethod(PrayerLocation(latitude, longitude)),
          method,
        );
      });
    }

    test('«Auto» uses the regional method, an explicit pick overrides it', () {
      const moscow = PrayerLocation(55.7558, 37.6173);
      const auto = PrayerSettings(location: moscow);
      expect(effectiveMethod(auto, moscow), PrayerMethod.russia);
      expect(
        effectiveMethod(auto.copyWith(method: PrayerMethod.karachi), moscow),
        PrayerMethod.karachi,
      );
      // Russia (16°/15°) is not MWL (18°/17°): Fajr differs.
      final regional = dayTimes(auto, moscow, noon);
      final mwl = dayTimes(
        auto.copyWith(method: PrayerMethod.muslimWorldLeague),
        moscow,
        noon,
      );
      expect(regional[DayMoment.fajr], isNot(mwl[DayMoment.fajr]));
    });

    test('angles of a method are exposed for the picker', () {
      expect(methodAngles(PrayerMethod.russia).fajr, 16);
      expect(methodAngles(PrayerMethod.ummAlQura).ishaInterval, 90);
    });
  });
}
