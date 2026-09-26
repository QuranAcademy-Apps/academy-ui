// Run explicitly: flutter test tool/capture_controls_test.dart --no-pub
// Produces previews from real library widgets, with bundled fonts loaded.
import 'dart:io';
import 'dart:ui' as ui;

import 'package:academy_ui/academy_ui.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

Future<void> fonts() async {
  for (final (family, asset) in [
    ('packages/academy_ui/Inter', 'packages/academy_ui/assets/fonts/Inter.ttf'),
    ('.SF Pro Text', 'packages/academy_ui/assets/fonts/Inter.ttf'),
    (
      'packages/flutter_sficon/sficons',
      'packages/flutter_sficon/lib/fonts/sficons.ttf',
    ),
    (
      'packages/cupertino_icons/CupertinoIcons',
      'packages/cupertino_icons/assets/CupertinoIcons.ttf',
    ),
  ]) {
    await (FontLoader(family)..addFont(rootBundle.load(asset))).load();
  }
}

Widget label(String title, Widget child) => Padding(
  padding: const EdgeInsets.only(bottom: 20),
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    mainAxisSize: MainAxisSize.min,
    children: [
      Text(
        title,
        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
      ),
      const SizedBox(height: 8),
      child,
    ],
  ),
);

Widget gallery(Brightness brightness, TextEditingController search) {
  final theme = academyTheme(brightness);
  return AcademyTheme(
    data: theme,
    child: CupertinoTheme(
      data: theme.cupertino,
      child: AcademyChromeTheme(
        style: AcademyChromeStyle.blur,
        child: ColoredBox(
          color: theme.scaffoldBackgroundColor,
          child: DefaultTextStyle(
            style: theme.textTheme.bodyLarge,
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    brightness == Brightness.light
                        ? 'Светлая тема'
                        : 'Тёмная тема',
                    style: theme.textTheme.bodyLarge.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 24),
                  label(
                    '1. Две кнопки · общий фон и разделитель',
                    Align(
                      alignment: AlignmentDirectional.centerStart,
                      child: AcademyChromeGroup(
                        actions: [
                          AcademyChromeAction(
                            AcademySymbols.book,
                            'Закладки',
                            () {},
                          ),
                          AcademyChromeAction(
                            AcademySymbols.search,
                            'Поиск',
                            () {},
                          ),
                        ],
                      ),
                    ),
                  ),
                  label(
                    '2. Список · закрыт',
                    AcademyDisclosureCard(
                      title: 'Раскрывающийся список',
                      expanded: false,
                      onToggle: () {},
                      child: const Text('Содержимое'),
                    ),
                  ),
                  label(
                    '2. Список · раскрыт',
                    AcademyDisclosureCard(
                      title: 'Раскрывающийся список',
                      expanded: true,
                      onToggle: () {},
                      child: const Column(
                        children: [
                          AcademyRow(
                            title: 'Первый пункт',
                            subtitle: 'Описание пункта',
                            icon: AcademySymbols.book,
                          ),
                          AcademyRow(
                            title: 'Второй пункт',
                            subtitle: 'Описание пункта',
                            icon: AcademySymbols.checkmark,
                          ),
                        ],
                      ),
                    ),
                  ),
                  label(
                    '4. Маленькие сегменты и кнопка',
                    Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: AcademyCompactSegment<int>(
                                items: const [0, 1, 2],
                                value: 0,
                                labelFor: (i) => '$i',
                                iconFor: (i) => [
                                  AcademySymbols.document,
                                  AcademySymbols.checklist,
                                  AcademySymbols.book,
                                ][i],
                                onChanged: (_) {},
                              ),
                            ),
                            AcademyCompactIconButton(onPressed: () {}),
                          ],
                        ),
                        AcademyCompactSegment<int>(
                          items: const [0, 1, 2],
                          value: 1,
                          labelFor: (i) => ['1×', '1.5×', '2×'][i],
                          onChanged: (_) {},
                          style: AcademySegmentStyle.compact,
                        ),
                      ],
                    ),
                  ),
                  label(
                    '5. Тема · двойной шеврон',
                    Row(
                      children: [
                        AcademySettingsSquareButton(
                          icon: AcademySymbols.rotate,
                          label: 'Повернуть',
                          onPressed: () {},
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: AcademyMenuButton(
                            title: 'Тема',
                            minimumHeight: 68,
                            expand: true,
                            subtitle: 'Классическая',
                            style: AcademyChromeStyle.flat,
                            items: const [],
                          ),
                        ),
                        const SizedBox(width: 8),
                        AcademySettingsSquareButton(
                          icon: AcademySymbols.sun,
                          label: 'Свет',
                          onPressed: () {},
                        ),
                      ],
                    ),
                  ),
                  label(
                    '5. Меню · шеврон слева',
                    const AcademyMenuButton(
                      title: 'Uthmani 25',
                      subtitle: 'Коран',
                      chevronOnLeading: true,
                      items: [],
                    ),
                  ),
                  label(
                    '6. Лупа → поиск → крестик',
                    AcademyExpandingSearch(
                      controller: search,
                      resting: const Text('Нажмите лупу'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    ),
  );
}

void main() {
  testWidgets('render component and interaction previews', (tester) async {
    await fonts();
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(900, 1040);
    addTearDown(tester.view.reset);
    final left = TextEditingController(), right = TextEditingController();
    addTearDown(left.dispose);
    addTearDown(right.dispose);
    final boundary = GlobalKey();
    Future<void> save(String name) async {
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      await tester.runAsync(() async {
        final image =
            await (boundary.currentContext!.findRenderObject()
                    as RenderRepaintBoundary)
                .toImage(pixelRatio: 2);
        final png = await image.toByteData(format: ui.ImageByteFormat.png);
        final directory = Directory('../../docs/previews')
          ..createSync(recursive: true);
        File('${directory.path}/$name.png')
            .writeAsBytesSync(png!.buffer.asUint8List());
        image.dispose();
      });
    }

    await tester.pumpWidget(
      RepaintBoundary(
        key: boundary,
        child: AcademyApp(
          home: Row(
            children: [
              Expanded(child: gallery(Brightness.light, left)),
              Expanded(child: gallery(Brightness.dark, right)),
            ],
          ),
        ),
      ),
    );
    await save('quran-controls');

    tester.view.physicalSize = const Size(900, 600);
    late BuildContext context;
    await tester.pumpWidget(
      RepaintBoundary(
        key: boundary,
        child: AcademyApp(
          home: Builder(
            builder: (ctx) {
              context = ctx;
              return ColoredBox(
                color: AcademyTheme.of(ctx).scaffoldBackgroundColor,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 100, 24, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text(
                        'Меню с иконками и выбором · раскрытый поиск',
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 32),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            width: 340,
                            child: AcademyMenuButton(
                              title: 'Открыть меню',
                              items: [
                                AcademyMenuItem(
                                  title: 'Начало',
                                  trailingIcon: AcademySymbols.play,
                                  onPressed: () {},
                                ),
                                AcademyMenuItem(
                                  title: 'Автопрокрутка',
                                  leadingIcon: AcademySymbols.upDown,
                                  checked: true,
                                  onPressed: () {},
                                ),
                                AcademyMenuItem(
                                  title: 'Настройки',
                                  leadingIcon: AcademySymbols.gear,
                                  trailingIcon: AcademySymbols.forward,
                                  onPressed: () {},
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 32),
                          Expanded(
                            child: AcademyExpandingSearch(
                              controller: left,
                              resting: const Text('Поиск'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(
      find.byWidgetPredicate(
        (w) => w is AcademyChromeButton && w.label == 'Открыть поиск',
      ),
    );
    await tester.pumpAndSettle();
    left.text = 'Поиск';
    await tester.tap(find.text('Открыть меню'));
    await tester.pumpAndSettle();
    if (!context.mounted) return;
    AcademyToastHost.show(
      context,
      'Настройки сохранены · смахните тост',
      position: AcademyToastPosition.top,
      leadingIcon: AcademySymbols.gear,
      trailingIcon: AcademySymbols.checkmark,
      duration: const Duration(seconds: 20),
    );
    await save('quran-interactions');
  });
}
