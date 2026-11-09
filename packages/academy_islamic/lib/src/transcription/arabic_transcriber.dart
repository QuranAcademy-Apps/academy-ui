import 'arabic_word.dart';
import 'scheme_rules.dart';
import 'transcription_scheme.dart';
import 'word_renderer.dart';

/// Regional Cyrillic reading aids generated from vocalised Arabic.
///
/// Rule-based transcriptions, not reviewed translations or recitation
/// sources: they let a reader follow the Arabic when the corpus supplies no
/// transcription of its own. Text missing vowel marks is read with the vowel
/// the neighbouring letters imply, or none.
///
/// Stateless and synchronous; callers cache the result (see `Zikr`).
abstract final class ArabicTranscriber {
  /// One transcription line per non-empty (trimmed) line of [arabic], in the
  /// same order, so the result always lines up with the Arabic lines. A line
  /// with nothing to read gives an empty string, it is never dropped.
  static List<String> lines(String arabic, TranscriptionScheme scheme) {
    final rules = schemeRules[scheme]!;
    return [
      for (final (index, line) in sourceLines(arabic).indexed)
        _line(line, rules, first: index == 0),
    ];
  }

  /// The non-empty, trimmed lines of a text: the unit the corpus aligns
  /// Arabic, translation and transliteration by.
  static List<String> sourceLines(String text) => [
    for (final line in text.split('\n'))
      if (line.trim().isNotEmpty) line.trim(),
  ];

  /// The whole text, lines joined by a newline.
  static String text(String arabic, TranscriptionScheme scheme) =>
      lines(arabic, scheme).join('\n');

  static final _spaces = RegExp(r'\s+');
  static final _yaBeforeA = RegExp('(?<![й])йа');
  static final _yaBeforeU = RegExp('(?<![й])йу(?!у)');

  static String _line(String line, SchemeRules s, {required bool first}) {
    final tokens = <ArabicWord>[];
    var continues = false;
    for (final raw in line.split(_spaces)) {
      if (raw.isEmpty) continue;
      final word = ArabicWord.parse(raw);
      if (word.letters.isEmpty) {
        if (tokens.isNotEmpty) tokens.last.trailing += word.trailing;
        continue;
      }
      // A line that starts with the conjunction "وَ" continues the previous
      // one, so its first letter is not capitalised ("ва аӏу́зу бика").
      if (tokens.isEmpty) continues = !first && word.startsWithConjunction;
      // "وَ" is a separate word in the regional traditions ("ва ана"), but
      // not when a letter with sukun follows: that waw is a root ("вахьдахӏу").
      if (s.separateWaw && word.startsWithConjunction) {
        tokens.add(ArabicWord([word.letters[0]], ''));
        tokens.add(ArabicWord(word.letters.sublist(1), word.trailing));
      } else {
        tokens.add(word);
      }
    }
    final out = StringBuffer();
    for (var i = 0; i < tokens.length; i++) {
      final word = tokens[i];
      final prev = i > 0 ? tokens[i - 1] : null;
      final r = WordRenderer(
        word,
        s,
        lineStart: i == 0,
        lineEnd: i == tokens.length - 1,
        prev: prev,
      ).render();
      if (r.body.isEmpty && r.piece.isEmpty) continue;
      final body = word.isGod && r.elided != Elision.god
          ? _capital(r.body)
          : r.body;
      if (out.isEmpty) {
        out.write(r.piece.isEmpty ? body : '${r.piece}$nonBreakingHyphen$body');
      } else if (r.elided == Elision.article) {
        _joinArticle(out, r, body, s);
      } else if (r.elided == Elision.god) {
        // "bi-smi-llāhi": the alif of Allāh is dropped after a vowel.
        if (s.article == ArticleStyle.hyphen) {
          out.write('$nonBreakingHyphen$body');
        } else {
          _glue(out, s, body);
        }
      } else {
        if (s.idgham && r.piece.isEmpty) _mergeNun(out, s, prev!, word);
        out.write(' ');
        out.write(r.piece.isEmpty ? body : '${r.piece}$nonBreakingHyphen$body');
      }
      out.write(word.trailing);
    }
    final text = out
        .toString()
        .replaceAll(_yaBeforeA, 'я')
        .replaceAll(_yaBeforeU, 'ю');
    return continues ? text : _capital(text);
  }

  /// Idgham: "إِنْ لَمْ" is read "ил лам", "عَلِيمٌ رَحِيمٌ" "алимур рахим".
  static void _mergeNun(
    StringBuffer out,
    SchemeRules s,
    ArabicWord prev,
    ArabicWord next,
  ) {
    if (prev.letters.isEmpty ||
        next.letters.isEmpty ||
        prev.trailing.isNotEmpty) {
      return;
    }
    final target = next.letters.first.base;
    if (target != 'ل' && target != 'ر') return;
    final last = prev.letters.last;
    final n = prev.letters.length;
    final tanwin =
        last.fathatan ||
        last.dammatan ||
        last.kasratan ||
        (n > 1 &&
            'اى'.contains(last.base) &&
            !last.hasVowel &&
            prev.letters[n - 2].fathatan);
    final nunSakin =
        last.base == 'ن' && !last.hasVowel && !last.shadda && n > 1;
    if (!tanwin && !nunSakin) return;
    final text = out.toString();
    if (!text.endsWith('н')) return;
    out
      ..clear()
      ..write(text.substring(0, text.length - 1))
      ..write(s.softLam && target == 'ل' ? 'ль' : s.consonants[target]);
  }

  static String _capital(String text) => text.isEmpty
      ? text
      : text.substring(0, 1).toUpperCase() + text.substring(1);

  static void _glue(StringBuffer out, SchemeRules s, String text) {
    final before = out.toString();
    out
      ..clear()
      ..write(s.shortensBeforeArticle ? _shorten(before) : before)
      ..write(text);
  }

  /// Appends a word whose article lost its alif after the previous word.
  static void _joinArticle(
    StringBuffer out,
    RenderedWord r,
    String body,
    SchemeRules s,
  ) {
    switch (s.article) {
      case ArticleStyle.hyphen:
        out.write('$nonBreakingHyphen${r.piece}$nonBreakingHyphen$body');
      case ArticleStyle.glue:
        // "тухьиббул‑ӏафва", "фид‑дуня": the lam or the sun letter closes the
        // previous word, and a long final vowel there is read short.
        _glue(out, s, '${r.piece}$nonBreakingHyphen$body');
      case ArticleStyle.dagestan:
        if (r.sun) {
          // "къамати ссамавату": the sun letter is simply doubled.
          out.write(' ${r.piece}$body');
        } else {
          // "валь арзу": the lam stays with the previous word.
          out.write('${r.piece} $body');
        }
    }
  }

  /// A long vowel before an elided alif is short: "фии" + "л" → "фил".
  static String _shorten(String text) {
    if (text.endsWith(combiningAcute)) {
      return text.substring(0, text.length - 1);
    }
    if (text.length < 2) return text;
    final last = text[text.length - 1], before = text[text.length - 2];
    const vowels = 'аыуиәү';
    if (last == before && vowels.contains(last)) {
      return text.substring(0, text.length - 1);
    }
    if (last == 'й' && before == 'и') return text.substring(0, text.length - 1);
    return text;
  }
}
