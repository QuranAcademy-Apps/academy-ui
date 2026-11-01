import 'package:academy_ui/academy_ui.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _host(Widget child) => AcademyApp(
  home: Builder(
    builder: (context) => MediaQuery(
      data: MediaQuery.of(context).copyWith(disableAnimations: true),
      child: CupertinoPageScaffold(child: SingleChildScrollView(child: child)),
    ),
  ),
);

void main() {
  testWidgets('header folds the rows in and out and turns the chevron', (
    tester,
  ) async {
    var expanded = false;
    await tester.pumpWidget(
      _host(
        StatefulBuilder(
          builder: (context, setState) => AcademyDisclosureTable(
            title: 'На все случаи жизни',
            subtitle: 'Крепость мусульманина',
            expanded: expanded,
            onToggle: () => setState(() => expanded = !expanded),
            rows: const [AcademyRow(title: 'Сон и пробуждение')],
          ),
        ),
      ),
    );
    expect(find.text('Сон и пробуждение'), findsNothing);
    double turns() =>
        tester.widget<AnimatedRotation>(find.byType(AnimatedRotation)).turns;
    expect(turns(), 0);

    await tester.tap(find.text('На все случаи жизни'));
    await tester.pumpAndSettle();
    expect(find.text('Сон и пробуждение'), findsOneWidget);
    expect(turns(), .25);

    await tester.tap(find.text('На все случаи жизни'));
    await tester.pumpAndSettle();
    expect(find.text('Сон и пробуждение'), findsNothing);
    expect(turns(), 0);
  });

  testWidgets('animates open without layout errors', (tester) async {
    var expanded = false;
    await tester.pumpWidget(
      AcademyApp(
        home: CupertinoPageScaffold(
          child: SingleChildScrollView(
            child: StatefulBuilder(
              builder: (context, setState) => AcademyDisclosureTable(
                title: 'Заголовок',
                expanded: expanded,
                onToggle: () => setState(() => expanded = !expanded),
                rows: const [AcademyRow(title: 'Строка')],
              ),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Заголовок'));
    await tester.pump(const Duration(milliseconds: 100));
    await tester.pumpAndSettle();
    expect(find.text('Строка'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
