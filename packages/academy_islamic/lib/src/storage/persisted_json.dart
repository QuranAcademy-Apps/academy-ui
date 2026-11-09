import 'package:flutter/foundation.dart';

import 'key_value_store.dart';

/// Serialized JSON writes of one storage key. Writes run one after another; a
/// snapshot waiting behind a running write is replaced by a newer one, so a
/// burst of changes ends in one write of the latest value. A failed write is
/// logged and does not block the later ones.
class PersistedJson {
  PersistedJson(this._store, this.key);

  final KeyValueStore _store;
  final String key;
  Future<void> _writes = Future.value();
  Map<String, dynamic>? _queued;

  Future<Map<String, dynamic>?> read() => _store.readJson(key);

  void write(Map<String, dynamic> snapshot) {
    final waiting = _queued != null;
    _queued = snapshot;
    if (waiting) return;
    _writes = _writes.then((_) async {
      final next = _queued!;
      _queued = null;
      try {
        await _store.writeJson(key, next);
      } on Object catch (error) {
        debugPrint('Storage $key not written: $error');
      }
    });
  }

  /// Completes after pending writes; used by tests and app shutdown.
  Future<void> get flushed => _writes;
}

/// A value published to listeners and saved as JSON under [key] whenever
/// [update] changes it.
class PersistedNotifier<T> {
  PersistedNotifier(
    KeyValueStore store,
    String key,
    T initial, {
    required this._toJson,
  }) : _json = PersistedJson(store, key),
       _value = ValueNotifier(initial);

  final PersistedJson _json;
  final Map<String, dynamic> Function(T value) _toJson;
  final ValueNotifier<T> _value;

  ValueListenable<T> get listenable => _value;

  T get value => _value.value;

  /// Publishes [value] without saving it (restored or derived state).
  set value(T value) => _value.value = value;

  Future<Map<String, dynamic>?> read() => _json.read();

  /// Applies [change]; publishes and saves only when the value differs.
  /// Returns whether it did.
  bool update(T Function(T current) change) {
    final next = change(_value.value);
    if (next == _value.value) return false;
    _value.value = next;
    _json.write(_toJson(next));
    return true;
  }

  Future<void> get flushed => _json.flushed;

  void dispose() => _value.dispose();
}
