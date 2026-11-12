import 'package:academy_ui/academy_ui.dart';
import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:flutter_test/flutter_test.dart';

// Menu and toast options added with Yalla's menus and toasts (2026-11-02).

const _menuSurface = Color(0xFFF0F1F3);
const _menuHighlight = Color(0xFFDDE8FF);

AcademyThemeData _theme() => academyTheme(
  Brightness.dark,
  colors: AcademyPalette(
    Brightness.dark,
    AcademyTokens.brand,
  ).copyWith(menuSurface: _menuSurface, menuHighlight: _menuHighlight),
);

void main() {
  test('menu surface follows the card surface until a client sets it', () {
    final data = AcademyColorsData.from(
      AcademyPalette(Brightness.light, AcademyTokens.brand),
    );
    expect(data.menuSurface, data.surface);
    expect(
      data.copyWith(surface: const Color(0xFF123456)).menuSurface,
      const Color(0xFF123456),
    );
    final own = data.copyWith(menuSurface: _menuSurface);
    expect(
      own.copyWith(surface: const Color(0xFF123456)).menuSurface,
      _menuSurface,
    );
    expect(own.value(AcademyColorRole.menuSurface), _menuSurface);
  });

  testWidgets('menu rows paint the opaque menu surface', (tester) async {
    final controller = MenuController();
    await tester.pumpWidget(
      AcademyApp(
        home: AcademyTheme(
          data: _theme(),
          child: Center(
            child: AcademyMenuAnchor(
              controller: controller,
              menuChildren: [
                AcademyMenuItem(title: 'Москва', onPressed: () {}),
              ],
              builder: (_, _, _) => const SizedBox.square(dimension: 44),
            ),
          ),
        ),
      ),
    );
    controller.open();
    await tester.pumpAndSettle();
    final decorations = tester
        .widgetList<DecoratedBox>(
          find.descendant(
            of: find.byType(AcademyMenuItem),
            matching: find.byType(DecoratedBox),
          ),
        )
        .map((box) => box.decoration)
        .whereType<BoxDecoration>()
        .where((box) => box.color == _menuSurface);
    expect(decorations, isNotEmpty);
    expect(decorations.first.backgroundBlendMode, BlendMode.srcOver);
  });

  testWidgets('the current option closes without repeating its action', (
    tester,
  ) async {
    final selected = <String>[];
    await tester.pumpWidget(
      AcademyApp(
        home: Center(
          child: AcademyInlineOptionMenu(
            label: 'Город',
            value: 'Москва',
            options: const ['Москва', 'Казань'],
            onSelected: selected.add,
          ),
        ),
      ),
    );
    Future<void> pick(String option) async {
      await tester.tap(find.text('Город'));
      await tester.pumpAndSettle();
      await tester.tap(find.text(option).last);
      await tester.pumpAndSettle();
    }

    await pick('Москва');
    expect(selected, isEmpty);
    expect(find.byType(AcademyMenuItem), findsNothing);
    await pick('Казань');
    expect(selected, ['Казань']);
  });

  testWidgets('toast clears side safe areas and takes the chrome style', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(844, 390);
    tester.view.devicePixelRatio = 1;
    tester.view.padding = const FakeViewPadding(left: 59, right: 21);
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      AcademyApp(
        home: AcademyToastHost(
          style: AcademyChromeStyle.glass,
          child: Builder(
            builder: (context) => CupertinoButton(
              onPressed: () => AcademyToastHost.show(
                context,
                'Очень длинное сообщение, которое займёт всю доступную ширину '
                'экрана в горизонтальной ориентации телефона',
              ),
              child: const Text('show'),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('show'));
    await tester.pumpAndSettle();
    final toast = tester.getRect(find.byType(AcademyChrome));
    expect(toast.left, greaterThanOrEqualTo(59 + 16));
    expect(toast.right, lessThanOrEqualTo(844 - 21 - 16));
    expect(find.byType(AcademyGlassMaterial), findsOneWidget);
  });

  testWidgets('toast overlay follows its message and runs its action', (
    tester,
  ) async {
    var acted = 0, dismissed = 0;
    Widget app(String? message) => AcademyApp(
      home: Center(
        child: AcademyToastOverlay(
          message: message,
          position: AcademyToastPosition.bottom,
          actionLabel: 'Вернуть',
          onAction: () => acted++,
          onDismissed: () => dismissed++,
          showCloseButton: true,
        ),
      ),
    );
    await tester.pumpWidget(app('Удалено'));
    await tester.pumpAndSettle();
    expect(find.text('Удалено'), findsOneWidget);
    await tester.tap(find.text('Вернуть'));
    await tester.pumpAndSettle();
    expect(acted, 1);
    expect(find.text('Удалено'), findsNothing);
    await tester.pumpWidget(app(null));
    await tester.pumpWidget(app('Снова'));
    await tester.pumpAndSettle();
    await tester.tap(find.bySemanticsLabel('Закрыть'));
    await tester.pumpAndSettle();
    expect(dismissed, 1);
    await tester.pumpWidget(const SizedBox());
  });

  test('the toast controller clears its value and stops after dispose', () {
    final controller = AcademyToastController<String>();
    controller.show('a');
    expect(controller.value, 'a');
    controller.hide();
    expect(controller.value, isNull);
    controller.dispose();
    controller.show('b');
    expect(controller.value, isNull);
  });
}
