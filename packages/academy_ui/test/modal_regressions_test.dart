import 'package:academy_ui/academy_ui.dart';
import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:flutter_test/flutter_test.dart';

// Regressions found while moving Yalla's sheets onto showAcademyModal
// (2026-11-02):
// - with a non-zero top safe area every detent showed only
//   (screen - top) / screen of its height (package tests had no safe area);
// - Reduce Motion gave the sheet spring a zero duration and asserted;
// - a nested navigator's route focus expanded the sheet like a text field;
// - the scroll inset kept the home-indicator gap under the keyboard.

void main() {
  testWidgets('pinned content meets the keyboard without a safe-area gap', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    tester.view.padding = const FakeViewPadding(top: 59, bottom: 34);
    tester.view.viewInsets = const FakeViewPadding(bottom: 300);
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      AcademyApp(
        home: Builder(
          builder: (context) => CupertinoButton(
            onPressed: () => showAcademyModal<void>(
              context,
              title: 'Лист',
              initiallyExpanded: true,
              builder: (_) => const _Body(),
            ),
            child: const Text('open'),
          ),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    expect(
      tester.getBottomLeft(find.byKey(const ValueKey('pinned'))).dy,
      closeTo(844 - 300, .5),
    );
  });

  testWidgets('nested navigation rests at its detent; text focus expands', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final field = FocusNode();
    addTearDown(field.dispose);
    await tester.pumpWidget(
      AcademyApp(
        home: Builder(
          builder: (context) => CupertinoButton(
            onPressed: () => showAcademyModal<void>(
              context,
              title: 'Лист',
              nestedNavigation: true,
              detents: const [ModalSheetDetent.medium, ModalSheetDetent.full],
              builder: (_) => CupertinoTextField(focusNode: field),
            ),
            child: const Text('open'),
          ),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    expect(
      tester.getTopLeft(find.byType(AcademyModalScaffold)).dy,
      closeTo(422, .5),
    );
    field.requestFocus();
    await tester.pumpAndSettle();
    expect(tester.getTopLeft(find.byType(AcademyModalScaffold)).dy, 0);
  });

  testWidgets('modal opens and closes with Reduce Motion', (tester) async {
    await tester.pumpWidget(
      MediaQuery(
        data: const MediaQueryData(disableAnimations: true),
        child: AcademyApp(
          home: Builder(
            builder: (context) => CupertinoButton(
              onPressed: () => showAcademyModal<void>(
                context,
                title: 'Лист',
                builder: (_) => const Text('Содержимое'),
              ),
              child: const Text('open'),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    expect(find.text('Содержимое'), findsOneWidget);
    await tester.tap(
      find.byWidgetPredicate(
        (w) => w is AcademyChromeButton && w.label == 'Закрыть',
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Содержимое'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  for (final (name, expectedTop, open) in [
    (
      'medium',
      844 / 2,
      (BuildContext context) => showAcademyModal<void>(
        context,
        title: 'Лист',
        detents: const [ModalSheetDetent.medium, ModalSheetDetent.full],
        builder: (_) => const _Body(),
      ),
    ),
    (
      'full',
      59.0,
      (BuildContext context) => showAcademyModal<void>(
        context,
        title: 'Лист',
        initiallyExpanded: true,
        builder: (_) => const _Body(),
      ),
    ),
    (
      'auto',
      844 - 400.0,
      (BuildContext context) => showAcademyModal<void>(
        context,
        title: 'Лист',
        autoHeight: 400,
        builder: (_) => const _Body(),
      ),
    ),
  ]) {
    testWidgets('$name detent keeps its height under a notch', (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1;
      tester.view.padding = const FakeViewPadding(top: 59, bottom: 34);
      addTearDown(tester.view.reset);
      await tester.pumpWidget(
        AcademyApp(
          home: Builder(
            builder: (context) => CupertinoButton(
              onPressed: () => open(context),
              child: const Text('open'),
            ),
          ),
        ),
      );
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();
      expect(
        tester.getTopLeft(find.byType(AcademyModalScaffold)).dy,
        closeTo(expectedTop, .5),
      );
      // Content pinned with the scroll inset sits right above the home
      // indicator, whatever the resting height.
      expect(
        tester.getBottomLeft(find.byKey(const ValueKey('pinned'))).dy,
        closeTo(844 - 34, .5),
      );
    });
  }
}

class _Body extends StatelessWidget {
  const _Body();
  @override
  Widget build(BuildContext context) => Stack(
    children: [
      Positioned(
        left: 0,
        right: 0,
        bottom: ModalSheetScrollInsets.of(context),
        child: const SizedBox(key: ValueKey('pinned'), height: 20),
      ),
    ],
  );
}
