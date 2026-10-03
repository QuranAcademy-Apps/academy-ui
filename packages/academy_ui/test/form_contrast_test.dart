import 'package:academy_ui/academy_ui.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  for (final brightness in Brightness.values) {
    testWidgets(
      'native filled fields keep readable text and accessible focus in $brightness',
      (tester) async {
        final theme = academyTheme(brightness);
        await tester.pumpWidget(
          AcademyApp(
            home: AcademyTheme(
              data: theme,
              child: Center(
                child: SizedBox(
                  width: 320,
                  child: AcademyTextFormField(label: 'Name', help: 'Required'),
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();
        final field = tester.widget<CupertinoTextField>(
          find.byType(CupertinoTextField),
        );
        final fill = field.decoration!.color!;
        expect((field.decoration!.border! as Border).top.color.a, 0);
        expect(
          AcademyContrast.ratio(field.placeholderStyle!.color!, fill),
          greaterThanOrEqualTo(4.5),
        );
        await tester.tap(find.byType(CupertinoTextField));
        await tester.pumpAndSettle();
        final focused = tester.widget<CupertinoTextField>(
          find.byType(CupertinoTextField),
        );
        expect(
          AcademyContrast.ratio(
            (focused.decoration!.border! as Border).top.color,
            fill,
          ),
          greaterThanOrEqualTo(3),
        );
        final label = tester.widget<Text>(find.text('Name'));
        expect(
          AcademyContrast.ratio(
            label.style!.color!,
            theme.scaffoldBackgroundColor,
          ),
          greaterThanOrEqualTo(4.5),
        );
      },
    );
  }
}
