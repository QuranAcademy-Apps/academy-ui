import 'package:academy_ui/academy_ui.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/academy_test_host.dart';

void main() {
  group('AcademySegmentedControl.fitted', () {
    Widget fitted({double textScale = 1}) => academyHost(
      AcademySegmentedControl<int>.fitted(
        items: const [0, 1],
        value: 0,
        labelFor: (i) => 'Сегмент $i',
        onChanged: (_) {},
        width: 300,
      ),
      textScale: textScale,
    );

    testWidgets('segments reach 44pt around the smaller control', (
      tester,
    ) async {
      await tester.pumpWidget(fitted());
      for (final button in find.byType(CupertinoButton).evaluate()) {
        expect(
          (button.renderObject! as RenderBox).size.height,
          greaterThanOrEqualTo(44),
        );
      }
      expect(
        tester.getSize(find.byType(AcademySegmentedControl<int>).first).height,
        44,
      );
    });

    testWidgets('the control grows with large text', (tester) async {
      await tester.pumpWidget(fitted(textScale: 2));
      expect(tester.takeException(), isNull);
      final label = tester.getSize(find.text('Сегмент 0')).height;
      final track = tester.getSize(
        find
            .descendant(
              of: find.byType(AcademySegmentedControl<int>).first,
              matching: find.byType(DecoratedBox),
            )
            .first,
      );
      expect(track.height, greaterThanOrEqualTo(label));
    });
  });

  group('AcademySlidingSegments', () {
    Widget sliding({required ValueChanged<int> onChanged}) => academyHost(
      SizedBox(
        width: 240,
        child: AcademySlidingSegments<int>(
          items: const [1, 2, 3],
          selection: 2,
          onSelectionChanged: onChanged,
          backgroundColor: const Color(0xFFEEEEEE),
          selectedBackgroundColor: const Color(0xFFFFFFFF),
          foregroundColor: const Color(0xFF111111),
          selectedForegroundColor: const Color(0xFF0000FF),
          contentBuilder: (item, color) =>
              Text('$item', style: TextStyle(color: color)),
        ),
      ),
    );

    testWidgets('segments reach 44pt around the 32pt control', (tester) async {
      await tester.pumpWidget(sliding(onChanged: (_) {}));
      expect(
        tester.getSize(find.byType(AcademySlidingSegments<int>)).height,
        44,
      );
      for (final button in find.byType(CupertinoButton).evaluate()) {
        expect((button.renderObject! as RenderBox).size.height, 44);
      }
    });

    testWidgets('a tap near the edge of the target selects', (tester) async {
      int? picked;
      await tester.pumpWidget(sliding(onChanged: (v) => picked = v));
      final box = tester.getRect(find.byType(AcademySlidingSegments<int>));
      await tester.tapAt(Offset(box.right - 30, box.top + 2));
      expect(picked, 3);
    });

    testWidgets('the selected segment is announced', (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(sliding(onChanged: (_) {}));
      expect(
        tester.getSemantics(find.bySemanticsLabel('2')),
        isSemantics(isSelected: true, isButton: true),
      );
      expect(
        tester.getSemantics(find.bySemanticsLabel('3')),
        isSemantics(isSelected: false, isButton: true),
      );
      handle.dispose();
    });
  });
}
