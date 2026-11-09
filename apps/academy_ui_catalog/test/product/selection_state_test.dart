import 'package:academy_ui_catalog/product/product.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/academy_test_host.dart';

void main() {
  group('AcademyCounterButton', () {
    testWidgets('a completed counter still takes a long press', (tester) async {
      var resets = 0;
      await tester.pumpWidget(
        academyHost(
          AcademyCounterButton(
            count: 3,
            total: 3,
            label: 'Счётчик',
            onLongPress: () => resets++,
          ),
        ),
      );
      await tester.longPress(find.byType(AcademyCounterButton));
      await tester.pumpAndSettle();
      expect(resets, 1);
    });

    testWidgets('without callbacks it stays disabled', (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(
        academyHost(
          const AcademyCounterButton(count: 1, total: 3, label: 'Счётчик'),
        ),
      );
      expect(
        tester.getSemantics(find.bySemanticsLabel('Счётчик')),
        isSemantics(isEnabled: false, hasEnabledState: true),
      );
      handle.dispose();
    });
  });
}
