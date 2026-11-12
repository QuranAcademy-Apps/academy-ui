import 'package:academy_ui/academy_ui.dart';
import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const customForward = IconData(0xE001, fontFamily: 'ClientIcons');
  const customBack = IconData(0xE002, fontFamily: 'ClientIcons');

  Widget app(AcademyThemeData theme, Widget child) => CupertinoApp(
    home: AcademyTheme(
      data: theme,
      child: Center(child: child),
    ),
  );

  testWidgets('a client glyph replaces a library icon and keeps its font', (
    tester,
  ) async {
    await tester.pumpWidget(
      app(
        academyTheme(
          Brightness.light,
          icons: const AcademyIcons(forward: customForward),
        ),
        AcademyRow(title: 'Строка', onPressed: () {}),
      ),
    );
    expect(find.byIcon(customForward), findsOneWidget);
    final text = tester.widget<RichText>(
      find.descendant(
        of: find.byIcon(customForward),
        matching: find.byType(RichText),
      ),
    );
    expect(text.text.style!.fontFamily, 'ClientIcons');
  });

  testWidgets('client back and forward glyphs mirror in RTL', (tester) async {
    await tester.pumpWidget(
      app(
        academyTheme(
          Brightness.light,
          icons: const AcademyIcons(forward: customForward, back: customBack),
        ),
        const Directionality(
          textDirection: TextDirection.rtl,
          child: AcademySfIcon(customForward, mirrorInRtl: true),
        ),
      ),
    );
    expect(find.byIcon(customBack), findsOneWidget);
  });

  test('default icons stay the SF symbols', () {
    const icons = AcademyIcons();
    expect(icons.forward, AcademySymbols.forward);
    expect(icons.close, AcademySymbols.close);
    expect(icons.copyWith(close: customBack).close, customBack);
    expect(icons.copyWith(close: customBack).forward, AcademySymbols.forward);
  });

  testWidgets('new color roles and radii reach the widgets', (tester) async {
    const scrim = Color(0xFF123456);
    final theme = academyTheme(
      Brightness.light,
      colors: AcademyPalette(
        Brightness.light,
        AcademyTokens.brand,
      ).copyWith(scrim: scrim),
      radii: const AcademyRadii(textBlock: 3),
    );
    await tester.pumpWidget(
      app(
        theme,
        const SizedBox(
          width: 200,
          height: 200,
          child: AcademySearchScrim(active: true, onDismiss: _noop),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(
      find.byWidgetPredicate((w) => w is ColoredBox && w.color == scrim),
      findsOneWidget,
    );
    expect(theme.radii.value(AcademyRadiusRole.textBlock), 3);
    expect(
      theme.colorScheme.withValue(AcademyColorRole.scrim, scrim).scrim,
      scrim,
    );
  });

  testWidgets('a row tile color can be replaced', (tester) async {
    const tile = Color(0xFF0A7A5C);
    late Color resolved;
    await tester.pumpWidget(
      app(
        academyTheme(
          Brightness.light,
          rowIconColors: const {AcademyRowIcons.trip: tile},
        ),
        Builder(
          builder: (context) {
            resolved = AcademyRowIcons.trip.colorOf(context);
            return const SizedBox();
          },
        ),
      ),
    );
    expect(resolved, tile);
  });

  testWidgets('sizes come from the theme, a widget parameter wins', (
    tester,
  ) async {
    await tester.pumpWidget(
      app(
        academyTheme(
          Brightness.light,
          sizes: const AcademySizes(
            buttonHeight: 70,
            rowHeight: 90,
            fieldHeight: 64,
          ),
        ),
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AcademyButton(
              key: const Key('button'),
              label: 'A',
              onPressed: () {},
            ),
            AcademyButton(
              key: const Key('explicit'),
              label: 'B',
              minimumHeight: 60,
              onPressed: () {},
            ),
            const AcademyRow(key: Key('row'), title: 'C'),
            const SizedBox(
              width: 300,
              child: AcademyFloatingInput(key: Key('field'), label: 'D'),
            ),
          ],
        ),
      ),
    );
    await tester.pumpAndSettle();
    double height(String key) => tester.getSize(find.byKey(Key(key))).height;
    expect(height('button'), 70);
    expect(height('explicit'), 60);
    expect(height('row'), greaterThanOrEqualTo(90));
    expect(height('field'), 64);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('a field label font comes from the theme', (tester) async {
    await tester.pumpWidget(
      app(
        academyTheme(
          Brightness.light,
          typography: const AcademyTypographySettings(
            styles: {
              AcademyTextRole.fieldLabel: TextStyle(
                fontFamily: 'ClientFont',
                fontSize: 15,
              ),
            },
          ),
        ),
        SizedBox(
          width: 300,
          child: AcademyPickerInput(
            label: 'Город',
            value: 'Мекка',
            icon: AcademySymbols.location,
            onPressed: () {},
          ),
        ),
      ),
    );
    final style = tester.widget<Text>(find.text('Город')).style!;
    expect(style.fontFamily, 'ClientFont');
    expect(style.fontSize, 15);
    await tester.pumpWidget(const SizedBox());
  });

  test('default derived text roles match their base role', () {
    final text = academyTheme(Brightness.light).textTheme;
    expect(text.fieldLabel, text.bodySmall.copyWith(fontSize: 12, height: 1.2));
    expect(text.fieldMessage, text.bodySmall.copyWith(fontSize: 12));
  });

  test(
    'press scales: 0.97 by default, 0.9 for navigation, both replaceable',
    () {
      const defaults = AcademyInteractionTheme();
      expect(defaults.pressedScale, .97);
      expect(defaults.chromePressedScale, .9);
      final theme = academyTheme(
        Brightness.light,
        interaction: const AcademyInteractionTheme(pressedScale: .95),
      );
      expect(theme.interaction.pressedScale, .95);
    },
  );
}

void _noop() {}
