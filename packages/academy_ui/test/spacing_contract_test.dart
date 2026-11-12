import 'package:academy_ui/academy_ui.dart';
import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  for (final direction in TextDirection.values) {
    testWidgets('stepper has equal targets with centered glyphs: $direction', (
      tester,
    ) async {
      var value = 3;
      await tester.pumpWidget(
        AcademyApp(
          home: Directionality(
            textDirection: direction,
            child: Center(
              child: StatefulBuilder(
                builder: (context, setState) => AcademyStepper(
                  value: value,
                  onChanged: (next) => setState(() => value = next),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      final buttons = find.descendant(
        of: find.byType(AcademyStepper),
        matching: find.byType(CupertinoButton),
      );
      final icons = find.descendant(
        of: find.byType(AcademyStepper),
        matching: find.byType(AcademySfIcon),
      );
      for (var i = 0; i < 2; i++) {
        final target = tester.getRect(buttons.at(i));
        expect(target.size, const Size(48, 44));
        expect(
          tester.getRect(icons.at(i)).center.dx,
          closeTo(target.center.dx, .1),
        );
      }
      await tester.tap(buttons.at(0));
      await tester.pump();
      expect(value, 2);
      await tester.tap(buttons.at(1));
      await tester.pump();
      expect(value, 3);
    });
  }
}
