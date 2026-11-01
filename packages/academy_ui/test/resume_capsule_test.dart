import 'package:academy_ui/academy_ui.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _host(Widget child) => AcademyApp(
  home: Builder(
    builder: (context) => MediaQuery(
      data: MediaQuery.of(context).copyWith(disableAnimations: true),
      child: CupertinoPageScaffold(child: Center(child: child)),
    ),
  ),
);

void main() {
  testWidgets('tap fires while visible and is ignored while hidden', (
    tester,
  ) async {
    var taps = 0;
    Widget capsule(bool visible) => AcademyResumeCapsule(
      visible: visible,
      title: 'Утренние азкары',
      caption: '4/17',
      onPressed: () => taps++,
    );
    await tester.pumpWidget(_host(capsule(true)));
    expect(find.text('Утренние азкары'), findsOneWidget);
    expect(find.text('4/17'), findsOneWidget);
    await tester.tap(find.byType(AcademyResumeCapsule));
    await tester.pumpAndSettle();
    expect(taps, 1);

    await tester.pumpWidget(_host(capsule(false)));
    await tester.pumpAndSettle();
    await tester.tap(find.byType(AcademyResumeCapsule), warnIfMissed: false);
    expect(taps, 1);
  });

  testWidgets('long titles ellipsize inside 320 points', (tester) async {
    await tester.pumpWidget(
      _host(
        SizedBox(
          width: 320,
          child: AcademyResumeCapsule(
            visible: true,
            title: 'Очень длинное название подборки азкаров для проверки',
            caption: '4/17',
            onPressed: () {},
          ),
        ),
      ),
    );
    expect(tester.takeException(), isNull);
  });
}
