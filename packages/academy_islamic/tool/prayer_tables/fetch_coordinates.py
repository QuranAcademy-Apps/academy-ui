#!/usr/bin/env python3
"""Coordinates for every place of the prayer tables, with a sanity check.

For each place the table file lists:
  1. the exact GeoNames coordinates of the same-named place of the crawled
     list (`cities-list.json` from crawl_calculated.py), if there is one;
  2. otherwise the first OpenStreetMap (Nominatim) result for
     «name, region, Россия» (≤ 1 request/second, descriptive User-Agent).
Every pair is then checked against the table itself: the sunrise computed
from (lat, lon, UTC offset) must be within TOLERANCE minutes of the sunrise in
the table (median over the year). Places that fail are listed, not written.

Usage (from a scratch directory that holds cities-list.json):
  python3 -I <repo>/apps/zikro/tool/prayer_tables/fetch_coordinates.py \
      --tables tool/prayer_tables/sources/namaz-times-cities-2026.json \
      --out    <repo>/apps/zikro/tool/prayer_tables/sources/coordinates.json
"""
import argparse
import concurrent.futures as cf
import datetime
import json
import math
import re
import statistics
import subprocess
import time
import urllib.parse
from pathlib import Path

UA = ("Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 "
      "(KHTML, like Gecko) Version/17.0 Safari/605.1.15")
NOMINATIM_UA = "ZikroPrayerTables/1.0 (data preparation; contact: repository owner)"
TOLERANCE = 12  # minutes: sunrise offset allowed
SPREAD = 25  # minutes: seasonal spread of the day-length residual
OFFSET = {  # UTC offset (hours) of the zones used in Russia; no DST since 2014
    "Europe/Kaliningrad": 2, "Europe/Moscow": 3, "Europe/Kirov": 3, "Europe/Volgograd": 3,
    "Europe/Samara": 4, "Europe/Saratov": 4, "Europe/Astrakhan": 4, "Europe/Ulyanovsk": 4,
    "Asia/Yekaterinburg": 5, "Asia/Omsk": 6, "Asia/Novosibirsk": 7, "Asia/Barnaul": 7,
    "Asia/Tomsk": 7, "Asia/Novokuznetsk": 7, "Asia/Krasnoyarsk": 7, "Asia/Irkutsk": 8,
    "Asia/Chita": 9, "Asia/Yakutsk": 9, "Asia/Vladivostok": 10, "Asia/Sakhalin": 11,
    "Asia/Magadan": 11,
}
# Region hint for places that are not in the crawled list.
REGION = {
    "ДУМ Республики Татарстан": "Республика Татарстан",
    "Муфтият Республики Дагестан": "Республика Дагестан",
    "ДУМ Кабардино-Балкарской Республики": "Кабардино-Балкарская Республика",
    "Муфтият Республики Ингушетия": "Республика Ингушетия",
    "ДУМ Кабардино-Балкарской Республики (единый график по республике)": "Кабардино-Балкарская Республика",
    "Муфтият Республики Ингушетия (единый график по республике)": "Республика Ингушетия",
}


def curl(url):
    out = subprocess.run(["curl", "-4", "-sL", "-m", "60", "-A", UA, url], capture_output=True)
    return out.stdout.decode("utf-8", "replace")


def sajda_coords(item):
    path, name = item
    text = curl("https://sajda.com" + path).replace('\\"', '"')
    lon = re.search(r'"longitude":(-?[\d.]+),"latitude":(-?[\d.]+)', text)
    return name, path, (float(lon.group(2)), float(lon.group(1))) if lon else None


def nominatim(query):
    url = "https://nominatim.openstreetmap.org/search?" + urllib.parse.urlencode(
        {"q": query, "format": "json", "limit": 1, "accept-language": "ru"})
    for _ in range(3):
        out = subprocess.run(["curl", "-4", "-sL", "-m", "20", "-A", NOMINATIM_UA, url],
                             capture_output=True)
        try:
            rows = json.loads(out.stdout.decode("utf-8", "replace"))
        except ValueError:
            time.sleep(2)
            continue
        if rows:
            return float(rows[0]["lat"]), float(rows[0]["lon"]), rows[0].get("display_name", "")
        return None
    return None


def _sun(date, lat, lon, offset):
    """Sunrise and sunset in minutes after local midnight (-0.833 deg altitude)."""
    d = (date - datetime.date(2000, 1, 1)).days - lon / 360  # days from J2000 noon at local solar noon
    g = math.radians((357.529 + 0.98560028 * d) % 360)
    q = (280.459 + 0.98564736 * d) % 360
    sun_lon = math.radians((q + 1.915 * math.sin(g) + 0.020 * math.sin(2 * g)) % 360)
    tilt = math.radians(23.439 - 0.00000036 * d)
    ra = (math.degrees(math.atan2(math.cos(tilt) * math.sin(sun_lon), math.cos(sun_lon))) / 15) % 24
    eqt = (q / 15 - ra + 12) % 24 - 12
    dec = math.asin(math.sin(tilt) * math.sin(sun_lon))
    x = (-math.sin(math.radians(0.833)) - math.sin(dec) * math.sin(math.radians(lat))) / (
        math.cos(dec) * math.cos(math.radians(lat)))
    if abs(x) > 1:
        return None
    noon = 12 + offset - lon / 15 - eqt
    half = math.degrees(math.acos(x)) / 15
    return (noon - half) * 60, (noon + half) * 60


def check(place, lat, lon):
    """(median sunrise residual, spread of day-length residual) in minutes.

    The sunrise residual says whether longitude and time zone fit the table;
    the day-length residual changes with the season when the latitude is off,
    so its spread (max - min over the year) catches a wrong latitude.
    """
    offset = OFFSET[place["timeZone"]]
    rises, lengths = [], []
    for day in place["days"][10::15]:
        sun = _sun(datetime.date.fromisoformat(day["date"]), lat, lon, offset)
        if sun is None:
            continue
        sunrise, maghrib = (minutes(day["times"][i]) for i in (1, 4))
        rises.append(sun[0] - sunrise)
        lengths.append((sun[1] - sun[0]) - (maghrib - sunrise))
    if not rises:
        return None, None
    return statistics.median(rises), max(lengths) - min(lengths)


def minutes(text):
    hours, mins = text.split(":")
    return int(hours) * 60 + int(mins)


def good(result):
    rise, spread = result
    return rise is not None and abs(rise) <= TOLERANCE and spread <= SPREAD


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--tables", required=True)
    parser.add_argument("--out", required=True)
    parser.add_argument("--list", default="cities-list.json")
    parser.add_argument("--provenance", default=str(Path(__file__).resolve().parent / "logs/provenance-internal.json"))
    args = parser.parse_args()
    places = json.load(open(args.tables, encoding="utf-8"))["cities"]
    listed = json.load(open(args.list, encoding="utf-8"))
    cache = Path("sajda-coords.json")
    if cache.exists():
        rows = json.load(open(cache, encoding="utf-8"))
        missing = [(path, name) for name, path, coords in rows if not coords]
        for name, path, coords in map(sajda_coords, [m for m in missing]):  # retry failed pages
            for row in rows:
                if row[1] == path and coords:
                    row[2] = coords
        json.dump(rows, open(cache, "w", encoding="utf-8"), ensure_ascii=False)
    else:
        with cf.ThreadPoolExecutor(6) as pool:
            rows = [list(row) for row in pool.map(sajda_coords, listed)]
        json.dump(rows, open(cache, "w", encoding="utf-8"), ensure_ascii=False)
    found = {}
    for name, path, coords in rows:
        if coords:
            found.setdefault(name, []).append((path, tuple(coords)))
    print(f"sajda: {sum(len(v) for v in found.values())} of {len(listed)} places have coordinates", flush=True)
    exact = {path: coords for hits in found.values() for path, coords in hits}
    provenance = json.load(open(args.provenance, encoding="utf-8"))
    result, failed, suspect = {}, [], []
    for place in places:
        name = re.sub(r" \(.*\)$", "", place["name"])
        source, coords = None, None
        # 1. the page the numbers came from: exact, no check needed
        original = (provenance.get(place["id"]) or {}).get("original", {}).get("url") or ""
        if original.startswith("https://sajda.com"):
            path = original[len("https://sajda.com"):]
            if path in exact:
                coords, source = exact[path], "geonames:" + path.rsplit("/", 1)[-1]
        # 2. a same-named place of the list that agrees with the table
        if coords is None:
            for path, candidate in found.get(name, []):
                if good(check(place, *candidate)):
                    source, coords = "geonames:" + path.rsplit("/", 1)[-1], candidate
                    break
        # 3. OpenStreetMap, region taken from the source of the table
        if coords is None:
            region = REGION.get(place["source"]["name"], "")
            time.sleep(1.1)
            guess = None
            for query in (f"{name}, {region}, Россия", f"{name}, {region}", f"{name} село, {region}"):
                guess = nominatim(query.replace(" ,", ","))
                if guess:
                    break
                time.sleep(1.1)
            print("osm", name, "->", guess and guess[:2], flush=True)
            if guess:
                coords, source = (guess[0], guess[1]), "osm"
        if coords is None:
            failed.append((name, "no coordinates"))
            continue
        rise, spread = check(place, *coords)
        if not source.startswith("geonames") and not good((rise, spread)):
            failed.append((name, f"sunrise {rise and round(rise)} min, day-length spread {spread and round(spread)} min for {coords} ({source})"))
            continue
        if not good((rise, spread)):
            suspect.append((name, f"sunrise {rise and round(rise)} min, day-length spread {spread and round(spread)} min ({source})"))
        result[place["id"]] = {"lat": round(coords[0], 4), "lon": round(coords[1], 4), "source": source,
                               "sunriseResidualMin": rise and round(rise, 1),
                               "dayLengthSpreadMin": spread and round(spread, 1)}
    json.dump(result, open(args.out, "w", encoding="utf-8"), ensure_ascii=False, indent=1)
    print(f"{len(result)} of {len(places)} places with verified coordinates")
    for name, why in failed:
        print("FAILED", name, why)
    for name, why in suspect:
        print("SUSPECT (coordinates exact, table does not fit them)", name, why)


if __name__ == "__main__":
    main()
