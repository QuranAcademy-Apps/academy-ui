import 'package:academy_ui/academy_ui.dart';
import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('A chevron without turns carries no implicit animation', (
    tester,
  ) async {
    await tester.pumpWidget(const AcademyApp(home: AcademyChevron()));
    expect(find.byType(AnimatedRotation), findsNothing);
  });

  testWidgets('A chevron with turns still animates its rotation', (
    tester,
  ) async {
    await tester.pumpWidget(const AcademyApp(home: AcademyChevron(turns: 0)));
    expect(find.byType(AnimatedRotation), findsOneWidget);
  });

  testWidgets('A table row chevron is static', (tester) async {
    await tester.pumpWidget(
      AcademyApp(
        home: AcademyRow(
          title: 'Row',
          onPressed: () {},
          chevron: const AcademyChevron(),
        ),
      ),
    );
    expect(find.byType(AnimatedRotation), findsNothing);
  });
}
