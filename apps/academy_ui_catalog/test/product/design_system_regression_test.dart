// ignore_for_file: deprecated_member_use_from_same_package

import 'package:academy_ui/academy_ui.dart';
import 'package:academy_ui_catalog/product/product.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

Widget host(Widget child, {Locale locale = const Locale('ru')}) => AcademyApp(
  locale: locale,
  home: Center(child: child),
);

List<SemanticsNode> nodes(WidgetTester tester) {
  final result = <SemanticsNode>[];
  void visit(SemanticsNode node) {
    if (!node.isMergedIntoParent) result.add(node);
    node.visitChildren((child) {
      visit(child);
      return true;
    });
  }

  visit(
    tester.binding.renderViews.single.owner!.semanticsOwner!.rootSemanticsNode!,
  );
  return result;
}

void act(
  WidgetTester tester,
  SemanticsNode node,
  SemanticsAction action, [
  Object? arguments,
]) {
  tester.binding.performSemanticsAction(
    SemanticsActionEvent(
      nodeId: node.id,
      viewId: tester.view.viewId,
      type: action,
      arguments: arguments,
    ),
  );
}

void testSemantics(String name, Future<void> Function(WidgetTester) callback) {
  testWidgets(name, (tester) async {
    final handle = tester.ensureSemantics();
    try {
      await callback(tester);
    } finally {
      handle.dispose();
    }
  });
}

void main() {
  testWidgets(
    'completed guide uses onDone, falls back to onNext, and omits read-only CTA',
    (tester) async {
      var next = 0, done = 0;
      Future<void> pump({bool readOnly = false, VoidCallback? onDone}) =>
          tester.pumpWidget(
            host(
              SizedBox(
                width: 280,
                child: AcademyGuideStep(
                  title: 'Title',
                  description: 'Description',
                  step: 1,
                  total: 1,
                  completed: true,
                  readOnly: readOnly,
                  onNext: () => next++,
                  onDone: onDone,
                ),
              ),
            ),
          );
      await pump(onDone: () => done++);
      await tester.tap(find.text('Готово'));
      expect(done, 1);
      expect(next, 0);
      await pump();
      await tester.tap(find.text('Готово'));
      expect(next, 1);
      await pump(readOnly: true);
      expect(find.byType(AcademyButton), findsNothing);
    },
  );

  testSemantics('settings keeps tap and long press in one native action node', (
    tester,
  ) async {
    var taps = 0, holds = 0;
    await tester.pumpWidget(
      host(
        AcademySettingsSquareButton(
          icon: AcademySymbols.gear,
          label: 'Settings',
          onPressed: () => taps++,
          onLongPress: () => holds++,
        ),
      ),
    );
    final node = nodes(tester)
        .singleWhere((n) => n.getSemanticsData().label == 'Settings');
    act(tester, node, SemanticsAction.tap);
    act(tester, node, SemanticsAction.longPress);
    await tester.pumpAndSettle();
    expect(taps, 1);
    expect(holds, 1);
    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.sendKeyEvent(LogicalKeyboardKey.space);
    await tester.pumpAndSettle();
    expect(taps, 2);
  });
}
