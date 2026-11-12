import 'package:academy_ui/academy_ui.dart';
import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

double paintedScale(WidgetTester tester) {
  var scale = 1.0;
  void visit(Layer layer) {
    if (layer is TransformLayer) {
      final value = layer.transform!.entry(0, 0);
      if (value > 0 && value < scale) scale = value;
    }
    if (layer is ContainerLayer) {
      for (
        Layer? child = layer.firstChild;
        child != null;
        child = child.nextSibling
      ) {
        visit(child);
      }
    }
  }

  visit(tester.binding.renderViews.single.debugLayer!);
  return scale;
}

Future<void> host(WidgetTester tester, Widget child) async {
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = const Size(390, 844);
  addTearDown(tester.view.reset);
  await tester.pumpWidget(AcademyApp(home: Center(child: child)));
  await tester.pumpAndSettle();
}

void main() {
  final variants = <String, Widget Function(VoidCallback)>{
    'primary': (action) => SizedBox(
      width: 360,
      child: AcademyButton(label: 'Action', onPressed: action),
    ),
    'tinted': (action) => SizedBox(
      width: 360,
      child: AcademyButton(
        label: 'Action',
        style: AcademyButtonStyle.tinted,
        onPressed: action,
      ),
    ),
    'text': (action) => AcademyTextButton(label: 'Action', onPressed: action),
    'icon': (action) => AcademyIconButton(
      label: 'Action',
      icon: AcademySymbols.info,
      onPressed: action,
    ),
    'compact': (action) =>
        AcademyCompactIconButton(label: 'Action', onPressed: action),
  };
  for (final variant in variants.entries) {
    testWidgets(
      '${variant.key} shrinks on contact, keeps its hit area and activates once',
      (tester) async {
        var calls = 0;
        await host(tester, variant.value(() => calls++));
        final button = find.byType(CupertinoButton);
        final before = tester.getRect(button);
        // The pointer is inside the original hit area but outside the shrunken
        // painted surface, so this also catches accidental hit-target shrinkage.
        final gesture = await tester.startGesture(
          Offset(before.left + .5, before.center.dy),
        );
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 120));
        expect(paintedScale(tester), lessThan(1));
        expect(paintedScale(tester), greaterThanOrEqualTo(.97));
        expect(
          before.longestSide * (1 - paintedScale(tester)),
          lessThanOrEqualTo(5.001),
        );
        expect(tester.getRect(button), before);
        expect(calls, 0);
        await gesture.up();
        await tester.pumpAndSettle();
        expect(paintedScale(tester), 1);
        expect(calls, 1);
        expect(tester.takeException(), isNull);
      },
    );
  }

  testWidgets('cancelled contact returns to rest without activating', (
    tester,
  ) async {
    var calls = 0;
    await host(
      tester,
      AcademyButton(label: 'Action', onPressed: () => calls++),
    );
    final gesture = await tester.startGesture(
      tester.getCenter(find.byType(CupertinoButton)),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 120));
    expect(paintedScale(tester), lessThan(1));
    await gesture.cancel();
    await tester.pumpAndSettle();
    expect(paintedScale(tester), 1);
    expect(calls, 0);
  });

  testWidgets('scrolling through a button cancels the scale and its action', (
    tester,
  ) async {
    var calls = 0;
    await host(
      tester,
      SizedBox(
        width: 360,
        height: 500,
        child: ListView(
          children: [
            AcademyButton(label: 'Action', onPressed: () => calls++),
            const SizedBox(height: 1000),
          ],
        ),
      ),
    );
    final gesture = await tester.startGesture(
      tester.getCenter(find.byType(CupertinoButton)),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 120));
    expect(paintedScale(tester), lessThan(1));
    await gesture.moveBy(const Offset(0, -50));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 120));
    expect(paintedScale(tester), 1);
    await gesture.up();
    await tester.pumpAndSettle();
    expect(calls, 0);
  });

  testWidgets(
    'disabling during contact resets feedback and prevents activation',
    (tester) async {
      var calls = 0;
      final enabled = ValueNotifier(true);
      addTearDown(enabled.dispose);
      await host(
        tester,
        ValueListenableBuilder<bool>(
          valueListenable: enabled,
          builder: (_, value, _) => AcademyButton(
            label: 'Action',
            onPressed: value ? () => calls++ : null,
          ),
        ),
      );
      final gesture = await tester.startGesture(
        tester.getCenter(find.byType(CupertinoButton)),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 120));
      expect(paintedScale(tester), lessThan(1));
      enabled.value = false;
      await tester.pumpAndSettle();
      expect(paintedScale(tester), 1);
      await gesture.up();
      await tester.pumpAndSettle();
      expect(calls, 0);
    },
  );

  testWidgets(
    'Reduce Motion stops the scale and leaves native activation working',
    (tester) async {
      var calls = 0;
      final reduced = ValueNotifier(false);
      addTearDown(reduced.dispose);
      await host(
        tester,
        ValueListenableBuilder<bool>(
          valueListenable: reduced,
          builder: (context, value, _) => MediaQuery(
            data: MediaQuery.of(context).copyWith(disableAnimations: value),
            child: AcademyButton(label: 'Action', onPressed: () => calls++),
          ),
        ),
      );
      final gesture = await tester.startGesture(
        tester.getCenter(find.byType(CupertinoButton)),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 120));
      expect(paintedScale(tester), lessThan(1));
      reduced.value = true;
      await tester.pumpAndSettle();
      expect(paintedScale(tester), 1);
      await gesture.up();
      await tester.pumpAndSettle();
      expect(calls, 1);
      await tester.tap(find.byType(CupertinoButton));
      await tester.pumpAndSettle();
      expect(calls, 2);
      expect(paintedScale(tester), 1);
    },
  );

  testWidgets('native keyboard activation still fires once', (tester) async {
    var calls = 0;
    await host(
      tester,
      AcademyButton(label: 'Action', onPressed: () => calls++),
    );
    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.pumpAndSettle();
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pumpAndSettle();
    expect(calls, 1);
  });
}
