import 'package:academy_ui/academy_ui.dart';
import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:flutter/rendering.dart' show RenderParagraph;
import 'package:flutter_test/flutter_test.dart';

// Navigation design ported from Yalla: tinted glass chrome, neutral tab
// highlight with a saturated symbol, text-only tabs and the modal header with
// close on the leading side.

const _yallaChrome = AcademyChromeColors(
  buttonForeground: Color(0xFF0B131D),
  selection: Color(0xFFE6E7E8),
  selectedIcon: Color(0xFF0B73FE),
  selectedLabel: Color(0xFF0A5FD1),
  unselectedForeground: Color(0xFF0B131D),
  border: Color(0x1F000000),
  shadow: Color(0x12000000),
);

Widget _app(
  Widget child, {
  AcademyChromeStyle style = AcademyChromeStyle.glass,
  AcademyChromeColors colors = _yallaChrome,
  double textScale = 1,
  double width = 390,
}) => AcademyApp(
  home: Builder(
    builder: (context) => MediaQuery(
      data: MediaQuery.of(context)
          .copyWith(textScaler: TextScaler.linear(textScale)),
      child: AcademyChromeTheme(
        style: style,
        colors: colors,
        child: Center(
          child: SizedBox(width: width, child: child),
        ),
      ),
    ),
  ),
);

List<AcademyTab> _tabs([List<String>? labels]) => [
  for (final label in labels ?? ['Туры', 'Умра', 'Профиль'])
    AcademyTab(
      key: ValueKey('tab-$label'),
      label: label,
      icon: AcademySymbols.book,
      builder: (_) => const SizedBox(),
    ),
];

void main() {
  for (final brightness in Brightness.values) {
    testWidgets('glass chrome paints the tinted material in $brightness', (
      tester,
    ) async {
      await tester.pumpWidget(
        AcademyApp(
          appearance: AcademyAppearanceController(
            initial: AcademyAppearance(
              mode: brightness == Brightness.dark
                  ? AcademyAppearanceMode.dark
                  : AcademyAppearanceMode.light,
              chromeStyle: AcademyChromeStyle.glass,
            ),
          ),
          home: const Center(
            child: AcademyChromeButton(
              icon: AcademySymbols.back,
              label: 'Назад',
              onPressed: _noop,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byType(AcademyGlassMaterial), findsOneWidget);
      final filter = tester.widget<BackdropFilter>(find.byType(BackdropFilter));
      expect(filter.enabled, isTrue);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('high contrast replaces glass with the opaque surface', (
    tester,
  ) async {
    await tester.pumpWidget(
      MediaQuery(
        data: const MediaQueryData(highContrast: true),
        child: _app(
          const AcademyChromeButton(
            icon: AcademySymbols.back,
            label: 'Назад',
            onPressed: _noop,
          ),
        ),
      ),
    );
    expect(find.byType(AcademyGlassMaterial), findsNothing);
    expect(find.byType(BackdropFilter), findsNothing);
  });

  testWidgets('chrome colors drive buttons and the selected disc', (
    tester,
  ) async {
    await tester.pumpWidget(
      _app(
        const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            AcademyChromeButton(
              key: ValueKey('plain'),
              icon: AcademySymbols.back,
              label: 'Назад',
              onPressed: _noop,
            ),
            AcademyChromeButton(
              key: ValueKey('selected'),
              icon: AcademySymbols.close,
              label: 'Карта',
              selected: true,
              onPressed: _noop,
            ),
          ],
        ),
      ),
    );
    AcademySfImage image(String key) => tester.widget<AcademySfImage>(
      find.descendant(
        of: find.byKey(ValueKey(key)),
        matching: find.byType(AcademySfImage),
      ),
    );
    expect(image('plain').foreground, _yallaChrome.buttonForeground);
    expect(image('selected').foreground, _yallaChrome.selectedIcon);
    final disc = tester
        .widgetList<DecoratedBox>(
          find.descendant(
            of: find.byKey(const ValueKey('selected')),
            matching: find.byType(DecoratedBox),
          ),
        )
        .map((box) => box.decoration)
        .whereType<BoxDecoration>()
        .firstWhere((box) => box.shape == BoxShape.circle);
    expect(disc.color, _yallaChrome.selection);
    expect(
      tester.getSemantics(find.byKey(const ValueKey('selected'))),
      isSemantics(isSelected: true),
    );
  });

  testWidgets('theme chrome colors apply without a chrome theme override', (
    tester,
  ) async {
    await tester.pumpWidget(
      AcademyTheme(
        data: academyTheme(Brightness.light, chromeColors: _yallaChrome),
        child: const Directionality(
          textDirection: TextDirection.ltr,
          child: Center(
            child: AcademyChromeButton(
              icon: AcademySymbols.back,
              label: 'Назад',
              onPressed: _noop,
            ),
          ),
        ),
      ),
    );
    expect(
      tester.widget<AcademySfImage>(find.byType(AcademySfImage)).foreground,
      _yallaChrome.buttonForeground,
    );
  });

  testWidgets('tab bar uses the neutral highlight and keyed buttons', (
    tester,
  ) async {
    var selected = 0;
    await tester.pumpWidget(
      _app(
        AcademyFloatingTabBar(
          tabs: _tabs(),
          index: 1,
          onChanged: (index) => selected = index,
        ),
      ),
    );
    final highlight = tester
        .widgetList<DecoratedBox>(find.byType(DecoratedBox))
        .map((box) => box.decoration)
        .whereType<BoxDecoration>()
        .where((box) => box.color == _yallaChrome.selection);
    expect(highlight, hasLength(1));
    final labels = {
      for (final label in ['Туры', 'Умра', 'Профиль'])
        label: tester.widget<Text>(find.text(label)).style!.color,
    };
    expect(labels['Умра'], _yallaChrome.selectedLabel);
    expect(labels['Туры'], _yallaChrome.unselectedForeground);
    await tester.tap(find.byKey(const ValueKey('tab-Профиль')));
    expect(selected, 2);
  });

  testWidgets('text-only tabs are a 44pt control with bold labels', (
    tester,
  ) async {
    await tester.pumpWidget(
      _app(
        AcademyFloatingTabBar(
          tabs: _tabs(['Мекка', 'Медина']),
          index: 0,
          showIcons: false,
          onChanged: (_) {},
        ),
      ),
    );
    expect(tester.getSize(find.byType(AcademyChrome)).height, 44);
    expect(find.byType(AcademySfIcon), findsNothing);
    final label = tester.widget<Text>(find.text('Мекка')).style!;
    expect(label.fontSize, 14);
    expect(label.fontWeight, FontWeight.w600);
  });

  testWidgets('scrollable text tabs keep the panel bounded', (tester) async {
    final controller = ScrollController();
    addTearDown(controller.dispose);
    await tester.pumpWidget(
      _app(
        AcademyFloatingTabBar(
          tabs: _tabs(['Один', 'Два', 'Три', 'Четыре', 'Пять', 'Шесть']),
          index: 0,
          showIcons: false,
          contentWidth: 640,
          scrollController: controller,
          onChanged: (_) {},
        ),
        width: 320,
      ),
    );
    expect(tester.getSize(find.byType(AcademyChrome)).width, 320);
    expect(controller.position.maxScrollExtent, greaterThan(0));
    expect(tester.takeException(), isNull);
  });

  testWidgets('large text tab labels shrink to fit instead of truncating', (
    tester,
  ) async {
    await tester.pumpWidget(
      _app(
        AcademyFloatingTabBar(
          tabs: _tabs(['Туры', 'Умра', 'Чат', 'Профиль']),
          index: 0,
          onChanged: (_) {},
        ),
        textScale: 2,
      ),
    );
    // The test font draws every glyph one em wide: «Профиль» fits at 1×
    // in a quarter of the 390pt bar, but not at 2×.
    final label = tester.widget<Text>(find.text('Профиль'));
    final scale = label.textScaler!.scale(11) / 11;
    expect(scale, greaterThanOrEqualTo(1));
    expect(scale, lessThan(2));
    final rendered = tester.renderObject<RenderParagraph>(find.text('Профиль'));
    expect(rendered.didExceedMaxLines, isFalse);
    expect(tester.takeException(), isNull);
  });

  testWidgets('modal header puts close leading and keeps a trailing action', (
    tester,
  ) async {
    var closed = 0, reset = 0;
    await tester.pumpWidget(
      _app(
        AcademyChromeModalHeader(
          title: 'Фильтры',
          closeOnLeading: true,
          onClose: () => closed++,
          trailing: AcademyTextButton(
            label: 'Сбросить',
            onPressed: () => reset++,
          ),
        ),
        width: 600,
      ),
    );
    final close = find.bySemanticsLabel('Закрыть');
    expect(close, findsOneWidget);
    expect(
      tester.getCenter(close).dx,
      lessThan(tester.getCenter(find.text('Фильтры')).dx),
    );
    expect(
      tester.getCenter(find.text('Фильтры')).dy,
      tester.getCenter(find.text('Сбросить')).dy,
    );
    await tester.tap(close);
    await tester.tap(find.text('Сбросить'));
    expect((closed, reset), (1, 1));
  });

  testWidgets('a wide trailing action moves to its own row at large text', (
    tester,
  ) async {
    await tester.pumpWidget(
      _app(
        AcademyChromeModalHeader(
          title: 'Фильтры',
          closeOnLeading: true,
          trailing: AcademyTextButton(label: 'Сбросить', onPressed: () {}),
        ),
        textScale: 2,
        width: 320,
      ),
    );
    expect(
      tester.getTopLeft(find.text('Сбросить')).dy,
      greaterThan(tester.getBottomLeft(find.text('Фильтры')).dy),
    );
    expect(tester.takeException(), isNull);
  });
}

void _noop() {}
