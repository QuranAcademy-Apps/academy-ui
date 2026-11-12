import 'package:academy_ui/academy_ui.dart';
import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:flutter_test/flutter_test.dart';

const accents = [
  AcademyTokens.brand,
  Color(0xFF263E59),
  Color(0xFF246A89),
  Color(0xFF326555),
  Color(0xFF74537B),
  Color(0xFF98513D),
  AcademyTokens.action,
  CupertinoColors.white,
  CupertinoColors.black,
];

void main() {
  for (final brightness in Brightness.values) {
    test(
      'field fills stay neutral and accent roles stay readable: $brightness',
      () {
        final baseline = AcademyPalette(brightness, AcademyTokens.brand);
        for (final accent in accents) {
          final p = AcademyPalette(brightness, accent);
          expect(p.accentColor, accent);
          for (final fill in [
            p.textFieldBackground,
            p.textFieldSecondaryBackground,
            p.textFieldDisabledBackground,
          ]) {
            expect(fill.a, 1);
          }
          expect(p.textFieldBackground, baseline.textFieldBackground);
          expect(
            p.textFieldSecondaryBackground,
            baseline.textFieldSecondaryBackground,
          );
          expect(
            p.textFieldDisabledBackground,
            baseline.textFieldDisabledBackground,
          );
          expect(
            AcademyContrast.ratio(p.onAccentFill, p.accentFill),
            greaterThanOrEqualTo(4.5),
          );
          for (final bg in [
            p.textFieldBackground,
            p.textFieldSecondaryBackground,
            p.scaffoldBackground,
          ]) {
            expect(
              AcademyContrast.ratio(p.accentForeground, bg),
              greaterThanOrEqualTo(4.5),
            );
            expect(
              AcademyContrast.ratio(p.textFieldSecondaryForeground, bg),
              greaterThanOrEqualTo(4.5),
            );
          }
          expect(
            AcademyContrast.ratio(
              p.textFieldDisabledForeground,
              p.textFieldDisabledBackground,
            ),
            greaterThanOrEqualTo(4.5),
          );
          expect(
            AcademyContrast.ratio(
              p.textFieldFocusBorder,
              p.textFieldBackground,
            ),
            greaterThanOrEqualTo(3),
          );
          final altered = p.copyWith(
            surface: CupertinoColors.systemPink,
            surfaceContainerHighest: CupertinoColors.systemYellow,
            onSurface: CupertinoColors.systemGreen,
            onSurfaceVariant: CupertinoColors.systemRed,
            primary: CupertinoColors.systemPurple,
            outline: CupertinoColors.transparent,
          );
          expect(altered.textFieldBackground, baseline.textFieldBackground);
          expect(
            altered.textFieldDisabledBorder,
            baseline.textFieldDisabledBorder,
          );
          expect(altered.textFieldForeground, baseline.textFieldForeground);
          expect(
            altered.textFieldSecondaryForeground,
            baseline.textFieldSecondaryForeground,
          );
          expect(altered.accentFill, p.accentFill);
        }
        final gold = AcademyPalette(brightness, AcademyTokens.action);
        expect(gold.accentFill, AcademyTokens.action);
        expect(gold.onAccentFill, CupertinoColors.black);
        if (brightness == Brightness.light) {
          expect(gold.accentForeground, isNot(gold.accentFill));
        }
      },
    );

    testWidgets(
      'fields and actions use explicit component roles: $brightness',
      (tester) async {
        const fill = Color(0xFFDBE6F0),
            secondary = Color(0xFFE6DBF0),
            disabled = Color(0xFFF0E6DB);
        const ink = Color(0xFF102030),
            muted = Color(0xFF304050),
            disabledInk = Color(0xFF504030);
        const border = Color(0xFF506070),
            disabledBorder = Color(0xFF705030),
            focus = Color(0xFF214365);
        const action = Color(0xFFFFCF60),
            onAction = Color(0xFF171717),
            link = Color(0xFF493070),
            error = Color(0xFF702030);
        final colors = AcademyPalette(brightness, AcademyTokens.brand).copyWith(
          surface: CupertinoColors.systemPink,
          textFieldBackground: fill,
          textFieldSecondaryBackground: secondary,
          textFieldDisabledBackground: disabled,
          textFieldForeground: ink,
          textFieldSecondaryForeground: muted,
          textFieldDisabledForeground: disabledInk,
          textFieldBorder: border,
          textFieldDisabledBorder: disabledBorder,
          textFieldFocusBorder: focus,
          textFieldErrorForeground: error,
          accentFill: action,
          onAccentFill: onAction,
          accentForeground: link,
        );
        final search = TextEditingController();
        addTearDown(search.dispose);
        await tester.pumpWidget(
          AcademyApp(
            home: AcademyTheme(
              data: academyTheme(brightness, colors: colors),
              child: Center(
                child: SizedBox(
                  width: 320,
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        const AcademyField(
                          label: 'Name',
                          help: 'Help',
                          error: 'Error',
                        ),
                        const AcademyTextInput(
                          enabled: false,
                          placeholder: 'Disabled',
                        ),
                        AcademySearchBar(controller: search, chrome: false),
                        AcademySelect<String>(
                          label: 'Language',
                          value: 'ru',
                          options: const [
                            AcademySelectOption(value: 'ru', label: 'Russian'),
                          ],
                          searchable: true,
                          presentation: AcademySelectPresentation.popover,
                          onChanged: (_) {},
                        ),
                        const AcademyPickerInput(
                          label: 'Date',
                          value: 'Tomorrow',
                          icon: CupertinoIcons.calendar,
                        ),
                        AcademyButton(label: 'Continue', onPressed: () {}),
                        AcademyTextButton(label: 'Cancel', onPressed: () {}),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();
        var inputs = tester
            .widgetList<CupertinoTextField>(find.byType(CupertinoTextField))
            .toList();
        expect(inputs[0].decoration!.color, fill);
        expect(inputs[0].style!.color, ink);
        expect(inputs[0].placeholderStyle!.color, muted);
        expect((inputs[0].decoration!.border! as Border).top.color, border);
        expect(inputs[0].cursorColor, link);
        expect(inputs[1].decoration!.color, disabled);
        expect(inputs[1].style!.color, disabledInk);
        expect(
          (inputs[1].decoration!.border! as Border).top.color,
          disabledBorder,
        );
        expect(inputs[2].decoration!.color, fill);
        expect(tester.widget<Text>(find.text('Name')).style!.color, muted);
        expect(tester.widget<Text>(find.text('Error')).style!.color, error);
        expect(tester.widget<Text>(find.text('Russian')).style!.color, ink);
        final button = tester.widget<CupertinoButton>(
          find.descendant(
            of: find.byType(AcademyButton),
            matching: find.byType(CupertinoButton),
          ),
        );
        expect(button.color, action);
        expect(
          tester
              .widget<DefaultTextStyle>(
                find
                    .descendant(
                      of: find.byType(AcademyButton),
                      matching: find.byType(DefaultTextStyle),
                    )
                    .last,
              )
              .style
              .color,
          onAction,
        );
        expect(tester.widget<Text>(find.text('Cancel')).style!.color, link);
        await tester.tap(find.byType(CupertinoTextField).first);
        await tester.pumpAndSettle();
        inputs = tester
            .widgetList<CupertinoTextField>(find.byType(CupertinoTextField))
            .toList();
        expect((inputs.first.decoration!.border! as Border).top.color, focus);
        await tester.tap(find.text('Russian'));
        await tester.pumpAndSettle();
        final popupSearch = tester
            .widgetList<CupertinoTextField>(find.byType(CupertinoTextField))
            .last;
        expect(popupSearch.decoration!.color, secondary);
        expect(popupSearch.placeholderStyle!.color, muted);
        expect(tester.takeException(), isNull);
        await tester.pumpWidget(const SizedBox());
      },
    );
  }

  test('new semantic roles survive snapshots and partial editing', () {
    final original = AcademyPalette(Brightness.light, AcademyTokens.action);
    for (final role in AcademyColorRole.values) {
      final snapshot = AcademyColorsData.from(original);
      expect(snapshot.value(role), original.value(role));
      const custom = Color(0xFF123456);
      final edited = snapshot.withValue(role, custom);
      expect(edited.value(role), custom);
      expect(edited.copyWith().value(role), custom);
    }
    final fillOverride = original.copyWith(accentFill: CupertinoColors.black);
    expect(
      AcademyContrast.ratio(fillOverride.onAccentFill, fillOverride.accentFill),
      greaterThanOrEqualTo(4.5),
    );
    expect(fillOverride.accentColor, AcademyTokens.action);
    expect(fillOverride.textFieldBackground, original.textFieldBackground);
  });
}
