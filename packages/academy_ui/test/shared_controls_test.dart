import 'package:academy_ui/academy_ui.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _app(Widget child, {TextDirection direction = TextDirection.ltr}) =>
    CupertinoApp(
      localizationsDelegates: const [
        AcademyLocalizations.delegate,
        DefaultCupertinoLocalizations.delegate,
        DefaultWidgetsLocalizations.delegate,
      ],
      home: Directionality(
        textDirection: direction,
        child: AcademyTheme(
          data: academyTheme(Brightness.light),
          child: Align(alignment: Alignment.topLeft, child: child),
        ),
      ),
    );

void main() {
  group('AcademyStepper.actions', () {
    for (final direction in TextDirection.values) {
      testWidgets('minus and plus keep their hit areas in $direction', (
        tester,
      ) async {
        var decreased = 0, increased = 0;
        await tester.pumpWidget(
          _app(
            AcademyStepper.actions(
              onDecrease: () => decreased++,
              onIncrease: () => increased++,
            ),
            direction: direction,
          ),
        );
        final origin = tester.getTopLeft(find.byType(AcademyStepper));
        // The symbols are drawn minus-left / plus-right in both directions.
        await tester.tapAt(origin + const Offset(41.5, 22));
        expect((decreased, increased), (1, 0));
        await tester.tapAt(origin + const Offset(88.5, 22));
        expect((decreased, increased), (1, 1));
      });
    }

    testWidgets('a null callback disables only its half', (tester) async {
      var increased = 0;
      await tester.pumpWidget(
        _app(
          AcademyStepper.actions(
            onDecrease: null,
            onIncrease: () => increased++,
          ),
        ),
      );
      final origin = tester.getTopLeft(find.byType(AcademyStepper));
      await tester.tapAt(origin + const Offset(41.5, 22));
      expect(increased, 0);
      await tester.tapAt(origin + const Offset(88.5, 22));
      expect(increased, 1);
    });

    testWidgets('is a 112 x 44 hit area around a 94 x 32 pill', (tester) async {
      await tester.pumpWidget(
        _app(AcademyStepper.actions(onDecrease: () {}, onIncrease: () {})),
      );
      expect(tester.getSize(find.byType(AcademyStepper)), const Size(112, 44));
      expect(
        tester.getSize(
          find.byKey(const ValueKey('academy-action-stepper-track')),
        ),
        const Size(94, 32),
      );
    });
  });

  group('AcademySlidingSegments', () {
    Widget segments({
      required int selection,
      required ValueChanged<int> onChanged,
    }) => SizedBox(
      width: 240,
      child: AcademySlidingSegments<int>(
        items: const [1, 2, 3],
        selection: selection,
        onSelectionChanged: onChanged,
        backgroundColor: const Color(0xFFEEEEEE),
        selectedBackgroundColor: const Color(0xFFFFFFFF),
        foregroundColor: const Color(0xFF111111),
        selectedForegroundColor: const Color(0xFF0000FF),
        contentBuilder: (item, color) =>
            Text('$item', style: TextStyle(color: color)),
      ),
    );

    for (final direction in TextDirection.values) {
      testWidgets('selecting a segment reports it in $direction', (
        tester,
      ) async {
        int? picked;
        await tester.pumpWidget(
          _app(
            segments(selection: 1, onChanged: (v) => picked = v),
            direction: direction,
          ),
        );
        expect(tester.takeException(), isNull);
        await tester.tap(find.text('3'));
        expect(picked, 3);
      });
    }

    testWidgets('the selected segment gets the selected foreground', (
      tester,
    ) async {
      await tester.pumpWidget(_app(segments(selection: 2, onChanged: (_) {})));
      Color colorOf(String text) =>
          tester.widget<Text>(find.text(text)).style!.color!;
      expect(colorOf('2'), const Color(0xFF0000FF));
      expect(colorOf('1'), const Color(0xFF111111));
      expect(colorOf('3'), const Color(0xFF111111));
    });
  });

  group('AcademyDotStripScroller', () {
    testWidgets('a vertical drag reports quantized progress in 0..1', (
      tester,
    ) async {
      final reported = <double>[];
      await tester.pumpWidget(
        _app(
          SizedBox(
            width: AcademyDotStripScroller.stripWidth,
            height: 300,
            child: AcademyDotStripScroller(steps: 20, onProgress: reported.add),
          ),
        ),
      );
      await tester.drag(
        find.byType(AcademyDotStripScroller),
        const Offset(0, 240),
      );
      expect(reported, isNotEmpty);
      expect(reported.every((v) => v >= 0 && v <= 1), isTrue);
      for (var i = 1; i < reported.length; i++) {
        expect(
          reported[i],
          isNot(reported[i - 1]),
          reason: 'only a step change is reported',
        );
      }
      expect(reported.last, greaterThan(reported.first));
    });

    testWidgets('the gesture zone can be wider than the visible strip', (
      tester,
    ) async {
      await tester.pumpWidget(
        _app(
          SizedBox(
            width: 80,
            height: 200,
            child: AcademyDotStripScroller(
              steps: 10,
              gestureWidth: 80,
              onProgress: (_) {},
            ),
          ),
        ),
      );
      expect(tester.getSize(find.byType(AcademyDotStripScroller)).width, 80);
    });
  });

  group('AcademyChevron', () {
    double flip(WidgetTester tester) => tester
        .widget<Transform>(
          find.descendant(
            of: find.byType(AcademyChevron),
            matching: find.byType(Transform),
          ),
        )
        .transform
        .getRow(0)
        .x;

    testWidgets('mirrors in RTL only', (tester) async {
      const chevron = AcademyChevron.right(color: Color(0xFF000000));
      await tester.pumpWidget(_app(chevron));
      expect(flip(tester), 1);
      await tester.pumpWidget(_app(chevron, direction: TextDirection.rtl));
      expect(flip(tester), -1);
    });

    testWidgets('has the default 7 x 12 size', (tester) async {
      await tester.pumpWidget(
        _app(const AcademyChevron.left(color: Color(0xFF000000))),
      );
      expect(tester.getSize(find.byType(AcademyChevron)), const Size(7, 12));
    });
  });
}
