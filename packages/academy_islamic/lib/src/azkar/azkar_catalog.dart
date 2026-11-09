import 'zikr.dart';
import 'zikr_category.dart';

/// Immutable corpus: every dhikr by id, default collection order, virtues.
class AzkarCatalog {
  AzkarCatalog({
    required Map<int, Zikr> azkar,
    required Map<ZikrCategory, List<int>> collections,
    required this.fadail,
    this.chapters = const [],
  }) : _azkar = Map.unmodifiable(azkar),
       _collections = Map.unmodifiable({
         for (final entry in collections.entries)
           entry.key: List<int>.unmodifiable(entry.value),
       }),
       _chapterOf = {
         for (final chapter in chapters)
           for (final id in chapter.zikrIds) id: chapter,
       },
       _categoriesOf = _indexCategories(collections);

  static Map<int, List<ZikrCategory>> _indexCategories(
    Map<ZikrCategory, List<int>> collections,
  ) {
    final index = <int, List<ZikrCategory>>{};
    for (final entry in collections.entries) {
      for (final id in entry.value) {
        (index[id] ??= []).add(entry.key);
      }
    }
    return {
      for (final entry in index.entries)
        entry.key: List.unmodifiable(entry.value),
    };
  }

  /// [json] is `azkar.json`; [hisn] is `hisn.json` («Крепость мусульманина»).
  factory AzkarCatalog.fromJson(
    Map<String, dynamic> json, {
    Map<String, dynamic>? hisn,
    Map<String, dynamic>? words,
  }) {
    List<String>? glosses(Object id) => [
      for (final gloss in words?['$id'] as List? ?? const []) gloss as String,
    ].nullIfEmpty;
    final azkar = {
      for (final item in json['azkar'] as List)
        (item as Map<String, dynamic>)['id'] as int: Zikr.fromJson(
          item,
          wordGlosses: glosses(item['id'] as int),
        ),
    };
    final chapters = <HisnChapter>[];
    for (final item in hisn?['chapters'] as List? ?? const []) {
      final map = item as Map<String, dynamic>;
      final duas = [
        for (final dua in map['duas'] as List)
          Zikr.fromHisnJson(
            dua as Map<String, dynamic>,
            wordGlosses: glosses(Zikr.hisnId((dua)['id'] as String)),
          ),
      ];
      for (final dua in duas) {
        azkar[dua.id] = dua;
      }
      chapters.add(
        HisnChapter(
          id: map['id'] as int,
          number: chapters.length + 1,
          title: map['title'] as String,
          zikrIds: List.unmodifiable(duas.map((dua) => dua.id)),
        ),
      );
    }
    final collections = <ZikrCategory, List<int>>{};
    for (final item in json['categories'] as List) {
      final map = item as Map<String, dynamic>;
      final category = ZikrCategory.byId(map['id'] as String);
      if (category == null) continue;
      collections[category] = [
        for (final id in map['azkarIds'] as List)
          if (azkar.containsKey(id)) id as int,
      ];
    }
    return AzkarCatalog(
      azkar: azkar,
      collections: collections,
      fadail: [
        for (final item in json['fadail'] as List? ?? const [])
          Fadl.fromJson(item as Map<String, dynamic>),
      ],
      chapters: List.unmodifiable(chapters),
    );
  }

  final Map<int, Zikr> _azkar;
  final Map<ZikrCategory, List<int>> _collections;
  final List<Fadl> fadail;

  /// «Крепость мусульманина», in book order.
  final List<HisnChapter> chapters;

  /// Reverse indexes, built once: lists and search ask per dhikr.
  final Map<int, HisnChapter> _chapterOf;
  final Map<int, List<ZikrCategory>> _categoriesOf;

  HisnChapter? chapterOf(int zikrId) => _chapterOf[zikrId];

  Iterable<Zikr> get all => _azkar.values;

  Zikr? maybe(int id) => _azkar[id];

  Zikr zikr(int id) => _azkar[id]!;

  /// Default, editorial order of a collection.
  List<int> defaultIds(ZikrCategory category) =>
      _collections[category] ?? const [];

  /// Collections that contain the dhikr by default.
  List<ZikrCategory> categoriesOf(int id) => _categoriesOf[id] ?? const [];
}

extension on List<String> {
  List<String>? get nullIfEmpty => isEmpty ? null : this;
}

/// One chapter of «Крепость мусульманина».
class HisnChapter {
  const HisnChapter({
    required this.id,
    required this.number,
    required this.title,
    required this.zikrIds,
  });

  /// Chapter id in the source book (stable).
  final int id;

  /// 1-based position in the app list.
  final int number;
  final String title;
  final List<int> zikrIds;

  String get progressKey => 'hisn-$id';
}
