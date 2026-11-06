import 'package:academy_ui/academy_ui.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/academy_test_host.dart';

void main() {
  late int moves;
  int? destination;
  late int builds;

  setUp(() {
    moves = 0;
    destination = null;
    builds = 0;
  });

  Widget table() => academyHost(
    SizedBox(
      width: 320,
      child: AcademyDraggableTableSection<String>(
        sectionId: 'section',
        items: const ['a', 'b', 'c'],
        itemId: (item) => item,
        onMove: (source, section, to) {
          moves++;
          destination = to;
        },
        rowBuilder: (context, item, accessory) {
          builds++;
          return AcademyRow(title: item, trailing: accessory);
        },
      ),
    ),
  );

  Future<void> dragFirstRow(WidgetTester tester, double rows) async {
    final height = tester.getSize(find.byType(AcademyRow).first).height;
    final gesture = await tester.startGesture(
      tester.getCenter(find.byType(AcademyDragHandle).first),
    );
    await tester.pump();
    await gesture.moveBy(Offset(0, height * rows));
    await tester.pump();
    await gesture.up();
    await tester.pumpAndSettle();
  }

  testWidgets('rows at rest build once, without a hidden preview', (
    tester,
  ) async {
    await tester.pumpWidget(table());
    expect(builds, 3);
  });

  testWidgets('dropping on the lower half of the next row swaps them', (
    tester,
  ) async {
    await tester.pumpWidget(table());
    await dragFirstRow(tester, 1.3);
    expect((moves, destination), (1, 1));
  });

  testWidgets('dropping on the upper half of the next row changes nothing', (
    tester,
  ) async {
    await tester.pumpWidget(table());
    await dragFirstRow(tester, .7);
    expect(moves, 0);
  });

  testWidgets('dropping on the lower half of the last row moves to the end', (
    tester,
  ) async {
    await tester.pumpWidget(table());
    await dragFirstRow(tester, 2.3);
    expect((moves, destination), (1, 2));
  });
}
