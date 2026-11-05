import 'package:academy_ui/academy_ui.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Widget app(
    Widget child, {
    AcademyChromeButtonTheme look = const AcademyChromeButtonTheme(),
    TextDirection direction = TextDirection.ltr,
  }) => CupertinoApp(
    localizationsDelegates: const [AcademyLocalizations.delegate],
    home: Directionality(
      textDirection: direction,
      child: AcademyTheme(
        data: academyTheme(Brightness.light, chromeButton: look),
        child: Center(child: child),
      ),
    ),
  );

  testWidgets('the theme sets the symbol', (tester) async {
    await tester.pumpWidget(
      app(
        AcademyChromeButton(
          icon: AcademySymbols.close,
          label: 'Закрыть',
          onPressed: () {},
        ),
        look: const AcademyChromeButtonTheme(
          symbolFrame: 44,
          symbolSize: 16,
          symbolWeight: FontWeight.w700,
        ),
      ),
    );
    final image = tester.widget<AcademySfImage>(find.byType(AcademySfImage));
    expect(image.frameSize, 44);
    expect(image.symbolSize, 16);
    expect(image.weight, FontWeight.w700);
  });

  testWidgets('a disabled symbol takes the theme color', (tester) async {
    const disabled = Color(0xFF123456);
    await tester.pumpWidget(
      app(
        const AcademyChromeButton(icon: AcademySymbols.close, label: 'Закрыть'),
        look: const AcademyChromeButtonTheme(disabledForeground: disabled),
      ),
    );
    expect(
      tester.widget<AcademySfImage>(find.byType(AcademySfImage)).foreground,
      disabled,
    );
  });

  testWidgets('pressing can keep the surface still and long press works', (
    tester,
  ) async {
    var taps = 0, longPresses = 0;
    await tester.pumpWidget(
      app(
        AcademyChromeButton(
          icon: AcademySymbols.close,
          label: 'Закрыть',
          onPressed: () => taps++,
          onLongPress: () => longPresses++,
        ),
        look: const AcademyChromeButtonTheme(pressScalesSymbolOnly: true),
      ),
    );
    final scales = tester.widgetList<PressScale>(find.byType(PressScale));
    expect(scales.where((scale) => scale.enabled), hasLength(1));
    await tester.tap(find.byType(AcademySfImage));
    await tester.pumpAndSettle();
    expect(taps, 1);
    await tester.longPress(find.byType(AcademySfImage));
    await tester.pumpAndSettle();
    expect(longPresses, 1);
  });

  testWidgets('a smaller button rounds to its size', (tester) async {
    await tester.pumpWidget(
      app(
        AcademyChromeButton(
          icon: AcademySymbols.close,
          label: 'Закрыть',
          size: 36,
          onPressed: () {},
        ),
      ),
    );
    expect(tester.widget<AcademyChrome>(find.byType(AcademyChrome)).radius, 18);
    expect(tester.getSize(find.byType(AcademyChrome)), const Size.square(36));
  });

  testWidgets('a group action can draw its own glyph', (tester) async {
    const glyph = Key('glyph');
    await tester.pumpWidget(
      app(
        AcademyChromeGroup(
          actions: [
            AcademyChromeAction(
              null,
              'Закладки',
              () {},
              symbolBuilder: (_, color) => SizedBox.square(
                key: glyph,
                dimension: 20,
                child: ColoredBox(color: color),
              ),
            ),
          ],
        ),
      ),
    );
    expect(find.byKey(glyph), findsOneWidget);
  });

  testWidgets('the back button pops and follows text direction', (
    tester,
  ) async {
    const ltr = IconData(0xF001);
    const rtl = IconData(0xF002);
    const look = AcademyChromeButtonTheme(backIcon: ltr, backIconRtl: rtl);
    IconData? shown() => tester
        .widget<AcademyChromeButton>(find.byType(AcademyChromeButton))
        .icon;

    await tester.pumpWidget(app(const AcademyChromeBackButton(), look: look));
    expect(shown(), ltr);

    await tester.pumpWidget(
      app(
        const AcademyChromeBackButton(),
        look: look,
        direction: TextDirection.rtl,
      ),
    );
    expect(shown(), rtl);
  });

  testWidgets('the title capsule uses the theme styles', (tester) async {
    const title = TextStyle(fontSize: 15);
    const compact = TextStyle(fontSize: 14);
    const subtitle = TextStyle(fontSize: 11);
    const look = AcademyChromeButtonTheme(
      titleStyle: title,
      compactTitleStyle: compact,
      subtitleStyle: subtitle,
    );
    await tester.pumpWidget(
      app(const AcademyChromeTitleCapsule(title: 'Заголовок'), look: look),
    );
    expect(tester.widget<Text>(find.text('Заголовок')).style, title);

    await tester.pumpWidget(
      app(
        const AcademyChromeTitleCapsule(
          title: 'Заголовок',
          subtitle: 'Подпись',
        ),
        look: look,
      ),
    );
    expect(tester.widget<Text>(find.text('Заголовок')).style, compact);
    expect(tester.widget<Text>(find.text('Подпись')).style, subtitle);
    expect(tester.getSize(find.byType(AcademyChromeTitleCapsule)).height, 44);
  });
}
