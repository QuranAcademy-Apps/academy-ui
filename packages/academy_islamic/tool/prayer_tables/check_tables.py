#!/usr/bin/env python3
"""Validate the prayer tables file.

Usage:
  python3 -I tool/prayer_tables/check_tables.py [path]   # default: the file in assets

Errors (exit 1): broken structure, counts, ids, dates, time format, dataKind.
Warnings (exit 0): day-to-day steps above STEP minutes and days whose six
times are not in ascending order. Both are normal for white nights and the
Tatarstan «summer count» (Fajr/Isha after midnight) — the script only lists
them per place so a human can look; it never changes the file.
"""
import datetime
import json
import re
import sys
from pathlib import Path

DEFAULT = Path(__file__).resolve().parents[2] / "tool/prayer_tables/sources/namaz-times-cities-2026.json"
KINDS = {"official", "calculated", "unverified"}
STEP = 6  # minutes


def minutes(t):
    h, m = t.split(":")
    return int(h) * 60 + int(m)


def main(path):
    doc = json.load(open(path, encoding="utf-8"))
    errors, warnings = [], []
    cities = doc["cities"]
    if doc.get("prayers") != ["Fajr", "Sunrise", "Dhuhr", "Asr", "Maghrib", "Isha"]:
        errors.append("prayers list differs from the expected order")
    complete = sum(c["coverageStatus"] == "complete" for c in cities)
    for key, value in (("cityCount", len(cities)), ("completeCityCount", complete),
                       ("partialCityCount", len(cities) - complete)):
        if doc.get(key) != value:
            errors.append(f"{key}={doc.get(key)} but {value} counted")
    ids = [c["id"] for c in cities]
    if len(ids) != len(set(ids)):
        errors.append("duplicate ids")
    year = doc["year"]
    for c in cities:
        name = c["name"]
        if c.get("dataKind") not in KINDS:
            errors.append(f"{name}: dataKind {c.get('dataKind')!r}")
        src = c["source"]
        if c.get("dataKind") == "calculated" and src.get("url") is not None:
            errors.append(f"{name}: calculated place must have url null")
        if c.get("dataKind") == "official" and not src.get("name"):
            errors.append(f"{name}: official place without source name")
        days = c["days"]
        if not days or days[0]["date"] != c["coverageStart"] or days[-1]["date"] != c["coverageEnd"]:
            errors.append(f"{name}: coverage does not match days")
            continue
        if c["coverageStatus"] == "complete" and (c["coverageStart"] != f"{year}-01-01" or c["coverageEnd"] != f"{year}-12-31"):
            errors.append(f"{name}: complete but not the whole year")
        prev = None
        for d in days:
            date = datetime.date.fromisoformat(d["date"])
            if prev and (date - prev).days != 1:
                errors.append(f"{name}: gap before {d['date']}")
                break
            prev = date
            if len(d["times"]) != 6 or not all(re.fullmatch(r"([01]\d|2[0-3]):[0-5]\d", t) for t in d["times"]):
                errors.append(f"{name}: bad times on {d['date']}: {d['times']}")
                break
        else:
            steps = unsorted = 0
            for a, b in zip(days, days[1:]):
                steps += sum(abs(minutes(y) - minutes(x)) > STEP for x, y in zip(a["times"], b["times"]))
            for d in days:
                unsorted += d["times"] != sorted(d["times"])
            if steps or unsorted:
                warnings.append(f"{name}: {steps} steps > {STEP} min, {unsorted} unordered days")
    for w in warnings:
        print("warn ", w)
    for e in errors:
        print("ERROR", e)
    kinds = {k: sum(c["dataKind"] == k for c in cities) for k in sorted(KINDS)}
    print(f"{len(cities)} places ({complete} complete), {kinds}; "
          f"{len(warnings)} places with warnings, {len(errors)} errors")
    return 1 if errors else 0


if __name__ == "__main__":
    sys.exit(main(sys.argv[1] if len(sys.argv) > 1 else DEFAULT))
