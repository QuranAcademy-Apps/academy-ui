import 'package:academy_ui/academy_ui.dart';
import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/academy_test_host.dart';

void main() {
  Color inputBorder(WidgetTester tester, Finder field) {
    final decoration = tester
        .widget<CupertinoTextField>(
          find.descendant(of: field, matching: find.byType(CupertinoTextField)),
        )
        .decoration!;
    return (decoration.border! as Border).top.color;
  }

  Color selectBorder(WidgetTester tester) {
    final decorated = tester.widget<DecoratedBox>(
      find
          .descendant(
            of: find.byType(AcademySelect<String>),
            matching: find.byWidgetPredicate(
              (widget) =>
                  widget is DecoratedBox &&
                  widget.decoration is BoxDecoration &&
                  (widget.decoration as BoxDecoration).border is Border &&
                  // The focus outline is a transparent border around it.
                  ((widget.decoration as BoxDecoration).border! as Border)
                          .top
                          .color
                          .a >
                      0,
            ),
          )
          .first,
    );
    return ((decorated.decoration as BoxDecoration).border! as Border)
        .top
        .color;
  }

  Widget fields({bool highContrast = false, bool enabled = true}) =>
      academyHost(
        SizedBox(
          width: 320,
          child: Column(
            children: [
              AcademyTextInput(enabled: enabled),
              AcademyFloatingInput(label: 'Field', enabled: enabled),
              AcademySelect<String>(
                label: 'Select',
                value: null,
                enabled: enabled,
                options: const [AcademySelectOption(value: 'a', label: 'A')],
                onChanged: (_) {},
              ),
            ],
          ),
        ),
        highContrast: highContrast,
      );

  for (final (name, highContrast, enabled) in [
    ('resting', false, true),
    ('Increase Contrast', true, true),
    ('disabled', false, false),
    ('disabled with Increase Contrast', true, false),
  ]) {
    testWidgets('every field draws one border color: $name', (tester) async {
      await tester.pumpWidget(
        fields(highContrast: highContrast, enabled: enabled),
      );
      await tester.pumpAndSettle();
      final colors = {
        inputBorder(tester, find.byType(AcademyTextInput)),
        inputBorder(tester, find.byType(AcademyFloatingInput)),
        selectBorder(tester),
      };
      expect(colors, hasLength(1));
    });
  }

  testWidgets('a focused floating field uses the field focus role', (
    tester,
  ) async {
    final focus = FocusNode();
    addTearDown(focus.dispose);
    await tester.pumpWidget(
      academyHost(
        SizedBox(
          width: 320,
          child: AcademyFloatingInput(label: 'Field', focusNode: focus),
        ),
      ),
    );
    focus.requestFocus();
    await tester.pumpAndSettle();
    final theme = AcademyTheme.of(
      tester.element(find.byType(AcademyFloatingInput)),
    );
    expect(
      inputBorder(tester, find.byType(AcademyFloatingInput)),
      theme.colorScheme.textFieldFocusBorder,
    );
  });

  testWidgets('an invalid floating field uses the field error role', (
    tester,
  ) async {
    await tester.pumpWidget(
      academyHost(
        const SizedBox(
          width: 320,
          child: AcademyFloatingInput(label: 'Field', error: 'Ошибка'),
        ),
      ),
    );
    final theme = AcademyTheme.of(
      tester.element(find.byType(AcademyFloatingInput)),
    );
    expect(
      inputBorder(tester, find.byType(AcademyFloatingInput)),
      theme.colorScheme.textFieldErrorForeground,
    );
  });

  for (final direction in TextDirection.values) {
    testWidgets('the error icon gap follows $direction', (tester) async {
      await tester.pumpWidget(
        academyHost(
          const SizedBox(
            width: 320,
            child: AcademyFloatingInput(label: 'Field', error: 'Ошибка'),
          ),
          direction: direction,
        ),
      );
      final padding = tester.widget<Padding>(
        find
            .ancestor(
              of: find.byType(AcademySfIcon).last,
              matching: find.byType(Padding),
            )
            .first,
      );
      expect(
        padding.padding.resolve(direction),
        direction == TextDirection.ltr
            ? const EdgeInsets.only(top: 1, right: 4)
            : const EdgeInsets.only(top: 1, left: 4),
      );
    });
  }
}
