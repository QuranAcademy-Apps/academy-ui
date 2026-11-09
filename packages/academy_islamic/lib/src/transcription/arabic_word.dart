/// Unicode code points of the Arabic marks the transcriber reads.
abstract final class ArabicMark {
  static const fathatan = 0x064B;
  static const dammatan = 0x064C;
  static const kasratan = 0x064D;
  static const fatha = 0x064E;
  static const damma = 0x064F;
  static const kasra = 0x0650;
  static const shadda = 0x0651;
  static const sukun = 0x0652;

  /// Dagger alif: a long ā that the text does not spell with an alif.
  static const dagger = 0x0670;
}

/// One Arabic letter with the marks written over or under it.
class ArabicLetter {
  ArabicLetter(this.base);

  final String base;
  final marks = <int>{};

  bool get fatha => marks.contains(ArabicMark.fatha);
  bool get damma => marks.contains(ArabicMark.damma);
  bool get kasra => marks.contains(ArabicMark.kasra);
  bool get fathatan => marks.contains(ArabicMark.fathatan);
  bool get dammatan => marks.contains(ArabicMark.dammatan);
  bool get kasratan => marks.contains(ArabicMark.kasratan);
  bool get shadda => marks.contains(ArabicMark.shadda);
  bool get sukun => marks.contains(ArabicMark.sukun);
  bool get dagger => marks.contains(ArabicMark.dagger);
  bool get hasVowel =>
      fatha || damma || kasra || fathatan || dammatan || kasratan || dagger;

  /// Vowel tokens: a u i short, A long (dagger alif), n for tanwin.
  String get tokens {
    final buffer = StringBuffer();
    if (dagger) {
      buffer.write('A');
    } else if (fatha) {
      buffer.write('a');
    }
    if (damma) buffer.write('u');
    if (kasra) buffer.write('i');
    if (fathatan) buffer.write('an');
    if (dammatan) buffer.write('un');
    if (kasratan) buffer.write('in');
    return buffer.toString();
  }
}

/// A whitespace-separated Arabic word: its letters and the punctuation that
/// follows it.
class ArabicWord {
  ArabicWord(this.letters, this.trailing);

  /// Splits [raw] into letters, marks and trailing punctuation.
  factory ArabicWord.parse(String raw) {
    final letters = <ArabicLetter>[];
    final trailing = StringBuffer();
    for (final rune in raw.runes) {
      final ch = String.fromCharCode(rune);
      if (_isMark(rune)) {
        if (letters.isNotEmpty) letters.last.marks.add(_normalise(rune));
      } else if (_isLetter(rune)) {
        letters.add(ArabicLetter(ch));
      } else if (_punctuation.containsKey(ch)) {
        trailing.write(_punctuation[ch]);
      } else if (rune == 0x0640 || rune == 0x06DD) {
        // Tatweel and the ayah-end sign carry no sound.
      } else if (!_isSilent(rune)) {
        trailing.write(ch);
      }
    }
    // "زِدْنِى": an alif maksura after a kasra only spells the long ī.
    for (var i = 1; i < letters.length; i++) {
      final c = letters[i];
      if (c.base == 'ى' && (letters[i - 1].kasra || letters[i - 1].kasratan)) {
        letters[i] = ArabicLetter('ي')..marks.addAll(c.marks);
      }
    }
    return ArabicWord(letters, trailing.toString());
  }

  final List<ArabicLetter> letters;
  String trailing;

  static const _punctuation = {'،': ',', '؛': ';', '؟': '?', '۔': '.'};

  static bool _isLetter(int r) => (r >= 0x0621 && r <= 0x064A) || r == 0x0671;
  static bool _isMark(int r) =>
      (r >= 0x064B && r <= 0x065F) || r == 0x0670 || r == 0x06E1;

  /// Qur'anic variants of the usual marks: the inverted damma is a dammatan
  /// and the small high khah of the Hafs copies is a sukun.
  static int _normalise(int r) => switch (r) {
    0x0657 => ArabicMark.dammatan,
    0x06E1 => ArabicMark.sukun,
    _ => r,
  };

  /// Quranic annotation signs (small high marks), Arabic-Indic digits (ayah
  /// numbers) and brackets are not read.
  static bool _isSilent(int r) =>
      (r >= 0x06D6 && r <= 0x06ED && r != 0x06E1) ||
      (r >= 0x0660 && r <= 0x0669) ||
      '()[]«»'.contains(String.fromCharCode(r));

  /// The consonant skeleton of the word.
  String get skeleton => letters.map((c) => c.base).join();

  /// Words that begin with a root "وَ", not the conjunction (consonant
  /// skeletons): "wālidayya", "wālayta", "wa'adtanā", "waliyyan",
  /// "waliyyuhā", "waliyyī", "warathati".
  static const _rootWaw = {
    'والدي',
    'واليت',
    'وعدتنا',
    'وليا',
    'وليها',
    'وليي',
    'ورثة',
  };

  /// Starts with the conjunction "وَ" ("wa-", "and"), not a root waw.
  bool get startsWithConjunction =>
      letters.length > 1 &&
      letters[0].base == 'و' &&
      letters[0].fatha &&
      !letters[0].shadda &&
      !letters[1].sukun &&
      !_rootWaw.contains(skeleton);

  /// "الله" in either spelling: with the shadda mark or written plainly.
  bool get isGod {
    final bases = skeleton;
    return bases == 'اللله' ||
        bases == 'الله' ||
        (letters.length > 2 &&
            letters[0].base == 'ا' &&
            letters.any((c) => c.base == 'ل' && c.shadda) &&
            letters.any((c) => c.base == 'ه'));
  }

  /// Ends in a vowel, so an alif that opens the next word is dropped.
  bool get endsOpen {
    if (letters.isEmpty) return false;
    // The vocative "يَا" keeps the next alif ("я Аллах").
    if (letters.length == 2 &&
        letters[0].base == 'ي' &&
        letters[1].base == 'ا') {
      return false;
    }
    final last = letters.last;
    if (last.fatha || last.damma || last.kasra || last.dagger) return true;
    return 'اوىي'.contains(last.base) && !last.sukun;
  }

  /// Ends in a kasra, short or long ("بِسْمِ", "فِي").
  bool get endsInKasra {
    if (letters.isEmpty) return false;
    final last = letters.last;
    return last.kasra ||
        last.kasratan ||
        (last.base == 'ي' &&
            !last.hasVowel &&
            letters.length > 1 &&
            letters[letters.length - 2].kasra);
  }
}
