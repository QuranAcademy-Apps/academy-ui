import 'package:academy_ui/academy_ui.dart';
import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:flutter_test/flutter_test.dart';

const options = [
  AcademySelectOption(value: 'ru', label: 'Russian'),
  AcademySelectOption(value: 'en', label: 'English'),
];

void main() {
  for (final direction in TextDirection.values) {
    testWidgets(
      'select popup follows both field edges on resize in $direction',
      (tester) async {
        tester.view.physicalSize = const Size(700, 900);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.reset);
        final width = ValueNotifier(360.0);
        addTearDown(width.dispose);
        await tester.pumpWidget(
          AcademyApp(
            home: Directionality(
              textDirection: direction,
              child: Center(
                child: ValueListenableBuilder<double>(
                  valueListenable: width,
                  builder: (_, value, _) => SizedBox(
                    width: value,
                    child: AcademySelect<String>(
                      label: 'Language',
                      value: 'ru',
                      options: options,
                      onChanged: (_) {},
                      presentation: AcademySelectPresentation.popover,
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
        await tester.tap(find.text('Russian'));
        await tester.pumpAndSettle();
        for (final size in [360.0, 540.0, 280.0]) {
          width.value = size;
          await tester.pumpAndSettle();
          final trigger = tester.getRect(find.byType(AcademyTappable).first);
          final popup = tester.getRect(
            find
                .ancestor(
                  of: find.text('English'),
                  matching: find.byType(ClipRRect),
                )
                .first,
          );
          expect(popup.left, closeTo(trigger.left, .01));
          expect(popup.right, closeTo(trigger.right, .01));
          expect(tester.takeException(), isNull);
        }
      },
    );
  }

  testWidgets(
    'autocomplete anchors to input rather than outer label/help padding',
    (tester) async {
      final controller = TextEditingController();
      addTearDown(controller.dispose);
      await tester.pumpWidget(
        AcademyApp(
          paddings: const AcademyPaddings(fieldOuter: EdgeInsets.all(16)),
          home: Center(
            child: SizedBox(
              width: 360,
              child: AcademyAutocomplete<String>(
                label: 'Search',
                help: 'Help below the field',
                options: options,
                controller: controller,
              ),
            ),
          ),
        ),
      );
      await tester.enterText(find.byType(CupertinoTextField), 'Eng');
      await tester.pumpAndSettle();
      final field = tester.getRect(find.byType(CupertinoTextField));
      final popup = tester.getRect(
        find
            .ancestor(
              of: find.text('English'),
              matching: find.byType(ClipRRect),
            )
            .first,
      );
      expect(popup.left, closeTo(field.left, .01));
      expect(popup.right, closeTo(field.right, .01));
      expect(popup.top, closeTo(field.bottom + 8, .01));
      expect(tester.takeException(), isNull);
    },
  );
}
