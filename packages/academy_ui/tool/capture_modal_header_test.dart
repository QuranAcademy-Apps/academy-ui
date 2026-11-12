// Real-widget previews of the content sheet's scroll edge, in both themes.
import 'dart:io';
import 'dart:ui' as ui;

import 'package:academy_ui/academy_ui.dart';
import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';

import 'capture_controls_test.dart' show fonts;

void main() {
  testWidgets('capture content scrolling beneath the modal header', (
    tester,
  ) async {
    await fonts();
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(390, 844);
    tester.view.padding = const FakeViewPadding(top: 44, bottom: 34);
    tester.view.viewPadding = const FakeViewPadding(top: 44, bottom: 34);
    addTearDown(tester.view.reset);
    for (final mode in [
      AcademyAppearanceMode.light,
      AcademyAppearanceMode.dark,
    ]) {
      final appearance = AcademyAppearanceController(
        initial: AcademyAppearance(mode: mode),
      );
      await appearance.ready;
      final boundary = GlobalKey();
      final controller = ScrollController();
      late BuildContext context;
      await tester.pumpWidget(
        RepaintBoundary(
          key: boundary,
          child: AcademyApp(
            appearance: appearance,
            home: Builder(
              builder: (ctx) {
                context = ctx;
                return const CupertinoPageScaffold(
                  child: Center(child: Text('Контентный шит')),
                );
              },
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      if (!context.mounted) throw StateError('Preview host was disposed');
      showAcademyModal<void>(
        context,
        title: 'Материалы',
        autoHeight: 420,
        headerBehavior: AcademyModalHeaderBehavior.fade,
        headerFadeExtent: 32,
        builder: (_) => AcademyModalListView(
          controller: controller,
          children: [
            for (var i = 1; i <= 20; i++)
              AcademyRow(
                title: 'Урок $i · Арабский язык',
                subtitle: 'Материалы, задания и записи занятия',
                icon: AcademySymbols.document,
                onPressed: () {},
              ),
          ],
        ),
      );
      await tester.pumpAndSettle();
      controller.jumpTo(100);
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      await tester.runAsync(() async {
        final image =
            await (boundary.currentContext!.findRenderObject()
                    as RenderRepaintBoundary)
                .toImage(pixelRatio: 2);
        final bytes = (await image.toByteData(format: ui.ImageByteFormat.png))!;
        File('../../docs/previews/modal-header-fade-${mode.name}.png')
            .writeAsBytesSync(bytes.buffer.asUint8List());
        image.dispose();
      });
      await tester.pumpWidget(const SizedBox());
      controller.dispose();
      appearance.dispose();
    }
  });
}
