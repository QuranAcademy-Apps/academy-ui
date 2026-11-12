import 'dart:io';
import 'dart:ui' as ui;

import 'package:academy_ui/academy_ui.dart';
import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';

import 'capture_controls_test.dart' show fonts;

void main() {
  testWidgets('capture selection menus in both themes', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await fonts();
    for (final brightness in Brightness.values) {
      for (final multiple in [false, true]) {
        final key = GlobalKey();
        final appearance = AcademyAppearanceController(
          initial: AcademyAppearance(
            mode: brightness == Brightness.light
                ? AcademyAppearanceMode.light
                : AcademyAppearanceMode.dark,
          ),
        );
        await tester.pumpWidget(
          RepaintBoundary(
            key: key,
            child: AcademyApp(
              appearance: appearance,
              home: CupertinoPageScaffold(
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Text('Формы и выбор'),
                        const SizedBox(height: 24),
                        AcademyTextFormField(label: 'Имя', initialValue: 'Аюб'),
                        if (multiple)
                          AcademyMultiSelect<String>(
                            label: 'Темы',
                            values: const {'reading'},
                            presentation: AcademySelectPresentation.menu,
                            options: const [
                              AcademySelectOption(
                                value: 'reading',
                                label: 'Чтение',
                                subtitle: 'Текст и переводы',
                              ),
                              AcademySelectOption(
                                value: 'audio',
                                label: 'Аудио',
                                subtitle: 'Прослушивание',
                              ),
                              AcademySelectOption(
                                value: 'practice',
                                label: 'Практика',
                              ),
                            ],
                            onChanged: (_) {},
                          )
                        else
                          AcademySelect<String>(
                            label: 'Язык',
                            value: 'ru',
                            presentation: AcademySelectPresentation.menu,
                            options: const [
                              AcademySelectOption(
                                value: 'ru',
                                label: 'Русский',
                              ),
                              AcademySelectOption(
                                value: 'en',
                                label: 'English',
                              ),
                              AcademySelectOption(
                                value: 'ar',
                                label: 'Арабский',
                              ),
                              AcademySelectOption(
                                value: 'soon',
                                label: 'Скоро',
                                enabled: false,
                              ),
                            ],
                            onChanged: (_) {},
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
        await tester.tap(find.text(multiple ? 'Выбрано: 1' : 'Русский'));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        final boundary =
            key.currentContext!.findRenderObject() as RenderRepaintBoundary;
        await tester.runAsync(() async {
          final image = await boundary.toImage(pixelRatio: 2);
          final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
          final file = File(
            '../../docs/previews/select-${multiple ? 'topics' : 'language'}-${brightness.name}.png',
          );
          await file.writeAsBytes(bytes!.buffer.asUint8List());
          image.dispose();
        });
        await tester.pumpWidget(const SizedBox());
        appearance.dispose();
      }
    }
  });
}
