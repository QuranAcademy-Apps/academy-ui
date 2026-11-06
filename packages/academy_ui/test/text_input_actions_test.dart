import 'package:academy_ui/academy_ui.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/academy_test_host.dart';

void main() {
  final variants =
      <
        String,
        Widget Function(
          FocusNode focus,
          TextInputAction action,
          ValueChanged<String> onSubmitted,
        )
      >{
        'AcademyTextInput': (focus, action, onSubmitted) => AcademyTextInput(
          focusNode: focus,
          textInputAction: action,
          onSubmitted: onSubmitted,
        ),
        'AcademyFloatingInput': (focus, action, onSubmitted) =>
            AcademyFloatingInput(
              label: 'Field',
              focusNode: focus,
              textInputAction: action,
              onSubmitted: onSubmitted,
            ),
      };

  variants.forEach((name, field) {
    testWidgets('$name: next moves on, done closes the keyboard', (
      tester,
    ) async {
      final first = FocusNode(), second = FocusNode();
      addTearDown(first.dispose);
      addTearDown(second.dispose);
      final submitted = <String>[];
      await tester.pumpWidget(
        academyHost(
          SizedBox(
            width: 320,
            child: Column(
              children: [
                field(first, TextInputAction.next, submitted.add),
                field(second, TextInputAction.done, submitted.add),
              ],
            ),
          ),
        ),
      );
      await tester.showKeyboard(find.byType(CupertinoTextField).first);
      await tester.pump();
      expect(first.hasFocus, isTrue);

      await tester.testTextInput.receiveAction(TextInputAction.next);
      await tester.pump();
      expect(first.hasFocus, isFalse);
      expect(second.hasFocus, isTrue);

      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pump();
      expect(second.hasFocus, isFalse);
      expect(submitted, hasLength(2));
    });
  });

  testWidgets('dropping a supplied controller keeps the text in every field', (
    tester,
  ) async {
    final controller = TextEditingController(text: 'kept');
    addTearDown(controller.dispose);
    Future<void> pump(TextEditingController? value) => tester.pumpWidget(
      academyHost(
        SizedBox(
          width: 320,
          child: Column(
            children: [
              AcademyTextInput(controller: value),
              AcademyFloatingInput(label: 'Field', controller: value),
            ],
          ),
        ),
      ),
    );
    await pump(controller);
    await pump(null);
    expect(find.text('kept'), findsNWidgets(2));
  });
}
