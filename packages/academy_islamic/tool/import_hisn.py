#!/usr/bin/env python3
"""Reproducible import of «Крепость мусульманина» (Hisn al-Muslim) chapters.

Source: shakhbanov/dua-from-sunna (dua.shakhbanov.org), pinned commit, files
`data/chapters/NNN-*.ts` (Arabic word grid, Russian translation, notes,
sources). The TypeScript object literals are parsed as data — the upstream
code is never executed. The repository has no LICENSE; using it is the app owner's decision
(CHANGELOG 0.5.0).

Usage:
  python3 -I tool/import_hisn.py --repo PATH   # local clone at the pinned commit
  python3 -I tool/import_hisn.py               # shallow-clone the pinned commit
"""
import argparse
import json
import re
import subprocess
import tempfile
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
REPOSITORY = 'https://github.com/shakhbanov/dua-from-sunna.git'
PIN = 'fe48028563cc91820c61dc0f789a3eaac4cf6c90'
OUTPUT = ROOT / 'assets/azkar/hisn.json'
LINES = ROOT / 'tool/hisn_lines.jsonl'
# Text corrections from the audit (docs/tasks/2026-11-14-azkar-text-review):
# {"id", "field", "before", "after"} per line, applied after the line breaks;
# `before` must occur exactly once in the field.
TEXT_FIXES = ROOT / 'tool/hisn_text_fixes.jsonl'
# Situations (own wording, decisions #65): id, situation, label, upstream
# title. The upstream title must match, so a changed source chapter is noticed.
TITLES = ROOT / 'tool/hisn_titles.tsv'

# Chapter 1 is the author's preface (no supplications). Chapter 29 (morning
# and evening) duplicates the morning and evening collections of azkar.json.
SKIP_CHAPTERS = {1, 29}  # chapters without duas are skipped automatically

_NUMBERS = {
    'два': 2, 'две': 2, 'три': 3, 'четыре': 4, 'семь': 7, 'десять': 10,
    'тридцать три': 33, 'тридцать четыре': 34, 'сто': 100,
}
_ADVERBS = {'дважды': 2, 'трижды': 3, 'четырежды': 4}


def ts_literal_to_json(source):
    """Converts the object literal after `= ` into JSON text."""
    start = source.index('{', source.index('ChapterData ='))
    out, i, depth, in_string, quote = [], start, 0, False, ''
    while i < len(source):
        ch = source[i]
        if in_string:
            if ch == '\\':
                out.append(source[i:i + 2])
                i += 2
                continue
            if ch == quote:
                in_string = False
                out.append('"')
            elif ch == '"':
                out.append('\\"')
            elif ch == '\n':
                out.append('\\n')
            else:
                out.append(ch)
            i += 1
            continue
        if ch in '"\'`':
            in_string, quote = True, ch
            out.append('"')
        elif ch == '/' and source[i + 1] == '/':
            i = source.index('\n', i)
            continue
        elif ch == '/' and source[i + 1] == '*':
            i = source.index('*/', i) + 2
            continue
        elif ch.isalpha() or ch == '_':
            match = re.match(r'[A-Za-z_][A-Za-z0-9_]*', source[i:])
            word = match.group(0)
            rest = source[i + len(word):].lstrip()
            if rest.startswith(':'):
                out.append(f'"{word}"')
            elif word in ('true', 'false', 'null'):
                out.append(word)
            else:
                raise ValueError(f'Unexpected identifier {word!r}')
            i += len(word)
            continue
        else:
            if ch == '{' or ch == '[':
                depth += 1
            elif ch == '}' or ch == ']':
                depth -= 1
            out.append(ch)
            if depth == 0 and ch == '}':
                break
        i += 1
    text = ''.join(out)
    return re.sub(r',(\s*[}\]])', r'\1', text)


def repeats_of(*texts):
    """Repeat count stated in a note or translation, e.g. «по три раза»."""
    numbers = '|'.join(sorted(_NUMBERS, key=len, reverse=True))
    for text in texts:
        if not text:
            continue
        lowered = text.lower()
        if match := re.search(r'(\d+)\s*раз', lowered):
            return int(match.group(1))
        if match := re.search(rf'\b({numbers})\s+раз', lowered):
            return _NUMBERS[match.group(1)]
        for word, count in _ADVERBS.items():
            if re.search(rf'\b{word}\b', lowered):
                return count
    return 1


def ru(value):
    if isinstance(value, dict):
        value = value.get('ru')
    if not value:
        return None
    return value.strip() or None


def lines_of(item_id, sync, translation, breaks):
    """Arabic and translation broken into matching lines.

    `tool/hisn_lines.json` holds hand-made breaks per dua (read from the Arabic
    and the translation together): `a` are 1-based Arabic word numbers and `r`
    1-based translation token numbers after which a line ends. Duas without an
    entry stay on one line.
    """
    words = [w['text'].strip() for w in sync if w['text'].strip()]
    tokens = translation.split()
    cut = breaks.get(item_id)
    if not cut:
        return ' '.join(words), translation
    a, r = cut['a'], cut['r']
    assert len(a) == len(r) and a == sorted(set(a)) and r == sorted(set(r)), item_id
    assert a[-1] < len(words) and r[-1] < len(tokens), item_id

    def join(items, ends):
        lines, start = [], 0
        for end in ends + [len(items)]:
            lines.append(' '.join(items[start:end]))
            start = end
        return '\n'.join(lines)

    return join(words, a), join(tokens, r)


def apply_text_fixes(chapters):
    by_id = {d['id']: d for c in chapters for d in c['duas']}
    for line in TEXT_FIXES.read_text(encoding='utf-8').splitlines():
        if not line.strip():
            continue
        fix = json.loads(line)
        old = by_id[fix['id']][fix['field']]
        assert old.count(fix['before']) == 1, (fix['id'], fix['field'], fix['before'])
        by_id[fix['id']][fix['field']] = old.replace(fix['before'], fix['after'])


def merge_situations(chapters):
    """Chapters of one situation become one chapter (id and place of the first,
    duas in book order); in a merged one each dua is titled by its chapter."""
    rows = {}
    for line in TITLES.read_text(encoding='utf-8').splitlines():
        if line and not line.startswith('#'):
            id, situation, label, full = line.split('\t')
            rows[int(id)] = (situation, label, full)
    assert set(rows) == {c['id'] for c in chapters}, 'hisn_titles.tsv is out of date'
    merged = {}
    for chapter in chapters:
        situation, label, full = rows[chapter['id']]
        assert chapter['title'] == full, (chapter['id'], chapter['title'])
        merged.setdefault(situation, []).append((label, chapter))
    result = []
    for situation, parts in merged.items():
        duas = []
        for label, chapter in parts:
            for dua in chapter['duas']:
                duas.append({'id': dua['id'], 'title': label, **dua} if len(parts) > 1 else dua)
        result.append({'id': parts[0][1]['id'], 'title': situation, 'duas': duas})
    return result


def load(repo):
    breaks = {
        json.loads(line)['id']: json.loads(line)
        for line in LINES.read_text(encoding='utf-8').splitlines()
        if line.strip()
    }
    chapters = []
    for path in sorted((repo / 'data/chapters').glob('[0-9][0-9][0-9]-*.ts')):
        data = json.loads(ts_literal_to_json(path.read_text(encoding='utf-8')))
        if data.get('collection', 'sunna') != 'sunna':
            continue
        if data['id'] in SKIP_CHAPTERS:
            continue
        duas = []
        for item in data['duas']:
            translation = ru(item.get('fullTranslation'))
            if not item.get('sync') or not translation:
                continue
            arabic, translation = lines_of(item['id'], item['sync'], translation, breaks)
            if not arabic:
                continue
            note = ru(item.get('note'))
            record = {
                'id': item['id'],
                'title': ru(item.get('title')),
                'arabic': arabic,
                'translation': translation,
                'narration': ru(item.get('narration')),
                'note': note,
                'source': ru(item.get('source')),
                'repeats': repeats_of(note, translation),
            }
            duas.append({k: v for k, v in record.items() if v is not None})
        if duas:
            chapters.append({
                'id': data['id'],
                'title': ru(data['title']),
                'duas': duas,
            })
    apply_text_fixes(chapters)
    return merge_situations(chapters)


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('--repo', type=Path)
    args = parser.parse_args()
    with tempfile.TemporaryDirectory() as temp:
        repo = args.repo
        if repo is None:
            repo = Path(temp) / 'repo'
            subprocess.run(['git', 'clone', '-q', REPOSITORY, str(repo)], check=True)
            subprocess.run(['git', '-C', str(repo), 'checkout', '-q', PIN], check=True)
        head = subprocess.run(
            ['git', '-C', str(repo), 'rev-parse', 'HEAD'],
            check=True, capture_output=True, text=True,
        ).stdout.strip()
        assert head == PIN, f'Expected {PIN}, got {head}'
        chapters = load(repo)
    ids = [d['id'] for c in chapters for d in c['duas']]
    assert len(ids) == len(set(ids))
    assert len(chapters) >= 50, len(chapters)
    document = {
        'version': 1,
        'provenance': {
            'title': 'Крепость мусульманина (Hisn al-Muslim), Саид аль-Кахтани',
            'repository': 'shakhbanov/dua-from-sunna',
            'commit': PIN,
            'license': 'not specified upstream (see CHANGELOG 0.5.0)',
        },
        'chapters': chapters,
    }
    OUTPUT.write_text(
        json.dumps(document, ensure_ascii=False, indent=1) + '\n', encoding='utf-8'
    )
    print(f'Wrote {len(chapters)} chapters, {len(ids)} duas -> {OUTPUT}')


if __name__ == '__main__':
    main()
