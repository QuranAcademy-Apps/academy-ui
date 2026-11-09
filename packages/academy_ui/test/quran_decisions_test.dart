import 'dart:async';

import 'package:academy_ui/academy_ui.dart';
import 'package:academy_ui/src/foundation/layout/academy_stable_top_inset.dart'
    show AcademyTopInsetMemory;
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/academy_test_host.dart';

// Solutions the Quran app reached over its history, moved into academy_ui
// (2026-11-06). Behavior of existing screens stays the same unless they opt in.

void main() {
  group('AcademyDeferredRouteInit', () {
    testWidgets('waits for the entry transition of a page route', (
      tester,
    ) async {
      final navigator = GlobalKey<NavigatorState>();
      var fired = 0;
      await tester.pumpWidget(
        CupertinoApp(navigatorKey: navigator, home: const SizedBox()),
      );
      navigator.currentState!.push(
        CupertinoPageRoute<void>(
          builder: (_) => _DeferredProbe(onFire: () => fired++),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));
      expect(fired, 0);
      await tester.pumpAndSettle();
      expect(fired, 1);
    });

    testWidgets('fires for a route pushed without animation', (tester) async {
      final navigator = GlobalKey<NavigatorState>();
      var fired = 0;
      await tester.pumpWidget(
        CupertinoApp(navigatorKey: navigator, home: const SizedBox()),
      );
      navigator.currentState!.push(
        PageRouteBuilder<void>(
          transitionDuration: Duration.zero,
          pageBuilder: (_, _, _) => _DeferredProbe(onFire: () => fired++),
        ),
      );
      await tester.pump();
      await tester.pump();
      await tester.pump();
      expect(fired, 1);
    });

    testWidgets('fires for the initial route', (tester) async {
      var fired = 0;
      await tester.pumpWidget(
        CupertinoApp(home: _DeferredProbe(onFire: () => fired++)),
      );
      await tester.pump();
      await tester.pump();
      expect(fired, 1);
    });

    testWidgets('waits for the sheet around a nested navigator', (
      tester,
    ) async {
      phone(tester);
      var fired = 0;
      await openSheet(
        tester,
        nestedNavigation: true,
        builder: (_) => _DeferredProbe(onFire: () => fired++),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));
      await tester.pump(const Duration(milliseconds: 50));
      expect(fired, 0);
      await tester.pumpAndSettle();
      expect(fired, 1);
    });

    testWidgets('academyIsRouteTransitionActive follows a push', (
      tester,
    ) async {
      final navigator = GlobalKey<NavigatorState>();
      late BuildContext page;
      await tester.pumpWidget(
        CupertinoApp(navigatorKey: navigator, home: const SizedBox()),
      );
      navigator.currentState!.push(
        CupertinoPageRoute<void>(
          builder: (context) {
            page = context;
            return const SizedBox();
          },
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));
      expect(academyIsRouteTransitionActive(ModalRoute.of(page)), isTrue);
      await tester.pumpAndSettle();
      expect(academyIsRouteTransitionActive(ModalRoute.of(page)), isFalse);
      expect(academyIsRouteTransitionActive(null), isFalse);
    });
  });

  group('AcademyScrollToTop', () {
    Future<void> statusBarTap(WidgetTester tester) async {
      final response = Completer<void>();
      await TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .handlePlatformMessage(
            'flutter/status_bar',
            const JSONMethodCodec().encodeMethodCall(
              const MethodCall('handleScrollToTop'),
            ),
            (_) => response.complete(),
          );
      await response.future;
      await tester.pumpAndSettle();
    }

    Widget list(ScrollController controller) => ListView.builder(
      controller: controller,
      itemExtent: 80,
      itemCount: 100,
      itemBuilder: (_, index) => Text('$index'),
    );

    testWidgets('scrolls the visible list, even below the safe area', (
      tester,
    ) async {
      final controller = ScrollController();
      addTearDown(controller.dispose);
      var before = 0;
      await tester.pumpWidget(
        CupertinoApp(
          home: Padding(
            padding: const EdgeInsets.only(top: 80),
            child: AcademyScrollToTop(
              controller: controller,
              onBeforeScroll: () => before++,
              child: list(controller),
            ),
          ),
        ),
      );
      controller.jumpTo(600);
      await statusBarTap(tester);
      expect(controller.offset, 0);
      expect(before, 1);
    });

    testWidgets('an ordinary tap calls onTap without scrolling', (
      tester,
    ) async {
      final controller = ScrollController();
      addTearDown(controller.dispose);
      var tapped = 0, before = 0;
      await tester.pumpWidget(
        CupertinoApp(
          home: AcademyScrollToTop(
            controller: controller,
            onBeforeScroll: () => before++,
            onTap: () => tapped++,
            child: list(controller),
          ),
        ),
      );
      controller.jumpTo(600);
      await tester.tapAt(const Offset(200, 20));
      await tester.pumpAndSettle();
      expect(tapped, 1);
      expect(before, 0);
      expect(controller.offset, 600);
    });

    testWidgets('ignores a hidden tab', (tester) async {
      final visible = ScrollController(), hidden = ScrollController();
      addTearDown(visible.dispose);
      addTearDown(hidden.dispose);
      await tester.pumpWidget(
        CupertinoApp(
          home: IndexedStack(
            children: [
              AcademyScrollToTop(controller: visible, child: list(visible)),
              AcademyScrollToTop(controller: hidden, child: list(hidden)),
            ],
          ),
        ),
      );
      visible.jumpTo(600);
      hidden.jumpTo(600);
      await statusBarTap(tester);
      expect(visible.offset, 0);
      expect(hidden.offset, 600);
    });

    testWidgets('ignores a background route', (tester) async {
      final navigator = GlobalKey<NavigatorState>();
      final controller = ScrollController();
      addTearDown(controller.dispose);
      await tester.pumpWidget(
        CupertinoApp(
          navigatorKey: navigator,
          home: AcademyScrollToTop(
            controller: controller,
            child: list(controller),
          ),
        ),
      );
      controller.jumpTo(600);
      unawaited(
        navigator.currentState!.push<void>(
          CupertinoPageRoute<void>(builder: (_) => const SizedBox.expand()),
        ),
      );
      await tester.pumpAndSettle();
      await statusBarTap(tester);
      expect(controller.offset, 600);
    });

    testWidgets('respects enabled', (tester) async {
      final controller = ScrollController();
      addTearDown(controller.dispose);
      await tester.pumpWidget(
        CupertinoApp(
          home: AcademyScrollToTop(
            controller: controller,
            enabled: false,
            child: list(controller),
          ),
        ),
      );
      controller.jumpTo(600);
      await statusBarTap(tester);
      expect(controller.offset, 600);
    });
  });

  group('AcademyStableTopInset', () {
    setUp(AcademyTopInsetMemory.instance.reset);

    Future<double> topOf(
      WidgetTester tester, {
      required double top,
      Size size = const Size(400, 800),
    }) async {
      late double seen;
      await tester.pumpWidget(
        MediaQuery(
          data: MediaQueryData(
            size: size,
            padding: EdgeInsets.only(top: top),
          ),
          child: AcademyStableTopInset(
            child: Builder(
              builder: (context) {
                seen = MediaQuery.paddingOf(context).top;
                return const SizedBox();
              },
            ),
          ),
        ),
      );
      return seen;
    }

    testWidgets('keeps the inset when the status bar hides', (tester) async {
      expect(await topOf(tester, top: 24), 24);
      expect(await topOf(tester, top: 0), 24);
    });

    testWidgets('takes a new inset on rotation', (tester) async {
      expect(await topOf(tester, top: 24), 24);
      expect(await topOf(tester, top: 0, size: const Size(800, 400)), 0);
    });

    testWidgets('reserves a remembered inset on the first frame', (
      tester,
    ) async {
      AcademyTopInsetMemory.instance.observe(
        const MediaQueryData(
          size: Size(400, 800),
          padding: EdgeInsets.only(top: 24),
        ),
      );
      expect(await topOf(tester, top: 0), 24);
    });

    test('memory skips hidden bars and the frame of a rotation', () {
      final memory = AcademyTopInsetMemory.instance;
      const portrait = Size(400, 800), landscape = Size(800, 400);
      memory.observe(
        const MediaQueryData(size: portrait, padding: EdgeInsets.only(top: 24)),
      );
      memory.observe(const MediaQueryData(size: portrait));
      expect(memory.reservedFor(Orientation.portrait), 24);
      // New size with the stale padding of the previous orientation.
      memory.observe(
        const MediaQueryData(
          size: landscape,
          padding: EdgeInsets.only(top: 24),
        ),
      );
      expect(memory.reservedFor(Orientation.landscape), 0);
      memory.observe(
        const MediaQueryData(
          size: landscape,
          padding: EdgeInsets.only(top: 20),
        ),
      );
      expect(memory.reservedFor(Orientation.landscape), 20);
    });
  });

  group('Android insets', () {
    tearDown(() => debugDefaultTargetPlatformOverride = null);
    const media = MediaQueryData(
      size: Size(400, 800),
      systemGestureInsets: EdgeInsets.only(bottom: 30),
    );

    test('other platforms use the safe area, at least 8', () {
      debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
      expect(academyAndroidChromeBottomInset(media), 8);
      expect(
        academyAndroidChromeBottomInset(
          media.copyWith(padding: const EdgeInsets.only(bottom: 34)),
        ),
        34,
      );
    });

    test('Android caps the corner radius by the gesture inset', () {
      debugDefaultTargetPlatformOverride = TargetPlatform.android;
      expect(academyAndroidChromeBottomInset(media), 30);
      expect(
        academyAndroidChromeBottomInset(media, roundedCornerInset: 16),
        16,
      );
      expect(
        academyAndroidChromeBottomInset(media, roundedCornerInset: 90),
        30,
      );
    });

    test('button navigation clears the whole bar', () {
      debugDefaultTargetPlatformOverride = TargetPlatform.android;
      expect(
        academyAndroidChromeBottomInset(
          media,
          roundedCornerInset: 16,
          gestureNavigation: false,
        ),
        30,
      );
    });

    test('landscape side insets take the bottom inset on Android only', () {
      const landscape = MediaQueryData(
        size: Size(800, 400),
        padding: EdgeInsets.only(left: 10, bottom: 24),
      );
      debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
      expect(academyNormalizedAndroidLandscape(landscape), landscape);
      debugDefaultTargetPlatformOverride = TargetPlatform.android;
      final result = academyNormalizedAndroidLandscape(landscape);
      expect(result.padding.left, 24);
      expect(result.padding.right, 24);
      expect(
        academyNormalizedAndroidLandscape(
          landscape.copyWith(size: const Size(400, 800)),
        ).padding.left,
        10,
      );
    });
  });

  group('page insets', () {
    Future<double> bottomOf(
      WidgetTester tester,
      Widget Function(Widget probe) page, {
      double Function(BuildContext)? chromeBottomInsetOf,
    }) async {
      late double seen;
      await tester.pumpWidget(
        AcademyApp(
          chromeBottomInsetOf: chromeBottomInsetOf,
          home: page(
            Builder(
              builder: (context) {
                seen = AcademyPageInsets.bottomOf(context);
                return const SizedBox.expand();
              },
            ),
          ),
        ),
      );
      return seen;
    }

    testWidgets('a pushed page: safe area, at least 8, plus the gap', (
      tester,
    ) async {
      phone(tester);
      Widget page(Widget child) => AcademyPage(title: 'P', child: child);
      expect(await bottomOf(tester, page), 8 + 16);
      tester.view.padding = const FakeViewPadding(bottom: 34);
      await tester.pump();
      expect(await bottomOf(tester, page), 34 + 16);
    });

    testWidgets('a custom gap', (tester) async {
      phone(tester);
      expect(
        await bottomOf(
          tester,
          (child) => AcademyPage(title: 'P', bottomGap: 24, child: child),
        ),
        8 + 24,
      );
    });

    testWidgets('a page above the tab bar clears it', (tester) async {
      phone(tester);
      tester.view.padding = const FakeViewPadding(bottom: 34);
      expect(
        await bottomOf(
          tester,
          (child) => AcademyPage(title: 'P', hasTabBar: true, child: child),
        ),
        34 + 60 + 24,
      );
    });

    testWidgets('AcademyChromePage falls back to the same default', (
      tester,
    ) async {
      phone(tester);
      tester.view.padding = const FakeViewPadding(bottom: 34);
      expect(
        await bottomOf(
          tester,
          (child) => AcademyChromePage(title: 'P', child: child),
        ),
        34 + 16,
      );
    });

    testWidgets('chromeBottomInsetOf replaces the chrome bottom', (
      tester,
    ) async {
      phone(tester);
      expect(
        await bottomOf(
          tester,
          (child) => AcademyPage(title: 'P', child: child),
          chromeBottomInsetOf: (_) => 50,
        ),
        50 + 16,
      );
    });
  });

  group('toast', () {
    double? edge(WidgetTester tester, {required bool top}) {
      final positioned = tester.widget<Positioned>(
        find
            .ancestor(
              of: find.byType(AnimatedSlide),
              matching: find.byType(Positioned),
            )
            .first,
      );
      return top ? positioned.top : positioned.bottom;
    }

    Future<void> pumpToast(
      WidgetTester tester,
      AcademyToastPosition position, {
      AcademyToastTheme theme = const AcademyToastTheme(),
    }) async {
      await tester.pumpWidget(
        AcademyApp(
          toast: theme,
          home: AcademyToastOverlay(message: 'Saved', position: position),
        ),
      );
      await tester.pump();
    }

    testWidgets('a bottom toast rises above the keyboard', (tester) async {
      phone(tester);
      tester.view.padding = const FakeViewPadding(bottom: 34);
      tester.view.viewPadding = const FakeViewPadding(bottom: 34);
      await pumpToast(tester, AcademyToastPosition.bottom);
      expect(edge(tester, top: false), 8 + 34);

      tester.view.padding = FakeViewPadding.zero;
      tester.view.viewInsets = const FakeViewPadding(bottom: 300);
      await tester.pump();
      // The keyboard covers the home indicator, so that does not add up.
      expect(edge(tester, top: false), 8 + 300);
    });

    testWidgets('so does one with a custom bottom inset', (tester) async {
      phone(tester);
      tester.view.viewInsets = const FakeViewPadding(bottom: 300);
      await pumpToast(
        tester,
        AcademyToastPosition.bottom,
        theme: AcademyToastTheme(bottomInsetOf: (_) => 50),
      );
      expect(edge(tester, top: false), 8 + 300);
    });

    testWidgets('topInsetOf places a top toast below the bar', (tester) async {
      phone(tester);
      tester.view.padding = const FakeViewPadding(top: 59);
      await tester.pumpWidget(
        AcademyApp(
          toast: AcademyToastTheme(topInsetOf: (_) => 59 + 44 + 8),
          home: const AcademyToastOverlay(
            message: 'Saved',
            position: AcademyToastPosition.top,
          ),
        ),
      );
      await tester.pump();
      final positioned = tester.widget<Positioned>(
        find
            .ancestor(
              of: find.byType(AnimatedSlide),
              matching: find.byType(Positioned),
            )
            .first,
      );
      expect(positioned.top, 59 + 44 + 8);
    });
  });

  group('high contrast', () {
    AcademyColorsData faint(Brightness brightness, Color accent) {
      final base = AcademyColorsData.from(AcademyPalette(brightness, accent));
      return base.copyWith(
        onSurface: const Color(0xFF999999),
        onSurfaceVariant: const Color(0xFFBBBBBB),
        labelTertiary: const Color(0xFFCCCCCC),
      );
    }

    Future<AcademyColors> colorsOf(WidgetTester tester) async {
      late AcademyColors seen;
      await tester.pumpWidget(
        AcademyApp(
          colorsBuilder: faint,
          home: Builder(
            builder: (context) {
              seen = AcademyTheme.of(context).colorScheme;
              return const SizedBox();
            },
          ),
        ),
      );
      return seen;
    }

    testWidgets('the system setting raises text, not surfaces', (tester) async {
      final base = await colorsOf(tester);
      tester.platformDispatcher.accessibilityFeaturesTestValue =
          const FakeAccessibilityFeatures(highContrast: true);
      addTearDown(
        tester.platformDispatcher.clearAccessibilityFeaturesTestValue,
      );
      await tester.pump();
      final raised = await colorsOf(tester);
      for (final surface in [raised.surface, raised.scaffoldBackground]) {
        for (final text in [
          raised.onSurface,
          raised.onSurfaceVariant,
          raised.labelTertiary,
        ]) {
          expect(
            AcademyContrast.ratio(text, surface),
            greaterThanOrEqualTo(4.5),
          );
        }
      }
      expect(raised.surface, base.surface);
      expect(raised.outline, base.outline);
      expect(raised.outlineVariant, base.outlineVariant);
    });

    testWidgets('colors are untouched without it', (tester) async {
      final colors = await colorsOf(tester);
      expect(colors.onSurface, const Color(0xFF999999));
      expect(colors.onSurfaceVariant, const Color(0xFFBBBBBB));
    });

    testWidgets('a change of the setting reaches a running app', (
      tester,
    ) async {
      final before = await colorsOf(tester);
      tester.platformDispatcher.accessibilityFeaturesTestValue =
          const FakeAccessibilityFeatures(highContrast: true);
      addTearDown(
        tester.platformDispatcher.clearAccessibilityFeaturesTestValue,
      );
      await tester.pump();
      final context = tester.element(find.byType(SizedBox).first);
      expect(
        AcademyTheme.of(context).colorScheme.onSurface,
        isNot(before.onSurface),
      );
    });

    test('the default palette keeps what is already readable', () {
      final palette = AcademyPalette(Brightness.light, const Color(0xFF007AFF));
      expect(academyHighContrastColors(palette).onSurface, palette.onSurface);
    });
  });

  group('routes', () {
    testWidgets('AcademyPageRoute has no barrier; instantPush only skips in', (
      tester,
    ) async {
      final route = AcademyPageRoute<void>(builder: (_) => const SizedBox());
      expect(route.barrierColor, isNull);
      expect(route.transitionDuration, isNot(Duration.zero));
      final instant = AcademyPageRoute<void>(
        instantPush: true,
        builder: (_) => const SizedBox(),
      );
      expect(instant.transitionDuration, Duration.zero);
      expect(instant.reverseTransitionDuration, isNot(Duration.zero));
    });

    Future<void> pushFade(WidgetTester tester, {bool still = false}) async {
      if (still) {
        tester.platformDispatcher.accessibilityFeaturesTestValue =
            const FakeAccessibilityFeatures(disableAnimations: true);
        addTearDown(
          tester.platformDispatcher.clearAccessibilityFeaturesTestValue,
        );
      }
      final navigator = GlobalKey<NavigatorState>();
      await tester.pumpWidget(
        AcademyApp(navigatorKey: navigator, home: const Text('below')),
      );
      navigator.currentState!.push(
        AcademyFadeRoute<void>(builder: (_) => const Text('above')),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 150));
    }

    double opacityOf(WidgetTester tester) => tester
        .widget<FadeTransition>(
          find
              .ancestor(
                of: find.text('above'),
                matching: find.byType(FadeTransition),
              )
              .first,
        )
        .opacity
        .value;

    testWidgets('AcademyFadeRoute fades in over the page', (tester) async {
      await pushFade(tester);
      expect(opacityOf(tester), inExclusiveRange(0, 1));
      expect(find.text('below'), findsOneWidget);
      expect(
        find.ancestor(
          of: find.text('above'),
          matching: find.byType(SlideTransition),
        ),
        findsWidgets,
      );
      await tester.pumpAndSettle();
      expect(find.text('below'), findsOneWidget);
    });

    testWidgets('under Reduce Motion it only fades', (tester) async {
      await pushFade(tester, still: true);
      expect(
        find.ancestor(
          of: find.text('above'),
          matching: find.byType(SlideTransition),
        ),
        findsNothing,
      );
      await tester.pumpAndSettle();
    });
  });

  group('AcademyTimeField', () {
    Future<List<AcademyTime?>> open(
      WidgetTester tester, {
      required bool commitOnDismiss,
    }) async {
      phone(tester);
      final changes = <AcademyTime?>[];
      await tester.pumpWidget(
        AcademyApp(
          home: Center(
            child: AcademyTimeField(
              label: 'Time',
              value: const AcademyTime(9, 0),
              commitOnDismiss: commitOnDismiss,
              onChanged: changes.add,
            ),
          ),
        ),
      );
      await tester.tap(find.byType(AcademyTimeField));
      await tester.pumpAndSettle();
      return changes;
    }

    Future<void> scrollWheel(WidgetTester tester) async {
      await tester.drag(
        find.byType(CupertinoDatePicker),
        const Offset(0, -80),
        warnIfMissed: false,
      );
      await tester.pumpAndSettle();
    }

    Future<void> dismiss(WidgetTester tester) async {
      Navigator.of(tester.element(find.byType(CupertinoDatePicker))).pop();
      await tester.pumpAndSettle();
    }

    testWidgets('commitOnDismiss keeps a scrolled time', (tester) async {
      final changes = await open(tester, commitOnDismiss: true);
      await scrollWheel(tester);
      await dismiss(tester);
      expect(changes, hasLength(1));
      expect(changes.single, isNot(const AcademyTime(9, 0)));
    });

    testWidgets('an untouched wheel commits nothing', (tester) async {
      final changes = await open(tester, commitOnDismiss: true);
      await dismiss(tester);
      expect(changes, isEmpty);
    });

    testWidgets('by default dismissing discards it', (tester) async {
      final changes = await open(tester, commitOnDismiss: false);
      await scrollWheel(tester);
      await dismiss(tester);
      expect(changes, isEmpty);
    });
  });

  group('sheet', () {
    testWidgets('the keyboard does not move the top of an expanded sheet', (
      tester,
    ) async {
      phone(tester);
      tester.view.padding = const FakeViewPadding(top: 59, bottom: 34);
      tester.view.viewPadding = const FakeViewPadding(top: 59, bottom: 34);
      final insets = <double>[];
      await openSheet(
        tester,
        initiallyExpanded: true,
        builder: (context) {
          insets.add(ModalSheetScrollInsets.of(context));
          return const SizedBox.expand();
        },
      );
      await tester.pumpAndSettle();
      double top() =>
          tester.getTopLeft(find.byType(AcademyChromeModalHeader)).dy;
      final rest = top();
      Future<void> keyboard(double Function(double progress) height) async {
        for (var frame = 1; frame <= 21; frame++) {
          tester.view.viewInsets = FakeViewPadding(
            bottom: height(Curves.easeOutCubic.transform(frame / 21)),
          );
          await tester.pump(const Duration(milliseconds: 16));
          expect(top(), closeTo(rest, 1), reason: 'frame $frame');
        }
        await tester.pumpAndSettle();
        expect(top(), closeTo(rest, .5));
      }

      await keyboard((progress) => 336 * progress);
      insets.clear();
      await keyboard((progress) => 336 * (1 - progress));
      // Not flipping between the resting and the initial value on each frame.
      for (var i = 1; i < insets.length; i++) {
        expect(
          (insets[i] - insets[i - 1]).abs(),
          lessThan(40),
          reason: 'build $i of $insets',
        );
      }
    });

    testWidgets('minimumBottom lifts pinned content off a flat edge only', (
      tester,
    ) async {
      phone(tester);
      const key = ValueKey('pinned');
      Future<double> pinnedBottom() async {
        await openSheet(
          tester,
          builder: (_) => const AcademyModalFit(
            minimumBottom: 8,
            child: SizedBox.expand(key: key),
          ),
        );
        await tester.pumpAndSettle();
        final bottom = tester.getBottomLeft(find.byKey(key)).dy;
        await tester.pumpWidget(const SizedBox());
        return bottom;
      }

      expect(await pinnedBottom(), 844 - 8);
      tester.view.padding = const FakeViewPadding(bottom: 34);
      expect(await pinnedBottom(), 844 - 34);
    });

    testWidgets('modal lists pass physics on', (tester) async {
      phone(tester);
      const physics = AlwaysScrollableScrollPhysics();
      await openSheet(
        tester,
        builder: (_) => const AcademyModalListView(
          physics: physics,
          children: [SizedBox()],
        ),
      );
      await tester.pumpAndSettle();
      expect(tester.widget<ListView>(find.byType(ListView)).physics, physics);
      await tester.pumpWidget(const SizedBox());
      await openSheet(
        tester,
        builder: (_) =>
            const AcademyModalScrollView(physics: physics, child: SizedBox()),
      );
      await tester.pumpAndSettle();
      expect(
        tester
            .widget<SingleChildScrollView>(find.byType(SingleChildScrollView))
            .physics,
        physics,
      );
    });

    group('clipContent', () {
      const content = ValueKey('content');
      final fade = find.byKey(const ValueKey('academy-modal-header-fade'));
      Finder clipAbove(Finder finder) =>
          find.ancestor(of: finder, matching: find.byType(ClipPath));

      Future<void> open(WidgetTester tester, {required bool clip}) async {
        phone(tester);
        await openSheet(
          tester,
          headerBehavior: AcademyModalHeaderBehavior.fade,
          clipContent: clip,
          builder: (_) => const SizedBox.expand(key: content),
        );
        await tester.pumpAndSettle();
      }

      testWidgets('by default clips the content', (tester) async {
        await open(tester, clip: true);
        expect(clipAbove(find.byKey(content)), findsWidgets);
      });

      testWidgets('when false clips only the fade', (tester) async {
        await open(tester, clip: false);
        expect(clipAbove(find.byKey(content)), findsNothing);
        expect(clipAbove(fade), findsOneWidget);
      });

      testWidgets('carries over to a page pushed inside the sheet', (
        tester,
      ) async {
        phone(tester);
        late BuildContext first;
        await openSheet(
          tester,
          nestedNavigation: true,
          headerBehavior: AcademyModalHeaderBehavior.fade,
          clipContent: false,
          builder: (context) {
            first = context;
            return const SizedBox.expand();
          },
        );
        await tester.pumpAndSettle();
        pushAcademyModalPage<void>(
          first,
          title: 'Second',
          builder: (_) => const SizedBox.expand(key: content),
        );
        await tester.pumpAndSettle();
        expect(clipAbove(find.byKey(content)), findsNothing);
      });
    });
  });

  group('AcademyRingProgress', () {
    testWidgets('listenable repaints the ring without its parent', (
      tester,
    ) async {
      final progress = ValueNotifier<double>(.1);
      addTearDown(progress.dispose);
      var parentBuilds = 0;
      await tester.pumpWidget(
        AcademyApp(
          home: Builder(
            builder: (context) {
              parentBuilds++;
              return Center(
                child: SizedBox.square(
                  dimension: 40,
                  child: AcademyRingProgress.listenable(listenable: progress),
                ),
              );
            },
          ),
        ),
      );
      await tester.pumpAndSettle();
      final before = parentBuilds;
      TweenAnimationBuilder<double> ring() =>
          tester.widget(find.byType(TweenAnimationBuilder<double>));
      expect(ring().tween.end, .1);
      progress.value = .6;
      await tester.pumpAndSettle();
      expect(ring().tween.end, .6);
      expect(parentBuilds, before);
    });

    testWidgets('paints on its own layer', (tester) async {
      await tester.pumpWidget(
        const AcademyApp(home: Center(child: AcademyRingProgress(value: .5))),
      );
      await tester.pumpAndSettle();
      expect(
        find.descendant(
          of: find.byType(AcademyRingProgress),
          matching: find.byType(RepaintBoundary),
        ),
        findsOneWidget,
      );
    });
  });

  group('images', () {
    Widget network({int? cacheWidth, bool auto = false, double? width = 100}) =>
        AcademyApp(
          home: Center(
            child: AcademyNetworkImage(
              url: 'https://example.com/a.jpg',
              fallback: const SizedBox(),
              width: width,
              height: 100,
              cacheWidth: cacheWidth,
              autoCacheWidth: auto,
              provider: (_) => MemoryImage(Uint8List(0)),
            ),
          ),
        );

    Object? providerOf(WidgetTester tester) =>
        tester.widget<Image>(find.byType(Image)).image;

    testWidgets('autoCacheWidth decodes at the display size', (tester) async {
      tester.view.devicePixelRatio = 3;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(network(auto: true));
      final image = providerOf(tester);
      expect(image, isA<ResizeImage>());
      expect((image! as ResizeImage).width, 300);
      await tester.pumpAndSettle();
      tester.takeException();
    });

    testWidgets('an explicit cacheWidth wins; off by default', (tester) async {
      tester.view.devicePixelRatio = 3;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(network(cacheWidth: 120, auto: true));
      expect((providerOf(tester)! as ResizeImage).width, 120);
      await tester.pumpAndSettle();
      tester.takeException();
      await tester.pumpWidget(network());
      expect(providerOf(tester), isNot(isA<ResizeImage>()));
      await tester.pumpAndSettle();
      tester.takeException();
    });

    testWidgets('AcademyImage passes cacheWidth on', (tester) async {
      await tester.pumpWidget(
        const AcademyApp(
          home: AcademyImage(
            url: 'https://example.com/a.jpg',
            label: 'Photo',
            cacheWidth: 200,
          ),
        ),
      );
      final image = providerOf(tester);
      expect(image, isA<ResizeImage>());
      expect((image! as ResizeImage).width, 200);
      await tester.pump();
      tester.takeException();
    });
  });

  group('AcademyPicker', () {
    testWidgets('passes the wheel options on; defaults are unchanged', (
      tester,
    ) async {
      Widget picker({double? ratio, ChangeReportingBehavior? behavior}) =>
          AcademyApp(
            home: Center(
              child: AcademyPicker<int>(
                items: const [1, 2, 3],
                value: 1,
                labelFor: (item) => '$item',
                onChanged: (_) {},
                diameterRatio: ratio ?? 1.07,
                changeReportingBehavior:
                    behavior ?? ChangeReportingBehavior.onScrollUpdate,
              ),
            ),
          );
      CupertinoPicker wheel() => tester.widget(find.byType(CupertinoPicker));

      await tester.pumpWidget(picker());
      expect(
        wheel().changeReportingBehavior,
        ChangeReportingBehavior.onScrollUpdate,
      );
      expect(wheel().diameterRatio, 1.07);

      await tester.pumpWidget(
        picker(ratio: 1.3, behavior: ChangeReportingBehavior.onScrollEnd),
      );
      expect(
        wheel().changeReportingBehavior,
        ChangeReportingBehavior.onScrollEnd,
      );
      expect(wheel().diameterRatio, 1.3);
    });
  });

  group('AcademySliverGroupedTable in a sheet', () {
    testWidgets('masks its fill instead of clipping the rows', (tester) async {
      phone(tester);
      await openSheet(
        tester,
        initiallyExpanded: true,
        builder: (_) => CustomScrollView(
          slivers: [
            AcademySliverGroupedTable(
              itemCount: 3,
              itemBuilder: (_, index) => AcademyRow(title: 'Row $index'),
            ),
          ],
        ),
      );
      await tester.pumpAndSettle();
      final row = find.text('Row 0');
      expect(
        find.ancestor(of: row, matching: find.byType(ModalSheetMaskedFill)),
        findsOneWidget,
      );
      expect(
        find.ancestor(of: row, matching: find.byType(ClipRRect)),
        findsNothing,
      );
    });

    testWidgets('keeps its clip outside a sheet', (tester) async {
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
      expect(
        find.ancestor(of: find.text('Row 0'), matching: find.byType(ClipRRect)),
        findsWidgets,
      );
    });
  });

  group('scroll behavior', () {
    test('mouse drag only on native Apple platforms', () {
      bool mouse(TargetPlatform platform, {bool web = false}) =>
          AcademyScrollBehavior.forEnvironment(
            platform: platform,
            isWeb: web,
          ).dragDevices.contains(PointerDeviceKind.mouse);
      expect(mouse(TargetPlatform.macOS), isTrue);
      expect(mouse(TargetPlatform.iOS), isTrue);
      expect(mouse(TargetPlatform.macOS, web: true), isFalse);
      expect(mouse(TargetPlatform.android), isFalse);
      expect(mouse(TargetPlatform.windows), isFalse);
    });

    test('the default keeps mouse drag', () {
      expect(
        const AcademyScrollBehavior().dragDevices,
        contains(PointerDeviceKind.mouse),
      );
    });

    testWidgets('AcademyApp takes a behavior', (tester) async {
      late ScrollBehavior seen;
      await tester.pumpWidget(
        AcademyApp(
          scrollBehavior: const AcademyScrollBehavior(mouseDrag: false),
          home: Builder(
            builder: (context) {
              seen = ScrollConfiguration.of(context);
              return const SizedBox();
            },
          ),
        ),
      );
      expect(seen.dragDevices, isNot(contains(PointerDeviceKind.mouse)));
    });

    testWidgets('the selection boundary drops only the mouse', (tester) async {
      late ScrollBehavior seen;
      await tester.pumpWidget(
        ScrollConfiguration(
          behavior: const AcademyScrollBehavior(),
          child: AcademySelectionSafeScrollBoundary(
            child: Builder(
              builder: (context) {
                seen = ScrollConfiguration.of(context);
                return const SizedBox();
              },
            ),
          ),
        ),
      );
      expect(seen.dragDevices, isNot(contains(PointerDeviceKind.mouse)));
      expect(seen.dragDevices, contains(PointerDeviceKind.touch));
    });
  });
}

class _DeferredProbe extends StatefulWidget {
  const _DeferredProbe({required this.onFire});
  final VoidCallback onFire;
  @override
  State<_DeferredProbe> createState() => _DeferredProbeState();
}

class _DeferredProbeState extends State<_DeferredProbe>
    with AcademyDeferredRouteInit {
  @override
  void onRouteTransitionComplete() => widget.onFire();
  @override
  Widget build(BuildContext context) => const SizedBox.expand();
}
