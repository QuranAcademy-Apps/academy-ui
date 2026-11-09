#!/usr/bin/env python3
"""Cut the big tables file into what the app loads.

Reads  tool/prayer_tables/sources/namaz-times-cities-2026.json  (the source of
truth, not bundled) and  tool/prayer_tables/sources/coordinates.json  and writes

  assets/prayer_tables/index.json          one entry per place (≈ 60 KB)
  assets/prayer_tables/cities/NNN.json      {"t": [minutes after midnight, six
                                             per day, day after day]}

Places without verified coordinates are not written (listed at the end).
Run from the package directory:  python3 -I tool/prayer_tables/build_app_tables.py
"""
import hashlib
import json
import shutil
from pathlib import Path

APP = Path(__file__).resolve().parents[2]
DATA = APP / "assets/prayer_tables"
SOURCE = APP / "tool/prayer_tables/sources/namaz-times-cities-2026.json"
COORDINATES = APP / "tool/prayer_tables/sources/coordinates.json"


def minutes(text):
    hours, mins = text.split(":")
    return int(hours) * 60 + int(mins)


def main():
    doc = json.load(open(SOURCE, encoding="utf-8"))
    coordinates = json.load(open(COORDINATES, encoding="utf-8"))
    out = DATA / "cities"
    if out.exists():
        shutil.rmtree(out)
    out.mkdir()
    places, skipped = [], []
    for place in sorted(doc["cities"], key=lambda c: c["name"].lower().replace("ё", "е")):
        where = coordinates.get(place["id"])
        if not where:
            skipped.append(place["name"])
            continue
        flat = [minutes(t) for day in place["days"] for t in day["times"]]
        number = len(places) + 1
        file = f"cities/{number:03d}.json"
        text = json.dumps({"t": flat}, separators=(",", ":"))
        (DATA / file).write_text(text, encoding="utf-8")
        places.append({
            "id": place["id"],
            "name": place["name"],
            "kind": place["dataKind"],
            "source": place["source"]["name"],
            "lat": where["lat"],
            "lon": where["lon"],
            "file": file,
            "rev": hashlib.sha1(text.encode()).hexdigest()[:8],
            "start": place["coverageStart"],
            "days": len(place["days"]),
        })
    index = {"schemaVersion": 1, "year": doc["year"], "places": places}
    (DATA / "index.json").write_text(
        json.dumps(index, ensure_ascii=False, separators=(",", ":")), encoding="utf-8")
    size = sum(f.stat().st_size for f in out.iterdir())
    print(f"{len(places)} places, {size / 1e6:.2f} MB in cities/, "
          f"index {(DATA / 'index.json').stat().st_size / 1e3:.0f} KB")
    if skipped:
        print("not written (no verified coordinates):", ", ".join(skipped))


if __name__ == "__main__":
    main()
