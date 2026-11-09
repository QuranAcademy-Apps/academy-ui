import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:academy_islamic/academy_islamic.dart';

/// The bundled tables, as the app reads them (`tool/prayer_tables` builds them).
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final source = AssetPrayerTableSource(rootBundle);

  test('the index lists unique places with plausible coordinates', () async {
    final places = await source.loadIndex();
    expect(places.length, greaterThan(300));
    expect(places.map((p) => p.id).toSet().length, places.length);
    expect(places.map((p) => p.file).toSet().length, places.length);
    for (final place in places) {
      expect(
        place.location.latitude,
        inInclusiveRange(41.0, 77.0),
        reason: place.name,
      );
      expect(
        place.location.longitude,
        inInclusiveRange(19.0, 180.0),
        reason: place.name,
      );
      expect(place.days, inInclusiveRange(30, 366), reason: place.name);
    }
  });

  test(
    'every table file loads and every day has six ascending-or-night times',
    () async {
      final places = await source.loadIndex();
      for (final place in places) {
        final table = await source.loadTable(place);
        expect(table, isNotNull, reason: place.name);
        final first = table!.day(place.start)!;
        expect(first.length, DayMoment.values.length, reason: place.name);
        final last = table.day(
          place.start.add(Duration(days: place.days - 1)),
        )!;
        expect(
          last[DayMoment.fajr]!.isBefore(last[DayMoment.isha]!),
          isTrue,
          reason: place.name,
        );
        expect(table.day(place.start.add(Duration(days: place.days))), isNull);
      }
    },
  );

  test('Kazan matches the published table of DUM RT', () async {
    final places = await source.loadIndex();
    final kazan = places.firstWhere((p) => p.name == 'Казань');
    expect(kazan.kind, PrayerTableKind.official);
    final day = (await source.loadTable(kazan))!.day(DateTime(2026, 1, 1))!;
    String hm(DayMoment m) =>
        '${day[m]!.hour.toString().padLeft(2, '0')}:${day[m]!.minute.toString().padLeft(2, '0')}';
    expect(
      [for (final m in DayMoment.values) hm(m)],
      ['05:53', '08:14', '12:00', '13:34', '15:22', '17:19'],
    );
  });
}
