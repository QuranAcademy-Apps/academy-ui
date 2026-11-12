import 'dart:io';
import 'dart:ui' as ui;

import 'package:academy_ui/academy_ui.dart';
import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';

import 'capture_controls_test.dart' show fonts;

Widget sample(Brightness brightness, Color accent) {
  final theme = academyTheme(brightness, accent: accent);
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
                '${brightness == Brightness.light ? 'Светлая' : 'Тёмная'} · ${accent == AcademyTokens.brand ? 'Синий' : 'Золотой'}',
                style: theme.textTheme.titleMedium,
              ),
              const SizedBox(height: 12),
              const AcademyField(label: 'Имя', placeholder: 'Введите имя'),
              AcademySelect<String>(
                label: 'Язык',
                value: 'ru',
                options: const [
                  AcademySelectOption(value: 'ru', label: 'Русский'),
                ],
                onChanged: (_) {},
              ),
              const AcademyField(
                label: 'Недоступное поле',
                placeholder: 'Недоступно',
                enabled: false,
              ),
              const SizedBox(height: 12),
              AcademyButton(label: 'Продолжить', onPressed: () {}),
              AcademyTextButton(label: 'Отменить', onPressed: () {}),
            ],
          ),
        ),
      ),
    ),
  );
}

void main() {
  testWidgets('semantic field and accent color preview', (tester) async {
    tester.view.physicalSize = const Size(820, 920);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await fonts();
    final key = GlobalKey();
    await tester.pumpWidget(
      RepaintBoundary(
        key: key,
        child: AcademyApp(
          home: Row(
            children: [
              for (final accent in [AcademyTokens.brand, AcademyTokens.action])
                Expanded(
                  child: Column(
                    children: [
                      for (final brightness in [
                        Brightness.light,
                        Brightness.dark,
                      ])
                        Expanded(child: sample(brightness, accent)),
                    ],
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
      final image = await boundary.toImage(pixelRatio: 2);
      final png = await image.toByteData(format: ui.ImageByteFormat.png);
      final file = File('../../docs/previews/semantic-field-colors.png');
      await file.parent.create(recursive: true);
      await file.writeAsBytes(png!.buffer.asUint8List());
      image.dispose();
    });
    await tester.pumpWidget(const SizedBox());
  });
}
