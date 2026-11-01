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
}
