import 'package:academy_ui/academy_ui.dart';
import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:flutter/rendering.dart' show SemanticsAction;
import 'package:flutter_test/flutter_test.dart';

// Button contract added with Yalla's buttons: a call-to-action colour of its
// own, neutral and plain styles, explicit fills and a primary label role.

const _yellow = Color(0xFFFFDD2D);
const _ink = Color(0xFF0B131D);

AcademyThemeData _theme({Map<AcademyTextRole, TextStyle> styles = const {}}) =>
    academyTheme(
      Brightness.light,
      colors: AcademyPalette(
        Brightness.light,
        AcademyTokens.brand,
      ).copyWith(actionFill: _yellow, onActionFill: _ink),
      typography: AcademyTypographySettings(styles: styles),
    );

Widget _host(Widget child, {AcademyThemeData? theme}) => CupertinoApp(
  home: AcademyTheme(
    data: theme ?? _theme(),
    child: Center(child: SizedBox(width: 300, child: child)),
  ),
);

CupertinoButton _native(WidgetTester tester) =>
    tester.widget<CupertinoButton>(find.byType(CupertinoButton));

BoxDecoration _frame(WidgetTester tester) =>
    tester
            .widget<DecoratedBox>(
              find
                  .ancestor(
                    of: find.byType(CupertinoButton),
                    matching: find.byType(DecoratedBox),
                  )
                  .first,
            )
            .decoration
        as BoxDecoration;

void main() {
  test('action fill follows the accent until a client sets it', () {
    final palette = AcademyPalette(Brightness.light, AcademyTokens.brand);
    expect(palette.actionFill, palette.accentFill);
    final data = AcademyColorsData.from(palette);
    expect(data.actionFill, data.accentFill);
    final recoloured = data.copyWith(accentFill: const Color(0xFF00A86B));
    expect(recoloured.actionFill, const Color(0xFF00A86B));
    final companion = data.copyWith(actionFill: _yellow);
    expect(companion.accentFill, data.accentFill);
    expect(
      companion.copyWith(accentFill: const Color(0xFF00A86B)).actionFill,
      _yellow,
    );
    expect(companion.value(AcademyColorRole.actionFill), _yellow);
  });

  testWidgets('primary uses the action fill; selection keeps the accent', (
    tester,
  ) async {
    await tester.pumpWidget(
      _host(
        Column(
          children: [
            AcademyButton(label: 'Купить', onPressed: () {}),
            AcademySwitch(value: true, onChanged: (_) {}),
          ],
        ),
      ),
    );
    expect(_native(tester).color, _yellow);
    expect(
      tester.widget<Text>(find.text('Купить')).style?.color ??
          DefaultTextStyle.of(tester.element(find.text('Купить'))).style.color,
      _ink,
    );
    final palette = _theme().colorScheme;
    expect(
      tester
          .widget<CupertinoSwitch>(find.byType(CupertinoSwitch))
          .activeTrackColor,
      palette.accentFill,
    );
  });

  for (final (style, fill) in [
    (
      AcademyButtonStyle.neutral,
      (AcademyColors p) => p.surfaceContainerHighest,
    ),
    (AcademyButtonStyle.plain, (AcademyColors p) => p.surface),
  ]) {
    testWidgets('$style button uses ordinary text on its own fill', (
      tester,
    ) async {
      await tester.pumpWidget(
        _host(AcademyButton(label: 'Позже', style: style, onPressed: () {})),
      );
      final p = _theme().colorScheme;
      expect(_native(tester).color, fill(p));
      expect(
        DefaultTextStyle.of(tester.element(find.text('Позже'))).style.color,
        p.onSurface,
      );
      expect(
        _frame(tester).border!.top.color,
        style == AcademyButtonStyle.neutral
            ? p.chromeBorder
            : const Color(0x00000000),
      );
    });
  }

  testWidgets('explicit fill, size, radius and composition', (tester) async {
    const red = Color(0xFFE5261F);
    await tester.pumpWidget(
      _host(
        AcademyButton(
          label: 'Удалить',
          backgroundColor: red,
          foregroundColor: CupertinoColors.white,
          minimumHeight: 60,
          radius: 20,
          content: const Text('Удалить навсегда'),
          onPressed: () {},
        ),
      ),
    );
    final native = _native(tester);
    expect(native.color, red);
    expect(native.minimumSize!.height, 60);
    expect(native.borderRadius, BorderRadius.circular(20));
    expect(find.text('Удалить навсегда'), findsOneWidget);
    expect(
      tester.getSemantics(find.bySemanticsLabel('Удалить')),
      isSemantics(isButton: true, hasTapAction: true),
    );
    expect(
      tester.getSize(find.byType(CupertinoButton)).height,
      greaterThanOrEqualTo(60),
    );
  });

  testWidgets('primary label role styles only the call to action', (
    tester,
  ) async {
    await tester.pumpWidget(
      _host(
        Column(
          children: [
            AcademyButton(label: 'Далее', onPressed: () {}),
            AcademyButton(
              label: 'Назад',
              style: AcademyButtonStyle.neutral,
              onPressed: () {},
            ),
          ],
        ),
        theme: _theme(
          styles: const {
            AcademyTextRole.buttonLabel: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          },
        ),
      ),
    );
    TextStyle style(String label) =>
        DefaultTextStyle.of(tester.element(find.text(label))).style;
    expect(style('Далее').fontSize, 20);
    expect(style('Далее').fontWeight, FontWeight.w700);
    expect(style('Назад').fontSize, 17);
  });

  testWidgets('a button is its own accessibility element', (tester) async {
    final handle = tester.ensureSemantics();
    await tester.pumpWidget(
      _host(
        Column(
          children: [
            const Text('Отель'),
            AcademyButton(label: 'Открыть в Картах', onPressed: () {}),
          ],
        ),
      ),
    );
    final node = tester.getSemantics(find.bySemanticsLabel('Открыть в Картах'));
    expect(node.label, 'Открыть в Картах');
    expect(node.getSemanticsData().hasAction(SemanticsAction.tap), isTrue);
    handle.dispose();
  });

  testWidgets('text button measures with its custom label style', (
    tester,
  ) async {
    late Size plain, custom;
    await tester.pumpWidget(
      _host(
        Builder(
          builder: (context) {
            plain = AcademyTextButton(
              label: 'Сбросить',
              onPressed: () {},
            ).measure(context);
            custom = AcademyTextButton(
              label: 'Сбросить',
              onPressed: () {},
              textStyle: const TextStyle(fontSize: 30),
            ).measure(context);
            return const SizedBox();
          },
        ),
      ),
    );
    expect(custom.width, greaterThan(plain.width));
  });
}
