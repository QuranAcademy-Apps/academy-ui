import 'dart:io';
import 'dart:ui' as ui;

import 'package:academy_ui/academy_ui.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';

import 'capture_controls_test.dart' show fonts;

Widget panel(
  BuildContext context,
  Brightness brightness,
  TextDirection direction,
) {
  final theme = academyTheme(
    brightness,
    typography: const AcademyTypographySettings(
      styles: {
        AcademyTextRole.titleMedium: TextStyle(fontSize: 24, height: 2),
        AcademyTextRole.bodySmall: TextStyle(fontSize: 18, height: 2),
        AcademyTextRole.segmentLabel: TextStyle(fontSize: 30, height: 1.5),
      },
    ),
  );
  return SizedBox(
    width: 320,
    child: AcademyTheme(
      data: theme,
      child: CupertinoTheme(
        data: theme.cupertino,
        child: Directionality(
          textDirection: direction,
          child: MediaQuery(
            data: MediaQuery.of(context)
                .copyWith(textScaler: const TextScaler.linear(2)),
            child: ColoredBox(
              color: theme.scaffoldBackgroundColor,
              child: DefaultTextStyle(
                style: theme.textTheme.bodyRow,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        '${brightness.name} · ${direction.name} · 2×',
                        style: theme.textTheme.caption,
                      ),
                      const SizedBox(height: 16),
                      const AcademyChromeBar(
                        title: 'Заголовок',
                        subtitle: 'Подпись',
                      ),
                      const SizedBox(height: 24),
                      AcademySegmentedControl<String>(
                        items: const ['А', 'Б'],
                        value: 'А',
                        labelFor: (value) => value,
                        onChanged: (_) {},
                      ),
                      const SizedBox(height: 24),
                      AcademySegmentedControl<String>.compact(
                        items: const ['А', 'Б'],
                        value: 'Б',
                        labelFor: (value) => value,
                        onChanged: (_) {},
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    ),
  );
}

void main() {
  testWidgets('capture client typography at 2x in both themes and directions', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(1280, 650);
    addTearDown(tester.view.reset);
    await fonts();
    final boundary = GlobalKey();
    await tester.pumpWidget(
      AcademyApp(
        home: Builder(
          builder: (context) => RepaintBoundary(
            key: boundary,
            child: Row(
              children: [
                for (final brightness in Brightness.values)
                  for (final direction in TextDirection.values)
                    panel(context, brightness, direction),
              ],
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    final render =
        boundary.currentContext!.findRenderObject() as RenderRepaintBoundary;
    await tester.runAsync(() async {
      final image = await render.toImage();
      final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
      await File('../../docs/previews/review-typography-overrides.png')
          .writeAsBytes(bytes!.buffer.asUint8List());
      image.dispose();
    });
    await tester.pumpWidget(const SizedBox());
  });
}
