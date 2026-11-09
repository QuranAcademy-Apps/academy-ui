/// One dhikr from the imported corpus (`assets/azkar/azkar.json`).
class Zikr {
  Zikr({
    required this.id,
    required this.repeats,
    required this.arabic,
    required this.translation,
    this.type = ZikrType.hadith,
    this.source,
    this.title,
    this.transliteration,
    this.benefits,
    this.notes,
    this.hadith,
    this.narration,
    this.sourceText,
    this.audio,
    this.wordGlosses,
  });

  /// A supplication of «Крепость мусульманина» (the app's `hisn.json`).
  /// [id] is synthetic and stable: see [hisnId].
  factory Zikr.fromHisnJson(
    Map<String, dynamic> json, {
    List<String>? wordGlosses,
  }) => Zikr(
    id: hisnId(json['id'] as String),
    repeats: json['repeats'] as int? ?? 1,
    title: json['title'] as String?,
    arabic: json['arabic'] as String,
    translation: json['translation'] as String,
    notes: json['note'] as String?,
    narration: json['narration'] as String?,
    sourceText: json['source'] as String?,
    wordGlosses: wordGlosses,
  );

  /// `"29-11"` (chapter 29, dua 11) → 102911. Keeps favorites and progress
  /// stable across imports.
  static int hisnId(String key) {
    final [chapter, index] = key.split('-').map(int.parse).toList();
    return hisnIdBase + chapter * 100 + index;
  }

  static const hisnIdBase = 100000;

  bool get isHisn => id >= hisnIdBase;

  factory Zikr.fromJson(
    Map<String, dynamic> json, {
    List<String>? wordGlosses,
  }) => Zikr(
    id: json['id'] as int,
    repeats: json['repeats'] as int? ?? 1,
    type: json['type'] == 'quran' ? ZikrType.quran : ZikrType.hadith,
    source: json['source'] as String?,
    title: json['title'] as String?,
    arabic: json['arabic'] as String,
    translation: json['translation'] as String,
    transliteration: json['transliteration'] as String?,
    benefits: json['benefits'] as String?,
    notes: json['notes'] as String?,
    audio: json['audio'] as String?,
    hadith: json['hadith'] == null
        ? null
        : Hadith.fromJson(json['hadith'] as Map<String, dynamic>),
    wordGlosses: wordGlosses,
  );

  final int id;

  /// Default number of repetitions; a collection may override it.
  final int repeats;
  final ZikrType type;

  /// Comma-separated collection codes, e.g. `Tirmidhi, Ahmad`.
  final String? source;
  final String? title;
  final String arabic;
  final String translation;
  final String? transliteration;
  final String? benefits;
  final String? notes;
  final Hadith? hadith;

  /// «Передают со слов…» preface of a hadith supplication.
  final String? narration;

  /// Ready-made Russian reference, e.g. «аль-Бухари 6312; Муслим 2711».
  final String? sourceText;

  /// Russian gloss for each word of [arabic] (see `ZikrWords.split`), from
  /// the app's `words.json`; null when the dhikr has none.
  final List<String>? wordGlosses;

  /// Recitation file name; the app that plays it bundles the audio.
  final String? audio;

  /// Phrase-per-line view of the dhikr, or null when the source lines of
  /// Arabic, translation and transliteration do not line up one to one.
  /// Derived once: readers ask on every build.
  late final List<ZikrPhrase>? phrases = _phrases();

  List<ZikrPhrase>? _phrases() {
    List<String> lines(String text) => [
      for (final line in text.split('\n'))
        if (line.trim().isNotEmpty) line.trim(),
    ];
    final arabicLines = lines(arabic);
    final translationLines = lines(translation);
    final transliterationLines = transliteration == null
        ? null
        : lines(transliteration!);
    if (arabicLines.length != translationLines.length ||
        (transliterationLines != null &&
            transliterationLines.length != arabicLines.length)) {
      return null;
    }
    return [
      for (var i = 0; i < arabicLines.length; i++)
        ZikrPhrase(
          arabic: arabicLines[i],
          translation: translationLines[i],
          transliteration: transliterationLines?[i],
        ),
    ];
  }

  /// Short label for lists: the explicit title or the first translation line.
  late final String headline = _headline();

  static final _sentence = RegExp(r'^(.{24,}?[.!?»])\s');

  String _headline() {
    if (title case final title?) return title;
    var line = translation.split('\n').first.trim();
    final sentence = _sentence.firstMatch(line);
    if (sentence != null) line = sentence.group(1)!;
    if (line.length > 90) line = '${line.substring(0, 88).trimRight()}…';
    return line.endsWith(',') ? line.substring(0, line.length - 1) : line;
  }

  late final List<String> sourceCodes = [
    for (final code in (source ?? '').split(','))
      if (code.trim().isNotEmpty) code.trim(),
  ];
}

/// One source line of a dhikr with its translation and transliteration.
class ZikrPhrase {
  const ZikrPhrase({
    required this.arabic,
    required this.translation,
    this.transliteration,
  });

  final String arabic, translation;
  final String? transliteration;
}

enum ZikrType { hadith, quran }

/// Hadith that justifies a dhikr.
class Hadith {
  const Hadith({this.arabic, this.translation, this.source, this.sourceExt});

  factory Hadith.fromJson(Map<String, dynamic> json) => Hadith(
    arabic: json['arabic'] as String?,
    translation: json['translation'] as String?,
    source: json['source'] as String?,
    sourceExt: json['sourceExt'] as String?,
  );

  final String? arabic, translation, source, sourceExt;
}

/// A virtue of remembrance shown on the home screen.
class Fadl {
  const Fadl({required this.text, this.source});

  factory Fadl.fromJson(Map<String, dynamic> json) =>
      Fadl(text: json['text'] as String, source: json['source'] as String?);

  final String text;
  final String? source;
}
