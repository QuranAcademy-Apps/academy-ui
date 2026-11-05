import 'package:academy_ui/academy_ui.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';

// Contracts of components ported from Yalla (2026-11-02). Their pixels are
// checked against Yalla's originals in yalla-app/test/parity.

Widget _host(Widget child, {AcademyThemeData? theme}) => AcademyApp(
  home: AcademyTheme(
    data: theme ?? academyTheme(Brightness.light),
    child: Align(
      alignment: Alignment.topLeft,
      child: SizedBox(width: 390, child: child),
    ),
  ),
);

void _noop() {}

void main() {
  test('tertiary label follows the secondary text until set', () {
    final data = AcademyColorsData.from(
      AcademyPalette(Brightness.light, AcademyTokens.brand),
    );
    expect(data.labelTertiary, data.onSurfaceVariant);
    final own = data.copyWith(labelTertiary: const Color(0xFFAEB4BD));
    expect(own.value(AcademyColorRole.labelTertiary), const Color(0xFFAEB4BD));
    expect(
      own.copyWith(onSurfaceVariant: const Color(0xFF111111)).labelTertiary,
      const Color(0xFFAEB4BD),
    );
  });

  testWidgets('wide stepper keeps the 112 x 44 accessory and its limits', (
    tester,
  ) async {
    var value = 1;
    await tester.pumpWidget(
      _host(
        StatefulBuilder(
          builder: (context, setState) => Align(
            alignment: Alignment.topLeft,
            child: AcademyStepper(
              wide: true,
              value: value,
              max: 2,
              onChanged: (next) => setState(() => value = next),
            ),
          ),
        ),
      ),
    );
    expect(tester.getSize(find.byType(AcademyStepper)), const Size(112, 44));
    await tester.tap(find.bySemanticsLabel('Увеличить'));
    await tester.pump();
    expect(value, 2);
    await tester.tap(find.bySemanticsLabel('Увеличить'));
    await tester.pump();
    expect(value, 2);
  });

  testWidgets('checkmark, status, surface and pill options', (tester) async {
    const accent = Color(0xFF0B73FE);
    await tester.pumpWidget(
      _host(
        const Column(
          children: [
            AcademyCheckmark(color: accent),
            AcademyStatus(
              label: 'Подтверждено',
              tone: AcademyTone.success,
              icon: AcademySymbols.checkmark,
            ),
            SizedBox(
              width: 60,
              child: AcademyStatus(label: 'Очень длинный', compact: true),
            ),
            AcademySurface(
              radius: 14,
              continuousCorners: false,
              padding: EdgeInsets.all(4),
              child: Text('Карточка'),
            ),
            AcademyPillButton(
              accent: true,
              label: 'На карте',
              icon: AcademySymbols.location,
              onPressed: _noop,
            ),
          ],
        ),
      ),
    );
    expect(
      tester.widget<AcademySfIcon>(find.byType(AcademySfIcon).first).color,
      accent,
    );
    expect(find.byType(AcademySfIcon), findsNWidgets(3));
    final compact = tester.widget<Text>(find.text('Очень длинный'));
    expect(compact.maxLines, 1);
    final surface = tester
        .widgetList<DecoratedBox>(
          find.ancestor(
            of: find.text('Карточка'),
            matching: find.byType(DecoratedBox),
          ),
        )
        .first
        .decoration;
    expect(surface, isA<BoxDecoration>());
    final colors = academyTheme(Brightness.light).colorScheme;
    final pill = tester
        .widgetList<DecoratedBox>(
          find.ancestor(
            of: find.text('На карте'),
            matching: find.byType(DecoratedBox),
          ),
        )
        .map((box) => box.decoration)
        .whereType<BoxDecoration>()
        .first;
    expect(pill.color, colors.primaryContainer);
  });

  testWidgets('feedback takes a custom loading indicator', (tester) async {
    await tester.pumpWidget(
      _host(
        const AcademyFeedback(
          kind: AcademyFeedbackKind.loading,
          title: 'Загрузка',
          message: 'Подождите',
          loadingIndicator: AcademyContentSkeleton(rows: 1),
        ),
      ),
    );
    expect(find.byType(AcademyContentSkeleton), findsOneWidget);
    expect(find.byType(CupertinoActivityIndicator), findsNothing);
  });

  testWidgets('journey progress can hide its title and restyle the bar', (
    tester,
  ) async {
    await tester.pumpWidget(
      _host(
        const AcademyJourneyProgress(
          title: 'Подготовка',
          completed: 1,
          total: 4,
          showTitle: false,
          barHeight: 4,
        ),
      ),
    );
    expect(find.text('Подготовка'), findsNothing);
    expect(find.bySemanticsLabel('Подготовка'), findsOneWidget);
  });

  testWidgets('inline option menu: value beside label, current option quiet', (
    tester,
  ) async {
    final picked = <String>[];
    await tester.pumpWidget(
      _host(
        AcademyInlineOptionMenu(
          label: 'Город',
          value: 'Москва',
          options: const ['Москва', 'Казань'],
          onSelected: picked.add,
        ),
      ),
    );
    final label = tester.getRect(find.text('Город'));
    final value = tester.getRect(find.text('Москва'));
    expect(value.left, greaterThan(label.right));
    await tester.tap(find.text('Город'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Москва').last);
    await tester.pumpAndSettle();
    expect(picked, isEmpty);
  });

  testWidgets('inline input fields: floating label, error, read-only lock', (
    tester,
  ) async {
    final controller = TextEditingController(text: 'Иванов');
    addTearDown(controller.dispose);
    await tester.pumpWidget(
      _host(
        Column(
          children: [
            AcademyFloatingInput(
              label: 'Фамилия',
              controller: controller,
              error: 'Проверьте',
            ),
            const AcademyReadOnlyField(
              label: 'Паспорт',
              value: '45 00 123456',
              locked: true,
            ),
            AcademyDateInput(
              label: 'Дата',
              value: DateTime(1990, 5, 7),
              onChanged: (_) {},
            ),
          ],
        ),
      ),
    );
    expect(find.text('Проверьте'), findsOneWidget);
    expect(find.text('07.05.1990'), findsOneWidget);
    expect(
      find.byWidgetPredicate(
        (w) => w is AcademySfIcon && w.icon == AcademySymbols.lockOutline,
      ),
      findsOneWidget,
    );
  });

  testWidgets('large-title page and page options build in a navigator', (
    tester,
  ) async {
    await tester.pumpWidget(
      AcademyApp(
        home: AcademyLargeTitlePage(
          title: 'Профиль',
          eyebrow: 'Аккаунт',
          children: const [Text('Строка')],
        ),
      ),
    );
    expect(find.text('Профиль'), findsWidgets);
    expect(find.text('Аккаунт'), findsOneWidget);
    await tester.pumpWidget(
      const AcademyApp(
        home: AcademyPage(
          title: 'Поездка',
          subtitle: 'Мекка',
          softTopFade: true,
          maxContentWidth: double.infinity,
          child: Text('Содержимое'),
        ),
      ),
    );
    expect(find.text('Мекка'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('linked text and skeleton text render', (tester) async {
    await tester.pumpWidget(
      _host(
        const Column(
          children: [
            AcademyLinkedText(
              text: TextSpan(text: 'условия'),
              style: TextStyle(fontSize: 13),
              linkColor: Color(0xFF0B73FE),
            ),
            AcademySkeletonText(style: TextStyle(fontSize: 17)),
          ],
        ),
      ),
    );
    expect(find.text('условия', findRichText: true), findsOneWidget);
    expect(find.byType(AcademySkeletonBlock), findsWidgets);
  });
}
