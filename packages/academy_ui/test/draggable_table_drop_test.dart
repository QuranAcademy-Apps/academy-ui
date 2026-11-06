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

  testWidgets('a row dropped on the next row takes its place', (tester) async {
    await tester.pumpWidget(table());
    await dragFirstRow(tester, 1);
    expect((moves, destination), (1, 1));
  });

  testWidgets('a row dropped on the last row takes its place', (tester) async {
    await tester.pumpWidget(table());
    await dragFirstRow(tester, 2);
    expect((moves, destination), (1, 2));
  });

  testWidgets('a tall row swaps with a shorter neighbor', (tester) async {
    await tester.pumpWidget(
      academyHost(
        SizedBox(
          width: 320,
          child: AcademyDraggableTableSection<String>(
            sectionId: 'section',
            items: const ['tall', 'short'],
            itemId: (item) => item,
            onMove: (source, section, to) {
              moves++;
              destination = to;
            },
            rowBuilder: (context, item, accessory) => AcademyRow(
              title: item,
              minHeight: item == 'tall' ? 120 : 52,
              trailing: accessory,
            ),
          ),
        ),
      ),
    );
    final handle = tester.getCenter(find.byType(AcademyDragHandle).first);
    final short = tester.getCenter(find.byType(AcademyRow).last);
    final gesture = await tester.startGesture(handle);
    await tester.pump();
    await gesture.moveTo(short);
    await tester.pump();
    await gesture.up();
    await tester.pumpAndSettle();
    expect((moves, destination), (1, 1));
  });
}
