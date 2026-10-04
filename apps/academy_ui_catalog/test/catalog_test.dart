import 'package:academy_ui/academy_ui.dart';
import 'package:academy_ui_catalog/main.dart';
import 'package:academy_ui_catalog/catalog_pages.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('all component sections open in the standalone catalogue', (
    tester,
  ) async {
    final appearance = AcademyAppearanceController();
    addTearDown(appearance.dispose);
    await appearance.ready;
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(390, 844);
    addTearDown(tester.view.reset);
    await tester.pumpWidget(CatalogApp(appearance: appearance));
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.text('Academy UI'), findsOneWidget);
    for (final section in CatalogSection.values) {
      final row = find.widgetWithText(AcademyRow, section.title);
      await Scrollable.ensureVisible(tester.element(row), alignment: .5);
      await tester.tap(row);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 600));
      expect(find.byType(ComponentExamples), findsOneWidget);
      if (section == CatalogSection.input) {
        final theme = AcademyTheme.of(
          tester.element(find.byType(ComponentExamples)),
        );
        for (final role in AcademyRadiusRole.values) {
          expect(theme.radii.value(role), const AcademyRadii().value(role));
        }
        for (final role in AcademyPaddingRole.values) {
          expect(
            theme.paddings.value(role),
            const AcademyPaddings().value(role),
          );
        }
        expect(find.byType(AcademyTextField), findsNWidgets(5));
        expect(find.widgetWithText(AcademyField, 'Почта'), findsOneWidget);
        expect(find.byType(AcademyFloatingTextField), findsNWidgets(6));
      }
      expect(tester.takeException(), isNull);
      await tester.tap(
        find.byWidgetPredicate(
          (w) => w is AcademyChromeButton && w.label == 'Назад',
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));
    }
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('Quran, modals and appearance have working independent tabs', (
    tester,
  ) async {
    final appearance = AcademyAppearanceController();
    addTearDown(appearance.dispose);
    await appearance.ready;
    await tester.pumpWidget(CatalogApp(appearance: appearance));
    await tester.pump(const Duration(milliseconds: 100));
    await tester.tap(find.text('Quran'));
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.text('Элементы Quran'), findsOneWidget);
    await tester.tap(find.text('Модалки').last);
    await tester.pump(const Duration(milliseconds: 400));
    await tester.tap(find.text('Подтверждение'));
    await tester.pumpAndSettle();
    expect(find.text('Продолжить?'), findsOneWidget);
    await tester.tap(find.text('Продолжить'));
    await tester.pumpAndSettle();
    expect(find.byType(AcademyModalScaffold), findsNothing);
    await tester.tap(find.text('Оформление'));
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.text('Blur 20'), findsOneWidget);
    for (final removed in ['Скругления', 'Отступы', 'Цвета', 'Шрифты']) {
      expect(find.widgetWithText(AcademyRow, removed), findsNothing);
    }
    expect(find.widgetWithText(AcademyRow, 'Тема'), findsOneWidget);
    expect(find.widgetWithText(AcademyRow, 'Навигация'), findsOneWidget);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox());
  });
}
