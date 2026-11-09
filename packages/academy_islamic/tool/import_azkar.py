#!/usr/bin/env python3
"""Reproducible import of the Azkar corpus into `assets/azkar/azkar.json`.

Source: AvocadoApps/azkar-ios (formerly Jawziyya/azkar-ios), pinned commit.
The upstream LICENSE is GPL-3.0; see docs/decisions.md (licensing question).

Usage (from packages/academy_islamic):
  python3 -I tool/import_azkar.py                # download the pinned database
  python3 -I tool/import_azkar.py --db azkar.db  # use a local copy (sha256 checked)
  python3 -I tool/import_azkar.py --audio-dir ../../../Zikro/apps/zikro/assets/audio
                                                 # also write the recitations an app bundles
"""
import argparse
import hashlib
import json
import sqlite3
import tempfile
import urllib.request
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
PIN = 'a9fcf2d6ae033b874473673c37b740e5a974f637'
DATABASE_SHA256 = '7bd24de861293e319ac089498489132cabec711d47be78dbaaca6be728de98a3'
UPSTREAM = f'https://raw.githubusercontent.com/AvocadoApps/azkar-ios/{PIN}/'
OUTPUT = ROOT / 'assets/azkar/azkar.json'
LICENSE_OUTPUT = ROOT / 'assets/azkar/LICENSE.azkar.txt'

# Category order on the home screen.
CATEGORIES = ['morning', 'evening', 'after-salah', 'night', 'other', 'hundred-dua']


def digest(data):
    return hashlib.sha256(data).hexdigest()


def fetch(path):
    with urllib.request.urlopen(UPSTREAM + path) as response:
        return response.read()


def clean(value):
    if value is None:
        return None
    value = value.strip()
    return value or None

# Upstream breaks Arabic, translation and transliteration into different
# numbers of lines for these azkar, which disables «Умный перенос» (one block
# per source line). Re-broken here so the lines match one to one. Only line
# breaks change: the words must stay identical (checked in `apply_line_fixes`).
LINE_FIXES = {
    4: {
        'transliteration': (
            "Асбахна ва асбаха-ль-мульку ли-Лляхи\n"
            "ва-ль-хамду ли-Лляхи,\n"
            "ля иляха илля Ллаху вахда-ху ля шарикя ля-ху,\n"
            "ля-ху-ль-мульку ва ля-ху-ль-хамду\n"
            "ва хуа ааля кулли шайин кадирун.\n"
            "Рабби, ас'алю-кя хайра ма фи хаза-ль-йауми ва хайра ма ба'да-ху\n"
            "ва а'узу би-кя мин шарри ма фи хаза-ль-йауми ва шарри ма ба'да-ху!\n"
            "Рабби, а'узу би-кя мин аль-кясали ва суи-ль-кибари,\n"
            "Рабби, а'узу би-кя мин 'азабин фи-н-нари ва 'азабин фи-ль-кабри!"
        ),
    },
    8: {
        'translation': (
            "O Аллах, Знающий сокрытое и явное,\n"
            "Творец небес и земли,\n"
            "Господь и Владыка всего,\n"
            "свидетельствую, что нет достойного поклонения, кроме Тебя,\n"
            "прибегаю к Тебе от зла души своей,\n"
            "от зла и многобожия шайтана\n"
            "и от того, чтобы причинить зло самому себе\n"
            "или навлечь его на какого-нибудь мусульманина."
        ),
    },
    23: {
        'translation': (
            "Нет бога, кроме одного лишь Аллаха,\n"
            "у Которого нет сотоварища.\n"
            "Ему принадлежит власть, Ему — хвала,\n"
            "и Он всё может.\n\n"
            "О Аллах, никто не лишит того, что Ты даровал,\n"
            "и никто не дарует того, чего Ты лишил,\n"
            "и бесполезным пред Тобой окажется богатство обладающего богатством."
        ),
    },
    24: {
        'transliteration': (
            "Ля иляха илля Ллаху\n"
            "вахда-ху ля шарика ля-ху.\n"
            "Ля-ху ль-мульку ва ля-ху ль-хамду\n"
            "ва хуа ‘аля кулли шай’ин кадир.\n\n"
            "Ля хауля ва ля куввата илля би-Лляхи\n\n"
            "ля иляха илля Ллаху\n"
            "ва ля на‘буду илля иййа-ху.\n"
            "Ля-ху н-ни‘мату ва ля-ху ль-фадлю\n"
            "ва ля-ху с-сана’у ль-хасан.\n\n"
            "Ля иляха илля Ллаху мухлисына ля-ху д-дина\n"
            "ва ляу кяриха ль-кафирун!"
        ),
    },
    25: {
        'transliteration': (
            "Субхана-Ллах, Альхамду ли-Ллях, Аллаху акбар (по 33 раза).\n\n"
            "Ля иляха илля-Ллаху вахдаху\n"
            "ля шарика ля-х(у),\n"
            "Ля-ху-ль-мульку, ва ля-ху-ль-хамду\n"
            "ва хува 'аля кулли щай'ин къадир!"
        ),
    },
    26: {
        'transliteration': (
            "Ля иляха илля-Ллаху\n"
            "вахдаху ля шарика ля-х(у),\n"
            "Ля-ху-ль-мульку, ва ля-ху-ль-хамду\n"
            "юхйи ва юмиту\n"
            "ва хува 'аля кулли щай'ин къадир!"
        ),
    },
    36: {
        'translation': 'О Аллах! Я прошу у Тебя добавления Твоего благодеяния!',
    },
    139: {
        # Merge the five Arabic lines into the two the translation has.
        'arabic': lambda t: (
            ' '.join(t.split('\n')[:3]) + '\n' + ' '.join(t.split('\n')[3:])
        ),
        'translation': (
            'О Аллах! Поистине, я прибегаю к Твоей защите от '
            'мерзких нравственных качеств и скверных желаний,\n'
            'от плохих дел и недугов.'
        ),
    },
    146: {
        'translation': (
            'Господь наш! Не делай нас искушением для тех, которые не веруют.\n'
            'Господь наш! Не делай нас искушением для людей несправедливых.'
        ),
    },
    149: {
        'translation': 'Господи! Спаси меня от несправедливых людей.',
    },
}


# Further line breaks from a reading pass over every dhikr (one JSON object per
# line: {"id", "field", "text"}); same rule, only breaks may change.
LINE_REVIEW = ROOT / 'tool/azkar_lines.jsonl'


def apply_line_fixes(azkar):
    by_id = {z['id']: z for z in azkar}
    fixes = {id: dict(fields) for id, fields in LINE_FIXES.items()}
    if LINE_REVIEW.exists():
        for line in LINE_REVIEW.read_text(encoding='utf-8').splitlines():
            if line.strip():
                item = json.loads(line)
                fixes.setdefault(item['id'], {})[item['field']] = item['text']
    for id, fields in fixes.items():
        for field, text in fields.items():
            old = by_id[id][field]
            if callable(text):
                text = text(old)
            assert ''.join(old.split()) == ''.join(text.split()), (id, field)
            by_id[id][field] = text


def load(database):
    db = sqlite3.connect(database)
    db.row_factory = sqlite3.Row
    hadith = {
        row['id']: {
            'arabic': clean(row['text']),
            'translation': clean(row['translation_ru']),
            'source': clean(row['source']),
            'sourceExt': clean(row['source_ext'].strip("'")),
        }
        for row in db.execute('select * from ahadith')
    }
    azkar = []
    for row in db.execute(
        'select a.id, a.repeats, a.source, a.text, a.hadith, a.type, '
        'r.title, r.text as translation, r.benefits, r.notes, r.transliteration, '
        'au.link as audio '
        'from azkar a join azkar_ru r on r.id = a.id '
        'left join audios au on au.id = a.audio_id order by a.id'
    ):
        record = {
            'id': row['id'],
            'repeats': row['repeats'] or 1,
            'type': row['type'] or 'hadith',
            'source': clean(row['source']),
            'title': clean(row['title']),
            'arabic': clean(row['text']),
            'translation': clean(row['translation']),
            'transliteration': clean(row['transliteration']),
            'benefits': clean(row['benefits']),
            'notes': clean(row['notes']),
            'audio': clean(row['audio']),
        }
        if row['hadith'] in hadith:
            record['hadith'] = hadith[row['hadith']]
        azkar.append({k: v for k, v in record.items() if v is not None})
    apply_line_fixes(azkar)
    groups = {}
    for row in db.execute(
        'select "group", azkar_id from "azkar+azkar_group" order by "group", "order"'
    ):
        groups.setdefault(row['group'], []).append(row['azkar_id'])
    fadail = [
        {'text': clean(row['text']), 'source': clean(row['source'])}
        for row in db.execute('select * from fadail_ru order by id')
    ]
    return azkar, groups, fadail


def validate(document):
    ids = {z['id'] for z in document['azkar']}
    assert len(ids) == len(document['azkar'])
    for z in document['azkar']:
        assert z.get('arabic') and z.get('translation'), z['id']
        assert z['repeats'] >= 1
    for category in document['categories']:
        assert category['azkarIds'], category['id']
        assert set(category['azkarIds']) <= ids, category['id']
    assert [c['id'] for c in document['categories']] == CATEGORIES


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('--db', type=Path)
    parser.add_argument('--audio-dir', type=Path)
    args = parser.parse_args()
    data = args.db.read_bytes() if args.db else fetch('Azkar/Resources/azkar.db')
    assert digest(data) == DATABASE_SHA256, 'Unexpected upstream database'
    license_text = (
        args.db.parents[2].joinpath('LICENSE').read_bytes()
        if args.db and args.db.parents[2].joinpath('LICENSE').exists()
        else fetch('LICENSE')
    )
    with tempfile.TemporaryDirectory() as temp:
        database = Path(temp) / 'azkar.db'
        database.write_bytes(data)
        azkar, groups, fadail = load(database)
    document = {
        'version': 1,
        'provenance': {
            'repository': 'AvocadoApps/azkar-ios',
            'commit': PIN,
            'path': 'Azkar/Resources/azkar.db',
            'databaseSha256': DATABASE_SHA256,
            'license': 'GPL-3.0 (see LICENSE.azkar.txt)',
            'credits': 'https://azkar.ru',
        },
        'categories': [{'id': c, 'azkarIds': groups[c]} for c in CATEGORIES],
        'azkar': azkar,
        'fadail': fadail,
    }
    validate(document)
    audio = sorted({z['audio'] for z in azkar if 'audio' in z})
    if args.audio_dir:
        args.audio_dir.mkdir(parents=True, exist_ok=True)
    for name in audio if args.audio_dir else []:
        local = args.db.parent / 'Audios' / name if args.db else None
        data = (
            local.read_bytes()
            if local and local.exists()
            else fetch(f'Azkar/Resources/Audios/{name}')
        )
        (args.audio_dir / name).write_bytes(data)
    OUTPUT.write_text(
        json.dumps(document, ensure_ascii=False, indent=1) + '\n', encoding='utf-8'
    )
    LICENSE_OUTPUT.write_bytes(license_text)
    print(f'Wrote {len(azkar)} azkar, {len(groups)} groups, {len(audio)} audio -> {OUTPUT}')


if __name__ == '__main__':
    main()
