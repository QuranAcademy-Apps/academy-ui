import 'dart:async';

import 'package:academy_ui/academy_ui.dart';
import 'package:flutter_test/flutter_test.dart';

class FakeStore implements AcademyAppearanceStore {
  final readGate = Completer<AcademyAppearance?>();
  final writes = <AcademyAppearance>[];
  final gates = <Completer<void>>[];
  @override
  Future<AcademyAppearance?> read() => readGate.future;
  @override
  Future<void> write(AcademyAppearance appearance) {
    writes.add(appearance);
    final gate = Completer<void>();
    gates.add(gate);
    return gate.future;
  }
}

void main() {
  test('load cannot overwrite edits; accepted writes serialize and finish after dispose', () async {
    final store = FakeStore();
    final controller = AcademyAppearanceController(store: store);
    controller.update(
      const AcademyAppearance(mode: AcademyAppearanceMode.dark),
    );
    expect(controller.value.mode, AcademyAppearanceMode.system);
    store.readGate.complete(
      const AcademyAppearance(mode: AcademyAppearanceMode.light),
    );
    await controller.ready;
    controller.update(
      const AcademyAppearance(mode: AcademyAppearanceMode.dark),
    );
    controller.update(
      const AcademyAppearance(mode: AcademyAppearanceMode.system),
    );
    await Future<void>.delayed(Duration.zero);
    expect(store.writes.length, 1);
    controller.dispose();
    store.gates.first.complete();
    await Future<void>.delayed(Duration.zero);
    expect(store.writes.length, 2);
    store.gates.last.complete();
    await controller.flushed;
  });

  test(
    'persistence failures are observable without unhandled futures',
    () async {
      final store = FakeStore();
      final controller = AcademyAppearanceController(store: store);
      store.readGate.complete(null);
      await controller.ready;
      controller.update(const AcademyAppearance());
      await Future<void>.delayed(Duration.zero);
      store.gates.first.completeError(StateError('write failed'));
      await controller.flushed;
      expect(controller.persistenceError, isA<StateError>());
      controller.dispose();
    },
  );
}
