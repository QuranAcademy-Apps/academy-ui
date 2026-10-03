// Capture catalog widgets with local SF Pro on macOS; Inter elsewhere.
// System font files are used only for previews and never bundled with the app.
import 'dart:io';
import 'dart:ui' as ui;

import 'package:academy_ui/academy_ui.dart';
import 'package:academy_ui_catalog/profile_components_catalog.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../packages/academy_ui/tool/capture_controls_test.dart'
    show fonts;

Widget panel(
  Brightness brightness, {
  double scale = 1,
  TextDirection direction = TextDirection.ltr,
}) {
  final theme = academyTheme(brightness);
  return AcademyTheme(
    data: theme,
    child: CupertinoTheme(
      data: theme.cupertino,
      child: MediaQuery(
        data: MediaQueryData(
          textScaler: TextScaler.linear(scale),
          disableAnimations: true,
        ),
        child: Directionality(
          textDirection: direction,
          child: ColoredBox(
            color: theme.scaffoldBackgroundColor,
            child: DefaultTextStyle(
              style: theme.textTheme.bodyLarge,
              child: Padding(
                padding: theme.paddings.surface,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      '${brightness == Brightness.dark ? 'Тёмная' : 'Светлая'} · $scale× · ${direction.name}',
                      style: theme.textTheme.titleMedium,
                    ),
                    const SizedBox(height: AcademyTokens.gutter),
                    const ProfileComponentExamples(),
                  ],
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
  testWidgets('capture profile catalog in light dark and large RTL', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await fonts();
    final systemFont = File('/System/Library/Fonts/SFNS.ttf');
    if (Platform.isMacOS && systemFont.existsSync()) {
      await tester.runAsync(() async {
        final bytes = ByteData.sublistView(await systemFont.readAsBytes());
        for (final family in [
          'CupertinoSystemText',
          'CupertinoSystemDisplay',
        ]) {
          await (FontLoader(family)..addFont(Future.value(bytes))).load();
        }
      });
    }
    for (final mode in [0, 1, 2]) {
      final large = mode == 1;
      final detail = mode == 2;
      tester.view.physicalSize = Size(
        800,
        detail
            ? 620
            : large
            ? 3000
            : 1650,
      );
      Widget preview(
        Brightness brightness, {
        double scale = 1,
        TextDirection direction = TextDirection.ltr,
      }) {
        final content = panel(brightness, scale: scale, direction: direction);
        return detail ? SingleChildScrollView(child: content) : content;
      }

      final key = GlobalKey();
      await tester.pumpWidget(
        AcademyApp(
          home: RepaintBoundary(
            key: key,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: preview(Brightness.light, scale: large ? 2 : 1),
                ),
                Expanded(
                  child: preview(
                    Brightness.dark,
                    scale: large ? 2 : 1,
                    direction: large ? TextDirection.rtl : TextDirection.ltr,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      final boundary =
          key.currentContext!.findRenderObject() as RenderRepaintBoundary;
      await tester.runAsync(() async {
        final image = await boundary.toImage(pixelRatio: 1);
        final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
        final file = File(
          '../../docs/previews/profile-components${large
              ? '-large-rtl'
              : detail
              ? '-detail'
              : ''}.png',
        );
        await file.parent.create(recursive: true);
        await file.writeAsBytes(bytes!.buffer.asUint8List());
        image.dispose();
      });
    }
    await tester.pumpWidget(const SizedBox());
  }, variant: TargetPlatformVariant.only(TargetPlatform.iOS));
}
