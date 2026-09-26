import 'package:academy_ui/academy_ui.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';

import 'dart:ui' show SemanticsAction, SemanticsActionEvent;

void main() {
  for (final direction in TextDirection.values) {
    testWidgets('accessory menu matches the label outer inset in $direction', (
      tester,
    ) async {
      await tester.pumpWidget(
        AcademyApp(
          home: Directionality(
            textDirection: direction,
            child: Center(
              child: SizedBox(
                width: 320,
                child: AcademyTableBody(
                  rows: [
                    AcademyMenuRow(
                      label: 'Theme',
                      value: 'Light',
                      activation: AcademyMenuActivation.accessory,
                      items: const [],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      final body = tester.getRect(find.byType(AcademyTableBody));
      final label = tester.getRect(find.text('Theme'));
      final chevron = tester.getRect(find.byType(AcademySfIcon));
      if (direction == TextDirection.ltr) {
        expect(label.left - body.left, closeTo(16, .1));
        expect(body.right - chevron.right, closeTo(16, .1));
      } else {
        expect(body.right - label.right, closeTo(16, .1));
        expect(chevron.left - body.left, closeTo(16, .1));
      }
    });
  }
  for (final activation in AcademyMenuActivation.values) {
    testWidgets('menu activation $activation isolates the correct target', (
      tester,
    ) async {
      final semantics = tester.ensureSemantics();
      var selections = 0;
      await tester.pumpWidget(
        AcademyApp(
          home: Center(
            child: SizedBox(
              width: 320,
              child: AcademyGroupedTable(
                sections: [
                  AcademyTableSection(
                    rows: [
                      AcademyMenuRow(
                        label: 'Theme',
                        value: 'Light',
                        activation: activation,
                        items: [
                          AcademyMenuItem(
                            title: 'System',
                            checked: true,
                            onPressed: () => selections++,
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Theme'));
      await tester.pumpAndSettle();
      expect(
        find.text('System'),
        activation == AcademyMenuActivation.row ? findsOneWidget : findsNothing,
      );
      if (activation == AcademyMenuActivation.accessory) {
        final node = tester.getSemantics(find.bySemanticsLabel('Theme: Light'));
        tester.binding.performSemanticsAction(
          SemanticsActionEvent(
            nodeId: node.id,
            viewId: tester.view.viewId,
            type: SemanticsAction.tap,
          ),
        );
        await tester.pumpAndSettle();
      }
      await tester.tap(find.text('System'));
      await tester.pumpAndSettle();
      expect(selections, 1);
      expect(find.text('System'), findsNothing);
      semantics.dispose();
    });
  }
  testWidgets(
    'drag handle reorders within a section and moves between sections',
    (tester) async {
      final groups = <String, List<String>>{
        'a': ['A', 'B'],
        'b': ['C'],
      };
      var moves = 0;
      await tester.pumpWidget(
        AcademyApp(
          home: Center(
            child: SizedBox(
              width: 320,
              child: StatefulBuilder(
                builder: (context, setState) => Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    for (final id in groups.keys)
                      AcademyDraggableTableSection<String>(
                        sectionId: id,
                        items: groups[id]!,
                        itemId: (item) => item,
                        rowBuilder: (_, item, handle) =>
                            AcademyRow(title: item, trailing: handle),
                        onMove: (source, destination, index) => setState(() {
                          groups[source.sectionId]!.remove(source.item);
                          groups[destination]!.insert(index, source.item);
                          moves++;
                        }),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      final targets = find.byType(DragTarget<AcademyTableDragData<String>>);
      Future<void> drag(int handleIndex, int targetIndex) async {
        final destination = tester.getCenter(targets.at(targetIndex));
        final gesture = await tester.startGesture(
          tester.getCenter(find.byType(AcademyDragHandle).at(handleIndex)),
        );
        await gesture.moveBy(const Offset(0, 12));
        await tester.pump();
        await gesture.moveTo(destination);
        await tester.pump(const Duration(milliseconds: 100));
        await gesture.up();
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
      }

      await drag(0, 2);
      expect(groups['a'], ['B', 'A']);
      await drag(0, 3);
      expect(groups['a'], ['A']);
      expect(groups['b'], ['B', 'C']);
      expect(moves, 2);
    },
  );
  testWidgets('section hides empty rows and supports custom header/footer', (
    tester,
  ) async {
    await tester.pumpWidget(
      const AcademyApp(
        home: Center(
          child: AcademyGroupedTable(
            sections: [
              AcademyTableSection(title: 'Hidden', rows: []),
              AcademyTableSection(
                header: Text('Custom header'),
                footerWidget: Text('Custom footer'),
                rows: [AcademyRow(title: 'Row')],
              ),
            ],
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Hidden'), findsNothing);
    expect(find.text('Custom header'), findsOneWidget);
    expect(find.text('Custom footer'), findsOneWidget);
  });
}
