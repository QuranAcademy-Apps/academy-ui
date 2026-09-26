import 'package:academy_ui/academy_ui.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('partial overrides keep defaults and do not alter client colors', () {
    final defaults = AcademyPalette(Brightness.light, AcademyTokens.brand);
    final custom = defaults.copyWith(
      primary: const Color(0xFFFFFF00),
      segmentBackground: const Color(0xFF224466),
      toneForegrounds: {AcademyTone.success: const Color(0xFF012345)},
    );
    expect(custom.primary, const Color(0xFFFFFF00));
    expect(custom.surface, defaults.surface);
    expect(custom.segmentBackground, const Color(0xFF224466));
    expect(custom.toneForeground(AcademyTone.success), const Color(0xFF012345));
    expect(
      custom.toneForeground(AcademyTone.error),
      defaults.toneForeground(AcademyTone.error),
    );
    expect(defaults.segmentBackground, isNot(custom.segmentBackground));
  });

  testWidgets(
    'client colors reach fields, status, segments and an open modal',
    (tester) async {
      final appearance = AcademyAppearanceController(
        initial: const AcademyAppearance(mode: AcademyAppearanceMode.light),
      );
      await appearance.ready;
      addTearDown(appearance.dispose);
      const customField = Color(0xFF123456);
      const customSegment = Color(0xFF246810);
      const customShadow = Color(0x88224466);
      const customStatus = Color(0xFF334455);
      const customBarrier = Color(0x44332211);
      Color? observedBarrier;
      Color? observedModalSurface;
      await tester.pumpWidget(
        AcademyApp(
          appearance: appearance,
          colorsBuilder: (brightness, accent) =>
              AcademyPalette(brightness, accent).copyWith(
                scaffoldBackground: const Color(0xFF345678),
                surface: brightness == Brightness.light
                    ? const Color(0xFFABCDEF)
                    : const Color(0xFF654321),
                surfaceContainerHighest: customField,
                segmentBackground: customSegment,
                segmentShadow: customShadow,
                toneContainers: {AcademyTone.warning: customStatus},
                modalBarrier: customBarrier,
              ),
          home: Builder(
            builder: (context) => Center(
              child: SizedBox(
                width: 320,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const AcademyField(label: 'Name'),
                    const AcademyStatus(
                      label: 'Status',
                      tone: AcademyTone.warning,
                    ),
                    AcademyCompactSegment<int>(
                      items: const [1, 2],
                      value: 1,
                      labelFor: (value) => '$value',
                      onChanged: (_) {},
                    ),
                    CupertinoButton(
                      child: const Text('Open'),
                      onPressed: () {
                        showAcademyModal<void>(
                          context,
                          title: 'Modal',
                          builder: (sheetContext) {
                            observedBarrier = ModalRoute.of(sheetContext)!
                                .barrierColor;
                            observedModalSurface = AcademyTheme.of(sheetContext)
                                .colorScheme
                                .surface;
                            return const AcademyField(label: 'Modal field');
                          },
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(
        tester
            .widget<CupertinoTextField>(find.byType(CupertinoTextField))
            .decoration!
            .color,
        customField,
      );
      final status = tester.widget<Container>(
        find
            .descendant(
              of: find.byType(AcademyStatus),
              matching: find.byType(Container),
            )
            .first,
      );
      expect((status.decoration! as BoxDecoration).color, customStatus);
      final boxes = tester
          .widgetList<DecoratedBox>(
            find.descendant(
              of: find.byType(AcademyCompactSegment<int>),
              matching: find.byType(DecoratedBox),
            ),
          )
          .map((box) => box.decoration)
          .whereType<BoxDecoration>();
      expect(boxes.any((box) => box.color == customSegment), isTrue);
      expect(
        boxes.any(
          (box) =>
              box.boxShadow?.any((shadow) => shadow.color == customShadow) ??
              false,
        ),
        isTrue,
      );
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();
      expect(observedBarrier, customBarrier);
      expect(observedModalSurface, const Color(0xFFABCDEF));
      appearance.update(
        appearance.value.copyWith(mode: AcademyAppearanceMode.dark),
      );
      await tester.pumpAndSettle();
      expect(observedModalSurface, const Color(0xFF654321));
      expect(tester.takeException(), isNull);
    },
  );
}
