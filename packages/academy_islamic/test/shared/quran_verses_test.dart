import 'package:academy_islamic/academy_islamic.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/test_catalog.dart';

void main() {
  test('suras end each verse with its number, as in the mushaf', () {
    final falaq = loadTestCatalog().zikr(16);
    final lines = ArabicTranscriber.sourceLines(falaq.arabic);
    expect(lines.first, isNot(contains('۝')), reason: 'basmala');
    expect(lines.skip(1).map((line) => line.split('۝ ').last), [
      '١',
      '٢',
      '٣',
      '٤',
      '٥',
    ]);
    expect(loadTestCatalog().zikr(14).arabic, endsWith('۝ ٢٥٥'));
  });

  test('verse numbers keep the words and the transliteration', () {
    final ikhlas = loadTestCatalog().zikr(15);
    // One gloss cell per word in Zikro's words_ru.tsv: the numbers add none.
    expect(ZikrWords.split(ikhlas.arabic), hasLength(19));
    final text = ArabicTranscriber.text(
      ikhlas.arabic,
      TranscriptionScheme.general,
    );
    expect(text, isNot(contains(RegExp('[۝٠-٩]'))));
  });
}
