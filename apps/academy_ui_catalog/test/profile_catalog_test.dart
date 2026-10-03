import 'package:academy_ui/academy_ui.dart';
import 'package:academy_ui_catalog/profile_components_catalog.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('profile catalog exposes all variants and fits narrow widths', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(const AcademyApp(home: ProfileComponentsCatalog()));
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.text('Профиль и поездки'), findsWidgets);
    expect(tester.takeException(), isNull);
    for (var i = 0; i < 24; i++) {
      await tester.drag(find.byType(Scrollable).first, const Offset(0, -650));
      await tester.pump();
      expect(tester.takeException(), isNull);
    }
    await tester.pumpWidget(const SizedBox());
  });
}
