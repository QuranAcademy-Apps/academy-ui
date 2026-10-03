import 'package:academy_ui/academy_ui.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('navigation and content fit 320px, RTL and large text', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(320, 844);
    addTearDown(tester.view.reset);
    final appearance = AcademyAppearanceController(
      initial: const AcademyAppearance(mode: AcademyAppearanceMode.dark),
    );
    addTearDown(appearance.dispose);
    await appearance.ready;
    await tester.pumpWidget(
      AcademyApp(
        appearance: appearance,
        home: Builder(
          builder: (context) => MediaQuery(
            data: MediaQuery.of(context).copyWith(
              textScaler: const TextScaler.linear(2),
              disableAnimations: true,
            ),
            child: Directionality(
              textDirection: TextDirection.rtl,
              child: AcademyTabScaffold(
                tabs: [
                  AcademyTab(
                    label: 'Главная',
                    icon: AcademySymbols.book,
                    builder: (_) => AcademyPage(
                      title: 'Настройки',
                      child: Builder(
                        builder: (context) => ListView(
                          padding: EdgeInsets.fromLTRB(
                            16,
                            AcademyPageInsets.topOf(context),
                            16,
                            140,
                          ),
                          children: [
                            AcademyGroupedTable(
                              sections: [
                                AcademyTableSection(
                                  rows: [
                                    AcademyOptionMenu(
                                      label: 'Внешний вид',
                                      value: 'Системная тема',
                                      options: const ['Системная тема'],
                                      onSelected: (_) {},
                                    ),
                                    const AcademyRow(
                                      title: 'Очень длинное название настройки',
                                      subtitle: 'Дополнительное описание',
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            AcademyButton(
                              label: 'Продолжить с выбранными настройками',
                              onPressed: () {},
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  AcademyTab(
                    label: 'Настройки',
                    icon: AcademySymbols.gear,
                    builder: (_) => const SizedBox(),
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
    final bar = tester.getRect(find.byType(AcademyFloatingTabBar));
    expect(bar.left, 16);
    expect(bar.right, 304);
    expect(bar.bottom, lessThanOrEqualTo(844));
  });

  testWidgets(
    'blur is restricted to navigation and never inherited by content',
    (tester) async {
      final appearance = AcademyAppearanceController(
        initial: const AcademyAppearance(chromeStyle: AcademyChromeStyle.blur),
      );
      addTearDown(appearance.dispose);
      await appearance.ready;
      final search = TextEditingController();
      addTearDown(search.dispose);
      await tester.pumpWidget(
        AcademyApp(
          appearance: appearance,
          home: CupertinoPageScaffold(
            child: Column(
              children: [
                AcademyGroupedTable(
                  sections: [
                    AcademyTableSection(rows: [AcademyRow(title: 'Строка')]),
                  ],
                ),
                const AcademySurface(child: Text('Карточка')),
                AcademySearchBar(controller: search, chrome: false),
                AcademyChromeButton(
                  icon: AcademySymbols.close,
                  label: 'Закрыть',
                  onPressed: () {},
                ),
              ],
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(
        find.descendant(
          of: find.byType(AcademyGroupedTable),
          matching: find.byType(BackdropFilter),
        ),
        findsNothing,
      );
      expect(
        find.descendant(
          of: find.byType(AcademySurface),
          matching: find.byType(BackdropFilter),
        ),
        findsNothing,
      );
      expect(
        find.descendant(
          of: find.byType(AcademySearchBar),
          matching: find.byType(BackdropFilter),
        ),
        findsNothing,
      );
      final blur = tester.widget<BackdropFilter>(find.byType(BackdropFilter));
      expect(blur.filter.toString(), contains('20.0'));
      final field = tester.widget<CupertinoTextField>(
        find.byType(CupertinoTextField),
      );
      final theme = academyTheme(Brightness.light);
      expect(field.decoration!.color, theme.colorScheme.textFieldBackground);
      expect(
        field.placeholderStyle!.color,
        theme.colorScheme.textFieldSecondaryForeground,
      );
    },
  );

  testWidgets('pending and disabled buttons cannot submit', (tester) async {
    var actions = 0;
    await tester.pumpWidget(
      AcademyApp(
        home: CupertinoPageScaffold(
          child: Column(
            children: [
              const AcademyButton(label: 'Недоступно'),
              AcademyButton(
                label: 'Сохранение',
                pending: true,
                onPressed: () => actions++,
              ),
            ],
          ),
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 50));
    await tester.tap(find.text('Недоступно'));
    await tester.tap(find.text('Сохранение'));
    expect(actions, 0);
  });
}
