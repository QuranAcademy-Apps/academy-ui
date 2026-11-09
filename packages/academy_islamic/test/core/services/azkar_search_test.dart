import 'package:flutter_test/flutter_test.dart';
import 'package:academy_islamic/academy_islamic.dart';

import '../../support/test_catalog.dart';

void main() {
  final search = AzkarSearch(loadTestCatalog());

  test('finds by translation regardless of case and ё', () {
    final results = search.search('СЛАВА аллаху');
    expect(results.map((z) => z.id), contains(3));
  });

  test('finds by transliteration words in any order', () {
    final results = search.search('би-хамди субхана');
    expect(results.map((z) => z.id), contains(3));
  });

  test('finds Arabic without tashkeel', () {
    final results = search.search('سبحان الله وبحمده');
    expect(results.map((z) => z.id), contains(3));
  });

  test('empty query returns nothing', () {
    expect(search.search('   '), isEmpty);
  });
}
