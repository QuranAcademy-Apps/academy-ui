import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stupid_simple_sheet/stupid_simple_sheet.dart';

void main() {
  testWidgets('sheet background uses the Cupertino scaffold color',
      (tester) async {
    const background = Color(0xFF243647);
    await tester.pumpWidget(const CupertinoApp(
      theme: CupertinoThemeData(scaffoldBackgroundColor: background),
      home: SheetBackground(child: SizedBox(height: 100)),
    ));
    final box = tester.widget<DecoratedBox>(find.descendant(
      of: find.byType(SheetBackground),
      matching: find.byType(DecoratedBox),
    ));
    expect((box.decoration as ShapeDecoration).color, background);
    expect(tester.takeException(), isNull);
  });

  testWidgets('sheet has a Cupertino fallback without an ancestor theme',
      (tester) async {
    await tester.pumpWidget(const Directionality(
      textDirection: TextDirection.ltr,
      child: MediaQuery(
        data: MediaQueryData(size: Size(400, 800)),
        child: SheetBackground(child: SizedBox(height: 100)),
      ),
    ));
    expect(find.byType(DecoratedBox), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
