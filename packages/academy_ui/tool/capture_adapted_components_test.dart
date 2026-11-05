// Real widget preview. Inter substitutes for Apple system fonts in headless QA.
import 'dart:io';
import 'dart:ui' as ui;

import 'package:academy_ui/academy_ui.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';

import 'capture_controls_test.dart' show fonts;

const options = [
  AcademySelectOption(value: 'reading', label: 'Чтение'),
  AcademySelectOption(value: 'audio', label: 'Аудио'),
  AcademySelectOption(value: 'practice', label: 'Практика'),
];

Widget panel(Brightness brightness) {
  final theme = academyTheme(brightness);
  return AcademyTheme(
    data: theme,
    child: CupertinoTheme(
      data: theme.cupertino,
      child: ColoredBox(
        color: theme.scaffoldBackgroundColor,
        child: DefaultTextStyle(
          style: theme.textTheme.bodyLarge,
          child: Padding(
            padding: const EdgeInsets.all(28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  brightness == Brightness.light
                      ? 'Academy UI · Светлая'
                      : 'Academy UI · Тёмная',
                  style: theme.textTheme.titleMedium,
                ),
                const SizedBox(height: 18),
                AcademyTextFormField(
                  label: 'Название',
                  initialValue: 'Ежедневная практика',
                  help: 'Общая основа поля и валидации',
                ),
                AcademySelect<String>(
                  label: 'Раздел',
                  value: 'reading',
                  options: options,
                  onChanged: (_) {},
                ),
                AcademyMultiSelect<String>(
                  label: 'Темы',
                  values: const {'reading', 'audio'},
                  options: options,
                  onChanged: (_) {},
                ),
                const SizedBox(height: 8),
                AcademyDateInput(
                  label: 'Дата',
                  value: DateTime(2026, 10, 2),
                  onChanged: (_) {},
                ),
                AcademyTimeField(
                  label: 'Время',
                  value: const AcademyTime(9, 30),
                  onChanged: (_) {},
                ),
                const SizedBox(height: 20),
                Text('Календарь', style: theme.textTheme.titleMedium),
                AcademyCalendar(
                  value: DateTime(2026, 10, 2),
                  onChanged: (_) {},
                ),
                const SizedBox(height: 20),
                AcademySlider(
                  label: 'Размер текста',
                  value: 18,
                  min: 12,
                  max: 32,
                  onChanged: (_) {},
                  formatValue: (v) => '${v.round()} пт',
                ),
                const SizedBox(height: 12),
                AcademyFocusOutline(
                  focused: true,
                  child: AcademyButton(
                    label: 'Фокус с клавиатуры',
                    onPressed: () {},
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}

void main() {
  testWidgets('capture Academy adaptations in both themes', (tester) async {
    tester.view.physicalSize = const Size(880, 1220);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await fonts();
    final key = GlobalKey();
    await tester.pumpWidget(
      AcademyApp(
        home: RepaintBoundary(
          key: key,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(child: panel(Brightness.light)),
              Expanded(child: panel(Brightness.dark)),
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
      final file = File('../../docs/previews/forui-adapted-components.png');
      await file.parent.create(recursive: true);
      await file.writeAsBytes(bytes!.buffer.asUint8List());
      image.dispose();
    });
    await tester.pumpWidget(const SizedBox());
  });
}
