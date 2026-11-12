import 'package:academy_ui/academy_ui.dart';
import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _host(Widget child, {TextDirection direction = TextDirection.ltr}) =>
    Directionality(
      textDirection: direction,
      child: MediaQuery(
        data: const MediaQueryData(textScaler: TextScaler.linear(2)),
        child: Center(child: child),
      ),
    );

void main() {
  testWidgets('symbols ignore text scale unless asked to follow it', (
    tester,
  ) async {
    await tester.pumpWidget(
      _host(AcademySfIcon(AcademySymbols.heart, fontSize: 20)),
    );
    final fixed = tester.getSize(find.byType(AcademySfIcon));
    await tester.pumpWidget(
      _host(
        AcademySfIcon(AcademySymbols.heart, fontSize: 20, scaleWithText: true),
      ),
    );
    final scaled = tester.getSize(find.byType(AcademySfIcon));
    expect(scaled.width, closeTo(fixed.width * 2, .01));
    expect(scaled.height, closeTo(fixed.height * 2, .01));
  });

  testWidgets('back and forward swap in RTL only when mirroring is on', (
    tester,
  ) async {
    await tester.pumpWidget(
      _host(
        AcademySfIcon(AcademySymbols.forward),
        direction: TextDirection.rtl,
      ),
    );
    expect(
      tester.widget<Text>(find.byType(Text)).data!.runes.first,
      AcademySymbols.back.codePoint,
    );
    await tester.pumpWidget(
      _host(
        AcademySfIcon(AcademySymbols.forward, mirrorInRtl: false),
        direction: TextDirection.rtl,
      ),
    );
    expect(
      tester.widget<Text>(find.byType(Text)).data!.runes.first,
      AcademySymbols.forward.codePoint,
    );
  });
}
