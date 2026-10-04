import 'package:academy_ui/academy_ui.dart';
import 'package:academy_ui/src/widgets/table/academy_divider.dart' as legacy;
import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  for (final direction in TextDirection.values) {
    testWidgets('custom composed rows align separators in $direction', (
      tester,
    ) async {
      await tester.pumpWidget(
        AcademyApp(
          home: Directionality(
            textDirection: direction,
            child: const Center(
              child: SizedBox(
                width: 320,
                child: AcademyTableBody(
                  rows: [
                    AcademyTableRowLayout(
                      separatorInset: 73,
                      child: Padding(
                        padding: EdgeInsetsDirectional.only(start: 73),
                        child: Text('Composed'),
                      ),
                    ),
                    AcademyRow(title: 'Next'),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
      final body = tester.getRect(find.byType(AcademyTableBody));
      final separator = tester.getRect(
        find.descendant(
          of: find.byType(AcademyTableSeparator),
          matching: find.byType(Container),
        ),
      );
      expect(
        direction == TextDirection.ltr
            ? separator.left - body.left
            : body.right - separator.right,
        73,
      );
    });
  }

  testWidgets('leading geometry is shared by row and menu compositions', (
    tester,
  ) async {
    await tester.pumpWidget(
      AcademyApp(
        home: Center(
          child: SizedBox(
            width: 320,
            child: AcademyTableBody(
              rows: [
                const AcademyRow(title: 'Row', icon: AcademySymbols.gear),
                const AcademyMenuRow(
                  label: 'Menu',
                  value: 'Value',
                  icon: AcademySymbols.gear,
                  items: [],
                ),
                AcademyOptionMenu(
                  label: 'Option',
                  value: 'Value',
                  icon: AcademySymbols.gear,
                  options: const ['Value'],
                  onSelected: (_) {},
                ),
                const AcademyRow(title: 'Last'),
              ],
            ),
          ),
        ),
      ),
    );
    final context = tester.element(find.byType(AcademyTableBody));
    final expected =
        AcademyTheme.of(context).paddings.tableRow.left +
        AcademyTokens.tableIconExtent +
        AcademyTokens.inlineGap;
    final separators = tester.widgetList<AcademyTableSeparator>(
      find.byType(AcademyTableSeparator),
    );
    expect(separators.map((row) => row.start), [expected, expected, expected]);
  });

  testWidgets('legacy divider import exposes the same row scope', (
    tester,
  ) async {
    var inset = -1.0;
    await tester.pumpWidget(
      AcademyApp(
        home: legacy.AcademyTableRowScope(
          child: Builder(
            builder: (context) {
              expect(AcademyTableRowScope.contains(context), isTrue);
              inset = AcademyTableRowScope.of(context);
              return const SizedBox();
            },
          ),
        ),
      ),
    );
    expect(inset, 16);
  });
}
