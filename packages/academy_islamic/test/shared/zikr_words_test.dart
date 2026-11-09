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
    expect(catalog.defaultIds(ZikrCategory.morning), hasLength(17));
    expect(catalog.defaultIds(ZikrCategory.evening), hasLength(16));
    expect(catalog.defaultIds(ZikrCategory.hundredDua), hasLength(100));
  });
}
