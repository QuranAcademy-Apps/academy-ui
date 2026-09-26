import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stupid_simple_sheet/stupid_simple_sheet.dart';

import 'package:academy_ui/academy_ui.dart';

// Adapted from Quran's modal_sheet_scroll_inset_test.dart. These contracts
// preserve the detent/safe-area seam without donor theme or reader dependencies.
void main() {
  const portrait = Size(400, 800);

  late StupidSimpleSheetController<dynamic> controller;
  late BuildContext sheetContext;

  Future<void> pumpFrames(WidgetTester tester) async {
    for (var i = 0; i < 6; i++) {
      await tester.pump(const Duration(milliseconds: 16));
    }
    await tester.pumpAndSettle();
  }

  Future<void> openSheet(
    WidgetTester tester, {
    required List<ModalSheetDetent> detents,
    required ModalSheetDetent initial,
    FakeViewPadding? padding,
    WidgetBuilder? builder,
  }) async {
    tester.view.devicePixelRatio = 1.0;
    tester.view.physicalSize = portrait;
    if (padding != null) tester.view.padding = padding;
    late BuildContext rootContext;
    await tester.pumpWidget(
      AcademyApp(
        home: Builder(
          builder: (context) {
            rootContext = context;
            return const CupertinoPageScaffold(child: SizedBox.expand());
          },
        ),
      ),
    );
    showAcademyModalRoute<void>(
      context: rootContext,
      snappingConfig: modalSheetSnappingConfig(
        context: rootContext,
        detents: detents,
        initialDetent: initial,
      ),
      builder:
          builder ??
          (_) => LandscapeModalSheetFrame(
            child: Builder(
              builder: (context) {
                sheetContext = context;
                controller = StupidSimpleSheetController.maybeOf<dynamic>(
                  context,
                )!;
                return const ColoredBox(
                  color: CupertinoColors.white,
                  child: SizedBox.expand(),
                );
              },
            ),
          ),
    );
    await pumpFrames(tester);
  }

  testWidgets('resting at 0.6: off-screen slice + bottom safe area', (
    tester,
  ) async {
    addTearDown(tester.view.reset);
    await openSheet(
      tester,
      detents: [ModalSheetDetent.custom(0.6)],
      initial: ModalSheetDetent.custom(0.6),
    );

    // (1 - 0.6) * 800 + 0.
    expect(ModalSheetScrollInsets.of(sheetContext), closeTo(320, 0.5));
  });

  testWidgets('bottom safe area is added; top safe area cancels', (
    tester,
  ) async {
    addTearDown(tester.view.reset);
    await openSheet(
      tester,
      detents: [ModalSheetDetent.custom(0.6)],
      initial: ModalSheetDetent.custom(0.6),
      padding: const FakeViewPadding(top: 40, bottom: 20),
    );

    // (1 - 0.6) * 800 + bottom(20); top(40) cancels against full.heightOf.
    expect(ModalSheetScrollInsets.of(sheetContext), closeTo(340, 0.5));
    // A pinned footer already sits in a full-height child whose bottom is
    // offset by the full detent's top-safe-area subtraction.
    expect(
      ModalSheetScrollInsets.pinnedBottomOf(sheetContext),
      closeTo(300, 0.5),
    );
  });

  testWidgets('full detent: collapses to the safe-area gap only', (
    tester,
  ) async {
    addTearDown(tester.view.reset);
    await openSheet(
      tester,
      detents: [ModalSheetDetent.full],
      initial: ModalSheetDetent.full,
      padding: const FakeViewPadding(top: 40, bottom: 20),
    );

    // `full.heightOf` subtracts the top safe area, so the full detent rests at
    // (800-40)/800 = 0.95 of the raw route height — the same 5% off-screen slice
    // the legacy fixed-detent inset produced: top(40) + bottom(20).
    expect(ModalSheetScrollInsets.of(sheetContext), closeTo(60, 0.5));
    expect(
      ModalSheetScrollInsets.pinnedBottomOf(sheetContext),
      closeTo(20, 0.5),
    );
  });

  testWidgets('tracks a runtime detent override', (tester) async {
    addTearDown(tester.view.reset);
    await openSheet(
      tester,
      detents: [ModalSheetDetent.custom(0.6), ModalSheetDetent.full],
      initial: ModalSheetDetent.custom(0.6),
    );
    expect(ModalSheetScrollInsets.of(sheetContext), closeTo(320, 0.5));

    // setModalSheetDetentHeight overrides the config and animates; the provider
    // listens to the sheet animation, so the inset follows.
    controller.overrideSnappingConfig(
      const SheetSnappingConfig([0.4], initialSnap: 0.4),
      animateToComply: true,
    );
    await pumpFrames(tester);

    // (1 - 0.4) * 800 = 480.
    expect(ModalSheetScrollInsets.of(sheetContext), closeTo(480, 0.5));
  });

  testWidgets('outside a sheet: ModalSheetScrollInsets.of is 0', (
    tester,
  ) async {
    addTearDown(tester.view.reset);
    tester.view.devicePixelRatio = 1.0;
    tester.view.physicalSize = portrait;
    late BuildContext context;
    await tester.pumpWidget(
      CupertinoApp(
        home: Builder(
          builder: (ctx) {
            context = ctx;
            return const CupertinoPageScaffold(child: SizedBox.expand());
          },
        ),
      ),
    );

    expect(ModalSheetScrollInsets.of(context), 0);
    expect(ModalSheetScrollInsets.pinnedBottomOf(context), 0);
  });
}
