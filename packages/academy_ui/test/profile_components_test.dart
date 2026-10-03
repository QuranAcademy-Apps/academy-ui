import 'package:academy_ui/academy_ui.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_test/flutter_test.dart';

Widget host(
  Widget child, {
  Brightness brightness = Brightness.light,
  TextDirection direction = TextDirection.ltr,
  double scale = 1,
}) {
  final theme = academyTheme(brightness);
  return AcademyApp(
    home: AcademyTheme(
      data: theme,
      child: CupertinoTheme(
        data: theme.cupertino,
        child: MediaQuery(
          data: MediaQueryData(
            textScaler: TextScaler.linear(scale),
            disableAnimations: true,
          ),
          child: Directionality(
            textDirection: direction,
            child: SingleChildScrollView(child: child),
          ),
        ),
      ),
    ),
  );
}

List<SemanticsNode> nodes(WidgetTester tester) {
  final result = <SemanticsNode>[];
  void visit(SemanticsNode node) {
    if (!node.isMergedIntoParent) result.add(node);
    node.visitChildren((child) {
      visit(child);
      return true;
    });
  }

  visit(tester.binding.renderViews.single.owner!.semanticsOwner!.rootSemanticsNode!);
  return result;
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
  for (final brightness in Brightness.values) {
    for (final direction in TextDirection.values) {
      for (final scale in [1.0, 2.0]) {
        testWidgets('profile layout $brightness $direction $scale at 320', (
          tester,
        ) async {
          tester.view.physicalSize = const Size(320, 844);
          tester.view.devicePixelRatio = 1;
          addTearDown(tester.view.reset);
          await tester.pumpWidget(
            host(
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  AcademyTableHeader.action(
                    title: 'Мои подтверждённые данные',
                    action: 'Изменить информацию',
                    icon: AcademySymbols.gear,
                    onPressed: () {},
                  ),
                  AcademyTableBody(
                    rows: [
                      const AcademyValueRow(
                        label: 'Имя участника',
                        value: 'Очень длинное имя и фамилия',
                        readOnly: true,
                      ),
                      AcademyRow.action(
                        title: 'Информация ещё не заполнена',
                        action: 'Добавить информацию',
                        onPressed: () {},
                      ),
                      AcademyRow(
                        title: 'Удалить',
                        tone: AcademyTone.error,
                        icon: AcademySymbols.close,
                        onPressed: () {},
                      ),
                    ],
                  ),
                  AcademyActionButton(
                    title: 'Открыть информацию о поездке',
                    subtitle: 'Всё необходимое под рукой',
                    icon: AcademySymbols.info,
                    onPressed: () {},
                  ),
                  AcademyPillButton(
                    label: 'Позвонить организатору поездки',
                    icon: AcademySymbols.person,
                    onPressed: () {},
                  ),
                  AcademyStatGroup(
                    stats: const [
                      AcademyStat(label: 'Начало', value: '12 октября 2026'),
                      AcademyStat(label: 'Окончание', value: '22 октября 2026'),
                      AcademyStat(label: 'Длительность', value: '10 дней'),
                    ],
                  ),
                  const AcademyTimeline(
                    items: [
                      AcademyTimelineItem(
                        title: 'Подготовка документов',
                        date: '10 октября',
                        state: AcademyTimelineState.completed,
                      ),
                      AcademyTimelineItem(
                        title: 'Длинное название текущего этапа',
                        date: '12 октября',
                        subtitle: 'Подробное описание этапа',
                        state: AcademyTimelineState.current,
                      ),
                      AcademyTimelineItem(
                        title: 'Возвращение',
                        date: '22 октября',
                      ),
                    ],
                  ),
                ],
              ),
              brightness: brightness,
              direction: direction,
              scale: scale,
            ),
          );
          await tester.pumpAndSettle();
          expect(tester.takeException(), isNull);
          final button = find.descendant(
            of: find.byType(AcademyActionButton),
            matching: find.byType(CupertinoButton),
          );
          expect(tester.getSize(button).height, greaterThanOrEqualTo(64));
          final value = tester.getRect(
            find.text('Очень длинное имя и фамилия'),
          );
          final label = tester.getRect(find.text('Имя участника'));
          // At 2x the value is below the label and retains directional end alignment.
          if (scale == 2) expect(value.top, greaterThan(label.bottom));
        });
      }
    }
  }

  testSemantics('single named action nodes and disabled/pending callbacks', (
    tester,
  ) async {
    var count = 0;
    void tap() => count++;
    await tester.pumpWidget(
      host(
        Column(
          children: [
            AcademyActionButton(
              title: 'Открыть',
              subtitle: 'Подробности',
              icon: AcademySymbols.info,
              onPressed: tap,
            ),
            AcademyActionButton(
              title: 'Загрузка',
              icon: AcademySymbols.info,
              onPressed: tap,
              pending: true,
            ),
            const AcademyActionButton(
              title: 'Выключено',
              icon: AcademySymbols.info,
            ),
            AcademyPillButton(
              label: 'Карта',
              icon: AcademySymbols.location,
              onPressed: tap,
            ),
            const AcademyPillButton(label: 'Закрыто'),
            AcademyTableHeader.action(
              title: 'Данные',
              action: 'Изменить',
              onPressed: tap,
            ),
            AcademyRow.action(
              title: 'Пусто',
              action: 'Добавить',
              onPressed: tap,
            ),
            AcademyRow.action(
              title: 'Отключено',
              action: 'Нельзя',
              enabled: false,
              onPressed: tap,
            ),
            AcademyValueRow(
              label: 'Заблокировано',
              value: '1042',
              readOnly: true,
              onPressed: tap,
            ),
          ],
        ),
      ),
    );
    await tester.pumpAndSettle();
    final actions = nodes(tester)
        .where((n) => n.getSemanticsData().hasAction(SemanticsAction.tap))
        .toList();
    expect(actions.map((n) => n.label).toList(), hasLength(4));
    for (final name in ['Открыть', 'Карта', 'Изменить', 'Добавить']) {
      expect(actions.where((n) => n.label.contains(name)).length, 1);
    }
    for (final name in [
      'Загрузка',
      'Выключено',
      'Закрыто',
      'Отключено',
      'Заблокировано',
    ]) {
      final node = nodes(tester).singleWhere((n) => n.label.contains(name));
      expect(node.getSemanticsData().hasAction(SemanticsAction.tap), isFalse);
    }
    await tester.tap(find.text('Загрузка'), warnIfMissed: false);
    await tester.tap(find.text('Закрыто'), warnIfMissed: false);
    await tester.tap(find.text('Нельзя'), warnIfMissed: false);
    await tester.tap(find.text('1042'));
    expect(count, 0);
    await tester.tap(find.text('Открыть'));
    await tester.tap(find.text('Карта'));
    await tester.tap(find.text('Изменить'));
    await tester.tap(find.text('Добавить'));
    expect(count, 4);
  });

  testWidgets('pill fill 36 with 44 target and tappable outer margin', (
    tester,
  ) async {
    var count = 0;
    await tester.pumpWidget(
      host(
        Align(
          child: AcademyPillButton(label: 'Карта', onPressed: () => count++),
        ),
      ),
    );
    final button = find.byType(CupertinoButton);
    expect(tester.getSize(button).height, 44);
    final fill = find.descendant(
      of: find.byType(AcademyPillButton),
      matching: find.byType(DecoratedBox),
    );
    expect(tester.getSize(fill.last).height, 36);
    final rect = tester.getRect(button);
    await tester.tapAt(Offset(rect.center.dx, rect.top + 1));
    expect(count, 1);
  });

  testSemantics('timeline announces input order, state and date', (
    tester,
  ) async {
    await tester.pumpWidget(
      host(
        const AcademyTimeline(
          items: [
            AcademyTimelineItem(
              title: 'Первый',
              date: '10 октября',
              state: AcademyTimelineState.completed,
            ),
            AcademyTimelineItem(
              title: 'Второй',
              date: '12 октября',
              state: AcademyTimelineState.current,
            ),
            AcademyTimelineItem(title: 'Третий', date: '22 октября'),
          ],
        ),
      ),
    );
    final items = nodes(tester).where((n) => n.label.contains('/3,')).toList();
    expect(items.map((n) => n.label.split(',').first), ['1/3', '2/3', '3/3']);
    expect(items.map((n) => n.value), ['Завершено', 'Текущий', 'Впереди']);
  });

  testWidgets('tone and named icon roles resolve the active palette', (
    tester,
  ) async {
    final colors = <Color>[];
    for (final brightness in Brightness.values) {
      await tester.pumpWidget(
        host(
          Builder(
            builder: (context) {
              colors.add(AcademyRowIcons.person.colorOf(context));
              expect(
                AcademyRowIcons.alert.colorOf(context),
                brightness == Brightness.dark
                    ? CupertinoColors.systemRed.darkColor
                    : CupertinoColors.systemRed.color,
              );
              return const AcademyRow(
                title: 'Удалить',
                icon: AcademySymbols.close,
                tone: AcademyTone.error,
              );
            },
          ),
          brightness: brightness,
        ),
      );
      final expected = academyTheme(brightness).colorScheme
          .toneForeground(AcademyTone.error);
      expect(tester.widget<Text>(find.text('Удалить')).style!.color, expected);
      final fill = tester.widget<Container>(
        find
            .descendant(
              of: find.byType(AcademyRow),
              matching: find.byType(Container),
            )
            .first,
      );
      expect((fill.decoration! as BoxDecoration).color, expected);
    }
    expect(colors[0], isNot(colors[1]));
  });
}
