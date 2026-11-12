import 'package:academy_ui/academy_ui.dart';
import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets(
    'Telegram profile uses source geometry and equal widths when labels fit',
    (tester) async {
      final tabs = [
        for (final label in ['Каталог', 'Quran', 'Модалки', 'Оформление'])
          AcademyTab(
            label: label,
            icon: AcademySymbols.book,
            builder: (_) => const SizedBox(),
          ),
      ];
      Future<Size> measure(AcademyTabBarDensity density) async {
        await tester.pumpWidget(
          AcademyApp(
            home: Center(
              child: AcademyFloatingTabBar(
                tabs: tabs,
                index: 3,
                onChanged: (_) {},
                density: density,
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        return tester.getSize(find.byType(AcademyChrome));
      }

      final standard = await measure(AcademyTabBarDensity.standard);
      final compact = await measure(AcademyTabBarDensity.telegram);
      expect(standard, const Size(416, 60));
      expect(compact.height, 64);
      expect(compact.width, 500);
      final short = tester
          .getSize(find.widgetWithText(CupertinoButton, 'Quran'))
          .width;
      final long = tester
          .getSize(find.widgetWithText(CupertinoButton, 'Оформление'))
          .width;
      expect(long, short);
      final button = find.widgetWithText(CupertinoButton, 'Оформление');
      final label = find.text('Оформление');
      final labelWidget = tester.widget<Text>(label);
      expect(labelWidget.style!.fontSize, 10);
      expect(labelWidget.style!.fontWeight, FontWeight.w600);
      expect(
        tester.getBottomLeft(button).dy - tester.getBottomLeft(label).dy,
        8,
      );
      final icon = find.descendant(
        of: button,
        matching: find.byType(AcademySfIcon),
      );
      expect(tester.getTopLeft(icon).dy - tester.getTopLeft(button).dy, 3);
      final icons = tester.widgetList<AcademySfIcon>(
        find.byType(AcademySfIcon),
      );
      expect(
        icons.every((icon) => icon.boxSize == 32 && icon.paintExtent == 32),
        isTrue,
      );
    },
  );

  testWidgets(
    'Telegram profile gives long labels more width on narrow screens',
    (tester) async {
      var selected = -1;
      await tester.pumpWidget(
        AcademyApp(
          home: Center(
            child: SizedBox(
              width: 280,
              child: AcademyFloatingTabBar(
                density: AcademyTabBarDensity.telegram,
                index: 2,
                onChanged: (index) => selected = index,
                tabs: [
                  for (final label in [
                    'Контакты',
                    'Чаты',
                    'Настройки уведомлений',
                  ])
                    AcademyTab(
                      label: label,
                      icon: AcademySymbols.book,
                      builder: (_) => const SizedBox(),
                    ),
                ],
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      final short = tester
          .getSize(find.widgetWithText(CupertinoButton, 'Чаты'))
          .width;
      final long = tester
          .getSize(
            find.widgetWithText(CupertinoButton, 'Настройки уведомлений'),
          )
          .width;
      expect(long, greaterThan(short));
      expect(short, greaterThanOrEqualTo(44));
      expect(
        tester.getSize(find.byType(AcademyChrome)).width,
        lessThanOrEqualTo(280),
      );
      await tester.tap(find.text('Настройки уведомлений'));
      expect(selected, 2);
      expect(tester.takeException(), isNull);
    },
  );
  for (final density in AcademyTabBarDensity.values) {
    for (final direction in TextDirection.values) {
      testWidgets(
        '$density tab bar fits five tabs, large text and $direction',
        (tester) async {
          tester.view.devicePixelRatio = 1;
          tester.view.physicalSize = const Size(320, 844);
          addTearDown(tester.view.reset);
          final appearance = AcademyAppearanceController(
            initial: AcademyAppearance(tabBarDensity: density),
          );
          await appearance.ready;
          addTearDown(appearance.dispose);
          var selected = -1;
          double obstruction = 0;
          await tester.pumpWidget(
            AcademyApp(
              appearance: appearance,
              home: Builder(
                builder: (context) => MediaQuery(
                  data: MediaQuery.of(context)
                      .copyWith(textScaler: const TextScaler.linear(2)),
                  child: Directionality(
                    textDirection: direction,
                    child: Builder(
                      builder: (context) {
                        obstruction = AcademyFloatingTabBar.bottomObstructionOf(
                          context,
                        );
                        return Center(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: AcademyFloatingTabBar(
                              tabs: [
                                for (final label in [
                                  'Статус',
                                  'Звонки',
                                  'Инструменты',
                                  'Чаты',
                                  'Настройки',
                                ])
                                  AcademyTab(
                                    label: label,
                                    icon: AcademySymbols.book,
                                    builder: (_) => const SizedBox(),
                                  ),
                              ],
                              index: 3,
                              onChanged: (index) => selected = index,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
          );
          await tester.pumpAndSettle();
          expect(tester.takeException(), isNull);
          final height = tester.getSize(find.byType(AcademyChrome)).height;
          expect(height, switch (density) {
            AcademyTabBarDensity.standard => 71,
            AcademyTabBarDensity.compact => 66,
            AcademyTabBarDensity.telegram => 74,
          });
          expect(obstruction, greaterThanOrEqualTo(height));
          for (final button in tester.widgetList<CupertinoButton>(
            find.byType(CupertinoButton),
          )) {
            expect(
              tester.getSize(find.byWidget(button)).width,
              greaterThanOrEqualTo(44),
            );
          }
          await tester.tap(find.text('Чаты'));
          expect(selected, 3);
        },
      );
    }
  }

  testWidgets('compact is shorter and never wider than standard for 3–5 tabs', (
    tester,
  ) async {
    for (final screenWidth in [320.0, 1200.0]) {
      for (final scale in [1.0, 2.0]) {
        for (final count in [3, 4, 5]) {
          final tabs = [
            for (final label in [
              'Каталог',
              'Quran',
              'Модалки',
              'Оформление',
              'Настройки уведомлений',
            ].take(count))
              AcademyTab(
                label: label,
                icon: AcademySymbols.gear,
                builder: (_) => const SizedBox(),
              ),
          ];
          Future<Size> measure(AcademyTabBarDensity density) async {
            await tester.pumpWidget(
              AcademyApp(
                home: Builder(
                  builder: (context) => MediaQuery(
                    data: MediaQuery.of(context)
                        .copyWith(textScaler: TextScaler.linear(scale)),
                    child: Center(
                      child: SizedBox(
                        width: screenWidth,
                        child: AcademyFloatingTabBar(
                          density: density,
                          tabs: tabs,
                          index: 0,
                          onChanged: (_) {},
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            );
            await tester.pumpAndSettle();
            expect(tester.takeException(), isNull);
            return tester.getSize(find.byType(AcademyChrome));
          }

          final standard = await measure(AcademyTabBarDensity.standard);
          final compact = await measure(AcademyTabBarDensity.compact);
          expect(compact.height, lessThan(standard.height));
          expect(compact.width, lessThanOrEqualTo(standard.width));
          if (screenWidth > 416 && scale == 1) {
            expect(compact.width, lessThan(standard.width));
          }
          for (final button in tester.widgetList<CupertinoButton>(
            find.byType(CupertinoButton),
          )) {
            expect(
              tester.getSize(find.byWidget(button)).width,
              greaterThanOrEqualTo(44),
            );
          }
        }
      }
    }
  });
}
