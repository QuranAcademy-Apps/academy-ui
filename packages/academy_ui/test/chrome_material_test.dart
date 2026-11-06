// ignore_for_file: deprecated_member_use_from_same_package
import 'dart:ui' as ui;

import 'package:academy_ui/academy_ui.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';

class _SplitBackground extends CustomPainter {
  const _SplitBackground(this.left, this.right);
  final Color left, right;
  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Offset.zero & size, Paint()..color = right);
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width / 2, size.height),
      Paint()..color = left,
    );
  }

  @override
  bool shouldRepaint(_SplitBackground oldDelegate) =>
      left != oldDelegate.left || right != oldDelegate.right;
}

void main() {
  test(
    'neutral navigation tint is independent of general surfaces and accent',
    () {
      for (final brightness in Brightness.values) {
        final expected = brightness == Brightness.light
            ? const Color(0xFFFFFFFF)
            : const Color(0xFF1C1C1E);
        final palette = AcademyPalette(brightness, const Color(0xFF98513D));
        expect(palette.chromeSurface, expected);
        expect(
          palette.copyWith(surface: const Color(0xFFFF0000)).chromeSurface,
          expected,
        );
      }
    },
  );

  for (final brightness in Brightness.values) {
    testWidgets(
      '$brightness navigation labels consume the material contrast role',
      (tester) async {
        final controller = TextEditingController();
        addTearDown(controller.dispose);
        final theme = academyTheme(brightness);
        final value = brightness == Brightness.light
            ? AcademyTokens.chromeBlurToneStrength
            : 1 - AcademyTokens.chromeBlurToneStrength;
        final backdrop = Color.from(
          alpha: 1,
          red: value,
          green: value,
          blue: value,
        );
        await tester.pumpWidget(
          AcademyApp(
            home: AcademyTheme(
              data: theme,
              child: AcademyChromeTheme(
                style: AcademyChromeStyle.blur,
                child: Center(
                  child: SizedBox(
                    width: 320,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        AcademyFloatingTabBar(
                          tabs: [
                            AcademyTab(
                              label: 'Selected',
                              icon: AcademySymbols.book,
                              builder: (_) => const SizedBox(),
                            ),
                            AcademyTab(
                              label: 'Unselected',
                              icon: AcademySymbols.gear,
                              builder: (_) => const SizedBox(),
                            ),
                          ],
                          index: 0,
                          onChanged: (_) {},
                        ),
                        AcademySearchBar(controller: controller),
                        const AcademyMenuButton(
                          title: 'Menu',
                          subtitle: 'Subtitle',
                          items: [],
                          style: AcademyChromeStyle.blur,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();
        for (final color in [
          tester.widget<Text>(find.text('Unselected')).style!.color!,
          tester.widget<Text>(find.text('Subtitle')).style!.color!,
          tester
              .widget<CupertinoTextField>(find.byType(CupertinoTextField))
              .placeholderStyle!
              .color!,
        ]) {
          expect(
            AcademyContrast.ratio(color, backdrop),
            greaterThanOrEqualTo(4.5),
          );
        }
        expect(tester.takeException(), isNull);
      },
    );

    testWidgets('$brightness tint and blur render above a changing backdrop', (
      tester,
    ) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(400, 200);
      addTearDown(tester.view.reset);
      final theme = academyTheme(brightness);
      final boundary = GlobalKey();
      Future<void> render(Color left, Color right) async {
        await tester.pumpWidget(
          Directionality(
            textDirection: TextDirection.ltr,
            child: MediaQuery(
              data: const MediaQueryData(size: Size(400, 200)),
              child: AcademyTheme(
                data: theme,
                child: AcademyChromeTheme(
                  style: AcademyChromeStyle.blur,
                  child: RepaintBoundary(
                    key: boundary,
                    child: Stack(
                      children: [
                        Positioned.fill(
                          child: CustomPaint(
                            painter: _SplitBackground(left, right),
                          ),
                        ),
                        const Positioned(
                          left: 30,
                          right: 30,
                          top: 50,
                          height: 100,
                          child: AcademyChrome(
                            child: Stack(
                              children: [
                                Positioned(
                                  left: 20,
                                  top: 20,
                                  child: ColoredBox(
                                    color: Color(0xFFFF0000),
                                    child: SizedBox(width: 10, height: 10),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();
      }

      Future<List<Color>> pixels(List<Offset> points) async {
        return (await tester.runAsync(() async {
          final image =
              await (boundary.currentContext!.findRenderObject()
                      as RenderRepaintBoundary)
                  .toImage(pixelRatio: 1);
          final bytes = (await image.toByteData(
            format: ui.ImageByteFormat.rawRgba,
          ))!;
          final result = points.map((point) {
            final offset =
                (point.dy.toInt() * image.width + point.dx.toInt()) * 4;
            return Color.fromARGB(
              bytes.getUint8(offset + 3),
              bytes.getUint8(offset),
              bytes.getUint8(offset + 1),
              bytes.getUint8(offset + 2),
            );
          }).toList();
          image.dispose();
          return result;
        }))!;
      }

      void near(Color actual, Color expected) {
        expect(actual.r * 255, closeTo(expected.r * 255, 3));
        expect(actual.g * 255, closeTo(expected.g * 255, 3));
        expect(actual.b * 255, closeTo(expected.b * 255, 3));
      }

      Color filtered(Color color) =>
          AcademyChrome.blurBackgroundOf(boundary.currentContext!, color);
      await render(CupertinoColors.black, CupertinoColors.white);
      final first = await pixels(const [
        Offset(90, 100),
        Offset(310, 100),
        Offset(190, 100),
        Offset(55, 75),
      ]);
      near(first[0], filtered(CupertinoColors.black));
      near(first[1], filtered(CupertinoColors.white));
      expect(
        first[1].r - first[0].r,
        greaterThanOrEqualTo(.35),
        reason:
            'Default material preserves a visible share of backdrop changes',
      );
      expect(
        first[2].r,
        greaterThan(first[0].r),
        reason: 'Blur softens the edge',
      );
      expect(first[2].r, lessThan(first[1].r));
      expect(
        first[3],
        const Color(0xFFFF0000),
        reason: 'Backdrop filters never alter foreground children',
      );
      await render(const Color(0xFF008040), const Color(0xFF0040FF));
      final second = await pixels(const [Offset(90, 100), Offset(310, 100)]);
      near(second[0], filtered(const Color(0xFF008040)));
      near(second[1], filtered(const Color(0xFF0040FF)));
      expect(
        second[0],
        isNot(first[0]),
        reason: 'Material follows changed content',
      );
      expect(
        (second[1].b - second[0].b) /
            (const Color(0xFF0040FF).b - const Color(0xFF008040).b),
        greaterThanOrEqualTo(.35),
        reason: 'Content colors remain visible through the filtered backdrop',
      );
      expect(find.byType(BackdropFilter), findsOneWidget);
      final box = tester.widget<DecoratedBox>(
        find.descendant(
          of: find.byType(AcademyChrome),
          matching: find.byType(DecoratedBox),
        ),
      );
      expect(
        (box.decoration as BoxDecoration).color,
        isNull,
        reason: 'Blur has no painted color overlay',
      );
      expect(find.byType(ColorFiltered), findsNothing);
      expect(tester.takeException(), isNull);
    });

    testWidgets(
      '$brightness material foregrounds remain readable over extremes',
      (tester) async {
        await tester.pumpWidget(
          AcademyApp(
            home: AcademyTheme(
              data: academyTheme(brightness),
              child: AcademyChromeTheme(
                style: AcademyChromeStyle.blur,
                child: Builder(
                  builder: (context) {
                    final palette = AcademyTheme.of(context).colorScheme;

                    for (final preferred in [
                      palette.onSurface,
                      palette.onSurfaceVariant,
                      palette.primary,
                    ]) {
                      final foreground = AcademyChrome.foregroundColor(
                        context,
                        preferred,
                      );
                      for (final backdrop in const [
                        CupertinoColors.black,
                        CupertinoColors.white,
                        Color(0xFFFF0000),
                        Color(0xFF00FF00),
                      ]) {
                        expect(
                          AcademyContrast.ratio(
                            foreground,
                            AcademyChrome.blurBackgroundOf(context, backdrop),
                          ),
                          greaterThanOrEqualTo(4.5),
                        );
                      }
                      expect(
                        AcademyChrome.foregroundColor(
                          context,
                          preferred,
                          style: AcademyChromeStyle.flat,
                        ),
                        preferred,
                      );
                    }
                    return const SizedBox();
                  },
                ),
              ),
            ),
          ),
        );
        expect(tester.takeException(), isNull);
      },
    );
  }

  testWidgets(
    'global and local tone correction update and captured theme preserves strength',
    (tester) async {
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      final strength = ValueNotifier(.54);
      addTearDown(strength.dispose);
      late Color observed;
      late AcademyChromeTheme captured;
      final boundary = GlobalKey();
      await tester.pumpWidget(
        ValueListenableBuilder<double>(
          valueListenable: strength,
          builder: (_, value, _) => AcademyApp(
            chromeBlurToneStrength: value,
            colorsBuilder: (brightness, accent) => AcademyPalette(
              brightness,
              accent,
            ).copyWith(chromeSurface: const Color(0x80FF0000)),
            home: Builder(
              builder: (context) {
                observed = AcademyChrome.blurBackgroundOf(
                  context,
                  const Color.from(alpha: 1, red: .2, green: .2, blue: .2),
                  surfaceOpacity: .5,
                );
                captured = AcademyChromeTheme.maybeOf(
                  context,
                )!.wrap(context, const SizedBox()) as AcademyChromeTheme;
                return Center(
                  child: RepaintBoundary(
                    key: boundary,
                    child: SizedBox(
                      width: 100,
                      height: 50,
                      child: Stack(
                        children: [
                          const Positioned.fill(
                            child: ColoredBox(color: Color(0xFF404040)),
                          ),
                          const Positioned.fill(
                            child: AcademyChrome(
                              style: AcademyChromeStyle.blur,
                              blurToneStrength: .3,
                              surfaceOpacity: .5,
                              child: SizedBox(),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(observed.r, closeTo(.2 * .73 + .27, .0001));
      expect(captured.blurToneStrength, .54);
      Future<void> checkLocalPixels() async {
        await tester.runAsync(() async {
          final image =
              await (boundary.currentContext!.findRenderObject()
                      as RenderRepaintBoundary)
                  .toImage(pixelRatio: 1);
          final bytes = (await image.toByteData(
            format: ui.ImageByteFormat.rawRgba,
          ))!;
          final offset = (25 * image.width + 50) * 4;
          for (var channel = 0; channel < 3; channel++) {
            expect(
              bytes.getUint8(offset + channel),
              closeTo(64 * .85 + 255 * .15, 3),
            );
          }
          image.dispose();
        });
      }

      await checkLocalPixels();
      strength.value = .7;
      await tester.pumpAndSettle();
      expect(observed.r, closeTo(.2 * .65 + .35, .0001));
      expect(captured.blurToneStrength, .7);
      await checkLocalPixels();
      final box = tester.widget<DecoratedBox>(
        find.descendant(
          of: find.byType(AcademyChrome),
          matching: find.byType(DecoratedBox),
        ),
      );
      expect((box.decoration as BoxDecoration).color, isNull);
      expect(tester.takeException(), isNull);
    },
  );

  test(
    'legacy tint arguments map to backdrop correction without an overlay',
    () {
      const app = AcademyApp(home: SizedBox(), chromeBlurTintOpacity: .7);
      const theme = AcademyChromeTheme(
        style: AcademyChromeStyle.blur,
        blurTintOpacity: .3,
        child: SizedBox(),
      );
      const chrome = AcademyChrome(blurTintOpacity: .4, child: SizedBox());
      expect(app.chromeBlurToneStrength, .7);
      expect(theme.blurToneStrength, .3);
      expect(chrome.blurToneStrength, .4);
    },
  );

  testWidgets(
    'high contrast replaces translucency and blur with an opaque fill',
    (tester) async {
      await tester.pumpWidget(
        AcademyApp(
          home: MediaQuery(
            data: const MediaQueryData(highContrast: true),
            child: const AcademyChrome(
              style: AcademyChromeStyle.blur,
              surfaceOpacity: .2,
              child: SizedBox(width: 100, height: 50),
            ),
          ),
        ),
      );
      expect(find.byType(BackdropFilter), findsNothing);
      final box = tester.widget<DecoratedBox>(
        find.descendant(
          of: find.byType(AcademyChrome),
          matching: find.byType(DecoratedBox),
        ),
      );
      expect((box.decoration as BoxDecoration).color!.a, 1);
      expect(tester.takeException(), isNull);
    },
  );
}
