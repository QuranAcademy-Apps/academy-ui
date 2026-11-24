import 'package:academy_ui/academy_ui.dart';
import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Widget app(AcademyThemeData theme, Widget child) => CupertinoApp(
    home: AcademyTheme(data: theme, child: child),
  );

  testWidgets('the table theme sets the look of every row', (tester) async {
    const title = TextStyle(fontSize: 21, color: Color(0xFF112233));
    await tester.pumpWidget(
      app(
        academyTheme(
          Brightness.light,
          table: const AcademyTableTheme(
            headerUppercase: true,
            rowTitleStyle: title,
            showChevron: false,
          ),
        ),
        AcademyGroupedTable(
          sections: [
            AcademyTableSection(
              title: 'Раздел',
              rows: [AcademyRow(title: 'Строка', onPressed: () {})],
            ),
          ],
        ),
      ),
    );
    expect(find.text('РАЗДЕЛ'), findsOneWidget);
    expect(tester.widget<Text>(find.text('Строка')).style, title);
    expect(find.byType(AcademySfIcon), findsNothing);
  });

  testWidgets('the surface shadow falls under inline and lazy tables', (
    tester,
  ) async {
    const shadow = [
      BoxShadow(color: Color(0x0F000000), blurRadius: 4, offset: Offset(0, 1)),
    ];
    final theme = academyTheme(
      Brightness.light,
      table: const AcademyTableTheme(surfaceShadow: shadow),
    );
    await tester.pumpWidget(
      app(
        theme,
        const AcademyGroupedTable(
          sections: [
            AcademyTableSection(rows: [AcademyRow(title: 'Строка')]),
          ],
        ),
      ),
    );
    final shadowed = tester.widgetList<DecoratedBox>(find.byType(DecoratedBox))
        .map((box) => box.decoration)
        .whereType<BoxDecoration>()
        .where((decoration) => decoration.boxShadow == shadow);
    expect(shadowed, hasLength(1));

    await tester.pumpWidget(
      app(
        theme,
        AcademyGroupedTable(
          scrollable: true,
          lazyRows: true,
          sections: [
            AcademyTableSection(
              rows: [for (var i = 0; i < 3; i++) AcademyRow(title: 'Строка $i')],
            ),
          ],
        ),
      ),
    );
    // Each lazy row paints its own band of the one shadow.
    expect(
      tester
          .widgetList<CustomPaint>(find.byType(CustomPaint))
          .where((paint) => '${paint.painter.runtimeType}' == '_RowShadowPainter'),
      hasLength(3),
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('lazy rows are built only in view', (tester) async {
    await tester.pumpWidget(
      app(
        academyTheme(Brightness.light),
        AcademyGroupedTable(
          scrollable: true,
          lazyRows: true,
          sections: [
            AcademyTableSection(
              rows: [
                for (var i = 0; i < 500; i++) AcademyRow(title: 'Строка $i'),
              ],
            ),
          ],
        ),
      ),
    );
    expect(find.text('Строка 0'), findsOneWidget);
    expect(find.text('Строка 499'), findsNothing);
  });

  testWidgets('accessories follow a disabled row', (tester) async {
    await tester.pumpWidget(
      app(
        academyTheme(Brightness.light),
        Center(
          child: AcademyRow(
            title: 'Строка',
            enabled: false,
            trailing: AcademyRowAccessory.toggle(
              value: true,
              onChanged: (_) {},
            ),
          ),
        ),
      ),
    );
    expect(
      tester.widget<AcademySwitch>(find.byType(AcademySwitch)).onChanged,
      isNull,
    );
  });

  testWidgets('a row can scale when pressed and report its own label', (
    tester,
  ) async {
    var taps = 0;
    await tester.pumpWidget(
      app(
        academyTheme(
          Brightness.light,
          table: const AcademyTableTheme(press: AcademyRowPress()),
        ),
        Center(
          child: AcademyRow(
            title: 'Строка',
            semanticLabel: 'Своя подпись',
            onPressed: () => taps++,
          ),
        ),
      ),
    );
    expect(find.byType(PressScale), findsOneWidget);
    expect(find.bySemanticsLabel('Своя подпись'), findsOneWidget);
    await tester.tap(find.text('Строка'));
    await tester.pumpAndSettle();
    expect(taps, 1);
  });

  testWidgets('the theme can announce a row as one element', (tester) async {
    final handle = tester.ensureSemantics();
    Widget row(bool merge) => app(
      academyTheme(
        Brightness.light,
        table: AcademyTableTheme(mergeRowSemantics: merge),
      ),
      const Center(
        child: AcademyRow(title: 'Строка', subtitle: 'Подпись'),
      ),
    );
    await tester.pumpWidget(row(true));
    expect(find.bySemanticsLabel(RegExp('Строка\\s+Подпись')), findsOneWidget);
    await tester.pumpWidget(row(false));
    expect(find.bySemanticsLabel('Строка'), findsOneWidget);
    expect(find.bySemanticsLabel('Подпись'), findsOneWidget);
    handle.dispose();
  });
}
