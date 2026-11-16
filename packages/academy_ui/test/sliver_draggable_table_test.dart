import 'package:academy_ui/academy_ui.dart';
import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/academy_test_host.dart';

void main() {
  final items = [for (var i = 0; i < 200; i++) 'Запись $i'];

  Widget table(void Function(int from, int to) onMove) => academyHost(
    SizedBox(
      width: 320,
      height: 600,
      child: CustomScrollView(
        slivers: [
          AcademySliverDraggableTableSection<String>(
            sectionId: 'section',
            items: items,
            itemId: (item) => item,
            onMove: (source, _, to) => onMove(source.index, to),
            rowBuilder: (context, item, accessory) =>
                AcademyRow(title: item, trailing: accessory),
          ),
        ],
      ),
    ),
  );

  testWidgets('builds only the visible rows', (tester) async {
    await tester.pumpWidget(table((_, _) {}));
    expect(find.text('Запись 0'), findsOneWidget);
    expect(find.text('Запись 199'), findsNothing);
    expect(find.byType(AcademyRow).evaluate().length, lessThan(30));
  });

  testWidgets('dragging by the handle reports the move', (tester) async {
    int? from, to;
    await tester.pumpWidget(
      table((f, t) {
        from = f;
        to = t;
      }),
    );
    final height = tester.getSize(find.byType(AcademyRow).first).height;
    final gesture = await tester.startGesture(
      tester.getCenter(find.byType(AcademyDragHandle).first),
    );
    await tester.pump();
    await gesture.moveBy(Offset(0, height * 2));
    await tester.pump();
    await gesture.up();
    await tester.pumpAndSettle();
    expect(from, 0);
    expect(to, isNotNull);
    expect(to, greaterThan(0));
  });
}
