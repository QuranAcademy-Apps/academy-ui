# Changelog

## 0.3.2

- Azkar text corrections from an audit of the whole corpus, checked against vocalised hadith texts, Hisn al-Muslim, the mushaf and published Russian translations: missing or wrong tashkeel (mostly in «100 дуа»), typos and split words in the Arabic, translation errors (Latin «O», wrong word senses, missing phrases). 238 fixes in 84 Arabic and 69 translation fields. The importer applies them from `tool/azkar_text_fixes.jsonl` (`{id, field, before, after}`, `before` unique in the field) after the line breaks. Content changes only; the API is the same. Apps with per-word data keyed to the Arabic (Zikro's word glosses) must update the azkar whose word count changed: 6, 7, 26, 37, 62, 77, 78, 83, 141.

## 0.3.1

- Morning and evening collections are complete. Upstream leaves ten dawn/dusk azkar (ids 50–59) in no group; the importer now adds them: morning 17 → 24, evening 16 → 22 (witnessing «ушхидука», blessings «ни'ма», «'афини фи бадани», the second «асбахна/амсайна», «'ильман нафи'ан» in the morning, istighfar ×100, salawat ×10). Content changes only; the API is the same, nothing to change in apps. Apps that stored a collection order keep it; new ids are appended.

## 0.3.0

- Transcription fixes found by reading the whole corpus. Output changes; the API only grows, nothing to change in apps.
  - Stop (pause): `lines` still stops at every line end (line-by-line display); `text` now stops only at the very end, the other lines keep their last vowel.
  - Capitals: a line starts with a capital only when it opens a sentence. New `sentenceStarts` on `lines`/`text`, built by `ArabicTranscriber.sentenceStarts(translation)` (previous translation line ends in «.», «!», «?», «…»). Without it: the first line and lines after Arabic sentence punctuation.
  - Connecting alif after a vowel: the word joins the previous one, long vowel shortened («мастатӏоӏт», general «ма‑стата‘ту»); «الَّذِي» loses its alif like an article («Бисмилля́хӏил‑лази», «Бисми‑Ллахи‑л‑лази»).
  - Name of God after a particle («بِاللَّهِ», «لِلَّهِ», «فَلِلَّهِ», «وَاللَّهُ») and with «ٱ» is read as Allah («билля́хӏи», «би‑Ллахи»); after a hyphen it keeps its capital («Бисми‑Ллахи»).
  - Hafs spelling: tatweel is not a letter (its dagger alif or hamza is read: «ила́хӏа», «я’у́духӏу»); a dotless ya with a vowel, sukun or shadda is ya («ал‑хьаййу», «шай’ин»).
  - Root waw read solid: «وَسِعَ», «وَسِعَتْ», «وَقَبَ», «وَضَعْتُ», «وَجَّهْتُ», «وَعَدْتَهُ».
  - An unvocalised note in brackets («(ثلاثاً وثلاثين)») is not read; vocalised bracketed text still is.

## 0.2.0

- Transcription: `ArabicTranscriber` (`lines`, `text`, `sourceLines`) and `TranscriptionScheme` (general, vainakh, dagestan, tatar) read vocalised Arabic into Cyrillic by rules; `nonBreakingHyphen` is the joiner it writes. Pure Dart, no state. Moved from Zikro (originally Yalla's `dua_transliteration.dart`). Scheme display names stay in each app's localisation. The `general` scheme differs from Yalla's: soft «л», the alif of «Аллаһ» drops after a vowel («Бисми‑ллахи»), Arabic-Indic digits are ignored; the other schemes behave as in Yalla. Not breaking: nothing to change in apps that do not use it.

## 0.1.1

- Azkar: line breaks from the reading pass (`tool/azkar_lines.jsonl`), carried over from Zikro.

## 0.1.0

- Prayer times (tables of 310 places, adhan calculation, region method), azkar corpus and storage helpers moved here from Zikro.
