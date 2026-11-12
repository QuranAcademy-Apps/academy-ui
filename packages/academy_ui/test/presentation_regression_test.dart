import 'package:academy_ui/academy_ui.dart';
import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stupid_simple_sheet/stupid_simple_sheet.dart';

void phone(WidgetTester tester) {
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = const Size(390, 844);
  tester.view.padding = const FakeViewPadding(top: 44, bottom: 34);
  tester.view.viewPadding = const FakeViewPadding(top: 44, bottom: 34);
  addTearDown(tester.view.reset);
}

Rect popupRect(WidgetTester tester, String text) => tester.getRect(
  find.ancestor(of: find.text(text), matching: find.byType(ClipRRect)).first,
);

void main() {
  for (final placement in [
    AcademyPopoverPlacement.above,
    AcademyPopoverPlacement.below,
  ]) {
    testWidgets('autocomplete respects $placement and keeps both input edges', (
      tester,
    ) async {
      phone(tester);
      await tester.pumpWidget(
        AcademyApp(
          home: Center(
            child: SizedBox(
              width: 340,
              child: AcademyAutocomplete<String>(
                label: 'Search',
                placement: placement,
                options: const [
                  AcademySelectOption(value: 'a', label: 'Audio'),
                ],
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.byType(CupertinoTextField));
      await tester.pumpAndSettle();
      final field = tester.getRect(find.byType(CupertinoTextField));
      final popup = popupRect(tester, 'Audio');
      expect(popup.left, closeTo(field.left, .01));
      expect(popup.right, closeTo(field.right, .01));
      if (placement == AcademyPopoverPlacement.above) {
        expect(popup.bottom, closeTo(field.top - 8, .01));
      } else {
        expect(popup.top, closeTo(field.bottom + 8, .01));
      }
      expect(tester.takeException(), isNull);
    });
  }

  for (final direction in TextDirection.values) {
    for (final placement in [
      AcademyPopoverPlacement.start,
      AcademyPopoverPlacement.end,
    ]) {
      testWidgets('side hint $placement follows $direction', (tester) async {
        phone(tester);
        final control = AcademyPopoverController();
        addTearDown(control.dispose);
        await tester.pumpWidget(
          AcademyApp(
            home: Directionality(
              textDirection: direction,
              child: Center(
                child: AcademyPopover(
                  controller: control,
                  placement: placement,
                  width: 100,
                  builder: (_, _) => const SizedBox(
                    key: ValueKey('anchor'),
                    width: 44,
                    height: 44,
                  ),
                  contentBuilder: (_, _) => const Padding(
                    padding: EdgeInsets.all(12),
                    child: Text('Hint'),
                  ),
                ),
              ),
            ),
          ),
        );
        control.show();
        await tester.pumpAndSettle();
        final anchor = tester.getRect(find.byKey(const ValueKey('anchor')));
        final popup = popupRect(tester, 'Hint');
        final right =
            (placement == AcademyPopoverPlacement.end) ==
            (direction == TextDirection.ltr);
        expect(
          right ? popup.left : popup.right,
          closeTo(right ? anchor.right + 8 : anchor.left - 8, .01),
        );
        expect(popup.center.dy, closeTo(anchor.center.dy, .01));
        expect(tester.takeException(), isNull);
      });
    }
  }

  testWidgets('preferred lower popup moves above the software keyboard', (
    tester,
  ) async {
    phone(tester);
    await tester.pumpWidget(
      AcademyApp(
        home: Align(
          alignment: const Alignment(0, .25),
          child: SizedBox(
            width: 340,
            child: AcademyAutocomplete<String>(
              label: 'Search',
              placement: AcademyPopoverPlacement.below,
              options: const [AcademySelectOption(value: 'a', label: 'Audio')],
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.byType(CupertinoTextField));
    await tester.pumpAndSettle();
    tester.view.viewInsets = const FakeViewPadding(bottom: 290);
    await tester.pumpAndSettle();
    final field = tester.getRect(find.byType(CupertinoTextField));
    final popup = popupRect(tester, 'Audio');
    expect(popup.bottom, lessThanOrEqualTo(field.top - 8));
    expect(popup.top, greaterThanOrEqualTo(52));
    expect(popup.bottom, lessThanOrEqualTo(844 - 290));
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'no match shows a useful state and results return after clearing',
    (tester) async {
      phone(tester);
      await tester.pumpWidget(
        AcademyApp(
          locale: const Locale('ru'),
          home: Center(
            child: AcademyAutocomplete<String>(
              label: 'Поиск',
              emptyHint: 'Попробуйте другое слово.',
              options: const [AcademySelectOption(value: 'a', label: 'Аудио')],
            ),
          ),
        ),
      );
      await tester.enterText(find.byType(CupertinoTextField), 'zzzz');
      await tester.pumpAndSettle();
      expect(find.text('Ничего не найдено'), findsOneWidget);
      expect(find.text('Попробуйте другое слово.'), findsOneWidget);
      expect(find.text('Аудио'), findsNothing);
      await tester.enterText(find.byType(CupertinoTextField), '');
      await tester.pumpAndSettle();
      expect(find.text('Аудио'), findsOneWidget);
      expect(find.text('Ничего не найдено'), findsNothing);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('default modal has one position; lists explicitly request two', (
    tester,
  ) async {
    phone(tester);
    late BuildContext root;
    StupidSimpleSheetController<dynamic>? sheet;
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
    Widget body(BuildContext context) {
      sheet = StupidSimpleSheetController.maybeOf<dynamic>(context);
      return const AcademyModalListView(children: [Text('Content')]);
    }

    showAcademyModal<void>(root, title: 'Content', builder: body);
    await tester.pumpAndSettle();
    expect(sheet!.effectiveSnappingConfig.points, hasLength(1));
    Navigator.of(root).pop();
    await tester.pumpAndSettle();
    showAcademyModal<void>(
      root,
      title: 'List',
      builder: body,
      detents: const [ModalSheetDetent.medium, ModalSheetDetent.large],
    );
    await tester.pumpAndSettle();
    expect(sheet!.effectiveSnappingConfig.points, hasLength(2));
  });

  for (final scale in [1.0, 2.0]) {
    testWidgets(
      'confirmation fits its content at scale $scale and returns cancellation',
      (tester) async {
        phone(tester);
        tester.platformDispatcher.textScaleFactorTestValue = scale;
        addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
        late BuildContext root;
        await tester.pumpWidget(
          AcademyApp(
            locale: const Locale('en'),
            home: Builder(
              builder: (context) {
                root = context;
                return const SizedBox.expand();
              },
            ),
          ),
        );
        bool? result;
        showAcademyConfirmation(
          root,
          title: 'Continue?',
          message: 'Confirm this action.',
          confirmLabel: 'Continue',
          cancelLabel: 'Cancel',
        ).then((value) => result = value);
        await tester.pumpAndSettle();
        final context = tester.element(find.byType(AcademyModalListView));
        final sheet = StupidSimpleSheetController.maybeOf<dynamic>(context)!;
        expect(sheet.effectiveSnappingConfig.points, hasLength(1));
        expect(find.text('Continue').hitTestable(), findsOneWidget);
        expect(find.text('Cancel').hitTestable(), findsOneWidget);
        expect(
          tester.getRect(find.text('Cancel')).bottom,
          lessThanOrEqualTo(844 - 34),
        );
        await tester.tap(find.text('Cancel'));
        await tester.pumpAndSettle();
        expect(result, false);
        expect(tester.takeException(), isNull);
      },
    );
  }

  for (final date in [true, false]) {
    for (final scale in [1.0, 2.0]) {
      testWidgets(
        '${date ? 'date' : 'time'} uses one compact detent at scale $scale and survives rotation',
        (tester) async {
          phone(tester);
          tester.platformDispatcher.textScaleFactorTestValue = scale;
          addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
          await tester.pumpWidget(
            AcademyApp(
              locale: const Locale('en'),
              home: Center(
                child: date
                    ? AcademyDateInput(
                        label: 'Date',
                        value: DateTime(2026, 10, 2),
                        onChanged: (_) {},
                      )
                    : AcademyTimeField(
                        label: 'Time',
                        value: const AcademyTime(9, 30),
                        onChanged: (_) {},
                      ),
              ),
            ),
          );
          await tester.tap(find.byType(AcademyPickerInput));
          await tester.pumpAndSettle();
          final context = tester.element(find.byType(CupertinoDatePicker));
          final sheet = StupidSimpleSheetController.maybeOf<dynamic>(context)!;
          expect(sheet.effectiveSnappingConfig.points, hasLength(1));
          final top = tester.getRect(find.byType(AcademyModalScaffold)).top;
          expect(top, greaterThan(300));
          final done = find.widgetWithText(CupertinoButton, 'Done');
          expect(done.hitTestable(), findsOneWidget);
          expect(tester.getRect(done).bottom, lessThanOrEqualTo(844 - 34));
          await tester.drag(
            find.byType(AcademyChromeModalHeader),
            const Offset(0, -120),
          );
          await tester.pumpAndSettle();
          expect(
            tester.getRect(find.byType(AcademyModalScaffold)).top,
            closeTo(top, 1),
          );
          tester.view.physicalSize = const Size(844, 390);
          await tester.pumpAndSettle();
          expect(sheet.effectiveSnappingConfig.points, hasLength(1));
          tester.view.physicalSize = const Size(390, 844);
          await tester.pumpAndSettle();
          expect(sheet.effectiveSnappingConfig.points, hasLength(1));
          expect(
            tester.getRect(find.byType(AcademyModalScaffold)).top,
            closeTo(top, 1),
          );
          expect(done.hitTestable(), findsOneWidget);
          expect(tester.takeException(), isNull);
        },
      );
    }
  }
}
