import 'package:academy_ui/academy_ui.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_sficon/flutter_sficon.dart' as sf;
import 'package:flutter_test/flutter_test.dart';

void main() {
  for (final direction in TextDirection.values) {
    testWidgets('Chevron resolves logical direction once in $direction', (
      tester,
    ) async {
      await tester.pumpWidget(
        AcademyApp(
          home: Directionality(
            textDirection: direction,
            child: const AcademyChevron(turns: .25),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(
        tester.widget<sf.SFIcon>(find.byType(sf.SFIcon)).icon,
        direction == TextDirection.rtl
            ? AcademySymbols.back
            : AcademySymbols.forward,
      );
      expect(
        tester.widget<AnimatedRotation>(find.byType(AnimatedRotation)).turns,
        .25,
      );
    });
  }
  for (final style in AcademyButtonStyle.values) {
    // AcademyActionButton offers the primary and tinted styles only.
    for (final action in [
      false,
      if (style == AcademyButtonStyle.primary ||
          style == AcademyButtonStyle.tinted)
        true,
    ]) {
      testWidgets(
        '$style ${action ? 'action' : 'standard'} pending blocks activation and announces loading',
        (tester) async {
          final semantics = tester.ensureSemantics();

          var calls = 0;
          await tester.pumpWidget(
            AcademyApp(
              home: SizedBox(
                width: 320,
                child: action
                    ? AcademyActionButton(
                        title: 'Save',
                        icon: AcademySymbols.plus,
                        style: style,
                        pending: true,
                        onPressed: () => calls++,
                      )
                    : AcademyButton(
                        label: 'Save',
                        style: style,
                        pending: true,
                        onPressed: () => calls++,
                      ),
              ),
            ),
          );
          await tester.pump();
          final native = tester.widget<CupertinoButton>(
            find.byType(CupertinoButton),
          );
          final context = tester.element(find.byType(CupertinoButton));
          final palette = AcademyTheme.of(context).colorScheme;
          expect(native.color, switch (style) {
            AcademyButtonStyle.primary => palette.actionFill,
            AcademyButtonStyle.tinted => palette.secondaryContainer,
            AcademyButtonStyle.neutral => palette.surfaceContainerHighest,
            AcademyButtonStyle.plain => palette.surface,
          });
          expect(native.onPressed, isNull);
          final node = tester.getSemantics(find.bySemanticsLabel('Save'));
          expect(
            node.getSemanticsData().value,
            AcademyLocalizations.of(context).loading,
          );
          expect(
            node.getSemanticsData().hasAction(SemanticsAction.tap),
            isFalse,
          );
          await tester.tap(find.byType(CupertinoButton), warnIfMissed: false);
          await tester.sendKeyEvent(LogicalKeyboardKey.tab);
          await tester.sendKeyEvent(LogicalKeyboardKey.enter);
          await tester.pump();
          expect(calls, 0);
          semantics.dispose();
        },
      );
    }
  }
  testWidgets('all table labels honor bodyRow override at 320 and 2x', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(320, 1000);
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      AcademyApp(
        typography: const AcademyTypographySettings(
          styles: {
            AcademyTextRole.bodyRow: TextStyle(fontSize: 18, height: 24 / 18),
            AcademyTextRole.bodyLarge: TextStyle(fontSize: 30),
          },
        ),
        home: Builder(
          builder: (context) => MediaQuery(
            data: MediaQuery.of(context)
                .copyWith(textScaler: TextScaler.linear(2)),
            child: AcademyTableBody(
              rows: [
                const AcademyRow(title: 'Ordinary label', showChevron: false),
                AcademyRow.action(
                  title: 'Action label',
                  action: 'Add',
                  onPressed: () {},
                ),
                const AcademyValueRow(
                  label: 'Value label',
                  value: 'Longer value text',
                ),
              ],
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    for (final label in [
      'Ordinary label',
      'Action label',
      'Value label',
      'Longer value text',
    ]) {
      final text = tester.widget<Text>(find.text(label));
      expect(text.style!.fontSize, 18);
      expect(text.style!.height, 24 / 18);
    }
    expect(tester.takeException(), isNull);
  });
  testWidgets('pill geometry responds to its own roles and explicit padding', (
    tester,
  ) async {
    await tester.pumpWidget(
      AcademyApp(
        radii: const AcademyRadii(menuButton: 2, pillButton: 19),
        paddings: const AcademyPaddings(
          menuButton: EdgeInsets.all(50),
          pillButton: EdgeInsets.all(7),
        ),
        home: Center(
          child: AcademyPillButton(label: 'Add', onPressed: () {}),
        ),
      ),
    );
    await tester.pumpAndSettle();
    final fill = tester.widget<DecoratedBox>(
      find
          .descendant(
            of: find.byType(AcademyPillButton),
            matching: find.byType(DecoratedBox),
          )
          .last,
    );
    expect(
      (fill.decoration as BoxDecoration).borderRadius,
      BorderRadius.circular(19),
    );
    expect(
      tester
          .widgetList<Padding>(
            find.descendant(
              of: find.byType(AcademyPillButton),
              matching: find.byType(Padding),
            ),
          )
          .any((p) => p.padding == const EdgeInsets.all(7)),
      isTrue,
    );
  });
}
