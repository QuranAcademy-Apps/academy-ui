import 'transcription_scheme.dart';

/// Combining acute accent: marks a long vowel.
const combiningAcute = '́';

/// Non-breaking, so a line never wraps inside "фи‑ль‑джаннати".
const nonBreakingHyphen = '‑';

/// How the definite article joins the previous word.
enum ArticleStyle {
  /// "бис‑салихина".
  hyphen,

  /// "тухьиббул‑ӏафва": glued to the previous word, whose long final vowel is
  /// then read short.
  glue,

  /// "ррахӏими", "валь арзу": the sun letter doubled, the lam kept apart.
  dagestan,
}

/// Letters and conventions of one transcription tradition.
class SchemeRules {
  const SchemeRules(
    this.consonants, {
    this.hamza = '’',
    this.hamzaAfterConsonant,
    this.hamzaAfterAlif,
    this.longA = '',
    this.longU = '',
    this.longI = '',
    this.article = ArticleStyle.hyphen,
    this.articleVowel = 'а',
    this.articleL = 'ль',
    this.separateWaw = false,
    this.hyphenBeforeHamza = false,
    this.tatar = false,
    this.finalIShort = false,
    this.tafkhim = '',
    this.emphaticI = '',
    this.idgham = false,
    this.heavyAllah = false,
    this.softLam = false,
    this.pause,
    this.ladhiYa = false,
    this.sukunExtra = const {},
  });

  /// Arabic letter → Cyrillic.
  final Map<String, String> consonants;

  /// Glottal stop inside a word.
  final String hamza;
  final String? hamzaAfterConsonant;

  /// A hamza after a long ā is not written ("Микаила", "ражаака").
  final String? hamzaAfterAlif;

  /// What a long vowel adds to the short one ("наа", "ий", "уу").
  final String longA, longU, longI;
  final ArticleStyle article;

  /// The article's own vowel and its lam before a moon letter.
  final String articleVowel, articleL;

  /// "وَ" is a word of its own ("ва ана").
  final bool separateWaw;
  final bool hyphenBeforeHamza, tatar;

  /// A word-final long ī ("инни", "рабби", "ли") is read, and so written,
  /// plainly; only a long ī inside a word carries the stress mark.
  final bool finalIShort;

  /// Tajwid: after these letters a short or long "а" is read "о" ("Роббана").
  final String tafkhim;

  /// Tajwid: after these letters a kasra is read "ы" ("Родӏы́ту").
  final String emphaticI;

  /// Tajwid: a nun sakina or tanwin before ل or ر merges into that letter
  /// ("ва ил лам").
  final bool idgham;

  /// Tajwid lam of "Аллаһ": "Аллохӏу" after a fatha or damma, "лля́хӏи"
  /// after a kasra.
  final bool heavyAllah;

  /// A lam reads "ль" with sukun and "ля" with a short fatha at the start of
  /// a word ("лям", "якуль ляхӏу́", but "ю́лад").
  final bool softLam;

  /// Tajwid stop: at the end of a line the last short vowel and tanwin are
  /// dropped ("минан-нар"), and a final ta marbuta is written with this
  /// letter ("джаннахӏ"). Null keeps the full forms.
  final String? pause;

  /// "الَّذِي" after a vowel loses its alif and softens the lam: "ллязи".
  final bool ladhiYa;

  /// Consonants written differently when they close a syllable (sukun).
  final Map<String, String> sukunExtra;

  bool get shortensBeforeArticle => article == ArticleStyle.glue;
}

const _base = {
  'ب': 'б',
  'ت': 'т',
  'ث': 'с',
  'ج': 'дж',
  'ح': 'х',
  'خ': 'х',
  'د': 'д',
  'ذ': 'з',
  'ر': 'р',
  'ز': 'з',
  'س': 'с',
  'ش': 'ш',
  'ص': 'с',
  'ض': 'д',
  'ط': 'т',
  'ظ': 'з',
  'ع': '‘',
  'غ': 'г',
  'ف': 'ф',
  'ق': 'к',
  'ك': 'к',
  'ل': 'л',
  'م': 'м',
  'ن': 'н',
  'ه': 'х',
};

/// Rules of each tradition. Letters were checked against published texts
/// (see the schemes test); they remain a starting point for review by native
/// readers.
final schemeRules = Map<TranscriptionScheme, SchemeRules>.unmodifiable({
  // The corpus's own Russian texts write «ля иляха илля Ллах», «аль-хамду»:
  // the lam is soft, which brings the generated text closer to them.
  TranscriptionScheme.general: const SchemeRules(_base, softLam: true),
  // Chechen/Ingush. Letters: Wikipedia table, checked against two published
  // Chechen texts (steppenews.kz, an ok.ru azkar post): ح хь, ه хӏ, ع ӏ,
  // غ гӏ, ق къ, ط тӏ; ج дж and ض дӏ by the owner's rule. A long vowel carries
  // a stress mark; hamza ’; the article is glued to the previous word.
  TranscriptionScheme.vainakh: SchemeRules(
    {
      ..._base,
      'ح': 'хь',
      'ض': 'дӏ',
      'ط': 'тӏ',
      'ظ': 'зӏ',
      'ع': 'ӏ',
      'غ': 'гӏ',
      'ق': 'къ',
      'ه': 'хӏ',
    },
    longA: combiningAcute,
    longU: combiningAcute,
    longI: combiningAcute,
    article: ArticleStyle.glue,
    articleL: 'л',
    separateWaw: true,
    hyphenBeforeHamza: true,
    finalIShort: true,
    // Owner's tajwid rule: "о" after every heavy letter ("Роббана", "сыро́тӏо")
    // and "ы" for kasra after ص ض ط ظ ("Родӏы́ту"). The two Chechen texts
    // checked mostly write plain "а" and "и" here.
    tafkhim: 'خصضغطقظر',
    emphaticI: 'صضطظ',
    idgham: true,
    heavyAllah: true,
    softLam: true,
    pause: 'хӏ',
  ),
  // Avar/Dargin/Lak share ح хӏ, ه гь, ق къ; Avar ع гӏ, غ гъ. The Avar post
  // writes ج ж, خ х, ض з and the article lam plainly («бисмикал», «вал
  // арзи»). Sun letters are doubled.
  TranscriptionScheme.dagestan: SchemeRules(
    {
      ..._base,
      'ج': 'ж',
      'ح': 'хӏ',
      'ض': 'з',
      'ط': 'тӏ',
      'ع': 'гӏ',
      'غ': 'гъ',
      'ق': 'къ',
      'ه': 'гь',
    },
    hamza: 'ъ',
    hamzaAfterAlif: '',
    article: ArticleStyle.dagestan,
    articleL: 'л',
    ladhiYa: true,
    separateWaw: true,
  ),
  // Tatar: nur.tatar, igelek.ru, ok.ru/tatarchado. Long vowels doubled; ج җ,
  // ه һ, ع г; a back letter with sukun takes ъ (гъ дъ хъ къ тъ), a kasra
  // after one is «ый»; back vowels follow ق ص ض ط ظ غ خ.
  TranscriptionScheme.tatar: SchemeRules(
    {..._base, 'ج': 'җ', 'ع': 'г', 'غ': 'г', 'ه': 'һ'},
    hamzaAfterConsonant: 'ъ',
    article: ArticleStyle.glue,
    articleVowel: 'ә',
    articleL: 'л',
    separateWaw: true,
    tatar: true,
    sukunExtra: {
      'ع': 'гъ',
      'ض': 'дъ',
      'ل': 'ль',
      'خ': 'хъ',
      'ق': 'къ',
      'ط': 'тъ',
      'غ': 'гъ',
    },
    pause: 'һ',
  ),
});
