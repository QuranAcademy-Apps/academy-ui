import 'package:academy_ui/academy_ui.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';

Widget host(Widget child, {Locale locale = const Locale('en')}) => AcademyApp(
  locale: locale,
  home: CupertinoPageScaffold(
    child: Center(child: SizedBox(width: 320, child: child)),
  ),
);

void main() {
  testWidgets('Form.onChanged saves the accepted controlled value', (
    tester,
  ) async {
    final form = GlobalKey<FormState>();
    var value = 'old';
    String? saved;
    var notifications = 0;
    await tester.pumpWidget(
      host(
        StatefulBuilder(
          builder: (_, update) => Form(
            key: form,
            onChanged: () {
              notifications++;
              form.currentState!.save();
              expect(form.currentState!.validate(), isTrue);
            },
            child: AcademyFormField<String>(
              value: value,
              onChanged: (next) => update(() => value = next),
              onSaved: (next) => saved = next,
              validator: (next) => next == 'new' ? null : 'Stale value',
              builder: (_, change) => CupertinoButton(
                onPressed: () => change('new'),
                child: const Text('Change'),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Change'));
    await tester.pumpAndSettle();
    expect(value, 'new');
    expect(saved, 'new');
    expect(notifications, 1);
  });

  testWidgets('controlled requests coalesce and reset cancels pending edits', (
    tester,
  ) async {
    final form = GlobalKey<FormState>();
    var value = 'initial';
    final observed = <String?>[];
    late ValueChanged<String> change;
    await tester.pumpWidget(
      host(
        StatefulBuilder(
          builder: (_, update) => Form(
            key: form,
            onChanged: () => form.currentState!.save(),
            child: AcademyFormField<String>(
              value: value,
              onChanged: (next) => update(() => value = next),
              onSaved: observed.add,
              builder: (_, request) {
                change = request;
                return Text(value);
              },
            ),
          ),
        ),
      ),
    );
    change('first');
    change('last');
    await tester.pumpAndSettle();
    expect(observed, ['last']);
    change('cancelled');
    form.currentState!.reset();
    final resetNotifications = observed.length;
    await tester.pumpAndSettle();
    expect(value, 'initial');
    expect(observed.length, resetNotifications);
    change('removed');
    await tester.pumpWidget(const SizedBox());
    expect(tester.takeException(), isNull);
    expect(observed.length, resetNotifications);
  });

  for (final autocomplete in [false, true]) {
    testWidgets('controller transitions retain editing value: $autocomplete', (
      tester,
    ) async {
      final first = TextEditingController.fromValue(
        const TextEditingValue(
          text: 'First draft',
          selection: TextSelection(baseOffset: 1, extentOffset: 4),
          composing: TextRange(start: 1, end: 4),
        ),
      );
      final second = TextEditingController(text: 'Second draft');
      addTearDown(first.dispose);
      addTearDown(second.dispose);
      Widget field(TextEditingController? controller) => autocomplete
          ? AcademyAutocomplete<String>(label: 'Name', controller: controller)
          : AcademyTextInput(controller: controller);
      TextEditingController editor() => tester
          .widget<CupertinoTextField>(find.byType(CupertinoTextField))
          .controller!;

      await tester.pumpWidget(host(field(first)));
      await tester.pumpWidget(host(field(null)));
      expect(editor().value, first.value);
      final owned = editor();
      await tester.pumpWidget(host(field(second)));
      expect(editor(), same(second));
      expect(() => owned.addListener(() {}), throwsFlutterError);
      await tester.pumpWidget(host(field(null)));
      expect(editor().text, 'Second draft');
      first.text = 'Detached first';
      second.text = 'Detached second';
      await tester.pump();
      expect(editor().text, 'Second draft');
      await tester.pumpWidget(const SizedBox());
      first.text = 'Still alive';
      second.text = 'Still alive';
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('autocomplete clear and outside action work on the first tap', (
    tester,
  ) async {
    final controller = TextEditingController();
    addTearDown(controller.dispose);
    var outsidePresses = 0;
    await tester.pumpWidget(
      host(
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AcademyAutocomplete<String>(
              controller: controller,
              label: 'Search',
              options: const [AcademySelectOption(value: 'a', label: 'Alpha')],
            ),
            const SizedBox(height: 420),
            CupertinoButton(
              onPressed: () => outsidePresses++,
              child: const Text('Outside action'),
            ),
          ],
        ),
      ),
    );
    await tester.enterText(find.byType(CupertinoTextField), 'Al');
    await tester.pumpAndSettle();
    expect(find.text('Alpha'), findsOneWidget);
    final clear = find.descendant(
      of: find.byType(CupertinoTextField),
      matching: find.byType(CupertinoButton),
    );
    await tester.tap(clear);
    await tester.pumpAndSettle();
    expect(controller.text, isEmpty);
    await tester.tap(find.text('Outside action'));
    await tester.pumpAndSettle();
    expect(outsidePresses, 1);
    expect(find.text('Alpha'), findsNothing);
  });

  testWidgets('removing the selected tab falls back to an available page', (
    tester,
  ) async {
    final tabs = [
      AcademyTab(
        label: 'First',
        icon: AcademySymbols.book,
        builder: (_) => const Text('First page'),
      ),
      AcademyTab(
        label: 'Second',
        icon: AcademySymbols.gear,
        builder: (_) => const Text('Second page'),
      ),
    ];
    await tester.pumpWidget(host(AcademyTabScaffold(tabs: tabs)));
    await tester.tap(find.text('Second'));
    await tester.pumpAndSettle();
    await tester.pumpWidget(host(AcademyTabScaffold(tabs: [tabs.first])));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(find.text('First page'), findsOneWidget);
    expect(find.text('Second page'), findsNothing);
    await tester.pumpWidget(host(AcademyTabScaffold(tabs: tabs)));
    await tester.tap(find.text('Second'));
    await tester.pumpAndSettle();
    expect(find.text('Second page'), findsOneWidget);
  });

  testWidgets('custom line heights fit chrome and segments in both themes', (
    tester,
  ) async {
    final appearance = AcademyAppearanceController();
    await appearance.ready;
    addTearDown(appearance.dispose);
    for (final mode in [
      AcademyAppearanceMode.light,
      AcademyAppearanceMode.dark,
    ]) {
      appearance.update(AcademyAppearance(mode: mode));
      for (final direction in TextDirection.values) {
        for (final scale in [1.0, 2.0]) {
          await tester.pumpWidget(
            AcademyApp(
              appearance: appearance,
              typography: const AcademyTypographySettings(
                styles: {
                  AcademyTextRole.titleMedium: TextStyle(
                    fontSize: 24,
                    height: 2,
                  ),
                  AcademyTextRole.bodySmall: TextStyle(fontSize: 18, height: 2),
                  AcademyTextRole.segmentLabel: TextStyle(
                    fontSize: 30,
                    height: 1.5,
                  ),
                },
              ),
              home: Builder(
                builder: (context) => MediaQuery(
                  data: MediaQuery.of(context)
                      .copyWith(textScaler: TextScaler.linear(scale)),
                  child: Directionality(
                    textDirection: direction,
                    child: Center(
                      child: SizedBox(
                        width: 320,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const AcademyChromeBar(
                              title: 'Title',
                              subtitle: 'Subtitle',
                            ),
                            AcademySegmentedControl<String>(
                              items: const ['A', 'B'],
                              value: 'A',
                              labelFor: (value) => value,
                              onChanged: (_) {},
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
          await tester.pumpAndSettle();
          expect(tester.takeException(), isNull);
          for (final text in ['Title', 'Subtitle', 'A']) {
            final richText = find.descendant(
              of: find.text(text),
              matching: find.byType(RichText),
            );
            final paragraph = tester.renderObject<RenderParagraph>(richText);
            final painter = TextPainter(
              text: paragraph.text,
              textDirection: direction,
              textScaler: TextScaler.linear(scale),
              maxLines: 1,
            )..layout();
            expect(paragraph.size.height, greaterThanOrEqualTo(painter.height));
            painter.dispose();
          }
        }
      }
    }
  });

  for (final locale in AcademyLocalizations.supportedLocales) {
    testWidgets(
      'modal keeps local RTL/scaling and localized barrier: $locale',
      (tester) async {
        TextDirection? direction;
        double? scale;
        String? barrier;
        final navigator = GlobalKey<NavigatorState>();
        await tester.pumpWidget(
          AcademyApp(
            locale: locale,
            navigatorKey: navigator,
            home: Builder(
              builder: (context) => Directionality(
                textDirection: TextDirection.rtl,
                child: MediaQuery(
                  data: MediaQuery.of(context)
                      .copyWith(textScaler: const TextScaler.linear(2)),
                  child: Builder(
                    builder: (context) => CupertinoButton(
                      onPressed: () => showAcademyModal<void>(
                        context,
                        builder: (context) {
                          direction = Directionality.of(context);
                          scale = MediaQuery.textScalerOf(context).scale(1);
                          barrier = ModalRoute.of(context)!.barrierLabel;
                          return const Text('Modal content');
                        },
                      ),
                      child: const Text('Open'),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
        await tester.tap(find.text('Open'));
        await tester.pumpAndSettle();
        expect(direction, TextDirection.rtl);
        expect(scale, 2);
        expect(barrier, AcademyLocalizations(locale).close);
        navigator.currentState!.pop();
        await tester.pumpAndSettle();
      },
    );
  }

  testWidgets(
    'modal follows system scaling and locale without local overrides',
    (tester) async {
      final locale = ValueNotifier(const Locale('en'));
      addTearDown(locale.dispose);
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
      TextDirection? direction;
      double? scale;
      await tester.pumpWidget(
        ValueListenableBuilder<Locale>(
          valueListenable: locale,
          builder: (_, value, _) => host(
            Builder(
              builder: (context) => CupertinoButton(
                onPressed: () => showAcademyModal<void>(
                  context,
                  builder: (context) {
                    direction = Directionality.of(context);
                    scale = MediaQuery.textScalerOf(context).scale(1);
                    return const Text('Live modal');
                  },
                ),
                child: const Text('Open'),
              ),
            ),
            locale: value,
          ),
        ),
      );
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();
      expect(direction, TextDirection.ltr);
      expect(scale, 1);
      locale.value = const Locale('ar');
      tester.platformDispatcher.textScaleFactorTestValue = 2;
      await tester.pumpAndSettle();
      expect(direction, TextDirection.rtl);
      expect(scale, 2);
      expect(tester.takeException(), isNull);
    },
  );
}
