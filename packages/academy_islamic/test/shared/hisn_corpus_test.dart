import 'dart:convert';
import 'dart:io';

import 'package:academy_islamic/academy_islamic.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

class _DiskBundle extends CachingAssetBundle {
  @override
  Future<ByteData> load(String key) async => ByteData.sublistView(
    File(key.replaceFirst('packages/academy_islamic/', '')).readAsBytesSync(),
  );
}

void main() {
  test('the corpus carries «Крепость мусульманина»', () async {
    final catalog = await AzkarCorpus.load(_DiskBundle());
    expect(catalog.chapters, hasLength(57));
    final duas = [
      for (final chapter in catalog.chapters)
        for (final id in chapter.zikrIds) catalog.zikr(id),
    ];
    expect(duas, hasLength(232));
    expect(duas.every((z) => z.isHisn && z.arabic.isNotEmpty), isTrue);
    expect(duas.every((z) => z.translation.isNotEmpty), isTrue);
    // Every chapter belongs to a theme; the themes keep the book order.
    final sections = HisnSection.group(catalog.chapters);
    expect(
      sections.fold<int>(0, (sum, s) => sum + s.$2.length),
      catalog.chapters.length,
    );
    expect(sections.first.$1, HisnSection.sleep);
  });

  test('an app can replace the bundled Hisn document', () async {
    final none = await AzkarCorpus.load(
      _DiskBundle(),
      hisn: {'version': 1, 'chapters': <Object>[]},
    );
    expect(none.chapters, isEmpty);
  });

  test('the Hisn document states its source and that it has no license', () {
    final json =
        jsonDecode(File('assets/azkar/hisn.json').readAsStringSync())
            as Map<String, dynamic>;
    final provenance = json['provenance'] as Map<String, dynamic>;
    expect(provenance['repository'], 'shakhbanov/dua-from-sunna');
    expect(provenance['license'], contains('not specified'));
  });
}
