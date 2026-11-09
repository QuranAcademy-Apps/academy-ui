# academy_islamic

Общие для приложений QuranAcademy (Zikro, Yalla) время намаза и корпус азкаров
и дуа. Исправления текстов, таблиц и расчёта делаются только здесь.

## Что внутри

- **Время намаза** — `PrayerTimesService`: место (геопозиция или город),
  опубликованные таблицы муфтиятов (`assets/prayer_tables`, 310 мест на 2026 год)
  и расчёт `adhan_dart` там, где таблицы нет. `prayerSnapshot` даёт времена дня и
  ближайший намаз, `resolvePrayerMethod` — метод по региону.
- **Азкары и дуа** — `AzkarCorpus.load` читает `assets/azkar/azkar.json`
  (утренние, вечерние, после намаза, перед сном, 100 дуа и др.). «Крепость
  мусульманина» и глоссы слов приложение пока передаёт само (`hisn`, `words`).
- **Хранение** — `KeyValueStore`, `PersistedNotifier`.

## Подключение

```yaml
academy_islamic:
  git:
    url: git@github.com:QuranAcademy-Apps/academy-ui.git
    path: packages/academy_islamic
    ref: <тег academy_islamic-vX.Y.Z>
```

Приложение со своим ключом хранения передаёт его: `PrayerTimesService(store,
key: 'yalla.today.prayer.v1', tables: …)`. Зикро использует ключ по умолчанию.
iOS и Android: разрешение «при использовании» на геопозицию
(`NSLocationWhenInUseUsageDescription`, `ACCESS_COARSE/FINE_LOCATION`).

## Данные

- Азкары: `python3 -I tool/import_azkar.py` (закреплённый коммит azkar-ios,
  лицензия GPL-3.0 — `assets/azkar/LICENSE.azkar.txt`). Аудио приложение
  получает через `--audio-dir`.
- Таблицы: `tool/prayer_tables/README.md`. Таблицы покрывают только 2026 год;
  до 1 января нужна сборка на 2027-й, иначе останется только расчёт.

## Проверка

```sh
flutter test
```
