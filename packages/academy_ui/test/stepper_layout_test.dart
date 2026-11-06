import 'package:academy_ui/academy_ui.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/academy_test_host.dart';

void main() {
  const track = ValueKey('academy-action-stepper-track');

  Widget stepper({
    TextDirection direction = TextDirection.ltr,
    VoidCallback? onDecrease,
    VoidCallback? onIncrease,
    bool centered = false,
    int Function()? hapticCount,
    AcademyInteractionTheme interaction = const AcademyInteractionTheme(),
  }) => academyHost(
    AcademyStepper.actions(
      onDecrease: onDecrease,
      onIncrease: onIncrease,
      centered: centered,
    ),
    direction: direction,
    interaction: interaction,
  );

  testWidgets('both halves have a name for accessibility', (tester) async {
    final handle = tester.ensureSemantics();
    await tester.pumpWidget(stepper(onDecrease: () {}, onIncrease: () {}));
    expect(find.bySemanticsLabel('Уменьшить'), findsOneWidget);
    expect(find.bySemanticsLabel('Увеличить'), findsOneWidget);
    expect(
      tester.getSemantics(find.bySemanticsLabel('Увеличить')),
      isSemantics(isButton: true),
    );
    handle.dispose();
  });

  testWidgets('a disabled half is announced as disabled', (tester) async {
    final handle = tester.ensureSemantics();
    await tester.pumpWidget(stepper(onIncrease: () {}));
    expect(
      tester.getSemantics(find.bySemanticsLabel('Уменьшить')),
      isSemantics(isEnabled: false, hasEnabledState: true),
    );
    handle.dispose();
  });

  testWidgets('taps follow the divider, not the middle of the box', (
    tester,
  ) async {
    var decreased = 0, increased = 0;
    await tester.pumpWidget(
      stepper(onDecrease: () => decreased++, onIncrease: () => increased++),
    );
    final origin = tester.getTopLeft(find.byType(AcademyStepper));
    // The divider is at 65: 60 lies on the minus half of the pill.
    await tester.tapAt(origin + const Offset(60, 22));
    expect((decreased, increased), (1, 0));
    await tester.tapAt(origin + const Offset(70, 22));
    expect((decreased, increased), (1, 1));
  });

  testWidgets('in RTL the pill sits at the end of its box', (tester) async {
    var decreased = 0, increased = 0;
    await tester.pumpWidget(
      stepper(
        direction: TextDirection.rtl,
        onDecrease: () => decreased++,
        onIncrease: () => increased++,
      ),
    );
    final box = tester.getRect(find.byType(AcademyStepper));
    expect(tester.getRect(find.byKey(track)).left, box.left);
    // The divider is at 47, and the larger plus target reaches toward the text.
    await tester.tapAt(box.topLeft + const Offset(40, 22));
    expect((decreased, increased), (1, 0));
    await tester.tapAt(box.topLeft + const Offset(100, 22));
    expect((decreased, increased), (1, 1));
  });

  testWidgets('a centered pill keeps an even split in both directions', (
    tester,
  ) async {
    for (final direction in TextDirection.values) {
      await tester.pumpWidget(
        stepper(
          direction: direction,
          centered: true,
          onDecrease: () {},
          onIncrease: () {},
        ),
      );
      final box = tester.getRect(find.byType(AcademyStepper));
      expect(tester.getCenter(find.byKey(track)).dx, box.center.dx);
    }
  });

  testWidgets('haptics follow the interaction theme', (tester) async {
    var clicks = 0;
    await tester.pumpWidget(
      stepper(
        onDecrease: () {},
        onIncrease: () {},
        interaction: AcademyInteractionTheme(selectionFeedback: () => clicks++),
      ),
    );
    await tester.tap(find.bySemanticsLabel('Увеличить'));
    expect(clicks, 1);
  });

  testWidgets('wide draws the same pill and reads the value', (tester) async {
    final handle = tester.ensureSemantics();
    var value = 1;
    await tester.pumpWidget(
      academyHost(
        StatefulBuilder(
          builder: (context, setState) => AcademyStepper(
            wide: true,
            value: value,
            max: 2,
            onChanged: (next) => setState(() => value = next),
          ),
        ),
      ),
    );
    expect(tester.getSize(find.byKey(track)), const Size(94, 32));
    expect(
      tester.getSemantics(find.bySemanticsLabel('Увеличить')),
      isSemantics(value: '1'),
    );
    await tester.tap(find.bySemanticsLabel('Увеличить'));
    await tester.pump();
    expect(value, 2);
    handle.dispose();
  });
}
