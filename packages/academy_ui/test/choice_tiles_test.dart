import 'package:academy_ui/academy_ui.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('choice tiles select on tap and expose selected semantics', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    var value = 'pages';
    await tester.pumpWidget(
      AcademyApp(
        home: StatefulBuilder(
          builder: (context, setState) => Center(
            child: SizedBox(
              width: 320,
              child: AcademyChoiceTiles<String>(
                items: const ['pages', 'list'],
                value: value,
                labelFor: (v) => v == 'pages' ? 'Страницы' : 'Список',
                previewBuilder: (_, item, _) => Text('preview-$item'),
                onChanged: (v) => setState(() => value = v),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('preview-pages'), findsOneWidget);
    expect(find.text('preview-list'), findsOneWidget);
    expect(
      tester.getSemantics(find.text('Страницы')),
      matchesSemantics(
        label: 'Страницы',
        isButton: true,
        isSelected: true,
        hasSelectedState: true,
        hasEnabledState: true,
        isEnabled: true,
        hasTapAction: true,
        hasFocusAction: true,
        isFocusable: true,
      ),
    );

    await tester.tap(find.text('Список'));
    await tester.pumpAndSettle();
    expect(value, 'list');

    await tester.tap(find.text('Список'));
    await tester.pumpAndSettle();
    expect(value, 'list');
    semantics.dispose();
  });

  testWidgets('choice tiles keep their size when selection changes', (
    tester,
  ) async {
    var value = 0;
    await tester.pumpWidget(
      AcademyApp(
        home: StatefulBuilder(
          builder: (context, setState) => Center(
            child: SizedBox(
              width: 320,
              child: AcademyChoiceTiles<int>(
                items: const [0, 1],
                value: value,
                labelFor: (v) => 'Вариант $v',
                previewBuilder: (_, _, _) => const SizedBox(),
                onChanged: (v) => setState(() => value = v),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    final before = tester.getSize(find.byType(AcademyChoiceTiles<int>));
    await tester.tap(find.text('Вариант 1'));
    await tester.pumpAndSettle();
    expect(tester.getSize(find.byType(AcademyChoiceTiles<int>)), before);
  });
}
