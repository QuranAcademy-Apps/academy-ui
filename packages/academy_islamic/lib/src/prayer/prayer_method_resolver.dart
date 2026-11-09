import 'prayer_settings.dart';

/// Method used where no region below matches (the Adhan reference default
/// for Europe, the Far East and the rest of the world).
const _fallback = PrayerMethod.muslimWorldLeague;

/// The method that is customary at [place]. Offline, by coarse boxes
/// (south, north, west, east); the first match wins, so small states come
/// before the large boxes around them.
///
/// shortcut: boxes are rough near borders (a few cities of a neighbour
/// fall in the wrong box). Upgrade path: a country code from reverse
/// geocoding, mapped to the same methods. The user can always override it.
PrayerMethod resolvePrayerMethod(PrayerLocation place) {
  for (final (south, north, west, east, method) in _regions) {
    if (place.latitude >= south &&
        place.latitude <= north &&
        place.longitude >= west &&
        place.longitude <= east) {
      return method;
    }
  }
  return _fallback;
}

const _regions = <(double, double, double, double, PrayerMethod)>[
  (24.4, 26.3, 50.6, 51.7, PrayerMethod.qatar),
  (28.4, 30.2, 46.5, 48.5, PrayerMethod.kuwait),
  (22.6, 26.2, 51.7, 56.5, PrayerMethod.dubai),
  // Singapore, peninsular Malaysia, Borneo (Malaysia, Brunei): MUIS/JAKIM.
  (1.1, 1.5, 103.6, 104.1, PrayerMethod.singapore),
  (0.8, 6.8, 99.6, 104.7, PrayerMethod.singapore),
  (0.8, 7.4, 109.5, 119.3, PrayerMethod.singapore),
  (-11.1, 6.1, 95.0, 141.0, PrayerMethod.indonesian),
  (29.1, 30.4, 34.9, 39.3, PrayerMethod.jordan),
  (30.4, 33.4, 35.55, 39.3, PrayerMethod.jordan),
  // Palestine, Lebanon, Syria, Iraq.
  (29.1, 36.5, 34.9, 46.0, PrayerMethod.egyptian),
  (22.0, 31.6, 24.7, 34.9, PrayerMethod.egyptian),
  (16.3, 29.0, 34.6, 55.8, PrayerMethod.ummAlQura),
  (36.0, 42.2, 26.0, 44.2, PrayerMethod.turkiye),
  (25.0, 39.8, 46.0, 48.9, PrayerMethod.tehran),
  (25.0, 37.5, 48.9, 61.5, PrayerMethod.tehran),
  // Afghanistan, Pakistan, India, Bangladesh, Nepal, Sri Lanka.
  (6.0, 38.5, 60.5, 97.5, PrayerMethod.karachi),
  (14.0, 72.0, -170.0, -52.0, PrayerMethod.northAmerica),
  (27.6, 35.95, -13.2, -1.7, PrayerMethod.morocco),
  (19.0, 37.2, -8.7, 8.3, PrayerMethod.algerian),
  (30.2, 37.6, 8.3, 11.7, PrayerMethod.tunisia),
  (36.9, 42.15, -9.6, -7.3, PrayerMethod.portugal),
  (42.3, 49.7, -5.2, 8.3, PrayerMethod.france),
  (49.7, 51.0, 1.5, 3.9, PrayerMethod.france),
  // Kaliningrad, then Russia and its neighbours east of 29.5°E.
  (54.2, 55.3, 19.6, 23.0, PrayerMethod.russia),
  (41.0, 82.0, 29.5, 87.0, PrayerMethod.russia),
  (49.5, 82.0, 87.0, 180.0, PrayerMethod.russia),
  (42.0, 49.5, 130.0, 180.0, PrayerMethod.russia),
];
