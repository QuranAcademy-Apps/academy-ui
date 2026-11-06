// ignore_for_file: deprecated_member_use_from_same_package
import 'dart:ui'
    show SemanticsAction, SemanticsActionEvent, Tristate, CheckedState;

import 'package:academy_ui/academy_ui.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_sficon/flutter_sficon.dart' as sf;

Widget host(Widget child, {Locale locale = const Locale('ru')}) => AcademyApp(
  locale: locale,
  home: Center(child: child),
);

List<SemanticsNode> nodes(WidgetTester tester) {
  final result = <SemanticsNode>[];
  void visit(SemanticsNode node) {
    if (!node.isMergedIntoParent) result.add(node);
    node.visitChildren((child) {
      visit(child);
      return true;
    });
  }

  visit(
    tester.binding.renderViews.single.owner!.semanticsOwner!.rootSemanticsNode!,
  );
  return result;
}

void act(
  WidgetTester tester,
  SemanticsNode node,
  SemanticsAction action, [
  Object? arguments,
]) {
  tester.binding.performSemanticsAction(
    SemanticsActionEvent(
      nodeId: node.id,
      viewId: tester.view.viewId,
      type: action,
      arguments: arguments,
    ),
  );
}

void testSemantics(String name, Future<void> Function(WidgetTester) callback) {
  testWidgets(name, (tester) async {
    final handle = tester.ensureSemantics();
    try {
      await callback(tester);
    } finally {
      handle.dispose();
    }
  });
}

void main() {
  testSemantics(
    'disabled composite row blocks pointer, focus and semantic actions',
    (tester) async {
      var calls = 0;
      await tester.pumpWidget(
        host(
          SizedBox(
            width: 280,
            child: AcademyRow(
              title: 'Disabled',
              enabled: false,
              trailing: CupertinoSwitch(
                value: false,
                onChanged: (_) => calls++,
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.byType(CupertinoSwitch), warnIfMissed: false);
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.sendKeyEvent(LogicalKeyboardKey.space);
      await tester.pump();
      expect(calls, 0);
      final node = nodes(tester)
          .singleWhere((n) => n.getSemanticsData().label == 'Disabled');
      expect(node.getSemanticsData().hasAction(SemanticsAction.tap), false);
      expect(
        node.getSemanticsData().flagsCollection.isEnabled,
        Tristate.isFalse,
      );
      expect(
        node.getSemanticsData().flagsCollection.isChecked,
        CheckedState.isFalse,
      );
    },
  );

  testSemantics(
    'disabled editing section cannot remove or expose an actionable child',
    (tester) async {
      var calls = 0;
      await tester.pumpWidget(
        host(
          SizedBox(
            width: 280,
            child: AcademyDraggableTableSection<String>(
              sectionId: 'a',
              items: const ['one'],
              itemId: (item) => item,
              rowBuilder: (context, item, accessory) =>
                  AcademyRow(title: item, trailing: accessory),
              onMove: (_, _, _) => calls++,
              enabled: false,
              editing: true,
              onRemove: (_) => calls++,
            ),
          ),
        ),
      );
      await tester.tap(find.byType(CupertinoButton), warnIfMissed: false);
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      expect(calls, 0);
      final item = nodes(tester)
          .singleWhere((n) => n.getSemanticsData().label == 'one');
      expect(item.getSemanticsData().hasAction(SemanticsAction.tap), false);
    },
  );

  testWidgets('SF glyph size stays fixed at 1x, 2x and 3x text', (
    tester,
  ) async {
    Size? original;
    for (final scale in [1.0, 2.0, 3.0]) {
      await tester.pumpWidget(
        host(
          MediaQuery(
            data: MediaQueryData(textScaler: TextScaler.linear(scale)),
            child: AcademyCompactIconButton(onPressed: () {}),
          ),
        ),
      );
      final glyph = find.descendant(
        of: find.byType(AcademySfIcon),
        matching: find.byType(RichText),
      );
      final size = tester.getSize(glyph);
      original ??= size;
      expect(size, original);
      expect(tester.takeException(), isNull);
    }
  });

  testWidgets(
    'navigation glyphs swap in RTL and nondirectional symbols stay unchanged',
    (tester) async {
      for (final direction in TextDirection.values) {
        await tester.pumpWidget(
          host(
            Directionality(
              textDirection: direction,
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AcademySfIcon(AcademySymbols.back),
                  AcademySfIcon(AcademySymbols.forward),
                  AcademySfIcon(AcademySymbols.play),
                ],
              ),
            ),
          ),
        );
        final glyphs = tester
            .widgetList<sf.SFIcon>(find.byType(sf.SFIcon))
            .toList();
        expect(
          glyphs[0].icon,
          direction == TextDirection.rtl
              ? AcademySymbols.forward
              : AcademySymbols.back,
        );
        expect(
          glyphs[1].icon,
          direction == TextDirection.rtl
              ? AcademySymbols.back
              : AcademySymbols.forward,
        );
        expect(glyphs[2].icon, AcademySymbols.play);
      }
    },
  );

  for (final direction in TextDirection.values) {
    testWidgets('page reserves trailing width on 320px in $direction', (
      tester,
    ) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(320, 640);
      addTearDown(tester.view.reset);
      const title = 'Very long title on a small screen';
      const actionKey = ValueKey('trailing-action');
      await tester.pumpWidget(
        host(
          Directionality(
            textDirection: direction,
            child: const AcademyPage(
              title: title,
              trailing: SizedBox(key: actionKey, width: 80, height: 44),
              child: SizedBox.expand(),
            ),
          ),
        ),
      );
      final text = tester.getRect(find.text(title)),
          action = tester.getRect(find.byKey(actionKey));
      expect(text.overlaps(action), false);
      expect(
        direction == TextDirection.rtl
            ? action.right <= text.left
            : text.right <= action.left,
        true,
      );
      expect(tester.takeException(), isNull);
    });
  }

  test('text color pairs pass contrast across native blue and custom accents in both themes', () {
    for (final brightness in Brightness.values) {
      for (final accent in [
        0xFF007AFF,
        0xFF263E59,
        0xFF246A89,
        0xFF326555,
        0xFF74537B,
        0xFF98513D,
        0xFFE8CA79,
      ]) {
        final p = AcademyPalette(brightness, Color(accent));
        for (final pair in [
          (p.onPrimary, p.primary),
          (p.secondary, p.secondaryContainer),
          (p.onPrimaryContainer, p.primaryContainer),
          for (final tone in AcademyTone.values)
            (p.toneForeground(tone), p.toneContainer(tone)),
        ]) {
          expect(
            AcademyContrast.ratio(pair.$1, pair.$2),
            greaterThanOrEqualTo(4.5),
            reason: '$brightness / ${accent.toRadixString(16)} / $pair',
          );
        }
      }
    }
  });

  testWidgets('tinted button and selected tab use client semantic roles', (
    tester,
  ) async {
    const ink = Color(0xFF001F10),
        fill = Color(0xFFD1F1DB),
        tabInk = Color(0xFF311F00);
    await tester.pumpWidget(
      AcademyApp(
        colorsBuilder: (brightness, accent) =>
            AcademyPalette(brightness, accent).copyWith(
              secondary: ink,
              secondaryContainer: fill,
              onPrimaryContainer: tabInk,
            ),
        home: Column(
          children: [
            AcademyButton(
              label: 'Tinted',
              style: AcademyButtonStyle.tinted,
              onPressed: () {},
            ),
            SizedBox(
              height: 80,
              child: AcademyFloatingTabBar(
                tabs: [
                  AcademyTab(
                    label: 'Selected',
                    icon: AcademySymbols.book,
                    builder: (_) => const SizedBox(),
                  ),
                ],
                index: 0,
                onChanged: (_) {},
              ),
            ),
          ],
        ),
      ),
    );
    final button = tester.widget<CupertinoButton>(
      find.descendant(
        of: find.byType(AcademyButton),
        matching: find.byType(CupertinoButton),
      ),
    );
    expect(button.color, fill);
    expect(
      tester
          .renderObject<RenderParagraph>(
            find.descendant(
              of: find.text('Tinted'),
              matching: find.byType(RichText),
            ),
          )
          .text
          .style!
          .color,
      ink,
    );
    expect(tester.widget<Text>(find.text('Selected')).style!.color, tabInk);
  });

  for (final enabled in [true, false]) {
    testSemantics(
      'utility buttons have one named action node, enabled=$enabled',
      (tester) async {
        var calls = 0;
        await tester.pumpWidget(
          host(
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                AcademyCompactIconButton(
                  label: 'Compact',
                  onPressed: enabled ? () => calls++ : null,
                ),
                AcademySettingsSquareButton(
                  label: 'Settings',
                  icon: AcademySymbols.gear,
                  onPressed: enabled ? () => calls++ : null,
                ),
                AcademyChromeButton(
                  label: 'Chrome',
                  icon: AcademySymbols.gear,
                  onPressed: enabled ? () => calls++ : null,
                ),
                AcademyIconButton(
                  label: 'Icon',
                  icon: AcademySymbols.gear,
                  onPressed: enabled ? () => calls++ : null,
                ),
              ],
            ),
          ),
        );
        final buttons = nodes(tester)
            .where((n) => n.getSemanticsData().flagsCollection.isButton)
            .toList();
        expect(buttons.length, 4);
        for (final label in ['Compact', 'Settings', 'Chrome', 'Icon']) {
          final node = buttons.singleWhere(
            (n) => n.getSemanticsData().label == label,
          );
          expect(
            node.getSemanticsData().hasAction(SemanticsAction.tap),
            enabled,
          );
          if (enabled) {
            act(tester, node, SemanticsAction.tap);
            await tester.pumpAndSettle();
          }
        }
        expect(calls, enabled ? 4 : 0);
      },
    );
  }

  testWidgets(
    'compact segments keep 44px targets and scroll on narrow layouts',
    (tester) async {
      var selected = 0;
      await tester.pumpWidget(
        host(
          SizedBox(
            width: 160,
            child: AcademyCompactSegment<int>(
              items: const [0, 1, 2, 3],
              value: 0,
              labelFor: (i) => '$i',
              onChanged: (i) => selected = i,
            ),
          ),
        ),
      );
      for (final button in find.byType(CupertinoButton).evaluate()) {
        final size = tester.getSize(find.byWidget(button.widget));
        expect(size.width, greaterThanOrEqualTo(44));
        expect(size.height, greaterThanOrEqualTo(44));
      }
      await tester.drag(
        find.byType(SingleChildScrollView),
        const Offset(-60, 0),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('3'));
      expect(selected, 3);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'PressScale follows reduce motion and notifier replacement without losing actions',
    (tester) async {
      final first = ValueNotifier(true), second = ValueNotifier(true);
      addTearDown(first.dispose);
      addTearDown(second.dispose);
      Future<void> pump(bool reduced, ValueNotifier<bool> notifier) async {
        await tester.pumpWidget(
          host(
            MediaQuery(
              data: MediaQueryData(disableAnimations: reduced),
              child: PressScale(
                externalPressed: notifier,
                child: const SizedBox(width: 60, height: 60),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();
      }

      double scale() => tester
          .widget<Transform>(
            find
                .descendant(
                  of: find.byType(PressScale),
                  matching: find.byType(Transform),
                )
                .first,
          )
          .transform
          .entry(0, 0);
      await pump(false, first);
      expect(scale(), closeTo(.9, .001));
      await pump(true, first);
      expect(scale(), 1);
      first.value = false;
      await tester.pumpAndSettle();
      expect(scale(), 1);
      await pump(false, second);
      expect(scale(), closeTo(.9, .001));
      second.value = false;
      await tester.pumpAndSettle();
      expect(scale(), closeTo(1, .001));
      var calls = 0;
      await tester.pumpWidget(
        host(
          MediaQuery(
            data: const MediaQueryData(disableAnimations: true),
            child: PressScale(
              onTap: () => calls++,
              child: const SizedBox(width: 60, height: 60),
            ),
          ),
        ),
      );
      await tester.tap(find.byType(PressScale));
      await tester.pumpAndSettle();
      expect(calls, 1);
      expect(scale(), 1);
    },
  );

  testSemantics(
    'reorder custom actions move locally and across allowed sections',
    (tester) async {
      final moves = <(Object, int)>[];
      await tester.pumpWidget(
        host(
          SizedBox(
            width: 300,
            child: AcademyDraggableTableSection<String>(
              sectionId: 'a',
              items: const ['one', 'two', 'three'],
              itemId: (item) => item,
              rowBuilder: (context, item, accessory) =>
                  AcademyRow(title: item, trailing: accessory),
              onMove: (source, destination, index) =>
                  moves.add((destination, index)),
              moveTargets: [
                const AcademyTableMoveTarget<String>(
                  sectionId: 'b',
                  label: 'Other',
                  itemCount: 2,
                ),
                AcademyTableMoveTarget<String>(
                  sectionId: 'c',
                  label: 'Rejected',
                  itemCount: 0,
                  accepts: (_) => false,
                ),
                const AcademyTableMoveTarget<String>(
                  sectionId: 'd',
                  label: 'Disabled',
                  itemCount: 0,
                  enabled: false,
                ),
              ],
            ),
          ),
        ),
      );
      final node = nodes(tester)
          .singleWhere((n) => n.getSemanticsData().label == 'Переместить two');
      final ids = node.getSemanticsData().customSemanticsActionIds!;
      final labels = ids
          .map((id) => CustomSemanticsAction.getAction(id)!.label)
          .toList();
      expect(
        labels,
        unorderedEquals([
          'Переместить выше',
          'Переместить ниже',
          'Переместить в Other',
        ]),
      );
      for (final id in ids) {
        act(tester, node, SemanticsAction.customAction, id);
      }
      expect(moves, unorderedEquals([('a', 0), ('a', 2), ('b', 2)]));
      await tester.tap(find.bySemanticsLabel('Переместить two'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Переместить в Other'));
      await tester.pumpAndSettle();
      expect(moves.last, ('b', 2));
      expect(moves.length, 4);
    },
  );

  testWidgets('reorder menu opens from keyboard and uses human item labels', (
    tester,
  ) async {
    final item = Object();
    var calls = 0;
    await tester.pumpWidget(
      host(
        SizedBox(
          width: 300,
          child: AcademyDraggableTableSection<Object>(
            sectionId: 'a',
            items: [item],
            itemId: (item) => item,
            labelForItem: (_) => 'Human label',
            rowBuilder: (_, _, accessory) =>
                AcademyRow(title: 'Human label', trailing: accessory),
            onMove: (_, _, _) => calls++,
            moveTargets: const [
              AcademyTableMoveTarget<Object>(
                sectionId: 'b',
                label: 'Other',
                itemCount: 0,
              ),
            ],
          ),
        ),
      ),
    );
    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pumpAndSettle();
    expect(find.text('Переместить в Other'), findsOneWidget);
    await tester.tap(find.text('Переместить в Other'));
    await tester.pumpAndSettle();
    expect(calls, 1);
  });

  for (final locale in [const Locale('en'), const Locale('ar')]) {
    testSemantics('built-in strings and direction follow $locale', (
      tester,
    ) async {
      final controller = TextEditingController();
      addTearDown(controller.dispose);
      late BuildContext context;
      await tester.pumpWidget(
        host(
          Builder(
            builder: (ctx) {
              context = ctx;
              return Column(
                children: [
                  AcademySearchBar(controller: controller),
                  AcademyCompactIconButton(onPressed: () {}),
                  AcademyGuideStep(
                    title: 'Title',
                    description: 'Description',
                    step: 1,
                    total: 1,
                    completed: true,
                    onNext: () {},
                  ),
                ],
              );
            },
          ),
          locale: locale,
        ),
      );
      final strings = AcademyLocalizations.of(context);
      expect(
        tester
            .widget<CupertinoTextField>(find.byType(CupertinoTextField))
            .placeholder,
        strings.search,
      );
      expect(find.text(strings.done), findsOneWidget);
      expect(
        nodes(tester)
            .where((n) => n.getSemanticsData().label == strings.close)
            .length,
        1,
      );
      expect(
        Directionality.of(context),
        locale.languageCode == 'ar' ? TextDirection.rtl : TextDirection.ltr,
      );
    });
  }

  testSemantics('client delegate overrides built-in wording', (tester) async {
    await tester.pumpWidget(
      AcademyApp(
        localizationsDelegates: const [_ClientDelegate()],
        home: AcademyCompactIconButton(onPressed: () {}),
      ),
    );
    await tester.pumpAndSettle();
    expect(
      nodes(tester)
          .where((n) => n.getSemanticsData().label == 'Dismiss custom')
          .length,
      1,
    );
  });

  testWidgets(
    'completed guide uses onDone, falls back to onNext, and omits read-only CTA',
    (tester) async {
      var next = 0, done = 0;
      Future<void> pump({bool readOnly = false, VoidCallback? onDone}) =>
          tester.pumpWidget(
            host(
              SizedBox(
                width: 280,
                child: AcademyGuideStep(
                  title: 'Title',
                  description: 'Description',
                  step: 1,
                  total: 1,
                  completed: true,
                  readOnly: readOnly,
                  onNext: () => next++,
                  onDone: onDone,
                ),
              ),
            ),
          );
      await pump(onDone: () => done++);
      await tester.tap(find.text('Готово'));
      expect(done, 1);
      expect(next, 0);
      await pump();
      await tester.tap(find.text('Готово'));
      expect(next, 1);
      await pump(readOnly: true);
      expect(find.byType(AcademyButton), findsNothing);
    },
  );

  test('large typography resolves Display family', () {
    const typography = AcademyTypography(Color(0xFF000000));
    expect(typography.bodyLarge.fontFamily, 'CupertinoSystemText');
    expect(typography.headlineMedium.fontFamily, 'CupertinoSystemDisplay');
    expect(typography.displaySmall.fontFamily, 'CupertinoSystemDisplay');
  });

  testSemantics('settings keeps tap and long press in one native action node', (
    tester,
  ) async {
    var taps = 0, holds = 0;
    await tester.pumpWidget(
      host(
        AcademySettingsSquareButton(
          icon: AcademySymbols.gear,
          label: 'Settings',
          onPressed: () => taps++,
          onLongPress: () => holds++,
        ),
      ),
    );
    final node = nodes(tester)
        .singleWhere((n) => n.getSemanticsData().label == 'Settings');
    act(tester, node, SemanticsAction.tap);
    act(tester, node, SemanticsAction.longPress);
    await tester.pumpAndSettle();
    expect(taps, 1);
    expect(holds, 1);
    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.sendKeyEvent(LogicalKeyboardKey.space);
    await tester.pumpAndSettle();
    expect(taps, 2);
  });

  testSemantics(
    'chrome menu has one label and a working accessibility action',
    (tester) async {
      await tester.pumpWidget(
        host(
          AcademyChromeMenu(
            label: 'Theme',
            value: 'Light',
            options: const ['Light', 'Dark'],
            onSelected: (_) {},
          ),
        ),
      );
      final buttons = nodes(tester)
          .where((n) => n.getSemanticsData().flagsCollection.isButton)
          .toList();
      expect(buttons.length, 1);
      expect(buttons.single.getSemanticsData().label, 'Theme');
      expect(buttons.single.getSemanticsData().value, 'Light');
      act(tester, buttons.single, SemanticsAction.tap);
      await tester.pumpAndSettle();
      expect(find.text('Dark'), findsOneWidget);
    },
  );

  testSemantics('disabled compact segment retains selection without actions', (
    tester,
  ) async {
    await tester.pumpWidget(
      host(
        SizedBox(
          width: 160,
          child: AcademyCompactSegment<int>(
            items: const [0, 1],
            value: 1,
            labelFor: (i) => '$i',
            onChanged: null,
          ),
        ),
      ),
    );
    final buttons = nodes(tester)
        .where((n) => n.getSemanticsData().flagsCollection.isButton)
        .toList();
    expect(buttons.length, 2);
    expect(
      buttons
          .singleWhere(
            (n) =>
                n.getSemanticsData().flagsCollection.isSelected ==
                Tristate.isTrue,
          )
          .getSemanticsData()
          .label,
      '1',
    );
    expect(
      buttons.every(
        (n) => !n.getSemanticsData().hasAction(SemanticsAction.tap),
      ),
      true,
    );
  });

  testWidgets('content search keeps its opaque background', (tester) async {
    final controller = TextEditingController();
    addTearDown(controller.dispose);
    await tester.pumpWidget(
      host(
        SizedBox(
          width: 280,
          child: AcademySearchBar(controller: controller, chrome: false),
        ),
      ),
    );
    expect(find.byType(BackdropFilter), findsNothing);
  });
}

class _ClientStrings extends AcademyLocalizations {
  const _ClientStrings(super.locale);
  @override
  String get close => 'Dismiss custom';
}

class _ClientDelegate extends LocalizationsDelegate<AcademyLocalizations> {
  const _ClientDelegate();
  @override
  bool isSupported(Locale locale) => true;
  @override
  Future<AcademyLocalizations> load(Locale locale) async =>
      _ClientStrings(locale);
  @override
  bool shouldReload(_ClientDelegate old) => false;
}
