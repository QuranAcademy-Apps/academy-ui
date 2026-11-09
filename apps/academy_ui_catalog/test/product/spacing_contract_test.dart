import 'package:academy_ui/academy_ui.dart';
import 'package:academy_ui_catalog/product/product.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  for (final direction in TextDirection.values) {
    testWidgets(
      'disclosure has compact header and consistent content insets: $direction',
      (tester) async {
        var expanded = false;
        const bodyKey = ValueKey('body');
        await tester.pumpWidget(
          AcademyApp(
            home: Directionality(
              textDirection: direction,
              child: Center(
                child: SizedBox(
                  width: 300,
                  child: StatefulBuilder(
                    builder: (context, setState) => AcademyDisclosureCard(
                      title: 'List',
                      expanded: expanded,
                      onToggle: () => setState(() => expanded = !expanded),
                      child: const SizedBox(key: bodyKey, height: 80),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();
        var card = tester.getRect(find.byType(AcademyDisclosureCard));
        final text = tester.getRect(find.text('List'));
        expect(card.height, 56);
        expect(
          direction == TextDirection.ltr
              ? text.left - card.left
              : card.right - text.right,
          closeTo(16, .1),
        );
        expect(text.center.dy, closeTo(card.center.dy, .1));
        await tester.tap(find.text('List'));
        await tester.pumpAndSettle();
        card = tester.getRect(find.byType(AcademyDisclosureCard));
        final body = tester.getRect(find.byKey(bodyKey));
        expect(body.left - card.left, 16);
        expect(card.right - body.right, 16);
        expect(body.top - card.top, 64);
        expect(card.bottom - body.bottom, 16);
        await tester.tap(find.text('List'));
        await tester.pumpAndSettle();
        expect(tester.getSize(find.byType(AcademyDisclosureCard)).height, 56);
      },
    );
  }
}
