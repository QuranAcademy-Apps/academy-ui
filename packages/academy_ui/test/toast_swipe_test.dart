import 'package:academy_ui/academy_ui.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';

final toast = find.byKey(const ValueKey('academy-toast'));

Future<BuildContext> host(WidgetTester tester, {bool reduced = false}) async {
  tester.view.physicalSize = const Size(390, 844);
  tester.view.devicePixelRatio = 1;
  tester.view.padding = const FakeViewPadding(top: 44, bottom: 34);
  addTearDown(tester.view.reset);
  tester.platformDispatcher.accessibilityFeaturesTestValue =
      FakeAccessibilityFeatures(disableAnimations: reduced);
  addTearDown(tester.platformDispatcher.clearAccessibilityFeaturesTestValue);
  late BuildContext root;
  await tester.pumpWidget(
    AcademyApp(
      home: Builder(
        builder: (context) {
          root = context;
          return const SizedBox.expand();
        },
      ),
    ),
  );
  await tester.pumpAndSettle();
  return root;
}

Future<void> show(
  WidgetTester tester,
  BuildContext context,
  AcademyToastPosition position, {
  Duration duration = const Duration(seconds: 30),
  String message = 'Toast',
}) async {
  AcademyToastHost.show(
    context,
    message,
    position: position,
    duration: duration,
  );
  await tester.pumpAndSettle();
}

void main() {
  for (final position in AcademyToastPosition.values) {
    final outward = position == AcademyToastPosition.top ? -1.0 : 1.0;

    testWidgets(
      '$position ignores horizontal and opposite swipes, then dismisses toward its edge',
      (tester) async {
        final context = await host(tester);
        await show(tester, context, position);
        final origin = tester.getRect(toast);
        for (final delta in [const Offset(140, 0), Offset(0, -outward * 100)]) {
          final gesture = await tester.startGesture(origin.center);
          await gesture.moveBy(delta);
          await tester.pumpAndSettle();
          expect(tester.getRect(toast), origin);
          await gesture.up();
          await tester.pumpAndSettle();
          expect(toast, findsOneWidget);
          expect(tester.getRect(toast), origin);
        }
        await tester.drag(toast, Offset(0, outward * 100));
        await tester.pumpAndSettle();
        expect(toast, findsNothing);
        expect(tester.takeException(), isNull);
      },
    );

    testWidgets(
      '$position hold cannot drag sideways or beyond bounded outward travel',
      (tester) async {
        final context = await host(tester);
        await show(
          tester,
          context,
          position,
          duration: const Duration(seconds: 1),
        );
        final origin = tester.getRect(toast);
        final gesture = await tester.startGesture(origin.center);
        await tester.pump(const Duration(seconds: 2));
        expect(toast, findsOneWidget);
        await gesture.moveBy(Offset(30, outward * 50));
        await tester.pumpAndSettle();
        final partial = tester.getRect(toast);
        expect(partial.left, origin.left);
        expect((partial.top - origin.top) * outward, greaterThan(0));
        await gesture.moveBy(Offset(180, outward * 400));
        await tester.pumpAndSettle();
        final far = tester.getRect(toast);
        expect(far.left, origin.left);
        expect((far.top - origin.top) * outward, lessThanOrEqualTo(96));
        // Returning the finger to its starting point restores the original
        // position, rather than accumulating travel from earlier moves.
        await gesture.moveTo(origin.center);
        await tester.pumpAndSettle();
        expect(tester.getRect(toast), origin);
        await gesture.cancel();
        await tester.pumpAndSettle();
        expect(toast, findsOneWidget);
        await tester.pump(const Duration(seconds: 1));
        await tester.pumpAndSettle();
        expect(toast, findsNothing);
      },
    );

    testWidgets('$position short slow swipe returns to its original position', (
      tester,
    ) async {
      final context = await host(tester);
      await show(tester, context, position);
      final origin = tester.getRect(toast);
      final gesture = await tester.startGesture(origin.center);
      await gesture.moveBy(Offset(0, outward * 30));
      await tester.pumpAndSettle();
      expect(
        (tester.getRect(toast).top - origin.top) * outward,
        greaterThan(0),
      );
      await tester.pump(const Duration(milliseconds: 600));
      await gesture.up();
      await tester.pumpAndSettle();
      expect(toast, findsOneWidget);
      expect(tester.getRect(toast), origin);
    });

    testWidgets(
      '$position fast short swipe dismisses only in its outward direction',
      (tester) async {
        final context = await host(tester);
        await show(tester, context, position);
        Future<void> flick(double direction) async {
          final gesture = await tester.startGesture(tester.getCenter(toast));
          // Three display-frame samples model a short finger flick. The test
          // helper fling oversamples 40px into 50 events, making Flutter's
          // velocity history too short to pass its fling-distance threshold.
          for (var frame = 1; frame <= 3; frame++) {
            await gesture.moveBy(
              Offset(0, direction * 12),
              timeStamp: Duration(milliseconds: frame * 16),
            );
            await tester.pump(const Duration(milliseconds: 16));
          }
          await gesture.up(timeStamp: const Duration(milliseconds: 64));
        }

        await flick(-outward);
        await tester.pumpAndSettle();
        expect(toast, findsOneWidget);
        await flick(outward);
        await tester.pumpAndSettle();
        expect(toast, findsNothing);
      },
    );

    testWidgets('$position Reduce Motion keeps directional swipe dismissal', (
      tester,
    ) async {
      final context = await host(tester, reduced: true);
      await show(tester, context, position);
      await tester.drag(toast, Offset(0, -outward * 100));
      await tester.pumpAndSettle();
      expect(toast, findsOneWidget);
      await tester.drag(toast, Offset(0, outward * 100));
      await tester.pumpAndSettle();
      expect(toast, findsNothing);
    });
  }

  testWidgets(
    'replacing a toast during a swipe leaves the new toast untouched',
    (tester) async {
      final context = await host(tester);
      await show(
        tester,
        context,
        AcademyToastPosition.bottom,
        message: 'First',
      );
      final gesture = await tester.startGesture(tester.getCenter(toast));
      await gesture.moveBy(const Offset(0, 60));
      await tester.pumpAndSettle();
      AcademyToastHost.show(
        context,
        'Replacement',
        position: AcademyToastPosition.top,
      );
      await tester.pumpAndSettle();
      final newPosition = tester.getRect(toast);
      await gesture.moveBy(const Offset(0, -150));
      await gesture.up();
      await tester.pumpAndSettle();
      expect(find.text('Replacement'), findsOneWidget);
      expect(tester.getRect(toast), newPosition);
      expect(tester.takeException(), isNull);
    },
  );
}
