import 'package:academy_ui/academy_ui.dart';
import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:flutter_test/flutter_test.dart';

// These are the approved control fills, deliberately independent of the
// palette getters so a change to the general surfaces cannot bless itself.
const _fills = {
  Brightness.light: (Color(0xFFE1E3E7), Color(0xFFFFFFFF)),
  Brightness.dark: (Color(0xFF3A3A3C), Color(0xFF636366)),
};

Iterable<BoxDecoration> _boxes(WidgetTester tester, Finder control) => tester
    .widgetList<DecoratedBox>(
      find.descendant(of: control, matching: find.byType(DecoratedBox)),
    )
    .map((box) => box.decoration)
    .whereType<BoxDecoration>();

double _contrast(Color first, Color second) {
  final a = first.computeLuminance(), b = second.computeLuminance();
  return a > b ? (a + .05) / (b + .05) : (b + .05) / (a + .05);
}

void main() {
  test('compact fills are opaque, neutral and independent of the accent', () {
    for (final brightness in Brightness.values) {
      final (track, selection) = _fills[brightness]!;
      for (final accent in const [
        AcademyTokens.brand,
        Color(0xFF263E59),
        Color(0xFF246A89),
        Color(0xFF326555),
        Color(0xFF74537B),
        Color(0xFF98513D),
        AcademyTokens.action,
      ]) {
        final colors = AcademyPalette(brightness, accent);
        expect(colors.segmentBackground, track);
        expect(colors.segmentSelected, selection);
        expect(colors.segmentBackground.a, 1);
        expect(colors.segmentSelected.a, 1);
        expect(_contrast(track, selection), greaterThan(1.2));
        expect(_contrast(colors.onSurface, track), greaterThanOrEqualTo(4.5));
        expect(
          _contrast(colors.onSurface, selection),
          greaterThanOrEqualTo(4.5),
        );
        expect(
          _contrast(colors.onSurfaceVariant, track),
          // The secondary foreground is used for symbols, not segment labels.
          greaterThanOrEqualTo(3),
        );
      }
    }
  });

  for (final brightness in Brightness.values) {
    testWidgets(
      '$brightness control fills survive live surface, chrome and state changes',
      (tester) async {
        final appearance = AcademyAppearanceController(
          initial: AcademyAppearance(
            mode: brightness == Brightness.light
                ? AcademyAppearanceMode.light
                : AcademyAppearanceMode.dark,
          ),
        );
        await appearance.ready;
        addTearDown(appearance.dispose);
        final revision = ValueNotifier(0);
        addTearDown(revision.dispose);
        const pillKey = ValueKey('pill');
        const compactKey = ValueKey('compact');
        const buttonKey = ValueKey('compact-button');
        await tester.pumpWidget(
          ValueListenableBuilder<int>(
            valueListenable: revision,
            builder: (_, value, _) => AcademyApp(
              appearance: appearance,
              colorsBuilder: (brightness, accent) {
                final palette = AcademyPalette(brightness, accent);
                return value == 0
                    ? palette
                    : palette.copyWith(
                        surface: const Color(0xFFFFE8CC),
                        scaffoldBackground: const Color(0xFF243046),
                        surfaceContainerHighest: const Color(0xFFCCE8FF),
                        chromeSurface: const Color(0xFFE8CCFF),
                      );
              },
              home: CupertinoPageScaffold(
                child: Center(
                  child: SizedBox(
                    width: 320,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        AcademySegmentedControl<int>(
                          key: pillKey,
                          items: const [0, 1, 2],
                          value: value % 3,
                          labelFor: (i) => '$i',
                          onChanged: value.isEven ? (_) {} : null,
                        ),
                        AcademySegmentedControl<int>.compact(
                          key: compactKey,
                          items: const [0, 1, 2],
                          value: value % 3,
                          labelFor: (i) => '$i',
                          onChanged: value.isEven ? (_) {} : null,
                        ),
                        AcademyCompactIconButton(
                          key: buttonKey,
                          onPressed: value.isEven ? () {} : null,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
        final (track, selection) = _fills[brightness]!;
        for (var i = 0; i < AcademyChromeStyle.values.length; i++) {
          revision.value = i;
          appearance.update(
            appearance.value.copyWith(
              chromeStyle: AcademyChromeStyle.values[i],
              accent: i.isEven ? AcademyTokens.brand : AcademyTokens.action,
            ),
          );
          await tester.pumpAndSettle();
          for (final key in [pillKey, compactKey]) {
            final fills = _boxes(
              tester,
              find.byKey(key),
            ).map((box) => box.color).whereType<Color>();
            expect(fills, containsAll([track, selection]));
          }
          final button = tester.widget<Container>(
            find.descendant(
              of: find.byKey(buttonKey),
              matching: find.byType(Container),
            ),
          );
          expect((button.decoration! as BoxDecoration).color, track);
          expect(tester.takeException(), isNull);
        }
      },
    );
  }
}
