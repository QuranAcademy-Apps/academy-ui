import 'package:academy_ui/academy_ui.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets(
    'label animates on focus, stays raised with text, and returns after clearing',
    (tester) async {
      final controller = TextEditingController();
      final focus = FocusNode();
      addTearDown(controller.dispose);
      addTearDown(focus.dispose);
      await tester.pumpWidget(
        AcademyApp(
          home: Center(
            child: SizedBox(
              width: 320,
              child: AcademyFloatingInput(
                label: 'Почта',
                controller: controller,
                focusNode: focus,
                help: 'Для входа в профиль',
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      final label = find.text('Почта');
      final emptyTop = tester.getTopLeft(label).dy;
      final fieldRect = tester.getRect(find.byType(CupertinoTextField));
      focus.requestFocus();
      await tester.pump();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 60));
      final movingTop = tester.getTopLeft(label).dy;
      await tester.pumpAndSettle();
      final raisedTop = tester.getTopLeft(label).dy;
      expect(raisedTop, lessThan(movingTop));
      expect(movingTop, lessThan(emptyTop));
      await tester.enterText(
        find.byType(CupertinoTextField),
        'test@example.com',
      );
      focus.unfocus();
      await tester.pumpAndSettle();
      expect(tester.getTopLeft(label).dy, raisedTop);
      expect(tester.getRect(find.byType(CupertinoTextField)), fieldRect);
      controller.clear();
      await tester.pumpAndSettle();
      expect(tester.getTopLeft(label).dy, emptyTop);
      expect(tester.getRect(find.byType(CupertinoTextField)), fieldRect);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox());
    },
  );

  for (final direction in TextDirection.values) {
    testWidgets('floating input supports large text and $direction', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(320, 844);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      final controller = TextEditingController(text: 'ayub@example.com');
      addTearDown(controller.dispose);
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
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: AcademyFloatingInput(
                      label: 'Почта',
                      controller: controller,
                      allowClear: false,
                      suffix: const Icon(CupertinoIcons.checkmark),
                      error: 'Проверьте адрес почты',
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      final label = tester.getRect(find.text('Почта'));
      final editor = tester.getRect(find.byType(EditableText));
      expect(label.bottom, lessThanOrEqualTo(editor.top));
      expect(find.text('Проверьте адрес почты'), findsOneWidget);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox());
    });
  }

  testWidgets(
    'floating form field validates and resets without duplicate header',
    (tester) async {
      final form = GlobalKey<FormState>();
      await tester.pumpWidget(
        AcademyApp(
          home: Center(
            child: SizedBox(
              width: 320,
              child: Form(
                key: form,
                child: AcademyTextFormField(
                  label: 'Почта',
                  floatingLabel: true,
                  validator: (value) =>
                      value!.contains('@') ? null : 'Проверьте почту',
                ),
              ),
            ),
          ),
        ),
      );
      await tester.enterText(find.byType(CupertinoTextField), 'test');
      expect(form.currentState!.validate(), isFalse);
      await tester.pumpAndSettle();
      expect(find.text('Почта'), findsOneWidget);
      expect(find.text('Проверьте почту'), findsOneWidget);
      form.currentState!.reset();
      await tester.pumpAndSettle();
      expect(
        tester
            .widget<CupertinoTextField>(find.byType(CupertinoTextField))
            .controller!
            .text,
        isEmpty,
      );
      expect(find.text('Проверьте почту'), findsNothing);
    },
  );
}
