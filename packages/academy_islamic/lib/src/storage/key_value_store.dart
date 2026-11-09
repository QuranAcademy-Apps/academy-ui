import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

/// Minimal persistent string storage; JSON helpers on top.
abstract interface class KeyValueStore {
  Future<String?> read(String key);
  Future<void> write(String key, String value);
}

extension KeyValueStoreJson on KeyValueStore {
  Future<Map<String, dynamic>?> readJson(String key) async {
    final raw = await read(key);
    if (raw == null) return null;
    try {
      return jsonDecode(raw) as Map<String, dynamic>;
    } on FormatException {
      return null;
    }
  }

  Future<void> writeJson(String key, Map<String, dynamic> value) =>
      write(key, jsonEncode(value));
}

class PreferencesKeyValueStore implements KeyValueStore {
  final _preferences = SharedPreferencesAsync();

  @override
  Future<String?> read(String key) => _preferences.getString(key);

  @override
  Future<void> write(String key, String value) =>
      _preferences.setString(key, value);
}

/// Test and preview store.
class MemoryKeyValueStore implements KeyValueStore {
  MemoryKeyValueStore([Map<String, String>? values]) : values = values ?? {};
  final Map<String, String> values;

  @override
  Future<String?> read(String key) async => values[key];

  @override
  Future<void> write(String key, String value) async => values[key] = value;
}
