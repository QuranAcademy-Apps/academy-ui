import 'package:academy_ui/academy_ui.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/academy_test_host.dart';

const _rows = <Widget>[AcademyRow(title: 'a'), AcademyRow(title: 'b')];

void main() {
  group('lazyRows', () {
    Widget lazy(AcademyTableSection section) => academyHost(
      SizedBox(
        width: 320,
        height: 500,
        child: AcademyGroupedTable(
          scrollable: true,
          lazyRows: true,
          padding: EdgeInsets.zero,
          sections: [section],
        ),
      ),
    );

    testWidgets('draws separators by default', (tester) async {
      await tester.pumpWidget(lazy(const AcademyTableSection(rows: _rows)));
      expect(find.byType(AcademyTableSeparator), findsOneWidget);
    });

    testWidgets('honors showSeparators', (tester) async {
      await tester.pumpWidget(
        lazy(const AcademyTableSection(rows: _rows, showSeparators: false)),
      );
      expect(find.byType(AcademyTableSeparator), findsNothing);
    });

    testWidgets('honors separatorBuilder', (tester) async {
      await tester.pumpWidget(
        lazy(
          AcademyTableSection(
            rows: _rows,
            separatorBuilder: (_, index) => Text('after $index'),
          ),
        ),
      );
      expect(find.byType(AcademyTableSeparator), findsNothing);
      expect(find.text('after 0'), findsOneWidget);
    });

    testWidgets('honors spacingBefore and bodyPadding', (tester) async {
      await tester.pumpWidget(
        lazy(
          const AcademyTableSection(
            rows: _rows,
            spacingBefore: 40,
            bodyPadding: EdgeInsets.only(top: 20, bottom: 30),
          ),
        ),
      );
      final top = tester.getTopLeft(find.byType(AcademyGroupedTable)).dy;
      expect(tester.getTopLeft(find.byType(AcademyRow).first).dy - top, 60);
      final last = tester.getBottomLeft(find.byType(AcademyRow).last).dy;
      final surface = tester
          .getBottomLeft(
            find
                .ancestor(
                  of: find.byType(AcademyRow).last,
                  matching: find.byType(DecoratedBox),
                )
                .first,
          )
          .dy;
      expect(surface - last, 30);
    });

    testWidgets('honors insetCustomRows', (tester) async {
      await tester.pumpWidget(
        lazy(
          const AcademyTableSection(
            insetCustomRows: true,
            rows: [SizedBox(key: ValueKey('custom'), width: 100, height: 60)],
          ),
        ),
      );
      expect(
        tester.getCenter(find.byKey(const ValueKey('custom'))).dx,
        tester.getCenter(find.byType(AcademyGroupedTable)).dx,
      );
    });
  });

  group('themed', () {
    Widget themed(
      List<AcademyTableSection> sections, {
      bool hideEmptySections = true,
    }) => academyHost(
      SizedBox(
        width: 320,
        child: AcademyGroupedTable.themed(
          sections: sections,
          hideEmptySections: hideEmptySections,
        ),
      ),
    );

    testWidgets('keeps the paddings a section sets', (tester) async {
      const padding = EdgeInsets.all(40);
      await tester.pumpWidget(
        themed(const [
          AcademyTableSection(
            title: 'Title',
            footer: 'Footer',
            rows: _rows,
            headerPadding: padding,
            bodyPadding: padding,
            footerPadding: padding,
          ),
        ]),
      );
      expect(
        tester
            .widget<AcademyTableHeader>(find.byType(AcademyTableHeader))
            .padding,
        padding,
      );
      expect(
        tester.widget<AcademyTableBody>(find.byType(AcademyTableBody)).padding,
        padding,
      );
      expect(
        tester
            .widget<AcademyTableFooter>(find.byType(AcademyTableFooter))
            .padding,
        padding,
      );
    });

    testWidgets('fills in the layout where a section sets nothing', (
      tester,
    ) async {
      await tester.pumpWidget(
        themed(const [AcademyTableSection(title: 'Title', rows: _rows)]),
      );
      expect(
        tester.widget<AcademyTableBody>(find.byType(AcademyTableBody)).padding,
        // Native inset grouped: no vertical padding in the table body.
        EdgeInsets.zero,
      );
      expect(
        tester
            .widget<AcademyTableHeader>(find.byType(AcademyTableHeader))
            .padding,
        const EdgeInsets.fromLTRB(16, 24, 16, 8),
      );
    });

    testWidgets('hides an empty section by default', (tester) async {
      const sections = [
        AcademyTableSection(title: 'Empty', rows: []),
        AcademyTableSection(title: 'Full', rows: _rows),
      ];
      await tester.pumpWidget(themed(sections));
      expect(find.text('Empty'), findsNothing);
      expect(find.text('Full'), findsOneWidget);
      await tester.pumpWidget(themed(sections, hideEmptySections: false));
      expect(find.text('Empty'), findsOneWidget);
    });
  });
}
