/// Splits dhikr Arabic into the words that the app's `words.json` glosses.
/// Mirrors `split_words` in `tool/import_words.py`.
abstract final class ZikrWords {
  static final _letter = RegExp('[ء-ي]');
  static final _marks = RegExp('[ً-ٰٟۖ-ۭـ]');
  static final _space = RegExp(r'\s+');

  /// Words by whitespace; a token with no Arabic letter (verse mark, number,
  /// ﷺ) joins the previous word.
  static List<String> split(String arabic) {
    final words = <String>[];
    for (final token in arabic.split(_space)) {
      if (token.isEmpty) continue;
      if (words.isNotEmpty && !_letter.hasMatch(token.replaceAll(_marks, ''))) {
        words.last = '${words.last} $token';
      } else {
        words.add(token);
      }
    }
    return words;
  }
}
