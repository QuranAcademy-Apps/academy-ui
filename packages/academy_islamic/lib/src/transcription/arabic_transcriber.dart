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
  ///
  /// Made to be shown line by line: every line ends in a stop (the schemes
  /// that read one drop its last short vowel). [sentenceStarts] tells which
  /// lines open a sentence and so begin with a capital (see
  /// [sentenceStarts]); without it only the first line does, and a line
  /// after Arabic sentence punctuation.
  static List<String> lines(
    String arabic,
    TranscriptionScheme scheme, {
    List<bool>? sentenceStarts,
  }) => _lines(arabic, scheme, sentenceStarts, pauseEveryLine: true);

  /// The whole text as one reading, lines joined by a newline: only its very
  /// end is read as a stop, every other line keeps its last vowel.
  /// Capitals as in [lines].
  static String text(
    String arabic,
    TranscriptionScheme scheme, {
    List<bool>? sentenceStarts,
  }) =>
      _lines(arabic, scheme, sentenceStarts, pauseEveryLine: false).join('\n');

  /// The non-empty, trimmed lines of a text: the unit the corpus aligns
  /// Arabic, translation and transliteration by.
  static List<String> sourceLines(String text) => [
    for (final line in text.split('\n'))
      if (line.trim().isNotEmpty) line.trim(),
  ];

  /// Which lines of a translation open a sentence: the first one, and each
  /// one after a line that ends in «.», «!», «?» or «…». Pass it as
  /// `sentenceStarts` when the translation has the Arabic's line breaks.
  static List<bool> sentenceStarts(String translation) {
    final lines = sourceLines(translation);
    return [
      for (var i = 0; i < lines.length; i++)
        i == 0 || _sentenceEnd.hasMatch(lines[i - 1]),
    ];
  }

  static final _sentenceEnd = RegExp('[.!?…؟۔][»"”’)\\]]*\$');
  static final _spaces = RegExp(r'\s+');
  static final _yaBeforeA = RegExp('(?<![й])йа');
  static final _yaBeforeU = RegExp('(?<![й])йу(?!у)');
  static final _bracketed = RegExp(r'\(([^()]*)\)|\[([^\[\]]*)\]');
  static final _arabicLetter = RegExp('[\u0621-\u063A\u0641-\u064A\u0671]');
  static final _vowelMark = RegExp('[\u064B-\u0650\u0670]');

  static List<String> _lines(
    String arabic,
    TranscriptionScheme scheme,
    List<bool>? sentenceStarts, {
    required bool pauseEveryLine,
  }) {
    final rules = schemeRules[scheme]!;
    final source = sourceLines(arabic);
    final starts = sentenceStarts?.length == source.length
        ? sentenceStarts!
        : [
            for (var i = 0; i < source.length; i++)
              i == 0 || _sentenceEnd.hasMatch(source[i - 1]),
          ];
    return [
      for (final (index, line) in source.indexed)
        _line(
          line,
          rules,
          capital: starts[index],
          pause: pauseEveryLine || index == source.length - 1,
        ),
    ];
  }

  /// Bracketed text is read without its brackets ("(اللَّهُمَّ)"), unless it
  /// is an unvocalised note to the reader ("(ثلاثاً وثلاثين)"), which is
  /// skipped.
  static String _readable(String line) =>
      line.replaceAllMapped(_bracketed, (m) {
        final inner = m[1] ?? m[2]!;
        final letters = _arabicLetter.allMatches(inner).length;
        final vowels = _vowelMark.allMatches(inner).length;
        return letters > 0 && vowels * 2 < letters ? ' ' : ' $inner ';
      });

  static String _line(
    String line,
    SchemeRules s, {
    required bool capital,
    required bool pause,
  }) {
    final tokens = <ArabicWord>[];
    for (final raw in _readable(line).split(_spaces)) {
      if (raw.isEmpty) continue;
      final word = ArabicWord.parse(raw);
      if (word.letters.isEmpty) {
        if (tokens.isNotEmpty) tokens.last.trailing += word.trailing;
        continue;
      }
      // "وَ" is a separate word in the regional traditions ("ва ана"), but
      // not when a letter with sukun follows: that waw is a root ("вахьдахӏу").
      final parts = s.separateWaw && word.startsWithConjunction
          ? [
              ArabicWord([word.letters[0]], ''),
              ArabicWord(word.letters.sublist(1), word.trailing),
            ]
          : [word];
      for (final part in parts) {
        final split = part.splitGodPrefix();
        for (final (k, t) in split.indexed) {
          // Particles after the first one are written solid with it
          // ("фали‑Ллахи"); the name itself joins as an elided word.
          if (k > 0 && k < split.length - 1) t.attached = true;
          tokens.add(t);
        }
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
        pause: pause,
      ).render();
      if (r.body.isEmpty && r.piece.isEmpty) continue;
      // The name of God keeps its capital, also after a hyphen
      // ("Бисми‑Ллахи"); written solid into a word it stays lower case
      // ("Бисмилля́хӏи"), as the regional texts write it.
      final body =
          word.isGod &&
              (r.elided != Elision.god || s.article == ArticleStyle.hyphen)
          ? _capital(r.body)
          : r.body;
      if (out.isEmpty) {
        out.write(r.piece.isEmpty ? body : '${r.piece}$nonBreakingHyphen$body');
      } else if (r.elided == Elision.article) {
        _joinArticle(out, r, body, s);
      } else if (r.elided == Elision.god || r.elided == Elision.wasla) {
        // "bi-smi-llāhi", "mā-staṭa'tu": the alif is dropped after a vowel.
        if (s.article == ArticleStyle.hyphen) {
          out.write('$nonBreakingHyphen$body');
        } else {
          _glue(out, s, body);
        }
      } else if (word.attached) {
        out.write(body);
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
    return capital ? _capital(text) : text;
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
