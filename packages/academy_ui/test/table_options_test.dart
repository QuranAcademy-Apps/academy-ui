import 'package:academy_ui/academy_ui.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';

// Row and table options added with Yalla's grouped tables (2026-11-02).

Widget _host(Widget child, {double width = 390, double textScale = 1}) =>
    AcademyApp(
      home: Builder(
        builder: (context) => MediaQuery(
          data: MediaQuery.of(context)
              .copyWith(textScaler: TextScaler.linear(textScale)),
          child: Align(
            alignment: Alignment.topCenter,
            child: SizedBox(width: width, child: child),
          ),
        ),
      ),
    );

void _tap() {}

void main() {
  testWidgets('row: eyebrow, detail, subtitle limits and selection', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();
    await tester.pumpWidget(
      _host(
        const AcademyTableRowScope(
          child: AcademyRow(
            title: 'Отель',
            eyebrow: 'Мекка',
            subtitle: 'Очень длинный подзаголовок, который не помещается',
            subtitleMaxLines: 1,
            detail: Text('Статус'),
            selected: true,
          ),
        ),
        width: 240,
      ),
    );
    final eyebrow = tester.getRect(find.text('Мекка'));
    final title = tester.getRect(find.text('Отель'));
    final detail = tester.getRect(find.text('Статус'));
    expect(eyebrow.bottom, lessThanOrEqualTo(title.top));
    expect(detail.top, greaterThan(title.bottom));
    final subtitle = tester.widget<Text>(find.textContaining('Очень'));
    expect(subtitle.maxLines, 1);
    expect(subtitle.overflow, TextOverflow.ellipsis);
    expect(
      tester.getSemantics(find.text('Отель')),
      isSemantics(isSelected: true),
    );
    handle.dispose();
  });

  testWidgets('row: a custom leading column, chevron and trailing gap', (
    tester,
  ) async {
    const extent = 34.0;
    await tester.pumpWidget(
      _host(
        const AcademyTableRowScope(
          child: Column(
            children: [
              AcademyRow(
                key: ValueKey('icon'),
                title: 'Документы',
                icon: AcademySymbols.document,
                leadingExtent: extent,
                onPressed: _tap,
                chevron: SizedBox(key: ValueKey('chevron'), width: 8),
              ),
              AcademyRow(
                key: ValueKey('trailing'),
                title: 'Город',
                trailing: SizedBox(key: ValueKey('end'), width: 20, height: 20),
                trailingSpacing: 10,
              ),
            ],
          ),
        ),
      ),
    );
    final row = tester.getRect(find.byKey(const ValueKey('icon')));
    final inset = AcademyTheme.of(
      tester.element(find.byKey(const ValueKey('icon'))),
    ).paddings.tableRow.left;
    expect(
      tester.getTopLeft(find.text('Документы')).dx - row.left,
      inset + extent + AcademyTokens.inlineGap,
    );
    final icon = tester.getRect(find.byType(AcademySfIcon).first);
    expect(icon.center.dx - row.left, closeTo(inset + extent / 2, .01));
    expect(find.byKey(const ValueKey('chevron')), findsOneWidget);
    expect(
      tester
          .widget<AcademyRow>(find.byKey(const ValueKey('icon')))
          .separatorStart(tester.element(find.byKey(const ValueKey('icon')))),
      inset + extent + AcademyTokens.inlineGap,
    );
    final title = tester.getRect(find.text('Город'));
    final end = tester.getRect(find.byKey(const ValueKey('end')));
    expect(end.left - title.right, greaterThanOrEqualTo(10));
  });

  testWidgets('row: pressed colour highlights the whole row', (tester) async {
    const pressed = Color(0xFFDDE3EA);
    var taps = 0;
    await tester.pumpWidget(
      _host(
        AcademyTableRowScope(
          child: AcademyRow(
            title: 'Настройки',
            pressedColor: pressed,
            onPressed: () => taps++,
          ),
        ),
      ),
    );
    final tile = tester.widget<CupertinoListTile>(
      find.byType(CupertinoListTile),
    );
    expect(tile.backgroundColorActivated, pressed);
    await tester.tap(find.text('Настройки'));
    expect(taps, 1);
  });

  testWidgets('header: subtitle and a trailing control that moves under it', (
    tester,
  ) async {
    Future<(Rect, Rect)> layout(double width, double scale) async {
      await tester.pumpWidget(
        _host(
          const AcademyTableHeader(
            title: 'Поездка',
            subtitle: 'Пояснение',
            trailing: Text('Действие'),
          ),
          width: width,
          textScale: scale,
        ),
      );
      expect(find.text('Пояснение'), findsOneWidget);
      return (
        tester.getRect(find.text('Поездка')),
        tester.getRect(find.text('Действие')),
      );
    }

    final (wideTitle, wideAction) = await layout(390, 1);
    expect(wideAction.center.dy, closeTo(wideTitle.center.dy, 1));
    final (narrowTitle, narrowAction) = await layout(260, 1);
    expect(narrowAction.top, greaterThanOrEqualTo(narrowTitle.bottom));
    final (largeTitle, largeAction) = await layout(390, 2);
    expect(largeAction.top, greaterThanOrEqualTo(largeTitle.bottom));
  });

  testWidgets('table: spacing, insets, clipping and custom content', (
    tester,
  ) async {
    await tester.pumpWidget(
      _host(
        const AcademyGroupedTable(
          padding: EdgeInsets.zero,
          sectionSpacing: 0,
          sections: [
            AcademyTableSection(
              title: 'Первая',
              rows: [AcademyRow(title: 'Строка')],
            ),
            AcademyTableSection(
              spacingBefore: 30,
              bodyPadding: EdgeInsets.symmetric(vertical: 4),
              separatorStart: 40,
              separatorEnd: 0,
              insetCustomRows: true,
              clip: true,
              rows: [
                AcademyRow(title: 'Вторая'),
                SizedBox(key: ValueKey('custom'), width: 60, height: 20),
              ],
            ),
          ],
        ),
      ),
    );
    final first = tester.getRect(find.text('Строка'));
    final second = tester.getRect(find.text('Вторая'));
    expect(second.top - first.bottom, greaterThanOrEqualTo(30));
    final table = tester.getRect(find.byType(AcademyGroupedTable));
    final custom = tester.getRect(find.byKey(const ValueKey('custom')));
    expect(custom.width, 60);
    expect(custom.center.dx, closeTo(table.center.dx, .01));
    final separator = tester.getRect(
      find
          .descendant(
            of: find.byType(AcademyTableSeparator),
            matching: find.byType(Container),
          )
          .first,
    );
    expect(separator.left - table.left, 40);
    expect(separator.right, table.right);
    expect(find.byType(ClipRRect), findsWidgets);
  });

  testWidgets('sliver table builds rows lazily with rounded ends', (
    tester,
  ) async {
    var built = 0;
    await tester.pumpWidget(
      _host(
        SizedBox(
          height: 500,
          child: CustomScrollView(
            slivers: [
              AcademySliverGroupedTable(
                header: const AcademyTableHeader(title: 'История'),
                itemCount: 200,
                edgePadding: 4,
                itemBuilder: (_, i) {
                  built++;
                  return AcademyRow(title: 'Запись $i');
                },
              ),
            ],
          ),
        ),
      ),
    );
    expect(find.text('История'), findsOneWidget);
    expect(find.text('Запись 0'), findsOneWidget);
    expect(find.text('Запись 199'), findsNothing);
    expect(built, lessThan(100));
    expect(find.byType(AcademyTableSeparator), findsWidgets);
  });
}
