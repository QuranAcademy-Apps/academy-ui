import 'package:academy_ui/academy_ui.dart';
import 'package:cupertino_ui/cupertino_ui.dart' as menu;
import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('field focus preserves field and editable text geometry', (
    tester,
  ) async {
    await tester.pumpWidget(
      const AcademyApp(
        home: Center(
          child: SizedBox(width: 300, child: AcademyField(label: 'Name')),
        ),
      ),
    );
    await tester.pumpAndSettle();
    final field = tester.getRect(find.byType(CupertinoTextField));
    final editable = tester.getRect(find.byType(EditableText));
    await tester.tap(find.byType(CupertinoTextField));
    await tester.pump();
    expect(tester.getRect(find.byType(CupertinoTextField)), field);
    expect(tester.getRect(find.byType(EditableText)), editable);
    FocusManager.instance.primaryFocus?.unfocus();
    await tester.pump();
    expect(tester.getRect(find.byType(EditableText)), editable);
  });

  for (final brightness in Brightness.values) {
    for (final direction in TextDirection.values) {
      testWidgets(
        'table and menu surfaces / icon insets: $brightness $direction',
        (tester) async {
          final appearance = AcademyAppearanceController(
            initial: AcademyAppearance(
              mode: brightness == Brightness.light
                  ? AcademyAppearanceMode.light
                  : AcademyAppearanceMode.dark,
            ),
          );
          await appearance.ready;
          addTearDown(appearance.dispose);
          await tester.pumpWidget(
            AcademyApp(
              appearance: appearance,
              home: Directionality(
                textDirection: direction,
                child: Center(
                  child: SizedBox(
                    width: 300,
                    child: AcademyGroupedTable(
                      sections: [
                        AcademyTableSection(
                          rows: [
                            AcademyInlineOptionMenu(
                              label: 'Theme',
                              value: 'Light',
                              options: const ['Light', 'Dark'],
                              onSelected: (_) {},
                            ),
                            AcademyMenuButton(
                              title: 'Actions',
                              items: [
                                AcademyMenuItem(
                                  title: 'Settings',
                                  leadingIcon: AcademySymbols.gear,
                                  trailingIcon: AcademySymbols.forward,
                                  checked: true,
                                  onPressed: () {},
                                ),
                                AcademyMenuItem(
                                  title: 'Plain',
                                  onPressed: () {},
                                ),
                              ],
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
          final palette = academyTheme(brightness).colorScheme;
          final boxes = tester.widgetList<DecoratedBox>(
            find.descendant(
              of: find.byType(AcademyGroupedTable),
              matching: find.byType(DecoratedBox),
            ),
          );
          expect(
            boxes.any(
              (box) =>
                  box.decoration is BoxDecoration &&
                  (box.decoration as BoxDecoration).color == palette.surface,
            ),
            isTrue,
          );
          await tester.tap(find.text('Theme'));
          await tester.pumpAndSettle();
          expect(find.byType(AcademyMenuItem), findsNWidgets(2));
          await tester.tap(find.text('Dark').last);
          await tester.pumpAndSettle();
          await tester.tap(find.text('Actions'));
          await tester.pumpAndSettle();
          final item = find.widgetWithText(menu.CupertinoMenuItem, 'Settings');
          final row = tester.getRect(item);
          final icons = find.descendant(
            of: item,
            matching: find.byType(AcademySfIcon),
          );
          final leading = tester.getRect(icons.at(0));
          final check = tester.getRect(icons.at(2));
          if (direction == TextDirection.ltr) {
            expect(leading.left - row.left, closeTo(16, .1));
            expect(row.right - check.right, closeTo(16, .1));
          } else {
            expect(row.right - leading.right, closeTo(16, .1));
            expect(check.left - row.left, closeTo(16, .1));
          }
          final plainRow = tester.getRect(
            find.widgetWithText(menu.CupertinoMenuItem, 'Plain'),
          );
          final plainText = tester.getRect(find.text('Plain'));
          if (direction == TextDirection.ltr) {
            expect(plainText.left - plainRow.left, closeTo(16, .1));
          } else {
            expect(plainRow.right - plainText.right, closeTo(16, .1));
          }
          final widget = tester.widget<menu.CupertinoMenuItem>(item);
          for (final states in [
            <WidgetState>{},
            {WidgetState.hovered},
            {WidgetState.pressed},
            {WidgetState.focused},
          ]) {
            final fill = widget.decoration!.resolve(states).color!;
            expect(fill.a, 1);
            expect(fill, isNot(CupertinoColors.black));
          }
          expect(widget.decoration!.resolve({}).color, palette.surface);
          expect(tester.takeException(), isNull);
        },
      );
    }
  }
}
