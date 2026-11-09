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
      if (rune == _tatweel) {
        // Tatweel only stretches the line; it is kept as a placeholder so
        // the marks written over it can be given back below.
        letters.add(ArabicLetter(_tatweelChar));
      } else if (_isMark(rune)) {
        if (letters.isNotEmpty) letters.last.marks.add(_normalise(rune));
      } else if (_isLetter(rune)) {
        letters.add(ArabicLetter(ch));
      } else if (_punctuation.containsKey(ch)) {
        trailing.write(_punctuation[ch]);
      } else if (rune == 0x06DD) {
        // The ayah-end sign carries no sound.
      } else if (!_isSilent(rune)) {
        trailing.write(ch);
      }
    }
    _resolveTatweel(letters);
    for (var i = 0; i < letters.length; i++) {
      final c = letters[i];
      if (c.base != 'ى') continue;
      // "زِدْنِى": an alif maksura after a kasra only spells the long ī.
      final afterKasra =
          i > 0 && (letters[i - 1].kasra || letters[i - 1].kasratan);
      // "ٱلْحَىُّ", "شَىْءٍ": in the Hafs copies a dotless ya with its own
      // vowel, sukun or shadda is the consonant ya, not an alif.
      final consonant =
          c.fatha ||
          c.damma ||
          c.kasra ||
          c.dammatan ||
          c.kasratan ||
          c.sukun ||
          c.shadda;
      if (afterKasra || consonant) {
        letters[i] = ArabicLetter('ي')..marks.addAll(c.marks);
      }
    }
    return ArabicWord(letters, trailing.toString());
  }

  static const _tatweel = 0x0640;
  static const _tatweelChar = 'ـ';

  /// Hamza above or below a tatweel.
  static const _hamzaMarks = {0x0654, 0x0655};

  /// "يَـُٔودُهُۥ": a tatweel that carries a hamza is that hamza with its
  /// vowel. "إِلَـٰهَ": any other marks on a tatweel belong to the letter
  /// before it.
  static void _resolveTatweel(List<ArabicLetter> letters) {
    for (var i = letters.length - 1; i >= 0; i--) {
      final t = letters[i];
      if (t.base != _tatweelChar) continue;
      if (t.marks.any(_hamzaMarks.contains)) {
        letters[i] = ArabicLetter('ء')
          ..marks.addAll(t.marks.where((m) => !_hamzaMarks.contains(m)));
      } else {
        letters.removeAt(i);
        if (i > 0) letters[i - 1].marks.addAll(t.marks);
      }
    }
  }

  final List<ArabicLetter> letters;
  String trailing;

  /// Written together with the previous word, with no space: a particle
  /// split off by [splitGodPrefix] ("фа" + "ли" in "فَلِلَّهِ").
  bool attached = false;

  static const _punctuation = {'،': ',', '؛': ';', '؟': '?', '۔': '.'};

  static bool _isLetter(int r) =>
      (r >= 0x0621 && r <= 0x064A && r != _tatweel) || r == 0x0671;
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
  /// skeletons): "wālidayya", "wālayta", "wa'adtanā", "wa'adtahu",
  /// "waliyyan", "waliyyuhā", "waliyyī", "warathati", "wasi'a", "wasi'at",
  /// "waqaba", "waḍa'tu", "wajjahtu". They are one word, written solid.
  static const _rootWaw = {
    'والدي',
    'واليت',
    'وعدتنا',
    'وعدته',
    'وليا',
    'وليها',
    'وليي',
    'ورثة',
    'وسع',
    'وسعت',
    'وقب',
    'وضعت',
    'وجهت',
  };

  /// Starts with the conjunction "وَ" ("wa-", "and"), not a root waw.
  bool get startsWithConjunction =>
      letters.length > 1 &&
      letters[0].base == 'و' &&
      letters[0].fatha &&
      !letters[0].shadda &&
      !letters[1].sukun &&
      !_rootWaw.contains(skeleton);

  /// "الله" in either spelling: with the shadda mark or written plainly, and
  /// with the plain or the wasla alif ("ٱللَّهُ").
  bool get isGod {
    final bases = skeleton.replaceAll('ٱ', 'ا');
    return bases == 'اللله' ||
        bases == 'الله' ||
        (letters.length > 2 &&
            bases.startsWith('ا') &&
            letters.any((c) => c.base == 'ل' && c.shadda) &&
            letters.any((c) => c.base == 'ه'));
  }

  /// One-letter particles that are written together with "الله".
  static const _godPrefixes = 'وفبلتك';

  /// "بِاللَّهِ", "لِلَّهِ", "فَلِلَّهِ", "وَاللَّهُ": the particles before the
  /// name of God become words of their own, so that the name is read as
  /// "Аллаһ" whose alif drops after their vowel ("би‑ллахи", "билля́хӏи").
  /// Any other word is returned as it is.
  List<ArabicWord> splitGodPrefix() {
    if (letters.length < 3 || isGod) return [this];
    final first = letters[0];
    if (!_godPrefixes.contains(first.base) ||
        first.shadda ||
        !(first.fatha || first.kasra)) {
      return [this];
    }
    var rest = letters.sublist(1);
    // "لِلَّهِ": the alif of the article is not written after li-.
    if (rest[0].base == 'ل' && rest[0].shadda) {
      rest = [ArabicLetter('ا'), ...rest];
    }
    final tail = ArabicWord(rest, trailing);
    final split = tail.isGod ? [tail] : tail.splitGodPrefix();
    if (split.length == 1 && !tail.isGod) return [this];
    return [
      ArabicWord([first], ''),
      ...split,
    ];
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
