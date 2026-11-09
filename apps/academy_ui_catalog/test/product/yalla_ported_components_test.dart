import 'package:academy_ui/academy_ui.dart';
import 'package:academy_ui_catalog/product/product.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';

// Contracts of components ported from Yalla (2026-11-02). Their pixels are
// checked against Yalla's originals in yalla-app/test/parity.

Widget _host(Widget child, {AcademyThemeData? theme}) => AcademyApp(
  home: AcademyTheme(
    data: theme ?? academyTheme(Brightness.light),
    child: Align(
      alignment: Alignment.topLeft,
      child: SizedBox(width: 390, child: child),
    ),
  ),
);

void main() {
  testWidgets('journey progress can hide its title and restyle the bar', (
    tester,
  ) async {
    await tester.pumpWidget(
      _host(
        const AcademyJourneyProgress(
          title: 'Подготовка',
          completed: 1,
          total: 4,
          showTitle: false,
          barHeight: 4,
        ),
      ),
    );
    expect(find.text('Подготовка'), findsNothing);
    expect(find.bySemanticsLabel('Подготовка'), findsOneWidget);
  });
}
