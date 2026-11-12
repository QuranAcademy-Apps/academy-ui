import 'dart:async';

import 'package:academy_ui/academy_ui.dart';
import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

Widget host(Widget child, {Locale locale = const Locale('en')}) => AcademyApp(
  locale: locale,
  home: CupertinoPageScaffold(
    child: Center(child: SizedBox(width: 320, child: child)),
  ),
);

void main() {
  testWidgets(
    'text form validates, resets and preserves external controllers',
    (tester) async {
      final key = GlobalKey<FormState>();
      final first = TextEditingController(text: 'Initial');
      final second = TextEditingController(text: 'Second');
      final revision = ValueNotifier(false);
      addTearDown(first.dispose);
      addTearDown(second.dispose);
      addTearDown(revision.dispose);
      await tester.pumpWidget(
        host(
          ValueListenableBuilder<bool>(
            valueListenable: revision,
            builder: (_, swapped, _) => Form(
              key: key,
              child: AcademyTextFormField(
                controller: swapped ? second : first,
                label: 'Name',
                validator: (v) => v == null || v.isEmpty ? 'Required' : null,
              ),
            ),
          ),
        ),
      );
      expect(key.currentState!.validate(), isTrue);
      await tester.enterText(find.byType(CupertinoTextField), '');
      expect(key.currentState!.validate(), isFalse);
      await tester.pump();
      expect(find.text('Required'), findsOneWidget);
      key.currentState!.reset();
      await tester.pump();
      expect(first.text, 'Initial');
      expect(find.text('Required'), findsNothing);
      revision.value = true;
      await tester.pump();
      expect(key.currentState!.validate(), isTrue);
      first.text = 'Detached';
      await tester.pump();
      expect(find.text('Second'), findsOneWidget);
      await tester.pumpWidget(const SizedBox());
      second.text = 'Still alive';
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('controlled form rejects edits without mutating parent value', (
    tester,
  ) async {
    final form = GlobalKey<FormState>();
    final value = ValueNotifier('A');
    addTearDown(value.dispose);
    final requests = <String>[];
    var changes = 0;
    await tester.pumpWidget(
      host(
        ValueListenableBuilder<String>(
          valueListenable: value,
          builder: (_, v, _) => Form(
            key: form,
            onChanged: () => changes++,
            child: AcademyFormField<String>(
              value: v,
              onChanged: requests.add,
              builder: (field, change) => CupertinoButton(
                onPressed: () => change('B'),
                child: Text(field.value!),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('A'));
    await tester.pump();
    expect(requests, ['B']);
    expect(find.text('A'), findsOneWidget);
    final previous = changes;
    value.value = 'C';
    await tester.pump();
    expect(find.text('C'), findsOneWidget);
    expect(changes, previous);
    form.currentState!.reset();
    await tester.pump();
    expect(requests.last, 'A');
    expect(find.text('C'), findsOneWidget);
  });

  testWidgets('tappable supports keyboard and blocks disabled actions', (
    tester,
  ) async {
    final focus = FocusNode();
    addTearDown(focus.dispose);
    final enabled = ValueNotifier(true);
    addTearDown(enabled.dispose);
    var presses = 0;
    await tester.pumpWidget(
      host(
        ValueListenableBuilder<bool>(
          valueListenable: enabled,
          builder: (_, v, _) => AcademyTappable(
            focusNode: focus,
            onPressed: v ? () => presses++ : null,
            builder: (_, _) => const Text('Action'),
          ),
        ),
      ),
    );
    focus.requestFocus();
    await tester.pump();
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.sendKeyEvent(LogicalKeyboardKey.space);
    expect(presses, 2);
    enabled.value = false;
    await tester.pump();
    await tester.tap(find.text('Action'));
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    expect(presses, 2);
    await tester.pumpWidget(const SizedBox());
    focus.addListener(() {});
  });

  testWidgets('popover flips near edge, closes with Escape and follows theme', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(400, 600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final focus = FocusNode();
    addTearDown(focus.dispose);
    final dark = ValueNotifier(false);
    addTearDown(dark.dispose);
    await tester.pumpWidget(
      AcademyApp(
        locale: const Locale('en'),
        home: ValueListenableBuilder<bool>(
          valueListenable: dark,
          builder: (_, v, _) => AcademyTheme(
            data: academyTheme(v ? Brightness.dark : Brightness.light),
            child: Align(
              alignment: Alignment.bottomRight,
              child: AcademyPopover(
                width: 240,
                builder: (context, control) => AcademyTappable(
                  focusNode: focus,
                  onPressed: control.toggle,
                  builder: (_, _) => const Text('Open'),
                ),
                contentBuilder: (context, close) => SizedBox(
                  height: 120,
                  child: CupertinoButton(
                    onPressed: close,
                    child: Text(AcademyTheme.of(context).brightness.name),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
    focus.requestFocus();
    await tester.pump();
    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();
    expect(find.text('light'), findsOneWidget);
    final panel = tester.getRect(find.text('light'));
    expect(panel.bottom, lessThan(556));
    expect(panel.right, lessThanOrEqualTo(400));
    dark.value = true;
    await tester.pump();
    expect(find.text('dark'), findsOneWidget);
    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await tester.pumpAndSettle();
    expect(find.text('dark'), findsNothing);
    expect(focus.hasFocus, isTrue);
  });

  const options = [
    AcademySelectOption(value: 'a', label: 'Alpha'),
    AcademySelectOption(value: 'b', label: 'Beta'),
    AcademySelectOption(value: 'x', label: 'Disabled option', enabled: false),
  ];
  testWidgets('select searches and commits only enabled options', (
    tester,
  ) async {
    String? selected;
    await tester.pumpWidget(
      host(
        StatefulBuilder(
          builder: (_, update) => AcademySelect<String>(
            label: 'Language',
            value: selected,
            options: options,
            searchable: true,
            presentation: AcademySelectPresentation.popover,
            onChanged: (v) => update(() => selected = v),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Choose'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Disabled option'));
    expect(selected, isNull);
    await tester.enterText(find.byType(CupertinoTextField), 'Bet');
    await tester.pumpAndSettle();
    expect(find.text('Alpha'), findsNothing);
    await tester.tap(find.text('Beta'));
    await tester.pumpAndSettle();
    expect(selected, 'b');
    expect(find.byType(CupertinoTextField), findsNothing);
  });

  testWidgets(
    'multi-select sheet cancels draft and confirms fresh immutable set',
    (tester) async {
      final nav = GlobalKey<NavigatorState>();
      Set<String> selected = {'a'};
      var changes = 0;
      await tester.pumpWidget(
        AcademyApp(
          locale: const Locale('en'),
          navigatorKey: nav,
          home: Center(
            child: SizedBox(
              width: 320,
              child: StatefulBuilder(
                builder: (_, update) => AcademyMultiSelect<String>(
                  label: 'Topics',
                  values: selected,
                  options: options,
                  searchable: false,
                  onChanged: (v) => update(() {
                    selected = v;
                    changes++;
                  }),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('1 selected'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Beta'));
      await tester.pumpAndSettle();
      expect(selected, {'a'});
      expect(changes, 0);
      nav.currentState!.pop();
      await tester.pumpAndSettle();
      expect(selected, {'a'});
      await tester.tap(find.text('1 selected'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Beta'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Done'));
      await tester.pumpAndSettle();
      expect(selected, {'a', 'b'});
      expect(changes, 1);
      expect(() => selected.add('c'), throwsUnsupportedError);
    },
  );

  testWidgets(
    'autocomplete ignores stale results and survives disposal during load',
    (tester) async {
      final pending = <String, Completer<List<AcademySelectOption<String>>>>{};
      Future<List<AcademySelectOption<String>>> load(String q) =>
          (pending[q] = Completer()).future;
      final controller = TextEditingController();
      addTearDown(controller.dispose);
      await tester.pumpWidget(
        host(
          AcademyAutocomplete<String>(
            label: 'Query',
            controller: controller,
            loader: load,
          ),
        ),
      );
      await tester.enterText(find.byType(CupertinoTextField), 'old');
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 250));
      await tester.enterText(find.byType(CupertinoTextField), 'new');
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 250));
      pending['new']!.complete([
        const AcademySelectOption(value: 'new', label: 'New result'),
      ]);
      await tester.pump();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      expect(find.text('New result'), findsOneWidget);
      pending['old']!.complete([
        const AcademySelectOption(value: 'old', label: 'Old result'),
      ]);
      await tester.pump();
      expect(find.text('Old result'), findsNothing);
      await tester.tap(find.text('New result'));
      await tester.pump();
      await tester.pump();
      expect(controller.text, 'New result');
      expect(find.byType(CupertinoActivityIndicator), findsNothing);
      await tester.enterText(find.byType(CupertinoTextField), 'late');
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 250));
      await tester.pumpWidget(const SizedBox());
      pending['late']!.completeError(StateError('Late failure'));
      await tester.pump();
      expect(tester.takeException(), isNull);
      controller.text = 'Alive';
    },
  );

  for (final locale in [const Locale('en'), const Locale('ar')]) {
    testWidgets('calendar bounds, RTL and large text in $locale', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(320, 800);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      DateTime? value = DateTime(2026, 10, 2);
      await tester.pumpWidget(
        host(
          Builder(
            builder: (context) => MediaQuery(
              data: MediaQuery.of(context)
                  .copyWith(textScaler: const TextScaler.linear(2)),
              child: StatefulBuilder(
                builder: (_, update) => AcademyCalendar(
                  value: value,
                  firstDate: DateTime(2026, 10, 2),
                  lastDate: DateTime(2026, 10, 20),
                  onChanged: (v) => update(() => value = v),
                ),
              ),
            ),
          ),
          locale: locale,
        ),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      final day = tester
          .widgetList<AcademyTappable>(find.byType(AcademyTappable))
          .first;
      expect(day.onPressed, isNull); // October 1 is below the bound.
      expect(
        Directionality.of(tester.element(find.byType(AcademyCalendar))),
        locale.languageCode == 'ar' ? TextDirection.rtl : TextDirection.ltr,
      );
    });
  }

  testWidgets('date dialog commits only on Done', (tester) async {
    final nav = GlobalKey<NavigatorState>();
    DateTime? value = DateTime(2026, 10, 2);
    await tester.pumpWidget(
      AcademyApp(
        locale: const Locale('en'),
        navigatorKey: nav,
        home: Center(
          child: AcademyDateInput(
            label: 'Date',
            value: value,
            onChanged: (v) => value = v,
          ),
        ),
      ),
    );
    await tester.tap(find.byType(AcademyPickerInput));
    await tester.pumpAndSettle();
    tester
        .widget<CupertinoDatePicker>(find.byType(CupertinoDatePicker))
        .onDateTimeChanged(DateTime(2026, 11, 3));
    nav.currentState!.pop();
    await tester.pumpAndSettle();
    expect(value, DateTime(2026, 10, 2));
    await tester.tap(find.byType(AcademyPickerInput));
    await tester.pumpAndSettle();
    tester
        .widget<CupertinoDatePicker>(find.byType(CupertinoDatePicker))
        .onDateTimeChanged(DateTime(2026, 11, 3));
    await tester.tap(find.text('Done'));
    await tester.pumpAndSettle();
    expect(value, DateTime(2026, 11, 3));
  });

  testWidgets('tooltip timers are cancelled on removal', (tester) async {
    await tester.pumpWidget(
      host(const AcademyTooltip(message: 'Help', child: Text('Hold'))),
    );
    await tester.longPress(find.text('Hold'));
    await tester.pump();
    expect(find.text('Help'), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(seconds: 5));
    expect(tester.takeException(), isNull);
  });

  testWidgets('remote selections keep labels and removable chips', (
    tester,
  ) async {
    var values = <int>{12, 24};
    await tester.pumpWidget(
      host(
        StatefulBuilder(
          builder: (_, update) => AcademyMultiSelect<int>(
            label: 'Remote',
            values: values,
            options: const [],
            labelFor: (id) => 'Item $id',
            onChanged: (next) => update(() => values = next),
          ),
        ),
      ),
    );
    expect(find.text('Item 12'), findsOneWidget);
    await tester.tap(find.text('Item 12'));
    await tester.pump();
    expect(values, {24});
    expect(find.text('Item 24'), findsOneWidget);
    expect(find.text('Item 12'), findsNothing);
  });

  testWidgets('range cannot include disabled interior days', (tester) async {
    AcademyDateRange? range;
    await tester.pumpWidget(
      host(
        AcademyRangeCalendar(
          value: null,
          firstDate: DateTime(2026, 10, 1),
          lastDate: DateTime(2026, 10, 31),
          selectableDayPredicate: (day) => day.day != 5,
          onChanged: (value) => range = value,
        ),
      ),
    );
    await tester.tap(find.text('2'));
    await tester.pump();
    await tester.tap(find.text('7'));
    await tester.pump();
    expect(range, isNull);
    await tester.tap(find.text('9'));
    await tester.pump();
    expect(
      range,
      AcademyDateRange(DateTime(2026, 10, 7), DateTime(2026, 10, 9)),
    );
  });

  testWidgets('time dialog cancels and commits a date-free value', (
    tester,
  ) async {
    final nav = GlobalKey<NavigatorState>();
    AcademyTime? value = const AcademyTime(9, 30);
    await tester.pumpWidget(
      AcademyApp(
        locale: const Locale('en'),
        navigatorKey: nav,
        home: Center(
          child: AcademyTimeField(
            label: 'Time',
            value: value,
            onChanged: (next) => value = next,
          ),
        ),
      ),
    );
    await tester.tap(find.byType(AcademyPickerInput));
    await tester.pumpAndSettle();
    tester
        .widget<CupertinoDatePicker>(find.byType(CupertinoDatePicker))
        .onDateTimeChanged(DateTime(2000, 1, 1, 18, 45));
    nav.currentState!.pop();
    await tester.pumpAndSettle();
    expect(value, const AcademyTime(9, 30));
    await tester.tap(find.byType(AcademyPickerInput));
    await tester.pumpAndSettle();
    tester
        .widget<CupertinoDatePicker>(find.byType(CupertinoDatePicker))
        .onDateTimeChanged(DateTime(2000, 1, 1, 18, 45));
    await tester.tap(find.text('Done'));
    await tester.pumpAndSettle();
    expect(value, const AcademyTime(18, 45));
  });

  testWidgets('autocomplete selects suggestions with the keyboard', (
    tester,
  ) async {
    String? selected;
    await tester.pumpWidget(
      host(
        AcademyAutocomplete<String>(
          label: 'Search',
          options: options,
          onSelected: (value) => selected = value,
        ),
      ),
    );
    await tester.enterText(find.byType(CupertinoTextField), 'Bet');
    await tester.pumpAndSettle();
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
    await tester.pumpAndSettle();
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pumpAndSettle();
    expect(selected, 'b');
    expect(
      tester
          .widget<CupertinoTextField>(find.byType(CupertinoTextField))
          .controller!
          .text,
      'Beta',
    );
  });
}
