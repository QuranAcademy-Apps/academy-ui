import 'package:academy_ui/academy_ui.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
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
                        AcademyOptionMenu(
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
        style == AcademyChromeStyle.blur ? findsNWidgets(2) : findsNothing,
      );
      if (style == AcademyChromeStyle.blur) {
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
