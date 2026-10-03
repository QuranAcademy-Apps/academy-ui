import 'dart:io';
import 'dart:ui' as ui;

import 'package:academy_ui/academy_ui.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../packages/academy_ui/tool/capture_controls_test.dart'
    show fonts;
import 'package:academy_ui_catalog/chrome_material_preview.dart';

void main() {
  testWidgets('capture the navigation material over scrolling content', (
    tester,
  ) async {
    await fonts();
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(820, 320);
    addTearDown(tester.view.reset);
    final boundary = GlobalKey();
    await tester.pumpWidget(
      RepaintBoundary(
        key: boundary,
        child: AcademyApp(
          home: Row(
            children: [
              for (final brightness in [Brightness.light, Brightness.dark])
                Expanded(
                  child: Builder(
                    builder: (context) {
                      final theme = academyTheme(brightness);
                      return AcademyTheme(
                        data: theme,
                        child: CupertinoTheme(
                          data: theme.cupertino,
                          child: ColoredBox(
                            color: theme.scaffoldBackgroundColor,
                            child: Padding(
                              padding: const EdgeInsets.all(20),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Text(
                                    brightness == Brightness.light
                                        ? 'Светлая тема'
                                        : 'Тёмная тема',
                                    style: theme.textTheme.titleMedium,
                                  ),
                                  const SizedBox(height: 20),
                                  const ChromeMaterialPreview(),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
            ],
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    for (final list in find.byType(ListView).evaluate()) {
      await tester.drag(find.byWidget(list.widget), const Offset(0, -100));
      await tester.pumpAndSettle();
    }
    expect(tester.takeException(), isNull);
    await tester.runAsync(() async {
      final image =
          await (boundary.currentContext!.findRenderObject()
                  as RenderRepaintBoundary)
              .toImage(pixelRatio: 2);
      final bytes = (await image.toByteData(format: ui.ImageByteFormat.png))!;
      File('../../docs/previews/chrome-material.png')
          .writeAsBytesSync(bytes.buffer.asUint8List());
      image.dispose();
    });
  });
}
