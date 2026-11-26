import 'package:academy_ui/academy_ui.dart';
import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:flutter_test/flutter_test.dart';

const _page = Color(0xFF000000);
const _sheet = Color(0xFF123456);

AcademyThemeData _theme(Color background, {bool wrap = false}) {
  final base = academyTheme(Brightness.dark);
  return base.copyWith(
    colors: (base.colorScheme as AcademyPalette).copyWith(
      scaffoldBackground: background,
    ),
    modalWrapper: wrap
        ? (context, child) => AcademyTheme(data: _theme(_sheet), child: child)
        : null,
  );
}

Color _background(WidgetTester tester, String text) =>
    AcademyTheme.of(tester.element(find.text(text))).scaffoldBackgroundColor;

void main() {
  testWidgets('modalWrapper themes the sheet, its pages and confirmations', (
    tester,
  ) async {
    late BuildContext page;
    await tester.pumpWidget(
      CupertinoApp(
        builder: (_, child) =>
            AcademyTheme(data: _theme(_page, wrap: true), child: child!),
        home: Builder(
          builder: (context) {
            page = context;
            return const Text('page');
          },
        ),
      ),
    );

    showAcademyModal<void>(
      page,
      title: 'Sheet',
      grouped: true,
      nestedNavigation: true,
      builder: (context) => CupertinoButton(
        onPressed: () => pushAcademyModalPage<void>(
          context,
          builder: (_) => const Text('second'),
        ),
        child: const Text('first'),
      ),
    );
    await tester.pumpAndSettle();
    expect(_background(tester, 'first'), _sheet);
    // The header and the sheet fill read the theme above the content.
    expect(_background(tester, 'Sheet'), _sheet);
    expect(_background(tester, 'page'), _page);

    await tester.tap(find.text('first'));
    await tester.pumpAndSettle();
    expect(_background(tester, 'second'), _sheet);

    Navigator.of(page).pop();
    await tester.pumpAndSettle();
    showAcademyConfirmation(page, title: 'Ask', message: 'message');
    await tester.pumpAndSettle();
    expect(_background(tester, 'message'), _sheet);
  });
}
