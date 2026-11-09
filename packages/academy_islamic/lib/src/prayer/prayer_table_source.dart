import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'prayer_table.dart';

/// Where the published tables come from. The app ships an asset source; a
/// remote one (a backend serving the same index and per-place files) plugs in
/// here without touching the repository or the screens.
abstract interface class PrayerTableSource {
  /// Every place with a table.
  Future<List<PrayerTablePlace>> loadIndex();

  /// The table of [place], or null when the source has none.
  Future<PrayerTable?> loadTable(PrayerTablePlace place);
}

/// Tables bundled with the app: `<root>/index.json` and one file per place.
class AssetPrayerTableSource implements PrayerTableSource {
  AssetPrayerTableSource(
    this._bundle, {
    this.root = 'packages/academy_islamic/assets/prayer_tables',
  });

  final AssetBundle _bundle;
  final String root;

  @override
  Future<List<PrayerTablePlace>> loadIndex() async {
    final index = jsonDecode(
      await _bundle.loadString('$root/index.json'),
    ) as Map<String, dynamic>;
    return [
      for (final place in index['places'] as List)
        PrayerTablePlace.fromJson(place as Map<String, dynamic>),
    ];
  }

  @override
  Future<PrayerTable?> loadTable(PrayerTablePlace place) async {
    try {
      final json = jsonDecode(
        await _bundle.loadString('$root/${place.file}'),
      ) as Map<String, dynamic>;
      return PrayerTable.fromJson(place, json);
    } on FlutterError {
      return null; // the file is not in the bundle
    }
  }
}
