import 'package:academy_ui/academy_ui.dart';
import 'package:academy_ui_catalog/product/product.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _host(Widget child, {double textScale = 1, double width = 320}) =>
    AcademyApp(
      home: Builder(
        builder: (context) => MediaQuery(
          data: MediaQuery.of(context).copyWith(
            textScaler: TextScaler.linear(textScale),
            disableAnimations: true,
          ),
          child: CupertinoPageScaffold(
            child: Center(
              child: SizedBox(width: width, child: child),
            ),
          ),
        ),
      ),
    );

AcademyPrayerStrip _strip({VoidCallback? onPressed}) => AcademyPrayerStrip(
  caption: 'Аср через 1 ч 20 мин',
  highlighted: 2,
  onPressed: onPressed,
  times: const [
    AcademyPrayerTime(name: 'Фаджр', time: '05:12'),
    AcademyPrayerTime(name: 'Зухр', time: '12:31'),
    AcademyPrayerTime(name: 'Аср', time: '15:48'),
    AcademyPrayerTime(name: 'Магриб', time: '18:07'),
    AcademyPrayerTime(name: 'Иша', time: '19:34'),
  ],
);

void main() {
  testWidgets('shows every time and the caption, tap fires once', (
    tester,
  ) async {
    var taps = 0;
    await tester.pumpWidget(_host(_strip(onPressed: () => taps++)));
    for (final text in [
      'Фаджр',
      '05:12',
      'Иша',
      '19:34',
      'Аср через 1 ч 20 мин',
    ]) {
      expect(find.text(text), findsOneWidget);
    }
    await tester.tap(find.byType(AcademyPrayerStrip));
    await tester.pumpAndSettle();
    expect(taps, 1);
  });

  testWidgets('fits 320 wide at the largest text size', (tester) async {
    await tester.pumpWidget(_host(_strip(), textScale: 2));
    expect(tester.takeException(), isNull);
  });
}
