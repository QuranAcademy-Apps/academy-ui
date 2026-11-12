// Captures real controls, including the open popover that prompted this fix.
import 'dart:io';
import 'dart:ui' as ui;

import 'package:academy_ui/academy_ui.dart';
import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';

import 'capture_controls_test.dart' show fonts;

void main() {
  for (final dark in [false, true]) {
    testWidgets('open form popover ${dark ? 'dark' : 'light'}', (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      await fonts();
      debugDisableShadows = false;
      addTearDown(() => debugDisableShadows = true);
      final appearance = AcademyAppearanceController(
        initial: AcademyAppearance(
          mode: dark ? AcademyAppearanceMode.dark : AcademyAppearanceMode.light,
        ),
      );
      addTearDown(appearance.dispose);
      final boundary = GlobalKey();
      const options = [
        AcademySelectOption(value: 'ru', label: 'Русский', group: 'Языки'),
        AcademySelectOption(value: 'en', label: 'English', group: 'Языки'),
        AcademySelectOption(value: 'ar', label: 'Арабский', group: 'Языки'),
        AcademySelectOption(value: 'soon', label: 'Скоро', enabled: false),
      ];
      await tester.pumpWidget(
        RepaintBoundary(
          key: boundary,
          child: AcademyApp(
            appearance: appearance,
            home: AcademyPage(
              title: 'Формы и выбор',
              child: Builder(
                builder: (context) => ListView(
                  padding: EdgeInsets.fromLTRB(
                    20,
                    AcademyPageInsets.topOf(context),
                    20,
                    32,
                  ),
                  children: [
                    const Text('Настройте язык и параметры чтения.'),
                    const SizedBox(height: 20),
                    AcademyTextFormField(
                      label: 'Имя',
                      help: 'Обязательное поле',
                      placeholder: 'Введите имя',
                    ),
                    AcademySelect<String>(
                      label: 'Язык — модалка',
                      value: 'ru',
                      options: options,
                      onChanged: (_) {},
                    ),
                    AcademySelect<String>(
                      key: const ValueKey('popup'),
                      label: 'Язык — всплывающая панель',
                      value: 'ru',
                      options: options,
                      searchable: true,
                      presentation: AcademySelectPresentation.popover,
                      onChanged: (_) {},
                    ),
                    const AcademySelect<String>(
                      label: 'Недоступное поле',
                      value: 'ru',
                      options: options,
                      onChanged: null,
                    ),
                    AcademyTextFormField(
                      label: 'Подсказки',
                      placeholder: 'Поиск по темам',
                    ),
                    const SizedBox(height: 12),
                    AcademyButton(label: 'Проверить форму', onPressed: () {}),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(
        find.descendant(
          of: find.byKey(const ValueKey('popup')),
          matching: find.byType(AcademyTappable),
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
          '../../docs/previews/form-contrast-${dark ? 'dark' : 'light'}.png',
        );
        await file.parent.create(recursive: true);
        await file.writeAsBytes(png!.buffer.asUint8List());
        image.dispose();
      });
      await tester.pumpWidget(const SizedBox());
      debugDisableShadows = true;
    });
  }
}
