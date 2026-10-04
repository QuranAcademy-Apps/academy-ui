import 'package:academy_ui/academy_ui.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('expanding search shares input and preserves client ownership', (
    tester,
  ) async {
    final controller = TextEditingController(text: 'query');
    final focus = FocusNode();
    final submitted = <String>[];
    final changes = <String>[];
    final opened = <bool>[];
    addTearDown(controller.dispose);
    addTearDown(focus.dispose);

    Future<void> pump({bool enabled = true, bool readOnly = false}) async {
      await tester.pumpWidget(
        AcademyApp(
          home: Directionality(
            textDirection: TextDirection.rtl,
            child: Center(
              child: SizedBox(
                width: 320,
                child: AcademyExpandingSearch(
                  controller: controller,
                  focusNode: focus,
                  enabled: enabled,
                  readOnly: readOnly,
                  onSubmitted: submitted.add,
                  onChanged: changes.add,
                  onOpenChanged: opened.add,
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
    }

    await pump();
    await tester.tap(find.bySemanticsLabel('Открыть поиск'));
    await tester.pumpAndSettle();
    expect(focus.hasFocus, isTrue);
    expect(opened, [true]);
    final input = tester.widget<AcademyTextInput>(
      find.byType(AcademyTextInput),
    );
    expect(input.chrome, isTrue);
    expect(input.clearable, isFalse);
    expect(input.focusNode, same(focus));
    final field = find.byType(CupertinoTextField);
    await tester.enterText(field, 'new query');
    await tester.testTextInput.receiveAction(TextInputAction.search);
    await tester.pumpAndSettle();
    expect(submitted, ['new query']);
    expect(changes, ['new query']);

    await pump(readOnly: true);
    expect(tester.widget<CupertinoTextField>(field).readOnly, isTrue);
    await pump(enabled: false);
    expect(tester.widget<CupertinoTextField>(field).enabled, isFalse);
    expect(focus.hasFocus, isFalse);
    expect(controller.text, 'new query');
    await pump();
    await tester.tap(find.bySemanticsLabel('Закрыть поиск'));
    await tester.pumpAndSettle();
    expect(controller.text, isEmpty);
    expect(changes, ['new query', '']);
    expect(opened, [true, false]);

    await tester.pumpWidget(const SizedBox());
    // Caller objects remain usable after removal of the search widget.
    controller.text = 'still owned';
    focus.addListener(() {});
    expect(controller.text, 'still owned');
    expect(tester.takeException(), isNull);
  });
}
