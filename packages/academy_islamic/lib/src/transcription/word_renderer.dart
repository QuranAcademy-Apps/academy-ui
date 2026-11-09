import 'arabic_word.dart';
import 'scheme_rules.dart';

/// What was dropped from a word because the previous one runs into it.
enum Elision {
  none,

  /// The alif of the article, or of «الَّذِي», whose lam closes the
  /// previous word.
  article,

  /// The alif of «Аллаһ».
  god,

  /// A connecting alif that is not an article ("مَا اسْتَطَعْتُ"): the word
  /// joins the previous one.
  wasla,
}

/// A rendered word.
class RenderedWord {
  const RenderedWord({
    required this.body,
    required this.piece,
    required this.sun,
    required this.elided,
  });

  /// The word without its article piece.
  final String body;

  /// "ль", "н"...: the article piece to attach to the previous word, or the
  /// written article ("аль", "ан") when nothing precedes it.
  final String piece;

  /// The article's lam assimilates to a sun letter.
  final bool sun;
  final Elision elided;
}

/// Renders one [ArabicWord] in the rules of one tradition.
///
/// Vowel tokens used inside: `a u i` short, `A U I` long, `n` tanwin.
class WordRenderer {
  WordRenderer(
    this.word,
    this.rules, {
    required this.lineStart,
    required this.lineEnd,
    required this.prev,
    this.pause = true,
  }) : l = word.letters,
       god = word.isGod,
       open = !lineStart && (prev?.endsOpen ?? false),
       last = word.letters.length - 1,
       endIdx = _endIndex(word.letters),
       stop = lineEnd && pause && rules.pause != null,
       isAna = _isAna(word.letters, rules);

  final ArabicWord word;
  final SchemeRules rules;
  final bool lineStart, lineEnd;
  final ArabicWord? prev;

  /// A line end here is read as a stop (see [stop]). Off for a line that
  /// runs on into the next one in a continuous text.
  final bool pause;

  final List<ArabicLetter> l;

  /// The word is "الله".
  final bool god;

  /// The previous word ends in a vowel, so this word's alif is dropped.
  final bool open;
  final int last;

  /// Last sounded letter; before a tanwin-fatha alif it is the tanwin letter.
  final int endIdx;

  /// The word ends a line that is read as a stop.
  final bool stop;

  /// «ана» and «илла» are read short in connected speech.
  final bool isAna;

  final _out = StringBuffer();
  var _piece = '';
  var _sun = false;
  var _elided = Elision.none;
  var _skipTo = -1;
  var _afterArticle = -1;

  /// A letter with shadda written once: the other half went to the previous
  /// word ("Бисмилля́хӏил‑лази").
  var _single = -1;

  /// Letters that swallow the lam of the article ("ash-shams").
  static const _sunLetters = 'تثدذرزسشصضطظلن';

  /// Tatar: letters that take а/у/ы instead of ә/ү/и.
  static const _backLetters = 'قصضطظغخ';

  static int _endIndex(List<ArabicLetter> l) {
    final last = l.length - 1;
    return last > 0 && 'اى'.contains(l[last].base) && l[last - 1].fathatan
        ? last - 1
        : last;
  }

  static bool _isAna(List<ArabicLetter> l, SchemeRules rules) =>
      (l.length == 3 && l[0].base == 'أ' && l[1].base == 'ن') ||
      (!rules.tatar &&
          l.length == 3 &&
          l[0].base == 'إ' &&
          l[1].base == 'ل' &&
          l[1].shadda &&
          l[2].base == 'ا');

  RenderedWord render() {
    for (var i = 0; i < l.length; i++) {
      if (i <= _skipTo) continue;
      if (god && i == 0) {
        _allah(i);
      } else if (_isAlif(i)) {
        _alif(i);
      } else {
        _letter(i);
      }
    }
    return RenderedWord(
      body: _out.toString(),
      piece: _piece,
      sun: _sun,
      elided: _elided,
    );
  }

  // --- vowels ---------------------------------------------------------------

  /// Marks are often dropped before a long vowel letter or a doubled letter;
  /// the vowel is then still the short one that goes with it.
  String _implied(int i) {
    final marks = l[i].marks;
    if (l[i].hasVowel) return '';
    if (!(marks.isEmpty || (marks.length == 1 && l[i].shadda))) return '';
    if (i + 1 >= l.length) return '';
    final next = l[i + 1];
    if (next.base == 'ا' || next.base == 'ى') return 'a';
    if (next.shadda && marks.isEmpty) return 'a';
    if (!next.hasVowel && next.marks.isEmpty) {
      if (next.base == 'و') return 'u';
      if (next.base == 'ي') return 'i';
    }
    return '';
  }

  /// Tatar picks a vowel by the consonant it follows.
  String _back(ArabicLetter? c, String kind) {
    final base = c?.base ?? '';
    final isBack = _backLetters.contains(base);
    return switch (kind) {
      'a' => isBack || base == 'ر' ? 'а' : 'ә',
      'u' => isBack ? 'у' : 'ү',
      _ => isBack || base == 'ع' ? 'ый' : 'и',
    };
  }

  String _short(String kind, ArabicLetter? after) => rules.tatar
      ? _back(after, kind)
      : kind == 'a' && after != null && rules.tafkhim.contains(after.base)
      ? 'о'
      : kind == 'i' && after != null && rules.emphaticI.contains(after.base)
      ? 'ы'
      : switch (kind) {
          'a' => 'а',
          'u' => 'у',
          _ => 'и',
        };

  /// Long vowel of [kind] ("a", "u" or "i") after [after].
  String _long(String kind, ArabicLetter? after) {
    final v = _short(kind, after);
    if (rules.tatar) return '$v$v';
    return '$v${switch (kind) {
      'a' => rules.longA,
      'u' => rules.longU,
      _ => rules.longI,
    }}';
  }

  /// Writes vowel [tokens] after the consonant [after].
  String _vowels(String tokens, [ArabicLetter? after]) {
    final b = StringBuffer();
    for (final t in tokens.split('')) {
      switch (t) {
        case 'a' || 'u' || 'i':
          b.write(_short(t, after));
        case 'A':
          b.write(_long('a', after));
        case 'U':
          b.write(_long('u', after));
        case 'I':
          b.write(_long('i', after));
        default:
          b.write('н');
      }
    }
    return b.toString();
  }

  /// Vowels of the letter at [i]. At a stop the last letter loses its short
  /// vowel and tanwin ("наар", "ахьад"); a tanwin fatha written with alif is
  /// read long ("ӏилма́").
  String _vowelsAt(int i, String tokens, ArabicLetter c) {
    if (!stop || i != endIdx) return _vowels(tokens, c);
    if (tokens.contains('A') || (c.fathatan && endIdx != last)) {
      return _vowels('A', c);
    }
    return '';
  }

  /// The velarised lam of "Аллаһ" keeps a back, long vowel in Tatar.
  String _vowelsOfConsonant(int i, ArabicLetter c) =>
      rules.tatar && god && c.base == 'ل' && c.shadda && c.fatha
      ? 'аа'
      : _vowelsAt(i, c.tokens, c);

  // --- structure ------------------------------------------------------------

  bool _isAlif(int i) => i < l.length && (l[i].base == 'ا' || l[i].base == 'ٱ');

  bool _bareLam(int i) =>
      i < l.length &&
      l[i].base == 'ل' &&
      !l[i].shadda &&
      !l[i].hasVowel &&
      i + 1 < l.length;

  /// A one-letter prefix ("وَ فَ بِ كَ لِ") before the article.
  bool _prefix(int i) =>
      i == 1 && l.length > 2 && 'وفبكل'.contains(l[0].base) && l[0].hasVowel;

  bool _article(int i) =>
      _isAlif(i) && _bareLam(i + 1) && (i == 0 || _prefix(i));

  static String _double(String c) => c == 'дж' || c == 'дз' ? 'д$c' : '$c$c';

  // --- letters --------------------------------------------------------------

  void _allah(int i) {
    // "Аллаһ": the alif is dropped after a vowel ("Бисми‑ллаһи").
    if (open) {
      _elided = Elision.god;
    } else {
      _out.write(rules.tatar ? 'ә' : 'а');
    }
    _out.write('лл');
    // Tajwid lam of "Аллаһ": heavy after a fatha or damma ("Аллохӏу"), light
    // after a kasra ("Бисми‑лля́хӏи").
    final light = !lineStart && (prev?.endsInKasra ?? false);
    _out.write(
      rules.tatar
          ? (light ? 'әә' : 'аа')
          : rules.heavyAllah
          ? (light ? 'я$combiningAcute' : 'о')
          : 'а',
    );
    _skipTo = l.lastIndexWhere((x) => x.base == 'ل');
  }

  void _alif(int i) {
    final p = i > 0 ? l[i - 1] : null;
    if (_article(i)) {
      final target = l[i + 2];
      final isSun = target.shadda && _sunLetters.contains(target.base);
      final sound = isSun
          ? (rules.consonants[target.base] ?? '')
          : rules.articleL;
      _skipTo = i + 1;
      _afterArticle = i + 2;
      if (i == 0) {
        if (open) {
          _elided = Elision.article;
          _piece = sound;
        } else {
          // At a line start (or after a closed word) the article keeps its
          // own vowel: "аль‑", "ал‑", "ан‑".
          _piece = '${rules.articleVowel}$sound';
        }
        _sun = isSun;
      } else {
        // After a prefix inside the word ("валь‑хамду").
        _out.write('$sound$nonBreakingHyphen');
      }
      if (isSun) {
        _out.write(sound);
        _out.write(_vowels(target.tokens, target));
        _skipTo = i + 2;
      }
    } else if (i == 0) {
      final third = l.length > 2 ? l[2] : null;
      if (l.length > 1 && l[1].base == 'ل' && l[1].shadda) {
        if (rules.tatar && open) {
          // «сүбхәәнәлләзии»: the alif is dropped and the word is glued.
          _elided = Elision.god;
        } else if (rules.ladhiYa && open) {
          // «ллязи»: the alif is dropped, the word stays apart.
        } else if (open) {
          // "الَّذِي" after a vowel loses its alif like an article before a
          // sun letter: "Бисмилля́хӏил‑лази", "Бисми‑ллахи‑л‑лази".
          _elided = Elision.article;
          _sun = true;
          _piece = rules.consonants['ل']!;
          _single = 1;
        } else {
          _out.write('а');
        }
      } else if (open) {
        // "مَا اسْتَطَعْتُ": the alif is not read and the word joins the
        // previous one ("ма‑стата‘ту", "мастатӏоӏт").
        _elided = Elision.wasla;
      } else {
        _out.write(_vowels(third != null && third.damma ? 'u' : 'i'));
      }
    } else if (p != null &&
        !isAna &&
        // The alif after a bare waw only spells the plural ("آمَنُوا").
        !(p.base == 'و' && !p.hasVowel) &&
        (p.fatha || _implied(i - 1) == 'a') &&
        !(i == 1 && l.length > 2 && l[2].sukun)) {
      // Long ā: the short vowel is already written, add the length.
      _out.write(rules.tatar ? _short('a', p) : rules.longA);
    }
  }

  void _letter(int i) {
    final c = l[i];
    final p = i > 0 ? l[i - 1] : null;
    switch (c.base) {
      case 'آ':
        // After a fatha it only lengthens that vowel ("шифәә").
        if (p != null && p.fatha && !(i == 1 && _prefix(1))) {
          _out.write(rules.tatar ? _short('a', p) : rules.longA);
        } else {
          _out.write(_vowels('A'));
        }
      case 'ى':
        if (p != null && p.fathatan) return;
        if (p == null || !p.fatha) {
          _out.write(_vowels('A', p));
        } else {
          _out.write(rules.tatar ? _short('a', p) : rules.longA);
        }
      case 'و':
        _waw(i, c, p);
      case 'ي':
        _ya(i, c, p);
      case 'ة':
        _taMarbuta(i, c);
      case 'ء' || 'أ' || 'إ' || 'ؤ' || 'ئ':
        _hamza(i, c, p);
      default:
        _consonant(i, c);
    }
  }

  void _waw(int i, ArabicLetter c, ArabicLetter? p) {
    final impliedU = p != null && _implied(i - 1) == 'u';
    if (!c.hasVowel &&
        !c.shadda &&
        p != null &&
        (p.damma || p.dammatan || impliedU)) {
      _out.write(rules.tatar ? _short('u', p) : rules.longU);
      return;
    }
    if (rules.tatar && !c.hasVowel && !c.shadda && p != null && p.fatha) {
      // "мәүгыйзатүм", "каум": the diphthong aw is written with ү/у.
      _out.write(_short('u', p));
      return;
    }
    if (rules.tatar && i > 0 && c.fatha && !c.shadda) {
      // Inside a word the Tatar texts write "үә" ("дәгъүәти", "һүә").
      _out.write(
        p != null && p.damma
            ? 'ә'
            : p != null && (p.fatha || p.base == 'ا')
            ? 'вә'
            : 'үә',
      );
      return;
    }
    _out.write(c.shadda && i != 0 ? 'вв' : 'в');
    _out.write(
      c.tokens.isEmpty && c.marks.isEmpty && i == 0 && l.length > 1
          ? _vowels('a')
          : _vowelsAt(i, c.tokens, c),
    );
  }

  void _ya(int i, ArabicLetter c, ArabicLetter? p) {
    final impliedI = p != null && _implied(i - 1) == 'i';
    if (!c.hasVowel &&
        !c.shadda &&
        p != null &&
        (p.kasra || p.kasratan || impliedI)) {
      _out.write(
        rules.tatar
            // After «ый» the long ī only adds «и»: «мүттәкыйинә».
            ? (_short('i', p) == 'ый' ? 'и' : _short('i', p))
            : (rules.finalIShort && i == l.length - 1 ? '' : rules.longI),
      );
      return;
    }
    _out.write(c.shadda ? 'йй' : 'й');
    _out.write(_vowelsAt(i, c.tokens, c));
  }

  void _taMarbuta(int i, ArabicLetter c) {
    if (rules.tatar && stop) {
      // Read in pause: "каа’имәһ".
      _out.write('һ');
    } else if (stop && i == endIdx) {
      // "джаннахӏ": a final ta marbuta is read ه at a stop.
      _out.write(rules.pause);
    } else if (c.hasVowel) {
      _out.write('т${_vowels(c.tokens, c)}');
    }
  }

  void _hamza(int i, ArabicLetter c, ArabicLetter? p) {
    var starts = i == 0 || i == _afterArticle;
    if (!starts && i == 1 && rules.hyphenBeforeHamza && _prefix(1)) {
      _out.write(nonBreakingHyphen);
      starts = true;
    }
    if (rules.tatar && !starts && !c.hasVowel && p != null && p.hasVowel) {
      // "мүэминиин": a hamza closing a syllable is written э.
      _out.write('э');
      return;
    }
    if (!starts && c.hasVowel) {
      final afterConsonant = p != null && !p.hasVowel && p.base != 'ا';
      _out.write(
        p != null &&
                p.base == 'ا' &&
                c.base != 'ئ' &&
                rules.hamzaAfterAlif != null
            ? rules.hamzaAfterAlif
            : afterConsonant && rules.hamzaAfterConsonant != null
            ? rules.hamzaAfterConsonant
            : rules.hamza,
      );
    }
    // A word-initial hamza seat with its mark omitted still has a vowel.
    _out.write(
      c.tokens.isEmpty && c.marks.isEmpty && starts
          ? _vowels(c.base == 'إ' ? 'i' : 'a')
          : _vowelsAt(i, c.tokens, c),
    );
  }

  void _consonant(int i, ArabicLetter c) {
    final sound = rules.consonants[c.base];
    if (sound == null) return;
    final own = c.tokens;
    final closing = c.sukun || (!c.hasVowel && !c.shadda);
    // A lam is soft: "ль" with sukun, "ля" with a short fatha opening a word
    // ("лям", "ляхӏу", but "ю́лад").
    final soft = rules.softLam && c.base == 'ل' && (!c.shadda || i == 0);
    if (rules.tatar &&
        i == 1 &&
        c.base == 'ل' &&
        closing &&
        l[0].base == 'ل' &&
        l[0].kasra &&
        l.length > 2) {
      // «li» + the article: «лил-мүттәкыйинә».
      _out.write('л$nonBreakingHyphen');
      return;
    }
    final letter = soft && closing && _implied(i).isEmpty
        ? 'ль'
        : (closing ? rules.sukunExtra[c.base] : null) ?? sound;
    // A shadda opening a word marks assimilation with the previous word's
    // ending, so it is not doubled here.
    _out.write(c.shadda && i != 0 && i != _single ? _double(letter) : letter);
    final nextBase = i + 1 < l.length ? l[i + 1].base : '';
    if (rules.ladhiYa &&
        i == 1 &&
        l[0].base == 'ا' &&
        c.shadda &&
        c.base == 'ل' &&
        l.length > 2 &&
        l[2].base == 'ذ') {
      // "ллязи": the lam of «аллази» is soft in the Dagestani texts.
      _out.write('я');
    } else if (soft &&
        i == 0 &&
        own == 'a' &&
        nextBase != 'ا' &&
        nextBase != 'آ' &&
        nextBase != 'ى') {
      _out.write('я');
    } else {
      _out.write(
        own.isEmpty ? _vowels(_implied(i), c) : _vowelsOfConsonant(i, c),
      );
    }
  }
}
