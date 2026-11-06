import 'package:academy_ui/academy_ui.dart';
import 'package:academy_ui/src/widgets/select/academy_option_results.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/academy_test_host.dart';

void main() {
  group('AcademyPicker', () {
    testWidgets('a parent rebuild during a drag does not snap the wheel back', (
      tester,
    ) async {
      late StateSetter rebuild;
      await tester.pumpWidget(
        academyHost(
          StatefulBuilder(
            builder: (context, setState) {
              rebuild = setState;
              return AcademyPicker<int>(
                items: List.generate(20, (i) => i),
                value: 3,
                labelFor: (i) => '$i',
                onChanged: (_) {},
                changeReportingBehavior: ChangeReportingBehavior.onScrollEnd,
              );
            },
          ),
        ),
      );
      final controller = tester
          .widget<CupertinoPicker>(find.byType(CupertinoPicker))
          .scrollController!;
      expect(controller.selectedItem, 3);

      final gesture = await tester.startGesture(
        tester.getCenter(find.byType(CupertinoPicker)),
      );
      await gesture.moveBy(const Offset(0, -150));
      await tester.pump();
      final dragged = controller.selectedItem;
      expect(dragged, greaterThan(3));

      rebuild(() {});
      await tester.pump();
      await tester.pump();
      expect(controller.selectedItem, dragged);

      // The owner kept its value, so the wheel returns once the scroll ends.
      await gesture.up();
      await tester.pumpAndSettle();
      expect(controller.selectedItem, 3);
    });
  });

  group('AcademyOptionResults', () {
    testWidgets('a new query shows loading, a rebuild refreshes in place', (
      tester,
    ) async {
      var calls = 0;
      var query = '';
      late StateSetter rebuild;
      await tester.pumpWidget(
        academyHost(
          StatefulBuilder(
            builder: (context, setState) {
              rebuild = setState;
              return SizedBox(
                width: 320,
                height: 300,
                child: AcademyOptionResults<String>(
                  query: query,
                  options: const [],
                  onSelected: (_) {},
                  loader: (q) {
                    calls++;
                    return [AcademySelectOption(value: q, label: 'Result $q')];
                  },
                ),
              );
            },
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 250));
      await tester.pump();
      expect(calls, 1);
      expect(find.text('Result '), findsOneWidget);

      rebuild(() {});
      await tester.pump();
      expect(find.byType(CupertinoActivityIndicator), findsNothing);
      expect(find.text('Result '), findsOneWidget);
      await tester.pump(const Duration(milliseconds: 250));
      await tester.pump();
      expect(calls, 2);
      expect(find.text('Result '), findsOneWidget);

      rebuild(() => query = 'x');
      await tester.pump();
      expect(find.byType(CupertinoActivityIndicator), findsOneWidget);
      await tester.pump(const Duration(milliseconds: 250));
      await tester.pump();
      expect(calls, 3);
      expect(find.text('Result x'), findsOneWidget);
    });

    testWidgets('a stable loader does not run again on a rebuild', (
      tester,
    ) async {
      var calls = 0;
      List<AcademySelectOption<String>> load(String q) {
        calls++;
        return [AcademySelectOption(value: q, label: 'Result')];
      }

      late StateSetter rebuild;
      await tester.pumpWidget(
        academyHost(
          StatefulBuilder(
            builder: (context, setState) {
              rebuild = setState;
              return SizedBox(
                width: 320,
                height: 300,
                child: AcademyOptionResults<String>(
                  query: '',
                  options: const [],
                  onSelected: (_) {},
                  loader: load,
                ),
              );
            },
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 250));
      await tester.pump();
      rebuild(() {});
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 250));
      await tester.pump();
      expect(calls, 1);
    });

    testWidgets('a loader over a new filter replaces the stale results', (
      tester,
    ) async {
      var category = 'a';
      late StateSetter rebuild;
      await tester.pumpWidget(
        academyHost(
          StatefulBuilder(
            builder: (context, setState) {
              rebuild = setState;
              final current = category;
              return SizedBox(
                width: 320,
                height: 300,
                child: AcademyOptionResults<String>(
                  query: '',
                  options: const [],
                  onSelected: (_) {},
                  loader: (_) => [
                    AcademySelectOption(value: current, label: current),
                  ],
                ),
              );
            },
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 250));
      await tester.pump();
      expect(find.text('a'), findsOneWidget);

      rebuild(() => category = 'b');
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 250));
      await tester.pump();
      expect(find.text('a'), findsNothing);
      expect(find.text('b'), findsOneWidget);
    });
  });

  group('AcademyRangeCalendar', () {
    Finder day(int number) => find.text('$number');

    testWidgets('an inline predicate keeps an unfinished range', (
      tester,
    ) async {
      AcademyDateRange? picked;
      late StateSetter rebuild;
      await tester.pumpWidget(
        academyHost(
          StatefulBuilder(
            builder: (context, setState) {
              rebuild = setState;
              return SizedBox(
                width: 340,
                child: AcademyRangeCalendar(
                  value: null,
                  onChanged: (range) => picked = range,
                  selectableDayPredicate: (_) => true,
                ),
              );
            },
          ),
        ),
      );
      await tester.tap(day(15));
      await tester.pump();
      rebuild(() {});
      await tester.pump();
      await tester.tap(day(20));
      await tester.pump();
      expect(picked?.start.day, 15);
      expect(picked?.end.day, 20);
    });

    testWidgets('a start that stops being selectable ends the gesture', (
      tester,
    ) async {
      AcademyDateRange? picked;
      var allowed = true;
      late StateSetter rebuild;
      await tester.pumpWidget(
        academyHost(
          StatefulBuilder(
            builder: (context, setState) {
              rebuild = setState;
              return SizedBox(
                width: 340,
                child: AcademyRangeCalendar(
                  value: null,
                  onChanged: (range) => picked = range,
                  selectableDayPredicate: (date) => allowed || date.day != 15,
                ),
              );
            },
          ),
        ),
      );
      await tester.tap(day(15));
      await tester.pump();
      rebuild(() => allowed = false);
      await tester.pump();
      await tester.tap(day(20));
      await tester.pump();
      // 20 is a new start, not the end of a range from 15.
      expect(picked, isNull);
    });
  });

  group('AcademyCounterButton', () {
    testWidgets('a completed counter still takes a long press', (tester) async {
      var resets = 0;
      await tester.pumpWidget(
        academyHost(
          AcademyCounterButton(
            count: 3,
            total: 3,
            label: 'Счётчик',
            onLongPress: () => resets++,
          ),
        ),
      );
      await tester.longPress(find.byType(AcademyCounterButton));
      await tester.pumpAndSettle();
      expect(resets, 1);
    });

    testWidgets('without callbacks it stays disabled', (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(
        academyHost(
          const AcademyCounterButton(count: 1, total: 3, label: 'Счётчик'),
        ),
      );
      expect(
        tester.getSemantics(find.bySemanticsLabel('Счётчик')),
        isSemantics(isEnabled: false, hasEnabledState: true),
      );
      handle.dispose();
    });
  });
}
