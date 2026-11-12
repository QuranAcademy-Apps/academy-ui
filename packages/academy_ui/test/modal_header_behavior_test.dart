import 'dart:ui' as ui;

import 'package:academy_ui/academy_ui.dart';
import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';

import 'modal_contract_test.dart' show host;

void main() {
  for (final behavior in AcademyModalHeaderBehavior.values) {
    testWidgets('$behavior preserves initial inset and last-row access', (
      tester,
    ) async {
      final context = await host(tester);
      final controller = ScrollController();
      addTearDown(controller.dispose);
      var taps = 0;
      showAcademyModal<void>(
        context,
        title: 'Контент',
        headerBehavior: behavior,
        builder: (_) => AcademyModalListView(
          controller: controller,
          children: [
            SizedBox(
              key: const ValueKey('first'),
              height: 44,
              child: CupertinoButton(
                padding: EdgeInsets.zero,
                onPressed: () => taps++,
                child: const Text('Первый'),
              ),
            ),
            for (var i = 0; i < 30; i++)
              SizedBox(height: 44, child: Text('Строка $i')),
            const SizedBox(
              key: ValueKey('last'),
              height: 44,
              child: Text('Последний'),
            ),
          ],
        ),
      );
      await tester.pumpAndSettle();
      final sheet = tester.getRect(find.byType(AcademyModalScaffold));
      final header = tester.getRect(find.byType(AcademyChromeModalHeader));
      final list = tester.getRect(find.byType(ListView));
      final underlap = behavior != AcademyModalHeaderBehavior.separate;
      expect(list.top, closeTo(underlap ? sheet.top : header.bottom, .1));
      expect(
        tester.getRect(find.byKey(const ValueKey('first'))).top,
        closeTo(header.bottom + 8, .1),
      );
      expect(
        find.byKey(const ValueKey('academy-modal-header-fade')),
        behavior == AcademyModalHeaderBehavior.fade
            ? findsOneWidget
            : findsNothing,
      );
      controller.jumpTo(header.height);
      await tester.pumpAndSettle();
      if (underlap) {
        expect(
          tester.getRect(find.byKey(const ValueKey('first'))).top,
          lessThan(header.bottom),
        );
        await tester.tapAt(Offset(header.left + 30, header.top + 25));
        await tester.pump();
        expect(taps, 0, reason: 'Header shields actions scrolled beneath it');
      }
      controller.jumpTo(controller.position.maxScrollExtent);
      await tester.pumpAndSettle();
      final last = tester.getRect(find.byKey(const ValueKey('last')));
      expect(last.bottom, lessThanOrEqualTo(844 - 34));
      expect(last.top, greaterThan(header.bottom));
      await tester.tap(
        find.byWidgetPredicate(
          (w) => w is AcademyChromeButton && w.icon == AcademySymbols.close,
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byType(AcademyModalScaffold), findsNothing);
      expect(tester.takeException(), isNull);
    });
  }

  for (final brightness in Brightness.values) {
    testWidgets('$brightness fade renders a gradual edge on scroll content', (
      tester,
    ) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(390, 600);
      addTearDown(tester.view.reset);
      final controller = ScrollController();
      addTearDown(controller.dispose);
      final boundaryKey = GlobalKey();
      final theme = academyTheme(brightness);
      const contentColor = Color(0xFF007AFF);
      await tester.pumpWidget(
        AcademyApp(
          home: AcademyTheme(
            data: theme,
            child: Center(
              child: RepaintBoundary(
                key: boundaryKey,
                child: SizedBox(
                  width: 320,
                  height: 400,
                  child: AcademyModalScaffold(
                    title: 'Заголовок',
                    headerBehavior: AcademyModalHeaderBehavior.fade,
                    headerFadeExtent: 32,
                    builder: (context) => SingleChildScrollView(
                      controller: controller,
                      padding: EdgeInsets.only(
                        top: AcademyModalContentInsets.topOf(context),
                      ),
                      child: const ColoredBox(
                        color: contentColor,
                        child: SizedBox(height: 1000, width: 320),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      controller.jumpTo(100);
      await tester.pumpAndSettle();
      final headerHeight = tester
          .getSize(find.byType(AcademyChromeModalHeader))
          .height;
      await tester.runAsync(() async {
        final image =
            await (boundaryKey.currentContext!.findRenderObject()
                    as RenderRepaintBoundary)
                .toImage(pixelRatio: 1);
        final bytes = (await image.toByteData(
          format: ui.ImageByteFormat.rawRgba,
        ))!;
        for (final delta in [2, 16, 30, 34]) {
          final y = headerHeight.toInt() - 32 + delta;
          final offset = (y * image.width + 8) * 4;
          final opacity = (1 - (delta + .5) / 32).clamp(0.0, 1.0);
          final expected = Color.alphaBlend(
            theme.colorScheme.surface.withValues(alpha: opacity),
            contentColor,
          );
          expect(bytes.getUint8(offset), closeTo(expected.r * 255, 3));
          expect(bytes.getUint8(offset + 1), closeTo(expected.g * 255, 3));
          expect(bytes.getUint8(offset + 2), closeTo(expected.b * 255, 3));
        }
        image.dispose();
      });
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets(
    'content sheet defaults to fade and nested pages inherit options',
    (tester) async {
      final context = await host(tester);
      showAcademySheet(
        context,
        title: 'Контент',
        height: 220,
        child: const Text('Содержимое'),
      );
      await tester.pumpAndSettle();
      expect(
        tester
            .widget<AcademyModalScaffold>(find.byType(AcademyModalScaffold))
            .headerBehavior,
        AcademyModalHeaderBehavior.fade,
      );
      Navigator.of(tester.element(find.text('Содержимое'))).pop();
      await tester.pumpAndSettle();
      showAcademyModal<void>(
        context,
        title: 'Первый',
        nestedNavigation: true,
        headerBehavior: AcademyModalHeaderBehavior.fade,
        headerFadeExtent: 40,
        builder: (inner) => AcademyModalListView(
          children: [
            AcademyButton(
              label: 'Дальше',
              onPressed: () => pushAcademyModalPage<void>(
                inner,
                title: 'Второй',
                builder: (inner) => AcademyModalListView(
                  children: [
                    AcademyButton(
                      label: 'Без фейда',
                      onPressed: () => pushAcademyModalPage<void>(
                        inner,
                        title: 'Третий',
                        headerBehavior: AcademyModalHeaderBehavior.separate,
                        builder: (_) => const AcademyModalListView(
                          children: [Text('Конец')],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Дальше'));
      await tester.pumpAndSettle();
      var scaffold = tester.widget<AcademyModalScaffold>(
        find.byType(AcademyModalScaffold).last,
      );
      expect(scaffold.headerBehavior, AcademyModalHeaderBehavior.fade);
      expect(scaffold.headerFadeExtent, 40);
      await tester.tap(find.text('Без фейда'));
      await tester.pumpAndSettle();
      scaffold = tester.widget<AcademyModalScaffold>(
        find.byType(AcademyModalScaffold).last,
      );
      expect(scaffold.headerBehavior, AcademyModalHeaderBehavior.separate);
      expect(tester.takeException(), isNull);
    },
  );
}
