import 'dart:io';
import 'dart:ui' as ui;

import 'package:academy_ui/academy_ui.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';

import 'capture_controls_test.dart' show fonts;

void main() {
  for (final dark in [false, true]) {
    testWidgets('floating field variants ${dark ? 'dark' : 'light'}', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(390, 1000);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      await fonts();
      final appearance = AcademyAppearanceController(
        initial: AcademyAppearance(
          mode: dark ? AcademyAppearanceMode.dark : AcademyAppearanceMode.light,
        ),
      );
      addTearDown(appearance.dispose);
      final name = TextEditingController(text: 'Аюб Бибулатов');
      final error = TextEditingController(text: 'тест');
      final email = TextEditingController(text: 'ayub@example.com');
      for (final controller in [name, error, email]) {
        addTearDown(controller.dispose);
      }
      final boundary = GlobalKey();
      await tester.pumpWidget(
        RepaintBoundary(
          key: boundary,
          child: AcademyApp(
            appearance: appearance,
            home: AcademyPage(
              title: 'Варианты текстовых полей',
              child: Builder(
                builder: (context) => ListView(
                  padding: EdgeInsets.fromLTRB(
                    16,
                    AcademyPageInsets.topOf(context),
                    16,
                    24,
                  ),
                  children: [
                    const Text('Обычный placeholder'),
                    const SizedBox(height: 12),
                    const AcademyTextField(placeholder: 'Почта'),
                    const SizedBox(height: 24),
                    const Text('Заголовок над полем'),
                    const SizedBox(height: 12),
                    const AcademyField(
                      label: 'Почта',
                      placeholder: 'Введите почту',
                      help: 'Для важных писем и входа в профиль',
                    ),
                    const SizedBox(height: 24),
                    const Text('Плавающий заголовок'),
                    const SizedBox(height: 12),
                    const AcademyFloatingTextField(
                      label: 'Почта',
                      help: 'Пустое поле — название на месте placeholder',
                    ),
                    AcademyFloatingTextField(label: 'Имя', controller: name),
                    AcademyFloatingTextField(
                      label: 'Почта',
                      controller: error,
                      error: 'Похоже, почта написана неверно',
                    ),
                    AcademyFloatingTextField(
                      label: 'Почта',
                      controller: email,
                      help: 'Для важных писем и входа в профиль',
                      clearable: false,
                      readOnly: true,
                      trailing: AcademySfIcon(
                        AcademySymbols.complete,
                        color: AcademyTheme.of(context).colorScheme
                            .toneForeground(AcademyTone.success),
                      ),
                    ),
                    const AcademyFloatingTextField(
                      label: 'Недоступное поле',
                      enabled: false,
                    ),
                  ],
                ),
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
        final image = await render.toImage(pixelRatio: 2);
        final png = await image.toByteData(format: ui.ImageByteFormat.png);
        final file = File(
          '../../docs/previews/text-fields-${dark ? 'dark' : 'light'}.png',
        );
        await file.parent.create(recursive: true);
        await file.writeAsBytes(png!.buffer.asUint8List());
        image.dispose();
      });
      await tester.pumpWidget(const SizedBox());
    });
  }
}
