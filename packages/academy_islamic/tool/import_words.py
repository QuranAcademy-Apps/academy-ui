#!/usr/bin/env python3
"""Builds assets/azkar/words.json (word-by-word glosses) from tool/words_ru.tsv.

words_ru.tsv is hand-authored, one row per distinct text:
`id[,id...]<TAB>gloss|gloss|...` (azkar.json ids). A row holds one cell per
Arabic word, in text order, translated in context. An empty cell means the
word shares the card (and the gloss) of the previous word, e.g. a negation
with its verb.

Words are split exactly like `ZikrWords.split` in Dart: on whitespace, a token
without an Arabic letter (verse mark, number, ﷺ) joins the previous word.

A hisn.json dua has the id Zikr.hisnId = 100000 + chapter * 100 + number.
Every azkar.json and hisn.json text needs a row with one cell per word, so a
change to a text's Arabic (tool/azkar_text_fixes.jsonl, import_azkar.py,
tool/hisn_text_fixes.jsonl, import_hisn.py) is noticed here.

Usage: python3 -I tool/import_words.py   # fails on a missing id or cell count
"""
import json
import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
GLOSSES = ROOT / 'tool/words_ru.tsv'
OUTPUT = ROOT / 'assets/azkar/words.json'
AZKAR = ROOT / 'assets/azkar/azkar.json'
HISN = ROOT / 'assets/azkar/hisn.json'
HISN_ID_BASE = 100000

_LETTERS = re.compile('[ء-ي]')
_MARKS = re.compile('[ً-ٰٟۖ-ۭـ‌‍]')


def split_words(arabic):
    words = []
    for token in arabic.split():
        if not _LETTERS.search(_MARKS.sub('', token)) and words:
            words[-1] += ' ' + token
        else:
            words.append(token)
    return words


def load_glosses():
    glosses = {}
    for line in GLOSSES.read_text(encoding='utf-8').splitlines():
        if line and not line.startswith('#'):
            ids, cells = line.split('\t')
            for zikr_id in ids.split(','):
                glosses[int(zikr_id)] = cells.split('|')
    return glosses


def main():
    glosses = load_glosses()
    azkar = json.loads(AZKAR.read_text(encoding='utf-8'))
    hisn = json.loads(HISN.read_text(encoding='utf-8'))
    texts = {item['id']: item['arabic'] for item in azkar['azkar']}
    for chapter in hisn['chapters']:
        for dua in chapter['duas']:
            number, index = map(int, dua['id'].split('-'))
            texts[HISN_ID_BASE + number * 100 + index] = dua['arabic']

    out, problems = {}, []
    for zikr_id, arabic in texts.items():
        words = split_words(arabic)
        cells = glosses.get(zikr_id)
        if cells is None:
            problems.append(f'{zikr_id}: no row')
        elif len(cells) != len(words):
            problems.append(f'{zikr_id}: {len(cells)} cells, {len(words)} words')
        elif not cells[0]:
            problems.append(f'{zikr_id}: first cell is empty')
        else:
            out[str(zikr_id)] = cells
    for zikr_id in glosses.keys() - texts.keys():
        problems.append(f'{zikr_id}: unknown id')
    if problems:
        sys.exit('\n'.join(sorted(problems)))
    OUTPUT.write_text(
        json.dumps(out, ensure_ascii=False, separators=(',', ':')) + '\n',
        encoding='utf-8',
    )
    print(f'{len(out)} texts, {sum(map(len, out.values()))} words -> {OUTPUT}')


if __name__ == '__main__':
    main()
