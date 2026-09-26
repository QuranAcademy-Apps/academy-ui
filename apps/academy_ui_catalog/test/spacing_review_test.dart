import 'package:academy_ui/academy_ui.dart';
import 'package:academy_ui_catalog/catalog_pages.dart';
import 'package:academy_ui_catalog/quran_controls_catalog.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  for (final direction in TextDirection.values) {
    for (final section in [...CatalogSection.values, null]) {
      testWidgets('spacing smoke 320px / 2x / $direction / $section', (
        tester,
      ) async {
        tester.view.devicePixelRatio = 1;
        tester.view.physicalSize = const Size(320, 844);
        addTearDown(tester.view.reset);
        await tester.pumpWidget(
          AcademyApp(
            home: Builder(
              builder: (context) => MediaQuery(
                data: MediaQuery.of(context).copyWith(
                  textScaler: const TextScaler.linear(2),
                  disableAnimations: true,
                ),
                child: Directionality(
                  textDirection: direction,
                  child: section == null
                      ? const QuranControlsCatalog()
                      : ComponentExamples(section: section),
                ),
              ),
            ),
          ),
        );
        await tester.pump(const Duration(milliseconds: 100));
        expect(tester.takeException(), isNull);
        final list = find.byType(ListView).first;
        final position = tester
            .state<ScrollableState>(
              find
                  .descendant(of: list, matching: find.byType(Scrollable))
                  .first,
            )
            .position;
        for (
          var i = 0;
          i < 30 && position.pixels < position.maxScrollExtent;
          i++
        ) {
          position.jumpTo(
            (position.pixels + 400).clamp(0, position.maxScrollExtent),
          );
          await tester.pump(const Duration(milliseconds: 100));
          expect(tester.takeException(), isNull);
        }
        await tester.pumpWidget(const SizedBox());
      });
    }
  }
}
