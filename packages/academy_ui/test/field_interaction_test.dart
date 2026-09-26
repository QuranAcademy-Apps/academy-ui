import 'package:academy_ui/academy_ui.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets(
    'clear button clears text, notifies once and preserves focus and geometry',
    (tester) async {
      final semantics = tester.ensureSemantics();
      final controller = TextEditingController();
      addTearDown(controller.dispose);
      final changes = <String>[];
      await tester.pumpWidget(
        AcademyApp(
          home: Center(
            child: SizedBox(
              width: 300,
              child: AcademyField(
                label: 'Name',
                controller: controller,
                onChanged: changes.add,
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      final initial = tester.getRect(find.byType(EditableText));
      expect(find.bySemanticsLabel('Очистить Name'), findsNothing);
      await tester.enterText(find.byType(CupertinoTextField), 'abc');
      await tester.pumpAndSettle();
      expect(tester.getRect(find.byType(EditableText)), initial);
      expect(find.bySemanticsLabel('Очистить Name'), findsOneWidget);
      await tester.tap(find.bySemanticsLabel('Очистить Name'));
      await tester.pumpAndSettle();
      expect(controller.text, isEmpty);
      expect(changes, ['abc', '']);
      expect(
        tester
            .widget<CupertinoTextField>(find.byType(CupertinoTextField))
            .focusNode!
            .hasFocus,
        isTrue,
      );
      expect(tester.getRect(find.byType(EditableText)), initial);
      await tester.pumpWidget(const SizedBox());
      controller.text = 'Still owned by client';
      semantics.dispose();
    },
  );

  testWidgets('focus border animates in both directions without layout shift', (
    tester,
  ) async {
    await tester.pumpWidget(
      const AcademyApp(
        home: Center(
          child: SizedBox(width: 300, child: AcademyField(label: 'Name')),
        ),
      ),
    );
    await tester.pumpAndSettle();
    Color border() =>
        (tester
                    .widget<CupertinoTextField>(find.byType(CupertinoTextField))
                    .decoration!
                    .border!
                as Border)
            .top
            .color;
    final resting = border();
    final geometry = tester.getRect(find.byType(EditableText));
    await tester.tap(find.byType(CupertinoTextField));
    await tester.pump();
    expect(border(), resting);
    await tester.pump(const Duration(milliseconds: 90));
    final halfway = border();
    expect(halfway, isNot(resting));
    expect(halfway, isNot(academyTheme(Brightness.light).colorScheme.primary));
    expect(tester.getRect(find.byType(EditableText)), geometry);
    await tester.pump(const Duration(milliseconds: 100));
    final focused = border();
    expect(focused, academyTheme(Brightness.light).colorScheme.primary);
    FocusManager.instance.primaryFocus!.unfocus();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 90));
    expect(border(), isNot(focused));
    expect(border(), isNot(resting));
    await tester.pump(const Duration(milliseconds: 100));
    expect(border(), resting);
    expect(tester.getRect(find.byType(EditableText)), geometry);
  });

  testWidgets(
    'disabled field cannot clear and reduced motion skips transitions',
    (tester) async {
      final controller = TextEditingController(text: 'Saved');
      addTearDown(controller.dispose);
      await tester.pumpWidget(
        AcademyApp(
          home: Builder(
            builder: (context) => MediaQuery(
              data: MediaQuery.of(context).copyWith(disableAnimations: true),
              child: Center(
                child: SizedBox(
                  width: 300,
                  child: AcademyField(
                    label: 'Disabled',
                    enabled: false,
                    controller: controller,
                  ),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.bySemanticsLabel('Очистить Disabled'), findsNothing);
      expect(controller.text, 'Saved');
      final tween = tester.widget<TweenAnimationBuilder<Color?>>(
        find.byType(TweenAnimationBuilder<Color?>),
      );
      expect(tween.duration, Duration.zero);
    },
  );
}
