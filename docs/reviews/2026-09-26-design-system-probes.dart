// Diagnostic snapshot for the 2026-09-26 review, not a regression suite.
// Run from packages/academy_ui:
// flutter test ../../docs/reviews/2026-09-26-design-system-probes.dart --no-pub
// Some assertions deliberately confirm the defective behavior in this snapshot.
import 'package:academy_ui/academy_ui.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/services.dart';
import 'package:cupertino_ui/cupertino_ui.dart' as kit;

double contrast(Color a, Color b) {
  final x = a.computeLuminance(), y = b.computeLuminance();
  return x > y ? (x + .05) / (y + .05) : (y + .05) / (x + .05);
}

Widget host(Widget child, {double scale = 1}) => AcademyApp(
  home: MediaQuery(
    data: MediaQueryData(textScaler: TextScaler.linear(scale)),
    child: Center(child: child),
  ),
);

void main() {
  test('palette contrast sweep', () {
    for (final brightness in Brightness.values) {
      for (final accent in [0xFF263E59, 0xFF246A89, 0xFF326555, 0xFF74537B, 0xFF98513D, 0xFFE8CA79]) {
        final p = AcademyPalette(brightness, Color(accent));
        final pairs = <String, (Color, Color)>{
          'primary/surface': (p.primary, p.surface),
          'primary/field': (p.primary, p.surfaceContainerHighest),
          'primary/primaryContainer': (p.primary, p.primaryContainer),
          'primary/secondaryButton': (p.primary, Color.lerp(p.primary, p.surface, .84)!),
          for (final tone in AcademyTone.values)
            'status/$tone': (p.toneForeground(tone), p.toneContainer(tone)),
        };
        for (final entry in pairs.entries) {
          final ratio = contrast(entry.value.$1, entry.value.$2);
          if (ratio < 4.5) print('LOW_CONTRAST $brightness ${accent.toRadixString(16)} ${entry.key} ${ratio.toStringAsFixed(2)}');
        }
      }
    }
  });

  testWidgets('disabled row child remains active', (tester) async {
    var changes = 0;
    await tester.pumpWidget(host(SizedBox(width: 280, child: AcademyRow(
      title: 'Disabled', enabled: false,
      trailing: CupertinoSwitch(value: false, onChanged: (_) => changes++),
    ))));
    await tester.tap(find.byType(CupertinoSwitch));
    await tester.pump();
    print('DISABLED_ROW_CHANGES $changes');
    expect(changes, 1);
  });

  testWidgets('segment target widths on constrained screen', (tester) async {
    await tester.pumpWidget(host(SizedBox(width: 160, child: AcademyCompactSegment<int>(
      items: const [0, 1, 2, 3], value: 0, labelFor: (i) => '$i', onChanged: (_) {},
    ))));
    final buttons = find.byType(kit.CupertinoButton);
    print('SEGMENT_TARGET ${tester.getSize(buttons.first)}');
    expect(tester.getSize(buttons.first).width, 40);
  });

  testWidgets('icons inherit large text scaler', (tester) async {
    for (final scale in [1.0, 2.0, 3.0]) {
      await tester.pumpWidget(host(AcademyCompactIconButton(onPressed: () {}), scale: scale));
      final glyph = find.descendant(of: find.byType(AcademySfIcon), matching: find.byType(RichText));
      print('ICON_SCALE $scale ${tester.getSize(glyph)}');
      expect(tester.takeException(), isNull);
    }
  });

  testWidgets('toast inherits wrong color for client palette', (tester) async {
    late BuildContext ctx;
    await tester.pumpWidget(AcademyApp(
      colorsBuilder: (brightness, accent) => AcademyPalette(brightness, accent).copyWith(onSurface: const Color(0xFF008000)),
      home: Builder(builder: (context) {ctx = context; return const SizedBox.expand();}),
    ));
    AcademyToastHost.show(ctx, 'audit toast', duration: const Duration(seconds: 30));
    await tester.pumpAndSettle();
    final paragraph = tester.renderObject<RenderParagraph>(find.descendant(of: find.text('audit toast'), matching: find.byType(RichText)));
    print('TOAST_COLOR ${paragraph.text.style?.color}');
    print('EXPECTED_COLOR ${AcademyTheme.of(ctx).colorScheme.onSurface}');
    await tester.tap(find.text('audit toast'));
    await tester.pumpAndSettle();
  });

  testWidgets('guide completed cannot trigger Done', (tester) async {
    var calls = 0;
    await tester.pumpWidget(host(SizedBox(width: 280, child: AcademyGuideStep(
      title: 'Done', description: 'Done', step: 1, total: 1, completed: true, onNext: () => calls++,
    ))));
    await tester.tap(find.text('Готово'));
    print('GUIDE_DONE_CALLS $calls');
    expect(calls, 0);
  });

  testWidgets('reduce motion standalone press scale', (tester) async {
    final pressed = ValueNotifier(false);
    addTearDown(pressed.dispose);
    await tester.pumpWidget(AcademyApp(home: MediaQuery(
      data: const MediaQueryData(disableAnimations: true),
      child: Center(child: PressScale(externalPressed: pressed, child: const SizedBox(width: 60, height: 60))),
    )));
    pressed.value = true;
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    final transform = tester.widget<Transform>(find.descendant(of: find.byType(PressScale), matching: find.byType(Transform)).first);
    print('REDUCE_MOTION_SCALE ${transform.transform.entry(0, 0)}');
    pressed.value = false;
    await tester.pumpAndSettle();
  });

  testWidgets('disabled editing section still removes', (tester) async {
    var removes = 0;
    await tester.pumpWidget(host(SizedBox(width: 280, child: AcademyDraggableTableSection<String>(
      sectionId: 'a', items: const ['one'], itemId: (item) => item,
      rowBuilder: (context, item, accessory) => AcademyRow(title: item, trailing: accessory),
      onMove: (_, _, _) {}, enabled: false, editing: true, onRemove: (_) => removes++,
    ))));
    await tester.tap(find.byType(CupertinoButton));
    print('DISABLED_SECTION_REMOVES $removes');
    expect(removes, 1);
  });

  testWidgets('secondary color override not used by secondary button', (tester) async {
    await tester.pumpWidget(AcademyApp(
      colorsBuilder: (brightness, accent) => AcademyPalette(brightness, accent).copyWith(
        secondaryContainer: const Color(0xFF00FF00), secondary: const Color(0xFFFF0000), onSecondary: const Color(0xFF0000FF),
      ),
      home: Center(child: AcademyButton(label: 'Secondary', secondary: true, onPressed: () {})),
    ));
    final button = tester.widget<CupertinoButton>(find.byType(CupertinoButton));
    print('SECONDARY_BUTTON_COLOR ${button.color}');
  });

  testWidgets('reader symbol and large text visual comparison', (tester) async {
    await (FontLoader('packages/flutter_sficon/sficons')..addFont(rootBundle.load('packages/flutter_sficon/lib/fonts/sficons.ttf'))).load();
    await (FontLoader('AuditInter')..addFont(rootBundle.load('packages/academy_ui/assets/fonts/Inter.ttf'))).load();
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(720, 480);
    addTearDown(tester.view.reset);
    final boundary = GlobalKey();
    await tester.pumpWidget(RepaintBoundary(key: boundary, child: AcademyApp(home: ColoredBox(color: const Color(0xFFF5F4F1), child: DefaultTextStyle(style: const TextStyle(fontFamily: 'AuditInter', fontSize: 15, color: Color(0xFF171D26)), child: Row(children: [
      for (final direction in TextDirection.values)
        Expanded(child: Directionality(textDirection: direction, child: Column(children: [
          Text('$direction'),
          AcademyRow(title: 'Navigate', titleWidget: const Text('Navigate', style: TextStyle(fontFamily: 'AuditInter', fontSize: 15, color: Color(0xFF171D26))), icon: AcademySymbols.book, onPressed: () {}),
          AcademyChromeButton(icon: AcademySymbols.back, label: 'Back', onPressed: () {}),
          for (final scale in [1.0, 2.0, 3.0])
            MediaQuery(data: MediaQueryData(textScaler: TextScaler.linear(scale)), child: Row(children: [
              MediaQuery.withNoTextScaling(child: SizedBox(width: 100, child: Text('Text ×$scale', textAlign: TextAlign.center))), AcademyCompactIconButton(onPressed: () {}), AcademySettingsSquareButton(icon: AcademySymbols.sun, label: 'Sun', onPressed: () {}),
            ])),
        ]))),
    ]))))));
    await tester.pumpAndSettle();
    await tester.runAsync(() async {
      final picture = await (boundary.currentContext!.findRenderObject() as RenderRepaintBoundary).toImage(pixelRatio: 2);
      final data = await picture.toByteData(format: ui.ImageByteFormat.png);
      File('/tmp/academy-audit-symbols.png').writeAsBytesSync(data!.buffer.asUint8List());
      picture.dispose();
    });
  });

  testWidgets('page trailing overlaps title', (tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(320, 640);
    addTearDown(tester.view.reset);
    const title = 'Very long title on a small screen';
    const actionKey = ValueKey('trailing-action');
    await tester.pumpWidget(AcademyApp(home: const AcademyPage(
      title: title, trailing: SizedBox(key: actionKey, width: 80, height: 44), child: SizedBox.expand(),
    )));
    print('PAGE_TITLE_RECT ${tester.getRect(find.text(title))}');
    print('PAGE_ACTION_RECT ${tester.getRect(find.byKey(actionKey))}');
    print('PAGE_HEADER_OVERLAP ${tester.getRect(find.text(title)).overlaps(tester.getRect(find.byKey(actionKey)))}');
  });

  testWidgets('compact button produces nested button semantics', (tester) async {
    final semantics = tester.ensureSemantics();
    await tester.pumpWidget(host(AcademyCompactIconButton(onPressed: () {})));
    print('COMPACT_BUTTON_SEMANTICS ${tester.getSemantics(find.byType(AcademyCompactIconButton)).toStringDeep()}');
    semantics.dispose();
  });

  testWidgets('feedback retry semantics', (tester) async {
    final semantics = tester.ensureSemantics();
    await tester.pumpWidget(host(AcademyFeedback(kind: AcademyFeedbackKind.error, title: 'Error', message: 'Message', onRetry: () {})));
    print('FEEDBACK_SEMANTICS ${tester.getSemantics(find.byType(AcademyFeedback)).toStringDeep()}');
    semantics.dispose();
  });
}
