import 'package:academy_ui/academy_ui.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _host(Widget child, {double textScale = 1, bool rtl = false}) =>
    AcademyApp(
      home: Builder(
        builder: (context) => MediaQuery(
          data: MediaQuery.of(context).copyWith(
            textScaler: TextScaler.linear(textScale),
            disableAnimations: true,
          ),
          child: Directionality(
            textDirection: rtl ? TextDirection.rtl : TextDirection.ltr,
            child: CupertinoPageScaffold(child: Center(child: child)),
          ),
        ),
      ),
    );

void main() {
  testWidgets('counter shows count/total, counts taps and completes', (
    tester,
  ) async {
    var count = 0, longPresses = 0;
    late StateSetter update;
    await tester.pumpWidget(
      _host(
        StatefulBuilder(
          builder: (context, setState) {
            update = setState;
            return AcademyCounterButton(
              count: count,
              total: 3,
              label: 'Счётчик',
              onPressed: () => setState(() => count++),
              onLongPress: () => longPresses++,
            );
          },
        ),
      ),
    );
    expect(find.text('0'), findsOneWidget);
    expect(find.text('/ 3'), findsOneWidget);
    await tester.tap(find.byType(AcademyCounterButton));
    await tester.pumpAndSettle();
    expect(count, 1);
    expect(find.text('1'), findsOneWidget);
    expect(
      tester.getSemantics(find.byType(AcademyCounterButton)),
      matchesSemantics(
        label: 'Счётчик',
        value: '1 / 3',
        isButton: true,
        hasTapAction: true,
        hasLongPressAction: true,
        hasEnabledState: true,
        isEnabled: true,
      ),
    );
    update(() => count = 3);
    await tester.pumpAndSettle();
    expect(find.text('/ 3'), findsNothing);
    expect(find.byType(AcademySfIcon), findsOneWidget);
    await tester.longPress(find.byType(AcademyCounterButton));
    expect(longPresses, 1);
  });

  testWidgets('counter fits large text and RTL without overflow', (
    tester,
  ) async {
    await tester.pumpWidget(
      _host(
        AcademyCounterButton(
          count: 99,
          total: 100,
          label: 'Счётчик',
          onPressed: () {},
        ),
        textScale: 3,
        rtl: true,
      ),
    );
    expect(tester.takeException(), isNull);
    expect(
      tester.getSize(find.byType(AcademyCounterButton)),
      const Size(64, 64),
    );
  });

  testWidgets('page dots select pages and scroll long strips', (tester) async {
    final selected = <int>[];
    await tester.pumpWidget(
      _host(
        SizedBox(
          width: 200,
          child: AcademyPageDots(
            count: 100,
            index: 50,
            isCompleted: (i) => i < 10,
            onSelected: selected.add,
            semanticsLabel: 'Зикр 51 из 100',
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(find.bySemanticsLabel('Зикр 51 из 100'), findsOneWidget);
    await tester.tapAt(tester.getCenter(find.byType(AcademyPageDots)));
    expect(selected.single, inInclusiveRange(48, 52));
  });

  testWidgets('short page dots are centered without scrolling', (tester) async {
    await tester.pumpWidget(
      _host(
        const SizedBox(width: 300, child: AcademyPageDots(count: 5, index: 0)),
      ),
    );
    expect(find.byType(SingleChildScrollView), findsNothing);
  });

  testWidgets('progress card reports progress and completion', (tester) async {
    var taps = 0;
    await tester.pumpWidget(
      _host(
        SizedBox(
          width: 340,
          child: AcademyProgressCard(
            title: 'Утренние азкары',
            subtitle: 'Прочитано 3 из 17',
            badge: 'Сейчас',
            icon: AcademySymbols.sunrise,
            highlighted: true,
            progress: .2,
            onPressed: () => taps++,
          ),
        ),
      ),
    );
    expect(find.byType(AcademyRingProgress), findsOneWidget);
    await tester.tap(find.text('Утренние азкары'));
    expect(taps, 1);
    await tester.pumpWidget(
      _host(
        const SizedBox(
          width: 340,
          child: AcademyProgressCard(title: 'Вечерние азкары', progress: 1),
        ),
      ),
    );
    expect(find.byType(AcademyRingProgress), findsNothing);
  });

  testWidgets('chrome fade keeps a solid band before the gradient', (
    tester,
  ) async {
    await tester.pumpWidget(
      _host(const AcademyChromeFade(solidExtent: 40, fadeExtent: 20)),
    );
    expect(tester.getSize(find.byType(AcademyChromeFade)).height, 60);
  });

  testWidgets('search scrim dims while open and swaps in results', (
    tester,
  ) async {
    var dismissed = 0;
    Widget scrim({required bool active, Widget? results}) => _host(
      SizedBox(
        width: 300,
        height: 300,
        child: AcademySearchScrim(
          active: active,
          results: results,
          onDismiss: () => dismissed++,
        ),
      ),
    );
    await tester.pumpWidget(scrim(active: false));
    await tester.tapAt(tester.getCenter(find.byType(AcademySearchScrim)));
    expect(dismissed, 0);
    await tester.pumpWidget(scrim(active: true));
    await tester.pumpAndSettle();
    await tester.tapAt(tester.getCenter(find.byType(AcademySearchScrim)));
    expect(dismissed, 1);
    await tester.pumpWidget(scrim(active: true, results: const Text('Итог')));
    await tester.pumpAndSettle();
    expect(find.text('Итог'), findsOneWidget);
  });

  testWidgets('expanding search can be closed from outside', (tester) async {
    final key = GlobalKey<AcademyExpandingSearchState>();
    final controller = TextEditingController();
    addTearDown(controller.dispose);
    final states = <bool>[];
    await tester.pumpWidget(
      _host(
        SizedBox(
          width: 360,
          child: AcademyExpandingSearch(
            key: key,
            controller: controller,
            onOpenChanged: states.add,
          ),
        ),
      ),
    );
    key.currentState!.open();
    await tester.pumpAndSettle();
    expect(key.currentState!.isOpen, isTrue);
    controller.text = 'дуа';
    key.currentState!.close();
    await tester.pumpAndSettle();
    expect(states, [true, false]);
    expect(controller.text, isEmpty);
  });

  testWidgets('progress tile, index badge and chrome menu button', (
    tester,
  ) async {
    var taps = 0, picked = 0;
    await tester.pumpWidget(
      _host(
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 170,
              child: AcademyProgressTile(
                title: 'Утренние азкары',
                caption: '2/17',
                progress: 2 / 17,
                icon: AcademySymbols.sunrise,
                highlighted: true,
                onPressed: () => taps++,
              ),
            ),
            const AcademyIndexBadge(125),
            AcademyChromeMenuButton(
              label: 'Ещё',
              items: [
                AcademyMenuItem(title: 'Список', onPressed: () => picked++),
              ],
            ),
          ],
        ),
        textScale: 2,
      ),
    );
    expect(tester.takeException(), isNull);
    await tester.tap(find.byType(AcademyProgressTile));
    expect(taps, 1);
    expect(find.text('125'), findsOneWidget);
    await tester.tap(find.byType(AcademyChromeMenuButton));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Список'));
    await tester.pumpAndSettle();
    expect(picked, 1);
  });

  testWidgets('counter view counts taps anywhere and shows completion', (
    tester,
  ) async {
    var count = 0;
    late StateSetter update;
    await tester.pumpWidget(
      _host(
        SizedBox(
          width: 360,
          height: 600,
          child: StatefulBuilder(
            builder: (context, setState) {
              update = setState;
              return AcademyCounterView(
                count: count,
                total: 33,
                label: 'Счётчик',
                hint: 'Нажимайте в любом месте',
                onPressed: () => setState(() => count++),
              );
            },
          ),
        ),
        textScale: 2,
      ),
    );
    await tester.tapAt(
      tester.getTopLeft(find.byType(AcademyCounterView)) + const Offset(10, 10),
    );
    await tester.pump();
    expect(count, 1);
    expect(find.text('1'), findsOneWidget);
    update(() => count = 33);
    await tester.pumpAndSettle();
    expect(find.text('/ 33'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('text block shows label and text, tinted on cards', (
    tester,
  ) async {
    await tester.pumpWidget(
      _host(
        const SizedBox(
          width: 320,
          child: AcademyTextBlock(
            label: 'Перевод',
            text: 'Слава Аллаху и хвала Ему.',
            onCard: true,
          ),
        ),
      ),
    );
    expect(find.text('Перевод'), findsOneWidget);
    expect(find.text('Слава Аллаху и хвала Ему.'), findsOneWidget);
    final box = tester.widget<Container>(find.byType(Container).first);
    final color = (box.decoration! as BoxDecoration).color;
    final context = tester.element(find.byType(AcademyTextBlock));
    expect(color, AcademyTextBlock.backgroundOf(context, onCard: true));
  });

  testWidgets('progress tile works without progress', (tester) async {
    await tester.pumpWidget(
      _host(
        const SizedBox(
          width: 170,
          child: AcademyProgressTile(
            title: 'Утренние',
            icon: AcademySymbols.sun,
          ),
        ),
      ),
    );
    expect(find.text('Утренние'), findsOneWidget);
    expect(find.byType(ClipRRect), findsNothing);
  });
}
