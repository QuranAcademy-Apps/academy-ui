import 'package:academy_ui/academy_ui.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('disclosure is controlled and does not inherit blur', (
    tester,
  ) async {
    var expanded = false;
    final appearance = AcademyAppearanceController(
      initial: const AcademyAppearance(chromeStyle: AcademyChromeStyle.blur),
    );
    await appearance.ready;
    addTearDown(appearance.dispose);
    await tester.pumpWidget(
      AcademyApp(
        appearance: appearance,
        home: StatefulBuilder(
          builder: (context, setState) => Center(
            child: SizedBox(
              width: 300,
              child: AcademyDisclosureCard(
                title: 'Список',
                expanded: expanded,
                onToggle: () => setState(() => expanded = !expanded),
                child: const SizedBox(height: 150, child: Text('Содержимое')),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    final collapsed = tester.getSize(find.byType(AcademyDisclosureCard)).height;
    await tester.tap(find.text('Список'));
    await tester.pumpAndSettle();
    expect(expanded, isTrue);
    expect(
      tester.getSize(find.byType(AcademyDisclosureCard)).height,
      greaterThan(collapsed + 100),
    );
    expect(find.byType(BackdropFilter), findsNothing);
    await tester.tap(find.text('Список'));
    await tester.pumpAndSettle();
    expect(
      tester.getSize(find.byType(AcademyDisclosureCard)).height,
      closeTo(collapsed, .1),
    );
  });

  testWidgets(
    'menu combines left/right icons and checkmark and closes after choice',
    (tester) async {
      var calls = 0;
      await tester.pumpWidget(
        AcademyApp(
          home: Center(
            child: AcademyMenuButton(
              title: 'Меню',
              items: [
                AcademyMenuItem(
                  title: 'Настройки',
                  leadingIcon: AcademySymbols.gear,
                  trailingIcon: AcademySymbols.forward,
                  checked: true,
                  onPressed: () => calls++,
                ),
                AcademyMenuItem(title: 'Простое действие', onPressed: () {}),
              ],
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Меню'));
      await tester.pumpAndSettle();
      expect(find.text('Настройки'), findsOneWidget);
      final icons = tester
          .widgetList<AcademySfIcon>(
            find.descendant(
              of: find.byType(AcademyMenuItem).first,
              matching: find.byType(AcademySfIcon),
            ),
          )
          .map((icon) => icon.icon);
      expect(
        icons,
        containsAll([
          AcademySymbols.gear,
          AcademySymbols.forward,
          AcademySymbols.checkmark,
        ]),
      );
      expect(
        find.descendant(
          of: find.byType(AcademyMenuItem).last,
          matching: find.byType(AcademySfIcon),
        ),
        findsNothing,
      );
      await tester.tap(find.text('Настройки'));
      await tester.pumpAndSettle();
      expect(calls, 1);
      expect(find.text('Настройки'), findsNothing);
    },
  );

  testWidgets('compact segment changes once and handles 320px large RTL text', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(320, 600);
    addTearDown(tester.view.reset);
    var value = 0;
    var calls = 0;
    await tester.pumpWidget(
      AcademyApp(
        home: StatefulBuilder(
          builder: (context, setState) => MediaQuery(
            data: MediaQuery.of(context).copyWith(
              textScaler: const TextScaler.linear(2),
              disableAnimations: true,
            ),
            child: Directionality(
              textDirection: TextDirection.rtl,
              child: Center(
                child: AcademyCompactSegment<int>(
                  items: const [0, 1, 2],
                  value: value,
                  labelFor: (i) => ['Первый', 'Второй', 'Третий'][i],
                  onChanged: (i) => setState(() {
                    value = i;
                    calls++;
                  }),
                ),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Первый'));
    expect(calls, 0);
    await tester.tap(find.text('Второй'));
    await tester.pumpAndSettle();
    expect(calls, 1);
    expect(value, 1);
    expect(tester.takeException(), isNull);
    final control = tester.getRect(find.byType(AcademyCompactSegment<int>));
    expect(control.width, 320);
    expect(control.height, greaterThanOrEqualTo(44));
  });

  testWidgets(
    'search reveals field, focuses it, clears on close and keeps external controller',
    (tester) async {
      final controller = TextEditingController();
      addTearDown(controller.dispose);
      final changes = <String>[];
      await tester.pumpWidget(
        AcademyApp(
          home: Center(
            child: SizedBox(
              width: 300,
              child: AcademyExpandingSearch(
                controller: controller,
                onChanged: changes.add,
                resting: const Text('Заголовок'),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(tester.getSize(find.byType(SizeTransition)).width, 0);
      await tester.tap(
        find.byWidgetPredicate(
          (w) => w is AcademyChromeButton && w.label == 'Открыть поиск',
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      final during = tester.getSize(find.byType(SizeTransition)).width;
      await tester.pumpAndSettle();
      expect(during, greaterThan(0));
      expect(
        during,
        lessThan(tester.getSize(find.byType(SizeTransition)).width),
      );
      final field = tester.widget<CupertinoTextField>(
        find.byType(CupertinoTextField),
      );
      expect(field.focusNode!.hasFocus, isTrue);
      await tester.enterText(find.byType(CupertinoTextField), 'Запрос');
      await tester.tap(
        find.byWidgetPredicate(
          (w) => w is AcademyChromeButton && w.label == 'Закрыть поиск',
        ),
      );
      await tester.pumpAndSettle();
      expect(controller.text, isEmpty);
      expect(field.focusNode!.hasFocus, isFalse);
      expect(changes, ['Запрос', '']);
      await tester.pumpWidget(const SizedBox());
      controller.text = 'Внешний контроллер жив';
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'toast supports both icons, top and bottom and swipes on either axis',
    (tester) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(390, 844);
      addTearDown(tester.view.reset);
      late BuildContext context;
      await tester.pumpWidget(
        AcademyApp(
          home: Builder(
            builder: (ctx) {
              context = ctx;
              return const SizedBox.expand();
            },
          ),
        ),
      );
      await tester.pumpAndSettle();
      AcademyToastHost.show(
        context,
        'Сверху',
        position: AcademyToastPosition.top,
        leadingIcon: AcademySymbols.gear,
        trailingIcon: AcademySymbols.checkmark,
      );
      await tester.pumpAndSettle();
      final toast = find.byKey(const ValueKey('academy-toast'));
      expect(tester.getRect(toast).top, lessThan(60));
      expect(
        tester
            .widgetList<AcademySfIcon>(
              find.descendant(of: toast, matching: find.byType(AcademySfIcon)),
            )
            .length,
        2,
      );
      await tester.drag(toast, const Offset(120, 0));
      await tester.pumpAndSettle();
      expect(toast, findsNothing);
      AcademyToastHost.show(
        context,
        'Снизу',
        trailingIcon: AcademySymbols.complete,
      );
      await tester.pumpAndSettle();
      expect(tester.getRect(toast).top, greaterThan(700));
      await tester.drag(toast, const Offset(0, -100));
      await tester.pumpAndSettle();
      expect(toast, findsNothing);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'toast timer pauses while held; replacement and disposal are safe',
    (tester) async {
      late BuildContext context;
      await tester.pumpWidget(
        AcademyApp(
          home: Builder(
            builder: (ctx) {
              context = ctx;
              return const SizedBox.expand();
            },
          ),
        ),
      );
      await tester.pumpAndSettle();
      AcademyToastHost.show(
        context,
        'Первый',
        duration: const Duration(seconds: 1),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));
      final toast = find.byKey(const ValueKey('academy-toast'));
      final gesture = await tester.startGesture(tester.getCenter(toast));
      await tester.pump(const Duration(seconds: 2));
      expect(find.text('Первый'), findsOneWidget);
      await gesture.moveBy(const Offset(100, 0));
      await gesture.up();
      await tester.pump(const Duration(milliseconds: 80));
      AcademyToastHost.show(context, 'Замена');
      await tester.pump(const Duration(milliseconds: 400));
      expect(find.text('Замена'), findsOneWidget);
      await tester.pumpWidget(const SizedBox());
      await tester.pump(const Duration(seconds: 5));
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('menu and toast can be used inside a partial modal', (
    tester,
  ) async {
    late BuildContext context;
    await tester.pumpWidget(
      AcademyApp(
        home: Builder(
          builder: (ctx) {
            context = ctx;
            return const SizedBox.expand();
          },
        ),
      ),
    );
    await tester.pumpAndSettle();
    showAcademyModal<void>(
      context,
      title: 'Модалка',
      builder: (context) => AcademyModalListView(
        children: [
          AcademyMenuButton(
            title: 'Выбрать',
            items: [
              AcademyMenuItem(
                title: 'Готово',
                onPressed: () => AcademyToastHost.show(context, 'Выбрано'),
              ),
            ],
          ),
        ],
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Выбрать'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Готово'));
    await tester.pumpAndSettle();
    expect(find.text('Выбрано'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
