import 'dart:convert';
import 'dart:io';

import 'package:academy_islamic/academy_islamic.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/test_catalog.dart';

/// Reads the package's assets from disk, as an app's bundle serves them.
class _DiskBundle extends CachingAssetBundle {
  @override
  Future<ByteData> load(String key) async {
    final bytes = File(
      key.replaceFirst('packages/academy_islamic/', ''),
    ).readAsBytesSync();
    return ByteData.sublistView(bytes);
  }
}

void main() {
  test('every corpus and Hisn text has one gloss per word', () async {
    final catalog = await AzkarCorpus.load(_DiskBundle());
    final problems = <String>[];
    expect(catalog.all.length, greaterThan(400));
    {
      for (final zikr in catalog.all) {
        final id = zikr.id;
        final glosses = zikr.wordGlosses;
        if (glosses == null) {
          problems.add('$id: no glosses');
        } else if (glosses.length != ZikrWords.split(zikr.arabic).length) {
          problems.add(
            '$id: ${glosses.length} glosses, '
            '${ZikrWords.split(zikr.arabic).length} words',
          );
        } else if (glosses.first.isEmpty) {
          problems.add('$id: first gloss is empty');
        }
      }
    }
    expect(problems, isEmpty);
  });

  test("an app's glosses are added to the corpus's and win on the same id", () async {
    final own = jsonDecode(
      File('assets/azkar/words.json').readAsStringSync(),
    ) as Map<String, dynamic>;
    final catalog = await AzkarCorpus.load(
      _DiskBundle(),
      words: {
        '1': ['own'],
        '100301': ['hisn'],
      },
    );
    expect(catalog.zikr(1).wordGlosses, ['own']);
    expect(catalog.zikr(2).wordGlosses, own['2']);
  });

  test('the catalog read without the bundle has no glosses', () {
    expect(loadTestCatalog().zikr(1).wordGlosses, isNull);
  });
}
