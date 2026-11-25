import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:academy_ui/academy_ui.dart';

Future<void> _pump(WidgetTester tester, String text, {double height = 100}) =>
    tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: Align(
          alignment: Alignment.topLeft,
          child: SizedBox(
            width: 300,
            height: height,
            child: AcademyReflowFit(
              child: Text(
                text,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 20),
              ),
            ),
          ),
        ),
      ),
    );

Rect _drawn(WidgetTester tester) => Rect.fromPoints(
  tester.getTopLeft(find.byType(Text)),
  tester.getBottomRight(find.byType(Text)),
);

void main() {
  testWidgets('a block that fits stays at its own size', (tester) async {
    await _pump(tester, 'short');
    final box = tester.getSize(find.byType(Text));
    expect(_drawn(tester).size, box);
  });

  testWidgets('a tall block is re-wrapped: fits the height, fills the width', (
    tester,
  ) async {
    await _pump(tester, 'word ' * 120);
    final drawn = _drawn(tester);
    expect(drawn.height, lessThanOrEqualTo(100.01));
    expect(drawn.width, greaterThan(300 * .9));
    expect(drawn.width, lessThanOrEqualTo(300.01));
    // The block is smaller than the real one: it was scaled.
    expect(
      _drawn(tester).width,
      lessThan(tester.getSize(find.byType(Text)).width),
    );
  });

  testWidgets('the drawn block is centered in the room', (tester) async {
    await _pump(tester, 'word ' * 120);
    final drawn = _drawn(tester);
    expect(drawn.center.dy, closeTo(50, 6));
    expect(drawn.center.dx, closeTo(150, 1));
  });
}
