// ignore_for_file: deprecated_member_use_from_same_package
import 'package:academy_ui/academy_ui.dart';
import 'package:academy_ui_catalog/product/product.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('disclosure is controlled and does not inherit blur', (
    tester,
  ) async {
    var expanded = false;
    final appearance = AcademyAppearanceController(
      initial: const AcademyAppearance(chromeStyle: AcademyChromeStyle.blur),
    );
    await appearance.ready;
    addTearDown(appearance.dispose);
    await tester.pumpWidget(
      AcademyApp(
        appearance: appearance,
        home: StatefulBuilder(
          builder: (context, setState) => Center(
            child: SizedBox(
              width: 300,
              child: AcademyDisclosureCard(
                title: 'Список',
                expanded: expanded,
                onToggle: () => setState(() => expanded = !expanded),
                child: const SizedBox(height: 150, child: Text('Содержимое')),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    final collapsed = tester.getSize(find.byType(AcademyDisclosureCard)).height;
    await tester.tap(find.text('Список'));
    await tester.pumpAndSettle();
    expect(expanded, isTrue);
    expect(
      tester.getSize(find.byType(AcademyDisclosureCard)).height,
      greaterThan(collapsed + 100),
    );
    expect(find.byType(BackdropFilter), findsNothing);
    await tester.tap(find.text('Список'));
    await tester.pumpAndSettle();
    expect(
      tester.getSize(find.byType(AcademyDisclosureCard)).height,
      closeTo(collapsed, .1),
    );
  });
}
