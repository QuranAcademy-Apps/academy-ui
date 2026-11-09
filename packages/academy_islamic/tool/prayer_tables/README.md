# prayer_tables tools

Tools and history for `tool/prayer_tables/sources/namaz-times-cities-2026.json`.
Format, sources, repair rules: [docs/features/prayer-tables.md](../../../../docs/features/prayer-tables.md).

- `check_tables.py` — validates the file (structure, counts, dates, `HH:MM`,
  `dataKind`); lists steps > 6 min and unordered days as warnings. Never edits.
  `python3 -I tool/prayer_tables/check_tables.py`
- `crawl_calculated.py` — downloads the calculated tables (run from a scratch
  directory, see its docstring).
- `sources/` — hand transcriptions that exist nowhere else as text:
  `ufa_cdum_hijri1448.txt` (Ufa, 16 Jun – 31 Dec 2026, from the CDUM month
  images), `ingushetia_jan-jul_dec.txt` and `ingushetia_oct-nov.txt` (perpetual
  calendar from the Muftiate's Telegram channel; Aug–Sep were taken from the
  earlier file). Format: `M <start date or month>` then six times per day.
- `logs/all-repairs.json` — every changed cell (city, prayer, date, was → now,
  kind). `logs/provenance-internal.json` — original source name/url/hash and
  basis of every calculated or unverified place. Internal; not for the app.

Not reproducible from this folder: the one-off conversions of the Tatarstan
xlsx/CSV, the Dagestan JSON (+ second copy), the DUM-KBR table, the Nizhny
Novgorod PDF and the repair passes were interactive and their scripts were not
saved. Their sources and rules are in the doc above and every changed cell is
in `logs/all-repairs.json`. Working copies and all intermediate downloads are in
the git-ignored `.artifacts/prayer-times/`.
