import 'package:academy_ui/academy_ui.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/academy_test_host.dart';

void main() {
  Widget table(
    Widget row, {
    double width = 320,
    double textScale = 1,
    AcademyTableTheme theme = const AcademyTableTheme(),
    TextDirection direction = TextDirection.ltr,
  }) => academyHost(
    SizedBox(
      width: width,
      child: AcademyTableBody(rows: [row]),
    ),
    textScale: textScale,
    table: theme,
    direction: direction,
  );

  group('title color', () {
    testWidgets('a theme title style keeps the tone', (tester) async {
      await tester.pumpWidget(
        table(
          const AcademyRow(title: 'Удалить', tone: AcademyTone.error),
          theme: const AcademyTableTheme(
            rowTitleStyle: TextStyle(fontSize: 20),
          ),
        ),
      );
      final style = tester.widget<Text>(find.text('Удалить')).style!;
      expect(style.fontSize, 20);
      expect(style.color, isNotNull);
    });

    testWidgets('an explicit title style wins over the tone', (tester) async {
      const color = Color(0xFF123456);
      await tester.pumpWidget(
        table(
          const AcademyRow(
            title: 'Удалить',
            tone: AcademyTone.error,
            titleStyle: TextStyle(color: color),
          ),
        ),
      );
      expect(tester.widget<Text>(find.text('Удалить')).style!.color, color);
    });
  });

  group('semantics', () {
    testWidgets('a disabled row announces its switch accessory', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(
        table(
          AcademyRow(
            title: 'Wi-Fi',
            enabled: false,
            trailing: AcademyRowAccessory.toggle(
              value: true,
              onChanged: (_) {},
            ),
          ),
        ),
      );
      expect(
        tester.getSemantics(find.bySemanticsLabel('Wi-Fi')),
        isSemantics(isChecked: true, hasCheckedState: true),
      );
      handle.dispose();
    });

    testWidgets('a row that scales when pressed keeps selected', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(
        table(
          AcademyRow(title: 'Русский', selected: true, onPressed: () {}),
          theme: const AcademyTableTheme(press: AcademyRowPress()),
        ),
      );
      expect(
        tester.getSemantics(find.bySemanticsLabel('Русский')),
        isSemantics(isSelected: true),
      );
      handle.dispose();
    });

    testWidgets('the «more» button has a name', (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(
        table(
          AcademyRow(
            title: 'Wi-Fi',
            trailing: AcademyRowAccessory.toggleWithButton(
              value: true,
              onChanged: (_) {},
              onButtonPressed: () {},
            ),
          ),
        ),
      );
      expect(find.bySemanticsLabel('Ещё'), findsOneWidget);
      handle.dispose();
    });

    testWidgets('the menu accessory is a named button', (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(
        table(
          AcademyRow(
            title: 'Тема',
            trailing: AcademyRowAccessory.menu(
              title: 'Системная',
              itemBuilder: (_) => [
                AcademyMenuItem(title: 'Светлая', onPressed: () {}),
              ],
            ),
          ),
        ),
      );
      expect(
        tester.getSemantics(find.bySemanticsLabel('Системная')),
        isSemantics(isButton: true),
      );
      handle.dispose();
    });
  });

  group('touch targets', () {
    const rowHeight = 52.0;

    testWidgets('an accessory button reaches 44pt without growing the row', (
      tester,
    ) async {
      await tester.pumpWidget(
        table(
          AcademyRow(
            title: 'Файл',
            trailing: AcademyRowAccessoryButton(
              onPressed: () {},
              child: const SizedBox.square(dimension: 20),
            ),
          ),
        ),
      );
      final button = tester.getSize(find.byType(CupertinoButton));
      expect(button.width, greaterThanOrEqualTo(44));
      expect(button.height, greaterThanOrEqualTo(44));
      expect(tester.getSize(find.byType(AcademyRow)).height, rowHeight);
    });

    for (final direction in TextDirection.values) {
      testWidgets('the accessory symbol stays at the row end in $direction', (
        tester,
      ) async {
        const symbol = ValueKey('symbol');
        await tester.pumpWidget(
          table(
            AcademyRow(
              title: 'Файл',
              trailing: AcademyRowAccessoryButton(
                onPressed: () {},
                child: const SizedBox.square(key: symbol, dimension: 32),
              ),
            ),
            direction: direction,
          ),
        );
        final row = tester.getRect(find.byType(AcademyRow));
        final box = tester.getRect(find.byKey(symbol));
        expect(
          direction == TextDirection.ltr
              ? row.right - box.right
              : box.left - row.left,
          16,
        );
      });
    }

    testWidgets('a long menu value fits and the menu reaches 44pt', (
      tester,
    ) async {
      await tester.pumpWidget(
        table(
          AcademyRow(
            title: 'Тема',
            trailing: AcademyRowAccessory.menu(
              title: 'Очень длинное значение, которое не помещается в строку',
              itemBuilder: (_) => [
                AcademyMenuItem(title: 'Светлая', onPressed: () {}),
              ],
            ),
          ),
        ),
      );
      expect(tester.takeException(), isNull);
      expect(
        tester.getSize(find.byType(CupertinoButton)).height,
        greaterThanOrEqualTo(44),
      );
      expect(tester.getSize(find.byType(AcademyRow)).height, rowHeight);
    });

    testWidgets('an inline info button is 44pt wide beside its title', (
      tester,
    ) async {
      await tester.pumpWidget(
        table(
          AcademyRow(
            title: 'Тема',
            titleTrailing: AcademyInfoButton.inline(onPressed: () {}),
          ),
        ),
      );
      expect(tester.getSize(find.byType(CupertinoButton)).width, 44);
      expect(tester.getSize(find.byType(AcademyRow)).height, rowHeight);
    });
  });

  group('large text', () {
    Future<void> expectBelowTitle(WidgetTester tester, String value) async {
      expect(tester.takeException(), isNull);
      expect(
        tester.getTopLeft(find.text(value)).dy,
        greaterThanOrEqualTo(tester.getBottomLeft(find.text('Заголовок')).dy),
      );
    }

    testWidgets('trailing text moves under the title', (tester) async {
      await tester.pumpWidget(
        table(
          const AcademyRow(title: 'Заголовок', trailingText: 'Значение'),
          textScale: 2,
        ),
      );
      await expectBelowTitle(tester, 'Значение');
    });

    testWidgets('a trailing text widget moves under the title', (tester) async {
      await tester.pumpWidget(
        table(
          const AcademyRow(
            title: 'Заголовок',
            trailing: AcademyRowTrailingText('Значение'),
          ),
          textScale: 2,
        ),
      );
      await expectBelowTitle(tester, 'Значение');
    });

    testWidgets('a menu value moves under the title', (tester) async {
      await tester.pumpWidget(
        table(
          AcademyRow(
            title: 'Заголовок',
            trailing: AcademyRowAccessory.menu(
              title: 'Значение',
              itemBuilder: (_) => [
                AcademyMenuItem(title: 'Другое', onPressed: () {}),
              ],
            ),
          ),
          textScale: 2,
        ),
      );
      await expectBelowTitle(tester, 'Значение');
    });

    testWidgets('a switch stays beside the title', (tester) async {
      await tester.pumpWidget(
        table(
          AcademyRow(
            title: 'Заголовок',
            trailing: AcademyRowAccessory.toggle(
              value: true,
              onChanged: (_) {},
            ),
          ),
          textScale: 2,
        ),
      );
      expect(
        tester.getTopLeft(find.byType(AcademySwitch)).dx,
        greaterThan(tester.getTopLeft(find.text('Заголовок')).dx),
      );
    });
  });

  testWidgets('a three-digit index badge stays on one line', (tester) async {
    await tester.pumpWidget(
      table(
        const AcademyRow(title: 'Глава 111', leading: AcademyIndexBadge(111)),
      ),
    );
    expect(tester.takeException(), isNull);
    final text = tester.getRect(find.text('111'));
    final badge = tester.getRect(find.byType(AcademyIndexBadge));
    expect(text.width, lessThanOrEqualTo(badge.width));
    expect(tester.widget<Text>(find.text('111')).softWrap, isFalse);
  });

  testWidgets('a navigation row uses the library chevron', (tester) async {
    await tester.pumpWidget(
      table(AcademyRow(title: 'Раздел', onPressed: () {})),
    );
    expect(find.byType(AcademyChevron), findsOneWidget);
  });
}
