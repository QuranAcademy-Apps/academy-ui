
import 'package:flutter_test/flutter_test.dart';
import 'package:academy_islamic/academy_islamic.dart';

/// Records every write; fails the first one when [failFirst].
class _RecordingStore extends MemoryKeyValueStore {
  _RecordingStore({this.failFirst = false});

  final bool failFirst;
  final writes = <String>[];
  var _failed = false;

  @override
  Future<void> write(String key, String value) async {
    if (failFirst && !_failed) {
      _failed = true;
      throw StateError('disk full');
    }
    writes.add(value);
    await super.write(key, value);
  }
}

void main() {
  group('PersistedJson', () {
    test('a failed write does not drop the later ones', () async {
      final store = _RecordingStore(failFirst: true);
      final json = PersistedJson(store, 'k');
      json.write({'v': 1});
      await json.flushed;
      json.write({'v': 2});
      await json.flushed;
      expect(await store.readJson('k'), {'v': 2});
    });

    test('a burst of snapshots is written once, the newest', () async {
      final store = _RecordingStore();
      final json = PersistedJson(store, 'k');
      for (var v = 1; v <= 5; v++) {
        json.write({'v': v});
      }
      await json.flushed;
      expect(store.writes, ['{"v":5}']);
    });
  });

  group('PersistedNotifier', () {
    test('saves only real changes', () async {
      final store = MemoryKeyValueStore();
      final value = PersistedNotifier<int>(
        store,
        'k',
        0,
        toJson: (v) => {'v': v},
      );
      expect(value.update((v) => v), isFalse);
      await value.flushed;
      expect(store.values, isEmpty);
      expect(value.update((v) => v + 1), isTrue);
      await value.flushed;
      expect(await store.readJson('k'), {'v': 1});
      value.dispose();
    });
  });
}
