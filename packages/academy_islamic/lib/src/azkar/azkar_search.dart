import 'azkar_catalog.dart';
import 'zikr.dart';

/// In-memory search over translation, transliteration, title and Arabic
/// (Arabic without tashkeel). Every query word must match.
class AzkarSearch {
  AzkarSearch(AzkarCatalog catalog)
    : _index = [
        for (final zikr in catalog.all)
          (
            zikr,
            normalize(
              [
                zikr.title ?? '',
                zikr.translation,
                zikr.transliteration ?? '',
                zikr.arabic,
              ].join(' '),
            ),
          ),
      ];

  static const maxResults = 50;

  final List<(Zikr, String)> _index;

  List<Zikr> search(String query) {
    final words = normalize(query)
        .split(' ')
        .where((word) => word.isNotEmpty)
        .toList();
    if (words.isEmpty) return const [];
    final results = <Zikr>[];
    for (final (zikr, text) in _index) {
      if (!words.every(text.contains)) continue;
      results.add(zikr);
      if (results.length == maxResults) break;
    }
    return results;
  }

  static final _tashkeel = RegExp('[ؐ-ًؚ-ٰٟۖ-ۭـ]');
  static final _alef = RegExp('[آأإٱ]');
  static final _separators = RegExp(r'[\s\-‑–—,.;:!?«»"()\[\]]+');

  static String normalize(String text) => text
      .toLowerCase()
      .replaceAll('ё', 'е')
      .replaceAll(_tashkeel, '')
      .replaceAll(_alef, 'ا')
      .replaceAll(_separators, ' ')
      .trim();
}
