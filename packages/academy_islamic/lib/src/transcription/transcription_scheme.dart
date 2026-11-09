/// Tradition of the Cyrillic transcription of the Arabic text.
///
/// Rule-based reading aids, not reviewed translations or recitation sources.
/// Display names belong to the app (its own localisation).
enum TranscriptionScheme {
  /// Common Russian record. A dhikr that has its own transliteration keeps it.
  general,

  /// Chechen and Ingush record.
  vainakh,

  /// Avar record (Lak and Dargin differ).
  dagestan,

  /// Tatar record with the vowels ә and ү.
  tatar,
}
