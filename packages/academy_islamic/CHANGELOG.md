# Changelog

## 0.2.0

- Transcription: `ArabicTranscriber` (`lines`, `text`, `sourceLines`) and `TranscriptionScheme` (general, vainakh, dagestan, tatar) read vocalised Arabic into Cyrillic by rules; `nonBreakingHyphen` is the joiner it writes. Pure Dart, no state. Moved from Zikro (originally Yalla's `dua_transliteration.dart`). Scheme display names stay in each app's localisation. The `general` scheme differs from Yalla's: soft «л», the alif of «Аллаһ» drops after a vowel («Бисми‑ллахи»), Arabic-Indic digits are ignored; the other schemes behave as in Yalla. Not breaking: nothing to change in apps that do not use it.

## 0.1.1

- Azkar: line breaks from the reading pass (`tool/azkar_lines.jsonl`), carried over from Zikro.

## 0.1.0

- Prayer times (tables of 310 places, adhan calculation, region method), azkar corpus and storage helpers moved here from Zikro.
