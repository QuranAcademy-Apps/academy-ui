import 'package:academy_ui/academy_ui.dart';
import 'package:academy_ui_catalog/advanced_components_catalog.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  for (final section in AdvancedCatalogSection.values) {
    testWidgets('advanced catalog $section renders at phone width', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(
        AcademyApp(home: AdvancedComponentsCatalog(section: section)),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      final list = find.byType(Scrollable).first;
      await tester.drag(list, const Offset(0, -600));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      tester.view.physicalSize = const Size(320, 844);
      tester.platformDispatcher.textScaleFactorTestValue = 2;
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
      await tester.pumpAndSettle();
      await tester.drag(list, const Offset(0, 1000));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox());
    });
  }
}
