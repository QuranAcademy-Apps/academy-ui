import 'package:academy_ui/academy_ui.dart';
import 'package:academy_ui_catalog/product/product.dart';
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
}
