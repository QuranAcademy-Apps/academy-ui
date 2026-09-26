import 'package:academy_ui/academy_ui.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';

Future<BuildContext> host(
  WidgetTester tester, {
  AcademyAppearanceController? appearance,
}) async {
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = const Size(390, 844);
  tester.view.padding = const FakeViewPadding(top: 44, bottom: 34);
  tester.view.viewPadding = const FakeViewPadding(top: 44, bottom: 34);
  addTearDown(tester.view.reset);
  late BuildContext context;
  await tester.pumpWidget(
    AcademyApp(
      appearance: appearance,
      home: Builder(
        builder: (ctx) {
          context = ctx;
          return const CupertinoPageScaffold(child: SizedBox.expand());
        },
      ),
    ),
  );
  await tester.pumpAndSettle();
  return context;
}

void main() {
  testWidgets('auto height is restored after editing', (tester) async {
    final context = await host(tester);
    showAcademyModal<void>(
      context,
      title: 'Форма',
      initialDetent: ModalSheetDetent.auto,
      detents: const [ModalSheetDetent.auto, ModalSheetDetent.full],
      autoHeight: 300,
      builder: (_) => const AcademyModalListView(
        children: [AcademyField(label: 'Название')],
      ),
    );
    await tester.pumpAndSettle();
    final restingTop = tester.getRect(find.byType(AcademyModalScaffold)).top;
    await tester.showKeyboard(find.byType(CupertinoTextField));
    await tester.pumpAndSettle();
    expect(
      tester.getRect(find.byType(AcademyModalScaffold)).top,
      lessThan(restingTop),
    );
    FocusManager.instance.primaryFocus?.unfocus();
    await tester.pumpAndSettle();
    expect(
      tester.getRect(find.byType(AcademyModalScaffold)).top,
      closeTo(restingTop, 1),
    );
  });

  testWidgets(
    'keyboard offset is owned once; last form action stays reachable',
    (tester) async {
      final context = await host(tester);
      var contentInset = -1.0;
      showAcademyModal<void>(
        context,
        title: 'Форма',
        builder: (context) {
          contentInset = MediaQuery.viewInsetsOf(context).bottom;
          return AcademyModalListView(
            children: [
              const AcademyField(label: 'Название'),
              for (var i = 0; i < 12; i++) Text('Строка $i'),
              AcademyButton(
                key: const ValueKey('save'),
                label: 'Сохранить',
                onPressed: () {},
              ),
            ],
          );
        },
      );
      await tester.pumpAndSettle();
      await tester.showKeyboard(find.byType(CupertinoTextField));
      tester.view.viewInsets = const FakeViewPadding(bottom: 320);
      tester.view.padding = const FakeViewPadding(top: 44);
      await tester.pumpAndSettle();
      expect(
        contentInset,
        0,
        reason: 'Route removes the consumed keyboard inset',
      );
      final rect = tester.getRect(find.byType(AcademyModalScaffold));
      expect(rect.height.isFinite, isTrue);
      expect(rect.height, lessThanOrEqualTo(524.5));
      expect(rect.top, greaterThanOrEqualTo(43.5));
      await tester.ensureVisible(find.byKey(const ValueKey('save')));
      // A translated sheet lays out a full-height body. Scroll to the end so
      // its detent padding, not the keyboard-covered slice, bounds the action.
      await tester.drag(find.byType(ListView), const Offset(0, -1000));
      await tester.pumpAndSettle();
      expect(
        tester.getRect(find.byKey(const ValueKey('save'))).bottom,
        lessThanOrEqualTo(524.5),
      );
      expect(tester.takeException(), isNull);

      FocusManager.instance.primaryFocus?.unfocus();
      tester.view.viewInsets = const FakeViewPadding();
      tester.view.padding = const FakeViewPadding(top: 44, bottom: 34);
      await tester.pumpAndSettle();
      expect(
        tester.getRect(find.byType(AcademyModalScaffold)).top,
        greaterThan(300),
      );
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('nested page survives rotation and close returns to app', (
    tester,
  ) async {
    final context = await host(tester);
    String? result;
    showAcademyModal<String>(
      context,
      title: 'Начало',
      nestedNavigation: true,
      builder: (inner) => AcademyModalListView(
        children: [
          AcademyButton(
            label: 'Дальше',
            onPressed: () => pushAcademyModalPage<void>(
              inner,
              title: 'Вложенная',
              builder: (inner) => AcademyModalListView(
                children: [
                  AcademyButton(
                    label: 'Готово',
                    onPressed: () => closeAcademyModal(inner, 'ok'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    ).then((value) => result = value);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Дальше'));
    await tester.pumpAndSettle();
    expect(find.text('Вложенная'), findsOneWidget);
    tester.view.physicalSize = const Size(844, 390);
    await tester.pumpAndSettle();
    expect(find.text('Вложенная'), findsOneWidget);
    expect(tester.takeException(), isNull);
    tester.view.physicalSize = const Size(390, 844);
    await tester.pumpAndSettle();
    expect(find.text('Вложенная'), findsOneWidget);
    await tester.tap(find.text('Готово'));
    await tester.pumpAndSettle();
    expect(result, 'ok');
    expect(find.byType(AcademyModalScaffold), findsNothing);
  });

  testWidgets('non-empty search stays expanded after focus is removed', (
    tester,
  ) async {
    final context = await host(tester);
    final search = TextEditingController();
    addTearDown(search.dispose);
    showAcademyModal<void>(
      context,
      title: 'Поиск',
      builder: (_) => AcademyModalListView(
        children: [
          AcademyModalSearch(
            controller: search,
            child: AcademySearchBar(controller: search),
          ),
        ],
      ),
    );
    await tester.pumpAndSettle();
    final restingTop = tester.getRect(find.byType(AcademyModalScaffold)).top;
    search.text = 'Запрос';
    await tester.pumpAndSettle();
    final expandedTop = tester.getRect(find.byType(AcademyModalScaffold)).top;
    expect(expandedTop, lessThan(restingTop));
    FocusManager.instance.primaryFocus?.unfocus();
    await tester.pumpAndSettle();
    expect(
      tester.getRect(find.byType(AcademyModalScaffold)).top,
      closeTo(expandedTop, 1),
    );
    search.clear();
    await tester.pumpAndSettle();
    expect(
      tester.getRect(find.byType(AcademyModalScaffold)).top,
      closeTo(restingTop, 1),
    );
  });

  testWidgets('an open modal follows theme and accent changes', (tester) async {
    final appearance = AcademyAppearanceController();
    addTearDown(appearance.dispose);
    await appearance.ready;
    final context = await host(tester, appearance: appearance);
    late Brightness modalBrightness;
    late Color modalPrimary;
    showAcademyModal<void>(
      context,
      title: 'Тема',
      builder: (context) {
        final theme = AcademyTheme.of(context);
        modalBrightness = theme.brightness;
        modalPrimary = theme.colorScheme.primary;
        return const SizedBox.expand();
      },
    );
    await tester.pumpAndSettle();
    final previousPrimary = modalPrimary;
    appearance.update(
      const AcademyAppearance(
        mode: AcademyAppearanceMode.dark,
        accent: Color(0xFF326555),
      ),
    );
    await tester.pumpAndSettle();
    expect(modalBrightness, Brightness.dark);
    expect(modalPrimary, isNot(previousPrimary));
  });
}
