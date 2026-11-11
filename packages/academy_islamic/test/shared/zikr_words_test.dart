import 'package:academy_islamic/academy_islamic.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/test_catalog.dart';

void main() {
  test('split joins marks to the previous word', () {
    expect(ZikrWords.split('بِسْمِ\nاللَّهِ ۝ ١'), ['بِسْمِ', 'اللَّهِ ۝ ١']);
  });

  test('every dhikr lines up into phrases for smart wrap', () {
    for (final zikr in loadTestCatalog().all) {
      expect(zikr.phrases, isNotNull, reason: 'dhikr ${zikr.id}');
    }
  });

  test('phrases pair each line with its translation and transliteration', () {
    final catalog = loadTestCatalog();
    final phrases = catalog.zikr(1).phrases!;
    expect(phrases, hasLength(9));
    expect(phrases.first.transliteration, isNotEmpty);
    // Source lines that do not line up fall back to running text.
    expect(
      Zikr(id: 0, repeats: 1, arabic: 'أ\nب', translation: 'один').phrases,
      isNull,
    );
  });

  test('daily collections are in the corpus', () {
    final catalog = loadTestCatalog();
    expect(catalog.defaultIds(ZikrCategory.morning), hasLength(24));
    expect(catalog.defaultIds(ZikrCategory.evening), hasLength(22));
    expect(catalog.defaultIds(ZikrCategory.hundredDua), hasLength(100));
  });

  test('morning and evening hold every upstream dawn/dusk dhikr', () {
    final catalog = loadTestCatalog();
    final morning = catalog.defaultIds(ZikrCategory.morning);
    final evening = catalog.defaultIds(ZikrCategory.evening);
    // Upstream leaves ids 50-59 out of its groups; the importer adds them.
    expect(morning, containsAll([50, 52, 54, 55, 57, 58, 59]));
    expect(evening, containsAll([51, 53, 54, 56, 58, 59]));
    // Suras and Ayat al-Kursi stay last.
    expect(morning.last, 14);
    expect(evening.last, 14);
    expect(morning.toSet(), hasLength(morning.length));
    expect(evening.toSet(), hasLength(evening.length));
  });
}
