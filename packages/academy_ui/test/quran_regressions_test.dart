import 'package:academy_ui/academy_ui.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/academy_test_host.dart';

// Decisions the Quran app reached over its history that academy_ui had lost or
// never had (compared 2026-11-06):
// - a sheet's scroll inset uses the resting detent while the sheet moves;
// - the keyboard does not rebuild tabs;
// - pages inside a sheet have no barrier: it shows in the rounded corners;
// - a metrics change does not restart a sheet that is already at its detent;
// - static chrome paints apart from the content scrolling under it;
// - chrome and toasts stay clear of a landscape notch.

void main() {
  RenderObject boundaryOf(WidgetTester tester, Finder finder) {
    RenderObject render = tester.renderObject(finder);
    while (!render.isRepaintBoundary) {
      render = render.parent!;
    }
    return render;
  }

  group('sheet', () {
    testWidgets('pinned content keeps its height on every opening frame', (
      tester,
    ) async {
      phone(tester);
      tester.view.padding = const FakeViewPadding(top: 59, bottom: 34);
      const key = ValueKey('pinned');
      await openSheet(
        tester,
        builder: (_) => const AcademyModalFit(child: SizedBox.expand(key: key)),
      );
      final heights = <double>{};
      for (var frame = 0; frame < 60; frame++) {
        await tester.pump(const Duration(milliseconds: 16));
        final found = find.byKey(key);
        if (found.evaluate().isNotEmpty) {
          heights.add(tester.getSize(found).height);
        }
      }
      await tester.pumpAndSettle();
      final settled = tester.getSize(find.byKey(key)).height;
      expect(settled, greaterThan(0));
      expect(heights, {settled});
    });

    testWidgets('the scroll inset is the resting one while opening', (
      tester,
    ) async {
      phone(tester);
      tester.view.padding = const FakeViewPadding(top: 59, bottom: 34);
      final insets = <double>{};
      await openSheet(
        tester,
        builder: (context) {
          insets.add(ModalSheetScrollInsets.of(context));
          return const SizedBox.expand();
        },
      );
      for (var frame = 0; frame < 60; frame++) {
        await tester.pump(const Duration(milliseconds: 16));
      }
      await tester.pumpAndSettle();
      // Half of 844 below the medium detent, plus the home indicator.
      expect(insets, {456.0});
    });

    testWidgets('pages inside a sheet have no barrier', (tester) async {
      phone(tester);
      late BuildContext first;
      await openSheet(
        tester,
        nestedNavigation: true,
        builder: (context) {
          first = context;
          return const SizedBox.expand();
        },
      );
      await tester.pumpAndSettle();
      expect(ModalRoute.of(first)!.barrierColor, isNull);

      late BuildContext second;
      pushAcademyModalPage<void>(
        first,
        title: 'Second',
        builder: (context) {
          second = context;
          return const SizedBox.expand();
        },
      );
      await tester.pumpAndSettle();
      expect(ModalRoute.of(second)!.barrierColor, isNull);
    });

    testWidgets('a metrics change does not restart a settled sheet', (
      tester,
    ) async {
      phone(tester);
      await openSheet(
        tester,
        initialDetent: ModalSheetDetent.medium,
        builder: (_) => const SizedBox.expand(),
      );
      await tester.pumpAndSettle();
      tester.view.systemGestureInsets = const FakeViewPadding(bottom: 20);
      await tester.pump();
      expect(tester.binding.transientCallbackCount, 0);
    });

    testWidgets('the header paints apart from the content under it', (
      tester,
    ) async {
      phone(tester);
      const key = ValueKey('content');
      await openSheet(
        tester,
        initialDetent: ModalSheetDetent.medium,
        builder: (_) => const SizedBox.expand(key: key),
      );
      await tester.pumpAndSettle();
      expect(
        boundaryOf(tester, find.byType(AcademyChromeModalHeader)),
        isNot(same(boundaryOf(tester, find.byKey(key)))),
      );
    });
  });

  group('tabs', () {
    testWidgets('the keyboard does not rebuild a tab', (tester) async {
      phone(tester);
      tester.view.viewPadding = const FakeViewPadding(bottom: 34);
      tester.view.padding = const FakeViewPadding(bottom: 34);
      var builds = 0;
      await tester.pumpWidget(
        AcademyApp(
          home: AcademyTabScaffold(
            tabs: [
              AcademyTab(
                label: 'One',
                icon: AcademySymbols.book,
                builder: (_) {
                  builds++;
                  return const SizedBox.expand();
                },
              ),
            ],
          ),
        ),
      );
      await tester.pumpAndSettle();
      final before = builds;
      final barBottom = tester
          .getBottomLeft(find.byType(AcademyFloatingTabBar))
          .dy;
      for (var frame = 1; frame <= 10; frame++) {
        final keyboard = frame * 30.0;
        tester.view.viewInsets = FakeViewPadding(bottom: keyboard);
        // As the engine does: the keyboard consumes the bottom padding.
        tester.view.padding = FakeViewPadding(
          bottom: keyboard >= 34 ? 0 : 34 - keyboard,
        );
        await tester.pump();
      }
      expect(builds, before);
      expect(
        tester.getBottomLeft(find.byType(AcademyFloatingTabBar)).dy,
        barBottom,
      );
    });

    testWidgets('the selected telegram icon uses its own color', (
      tester,
    ) async {
      phone(tester);
      const selected = Color(0xFF123456);
      await tester.pumpWidget(
        AcademyApp(
          home: AcademyChromeTheme(
            style: AcademyChromeStyle.gradient,
            colors: const AcademyChromeColors(selectedIcon: selected),
            child: Center(
              child: AcademyFloatingTabBar(
                density: AcademyTabBarDensity.telegram,
                index: 0,
                onChanged: (_) {},
                tabs: [
                  AcademyTab(
                    label: 'One',
                    icon: AcademySymbols.book,
                    builder: (_) => const SizedBox(),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
      expect(
        tester.widget<AcademySfIcon>(find.byType(AcademySfIcon)).color,
        selected,
      );
    });
  });

  group('pages', () {
    testWidgets('static chrome paints apart from the page content', (
      tester,
    ) async {
      phone(tester);
      const key = ValueKey('content');
      await tester.pumpWidget(
        const AcademyApp(
          home: AcademyPage(
            title: 'Page',
            child: SizedBox.expand(key: key),
          ),
        ),
      );
      expect(
        boundaryOf(tester, find.byType(AcademyChromeBar)),
        isNot(same(boundaryOf(tester, find.byKey(key)))),
      );

      await tester.pumpWidget(
        const AcademyApp(
          home: AcademyChromePage(
            title: 'Page',
            child: SizedBox.expand(key: key),
          ),
        ),
      );
      expect(
        boundaryOf(tester, find.byType(AcademyChromeBar)),
        isNot(same(boundaryOf(tester, find.byKey(key)))),
      );
    });

    testWidgets('AcademyChromePage keeps its bar clear of a notch', (
      tester,
    ) async {
      phone(tester, size: const Size(844, 390));
      tester.view.padding = const FakeViewPadding(left: 47, right: 47);
      await tester.pumpWidget(
        const AcademyApp(
          home: AcademyChromePage(title: 'Page', child: SizedBox.expand()),
        ),
      );
      final bar = tester.getRect(find.byType(AcademyChromeBar));
      expect(bar.left, 47);
      expect(bar.right, 844 - 47);
    });
  });

  group('toast overlay', () {
    Widget overlay() => const AcademyApp(
      home: AcademyToastOverlay(
        message: 'Saved',
        position: AcademyToastPosition.bottom,
      ),
    );

    testWidgets('does not move under Reduce Motion', (tester) async {
      phone(tester);
      // Set on the platform: the toast paints in the root overlay, above any
      // MediaQuery a page could wrap it in.
      tester.platformDispatcher.accessibilityFeaturesTestValue =
          const FakeAccessibilityFeatures(disableAnimations: true);
      addTearDown(
        tester.platformDispatcher.clearAccessibilityFeaturesTestValue,
      );
      await tester.pumpWidget(overlay());
      await tester.pump();
      expect(
        tester.widget<AnimatedSlide>(find.byType(AnimatedSlide)).duration,
        Duration.zero,
      );
      expect(
        tester.widget<AnimatedOpacity>(find.byType(AnimatedOpacity)).duration,
        Duration.zero,
      );
    });

    testWidgets('stays clear of a notch', (tester) async {
      phone(tester, size: const Size(844, 390));
      tester.view.padding = const FakeViewPadding(left: 47, right: 47);
      await tester.pumpWidget(overlay());
      await tester.pump();
      final positioned = tester.widget<Positioned>(
        find
            .ancestor(
              of: find.byType(AnimatedSlide),
              matching: find.byType(Positioned),
            )
            .first,
      );
      expect(positioned.left, 16 + 47);
      expect(positioned.right, 16 + 47);
    });
  });

  group('lists', () {
    testWidgets('AcademyPicker builds only the rows near the wheel', (
      tester,
    ) async {
      phone(tester);
      var labels = 0;
      await tester.pumpWidget(
        AcademyApp(
          home: Center(
            child: AcademyPicker<int>(
              items: List.generate(2000, (index) => index),
              value: 0,
              labelFor: (item) {
                labels++;
                return '$item';
              },
              onChanged: (_) {},
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(labels, lessThan(40));
    });

    testWidgets('AcademyPicker keeps a long label on one line', (tester) async {
      phone(tester);
      await tester.pumpWidget(
        AcademyApp(
          home: Center(
            child: AcademyPicker<String>(
              items: ['A very long label ' * 10],
              value: 'A very long label ' * 10,
              labelFor: (item) => item,
              onChanged: (_) {},
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      final text = tester.widget<Text>(find.textContaining('A very long'));
      expect(text.maxLines, 1);
      expect(text.overflow, TextOverflow.ellipsis);
    });

    testWidgets('a sliver table builds each row once when scrolled down', (
      tester,
    ) async {
      phone(tester);
      final builds = <int, int>{};
      await tester.pumpWidget(
        AcademyApp(
          home: CustomScrollView(
            slivers: [
              AcademySliverGroupedTable(
                itemCount: 100,
                itemBuilder: (_, index) {
                  builds[index] = (builds[index] ?? 0) + 1;
                  return SizedBox(height: 60, child: Text('Row $index'));
                },
              ),
            ],
          ),
        ),
      );
      await tester.pumpAndSettle();
      // The app rebuilds its first rows while it starts; count what scrolling
      // brings in.
      builds.clear();
      final position = tester
          .state<ScrollableState>(find.byType(Scrollable))
          .position;
      for (var step = 1; step <= 40; step++) {
        position.jumpTo(step * 50.0);
        await tester.pump();
      }
      expect(builds.length, greaterThan(20));
      expect(builds.values.where((count) => count > 1), isEmpty);
    });

    testWidgets('a sliver table takes the separator from the previous row', (
      tester,
    ) async {
      phone(tester);
      await tester.pumpWidget(
        AcademyApp(
          home: CustomScrollView(
            slivers: [
              AcademySliverGroupedTable(
                itemCount: 2,
                itemBuilder: (_, index) => AcademyRow(title: 'Row $index'),
              ),
            ],
          ),
        ),
      );
      await tester.pump();
      expect(find.byType(AcademyTableSeparator), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });
}
