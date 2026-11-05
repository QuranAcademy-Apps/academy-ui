import 'package:academy_ui/academy_ui.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('navigation search follows appearance without losing input', (
    tester,
  ) async {
    final appearance = AcademyAppearanceController(
      initial: const AcademyAppearance(
        mode: AcademyAppearanceMode.light,
        chromeStyle: AcademyChromeStyle.flat,
      ),
    );
    await appearance.ready;
    addTearDown(appearance.dispose);
    final search = TextEditingController();
    final contentSearch = TextEditingController();
    addTearDown(search.dispose);
    addTearDown(contentSearch.dispose);
    const searchKey = ValueKey('navigation-search');
    const buttonKey = ValueKey('navigation-button');
    await tester.pumpWidget(
      AcademyApp(
        appearance: appearance,
        colorsBuilder: (brightness, accent) =>
            AcademyPalette(brightness, accent).copyWith(
              surface: const Color(0xFFABCDEF),
              surfaceContainerHighest: const Color(0xFF998877),
              chromeSurface: brightness == Brightness.light
                  ? const Color(0xFFDBEACC)
                  : const Color(0xFF123456),
              chromeTintedSurface: const Color(0xFF556677),
              chromeGradientStart: const Color(0xFF223344),
              chromeGradientEnd: const Color(0xFF778899),
            ),
        home: Center(
          child: SizedBox(
            width: 320,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AcademySearchBar(key: searchKey, controller: search),
                AcademySearchBar(controller: contentSearch, chrome: false),
                const AcademyField(label: 'Name'),
                AcademyChromeButton(
                  key: buttonKey,
                  icon: AcademySymbols.search,
                  label: 'Navigation',
                  onPressed: () {},
                ),
              ],
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    final fieldFinder = find.descendant(
      of: find.byKey(searchKey),
      matching: find.byType(CupertinoTextField),
    );
    await tester.enterText(fieldFinder, 'query');
    const selection = TextSelection(baseOffset: 1, extentOffset: 4);
    search.selection = selection;
    BoxDecoration? background(Finder anchor) {
      final boxes = tester
          .widgetList<DecoratedBox>(
            find.descendant(of: anchor, matching: find.byType(DecoratedBox)),
          )
          .map((box) => box.decoration)
          .whereType<BoxDecoration>();
      return boxes.isEmpty ? null : boxes.first;
    }

    for (final mode in [
      AcademyAppearanceMode.light,
      AcademyAppearanceMode.dark,
    ]) {
      for (final style in AcademyChromeStyle.values) {
        appearance.update(
          appearance.value.copyWith(mode: mode, chromeStyle: style),
        );
        await tester.pumpAndSettle();
        final searchBackground = background(find.byKey(searchKey));
        final buttonBackground = background(find.byKey(buttonKey));
        // Glass lightens the top of a circular button on purpose, so only the
        // capsule material is compared with the button there.
        if (style != AcademyChromeStyle.glass) {
          expect(searchBackground?.color, buttonBackground?.color);
          expect(searchBackground?.gradient, buttonBackground?.gradient);
          expect(searchBackground?.border, buttonBackground?.border);
        }
        expect(
          find.descendant(
            of: find.byKey(searchKey),
            matching: find.byType(BackdropFilter),
          ),
          style == AcademyChromeStyle.blur || style == AcademyChromeStyle.glass
              ? findsOneWidget
              : findsNothing,
        );
        final field = tester.widget<CupertinoTextField>(fieldFinder);
        expect(field.decoration!.color, isNull);
        expect(field.focusNode!.hasFocus, isTrue);
        expect(search.text, 'query');
        expect(search.selection, selection);
        for (final contentField
            in tester
                .widgetList<CupertinoTextField>(find.byType(CupertinoTextField))
                .where((field) => field.controller != search)) {
          expect(
            contentField.decoration!.color,
            AcademyPalette(
              mode == AcademyAppearanceMode.dark
                  ? Brightness.dark
                  : Brightness.light,
              appearance.value.accent,
            ).textFieldBackground,
          );
        }
        expect(tester.takeException(), isNull);
      }
    }
  });

  for (final direction in TextDirection.values) {
    testWidgets('table leading slots align titles: $direction', (tester) async {
      await tester.pumpWidget(
        AcademyApp(
          home: Directionality(
            textDirection: direction,
            child: Center(
              child: SizedBox(
                width: 360,
                child: AcademyGroupedTable(
                  sections: [
                    AcademyTableSection(
                      rows: [
                        const AcademyRow(
                          title: 'Play',
                          icon: AcademySymbols.play,
                        ),
                        const AcademyRow(
                          title: 'List',
                          icon: AcademySymbols.checklist,
                        ),
                        const AcademyRow(
                          title: 'Arrow',
                          icon: AcademySymbols.upDown,
                        ),
                        const AcademyRow(
                          title: 'Tile',
                          icon: AcademySymbols.gear,
                          iconBackgroundColor: CupertinoColors.activeBlue,
                        ),
                        AcademyInlineOptionMenu(
                          label: 'Choice',
                          value: 'One',
                          options: const ['One'],
                          icon: AcademySymbols.book,
                          onSelected: (_) {},
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      final rects = [
        'Play',
        'List',
        'Arrow',
        'Tile',
        'Choice',
      ].map((text) => tester.getRect(find.text(text))).toList();
      for (final rect in rects.skip(1)) {
        expect(
          direction == TextDirection.ltr ? rect.left : rect.right,
          closeTo(
            direction == TextDirection.ltr
                ? rects.first.left
                : rects.first.right,
            .1,
          ),
        );
      }
      final icons = tester.widgetList<AcademySfIcon>(
        find.descendant(
          of: find.byType(AcademyGroupedTable),
          matching: find.byType(AcademySfIcon),
        ),
      );
      expect(
        icons
            .where((icon) => icon.size == 22)
            .every((icon) => icon.boxSize == AcademyTokens.tableIconExtent),
        isTrue,
      );
      expect(tester.takeException(), isNull);
    });
  }
  for (final style in AcademyChromeStyle.values) {
    testWidgets('expanded navigation search inherits $style', (tester) async {
      final appearance = AcademyAppearanceController(
        initial: AcademyAppearance(chromeStyle: style),
      );
      await appearance.ready;
      addTearDown(appearance.dispose);
      final controller = TextEditingController();
      addTearDown(controller.dispose);
      await tester.pumpWidget(
        AcademyApp(
          appearance: appearance,
          home: Center(
            child: SizedBox(
              width: 300,
              child: AcademyExpandingSearch(controller: controller),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.bySemanticsLabel('Открыть поиск'));
      await tester.pumpAndSettle();
      final search = find.byType(AcademyExpandingSearch);
      final chrome = find.descendant(
        of: search,
        matching: find.byType(AcademyChrome),
      );
      expect(chrome, findsNWidgets(2));
      final filters = find.descendant(
        of: search,
        matching: find.byType(BackdropFilter),
      );
      expect(
        filters,
        style == AcademyChromeStyle.blur || style == AcademyChromeStyle.glass
            ? findsNWidgets(2)
            : findsNothing,
      );
      if (style == AcademyChromeStyle.blur ||
          style == AcademyChromeStyle.glass) {
        for (final filter in tester.widgetList<BackdropFilter>(filters)) {
          expect(filter.filter.toString(), contains('20.0'));
        }
      }
      final field = tester.widget<CupertinoTextField>(
        find.byType(CupertinoTextField),
      );
      expect(field.decoration!.color, isNull);
      expect(field.focusNode!.hasFocus, isTrue);
      expect(tester.takeException(), isNull);
    });
  }
}
