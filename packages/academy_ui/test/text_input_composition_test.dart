import 'package:academy_ui/academy_ui.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  for (final direction in TextDirection.values) {
    testWidgets('input variants and accessories fit large text in $direction', (
      tester,
    ) async {
      final controller = TextEditingController();
      addTearDown(controller.dispose);
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(320, 844);
      addTearDown(tester.view.reset);
      var accessoryTaps = 0;
      await tester.pumpWidget(
        AcademyApp(
          home: Builder(
            builder: (context) => MediaQuery(
              data: MediaQuery.of(context)
                  .copyWith(textScaler: const TextScaler.linear(2)),
              child: Directionality(
                textDirection: direction,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      AcademyTextField(
                        key: const ValueKey('plain'),
                        placeholder: 'Обычное поле',
                        leading: const Icon(
                          CupertinoIcons.person,
                          key: ValueKey('leading'),
                        ),
                        trailing: CupertinoButton(
                          key: const ValueKey('trailing'),
                          padding: EdgeInsets.zero,
                          onPressed: () => accessoryTaps++,
                          child: const Icon(CupertinoIcons.checkmark),
                        ),
                      ),
                      const AcademyField(
                        label: 'Имя',
                        placeholder: 'Введите имя',
                      ),
                      AcademySearchBar(controller: controller),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      for (final field in tester.widgetList<CupertinoTextField>(
        find.byType(CupertinoTextField),
      )) {
        if (field.controller == controller) {
          expect(field.decoration, const BoxDecoration());
        } else {
          expect(
            field.decoration!.borderRadius,
            BorderRadius.circular(AcademyRadii.defaultField),
          );
        }
      }
      final chrome = tester.widget<AcademyChrome>(
        find.descendant(
          of: find.byType(AcademySearchBar),
          matching: find.byType(AcademyChrome),
        ),
      );
      expect(chrome.radius, AcademyRadii.defaultField);
      final plain = find.byKey(const ValueKey('plain'));
      final editor = find.descendant(
        of: plain,
        matching: find.byType(EditableText),
      );
      final leading = tester
          .getCenter(find.byKey(const ValueKey('leading')))
          .dx;
      final trailing = tester
          .getCenter(find.byKey(const ValueKey('trailing')))
          .dx;
      final text = tester.getCenter(editor).dx;
      expect(
        direction == TextDirection.ltr
            ? leading < text && trailing > text
            : leading > text && trailing < text,
        isTrue,
      );
      final labelledEditor = find.descendant(
        of: find.byType(AcademyField),
        matching: find.byType(CupertinoTextField),
      );
      expect(
        tester.getBottomLeft(find.text('Имя')).dy,
        lessThan(tester.getTopLeft(labelledEditor).dy),
      );
      await tester.tap(find.byKey(const ValueKey('trailing')));
      expect(accessoryTaps, 1);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox());
    });
  }

  testWidgets(
    'base safely swaps caller-owned controller and focus, and read-only cannot clear',
    (tester) async {
      final first = TextEditingController(text: 'First');
      final second = TextEditingController(text: 'Second');
      final firstFocus = FocusNode();
      final secondFocus = FocusNode();
      addTearDown(first.dispose);
      addTearDown(second.dispose);
      addTearDown(firstFocus.dispose);
      addTearDown(secondFocus.dispose);
      final state = ValueNotifier(0);
      addTearDown(state.dispose);
      var changes = 0;
      await tester.pumpWidget(
        AcademyApp(
          home: ValueListenableBuilder<int>(
            valueListenable: state,
            builder: (_, revision, _) => Center(
              child: SizedBox(
                width: 300,
                child: AcademyTextInput(
                  controller: revision == 0 ? first : second,
                  focusNode: revision == 0 ? firstFocus : secondFocus,
                  semanticLabel: 'Value',
                  readOnly: revision == 2,
                  cornerRadius: 16,
                  onChanged: (_) => changes++,
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      firstFocus.requestFocus();
      await tester.pumpAndSettle();
      state.value = 1;
      await tester.pumpAndSettle();
      first.text = 'Detached';
      firstFocus.requestFocus();
      await tester.pumpAndSettle();
      expect(find.text('Second'), findsOneWidget);
      expect(
        tester
            .widget<CupertinoTextField>(find.byType(CupertinoTextField))
            .decoration!
            .borderRadius,
        BorderRadius.circular(16),
      );
      state.value = 2;
      await tester.pumpAndSettle();
      expect(
        tester
            .widget<CupertinoTextField>(find.byType(CupertinoTextField))
            .readOnly,
        isTrue,
      );
      final clearButton = find.descendant(
        of: find.bySemanticsLabel('Очистить Value'),
        matching: find.byType(CupertinoButton),
      );
      expect(tester.widget<CupertinoButton>(clearButton).onPressed, isNull);
      await tester.tap(clearButton, warnIfMissed: false);
      expect(second.text, 'Second');
      expect(changes, 0);
      await tester.pumpWidget(const SizedBox());
      first.text = 'Alive';
      second.text = 'Also alive';
      firstFocus.addListener(() {});
      secondFocus.addListener(() {});
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'search keeps cancel behavior with shared input and custom accessories',
    (tester) async {
      final controller = TextEditingController();
      final focus = FocusNode();
      addTearDown(controller.dispose);
      addTearDown(focus.dispose);
      final changes = <String>[];
      var cancelled = 0;
      await tester.pumpWidget(
        AcademyApp(
          home: Center(
            child: SizedBox(
              width: 300,
              child: AcademySearchBar(
                controller: controller,
                focusNode: focus,
                leading: const Icon(CupertinoIcons.book),
                trailing: const Icon(CupertinoIcons.checkmark),
                onChanged: changes.add,
                onCancel: () => cancelled++,
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(CupertinoTextField), 'query');
      await tester.pumpAndSettle();
      expect(find.byIcon(CupertinoIcons.book), findsOneWidget);
      expect(find.byIcon(CupertinoIcons.checkmark), findsOneWidget);
      expect(focus.hasFocus, isTrue);
      await tester.tap(
        find.byWidgetPredicate(
          (w) => w is AcademyChromeButton && w.label == 'Закрыть поиск',
        ),
      );
      await tester.pumpAndSettle();
      expect(changes, ['query', '']);
      expect(cancelled, 1);
      expect(controller.text, isEmpty);
      expect(focus.hasFocus, isFalse);
      await tester.pumpWidget(const SizedBox());
      controller.text = 'Still alive';
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('search border stays unchanged on focus, input and blur', (
    tester,
  ) async {
    final controller = TextEditingController();
    final focus = FocusNode();
    addTearDown(controller.dispose);
    addTearDown(focus.dispose);
    await tester.pumpWidget(
      AcademyApp(
        home: Center(
          child: SizedBox(
            width: 300,
            child: AcademySearchBar(controller: controller, focusNode: focus),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    BoxDecoration decoration() =>
        tester
                .widget<DecoratedBox>(
                  find
                      .descendant(
                        of: find.byType(AcademyChrome),
                        matching: find.byType(DecoratedBox),
                      )
                      .first,
                )
                .decoration
            as BoxDecoration;
    final initial = decoration();
    final geometry = tester.getRect(find.byType(EditableText));
    await tester.tap(find.byType(CupertinoTextField));
    await tester.pumpAndSettle();
    expect(focus.hasFocus, isTrue);
    expect(decoration(), initial);
    await tester.enterText(find.byType(CupertinoTextField), 'query');
    await tester.pumpAndSettle();
    expect(decoration(), initial);
    focus.unfocus();
    await tester.pumpAndSettle();
    expect(decoration(), initial);
    expect(tester.getRect(find.byType(EditableText)), geometry);
  });

  testWidgets(
    'shared segmented control keeps both shapes and selection behavior',
    (tester) async {
      var selected = 0;
      await tester.pumpWidget(
        AcademyApp(
          home: Center(
            child: SizedBox(
              width: 300,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AcademySegmentedControl<int>(
                    items: const [0, 1],
                    value: 0,
                    labelFor: (i) => 'Pill $i',
                    onChanged: (i) => selected = i,
                  ),
                  AcademySegmentedControl<int>.compact(
                    items: const [0, 1],
                    value: 0,
                    labelFor: (i) => 'Compact $i',
                    onChanged: (i) => selected = i,
                  ),
                  AcademySegmentedControl<int>(
                    key: const ValueKey('custom'),
                    items: const [0, 1],
                    value: 0,
                    labelFor: (i) => 'Custom $i',
                    onChanged: null,
                    cornerRadius: 24,
                    selectionCornerRadius: 20,
                  ),
                ],
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      List<BorderRadiusGeometry?> radii(Finder of) => tester
          .widgetList<DecoratedBox>(
            find.descendant(of: of, matching: find.byType(DecoratedBox)),
          )
          .map((w) => w.decoration)
          .whereType<BoxDecoration>()
          .map((d) => d.borderRadius)
          .toList();
      final controls = find.byType(AcademySegmentedControl<int>);
      expect(radii(controls.at(0)), [
        BorderRadius.circular(16),
        BorderRadius.circular(14),
      ]);
      expect(radii(controls.at(1)), [
        BorderRadius.circular(8),
        BorderRadius.circular(7),
      ]);
      expect(radii(find.byKey(const ValueKey('custom'))), [
        BorderRadius.circular(24),
        BorderRadius.circular(20),
      ]);
      await tester.tap(find.text('Compact 1'));
      expect(selected, 1);
      await tester.tap(find.text('Pill 0'));
      expect(selected, 1); // An already selected segment does not notify again.
      expect(tester.takeException(), isNull);
    },
  );
}
