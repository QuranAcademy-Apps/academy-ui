import 'package:academy_ui/academy_ui.dart';
import 'package:flutter/cupertino.dart';
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
