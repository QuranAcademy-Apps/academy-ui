import 'package:academy_ui/academy_ui.dart';
import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _app(Widget child) => CupertinoApp(
  localizationsDelegates: const [
    AcademyLocalizations.delegate,
    DefaultCupertinoLocalizations.delegate,
    DefaultWidgetsLocalizations.delegate,
  ],
  home: AcademyTheme(data: academyTheme(Brightness.light), child: child),
);

void main() {
  testWidgets('AcademySwitch is 51 x 31 and reports the new value', (
    tester,
  ) async {
    bool? changed;
    await tester.pumpWidget(
      _app(
        Center(
          child: AcademySwitch(value: false, onChanged: (v) => changed = v),
        ),
      ),
    );
    expect(tester.getSize(find.byType(AcademySwitch)), const Size(51, 31));
    await tester.tap(find.byType(CupertinoSwitch));
    expect(changed, isTrue);
  });

  testWidgets('AcademySwitch uses the given track color', (tester) async {
    const color = Color(0xFF123456);
    await tester.pumpWidget(
      _app(
        Center(
          child: AcademySwitch(
            value: true,
            onChanged: (_) {},
            activeTrackColor: color,
          ),
        ),
      ),
    );
    expect(
      tester
          .widget<CupertinoSwitch>(find.byType(CupertinoSwitch))
          .activeTrackColor,
      color,
    );
  });

  testWidgets('AcademyFeedback.compact shows the message and a retry button', (
    tester,
  ) async {
    var retried = 0;
    await tester.pumpWidget(
      _app(
        AcademyFeedback.compact(
          message: 'Failed',
          onRetry: () => retried++,
          retryLabel: 'Again',
        ),
      ),
    );
    expect(find.text('Failed'), findsOneWidget);
    await tester.tap(find.text('Again'));
    expect(retried, 1);
  });

  testWidgets('AcademyFeedback.compact without a retry has no button', (
    tester,
  ) async {
    await tester.pumpWidget(
      _app(const AcademyFeedback.compact(message: 'Empty')),
    );
    expect(find.byType(CupertinoButton), findsNothing);
  });

  testWidgets('AcademyRingProgress.fill takes the space of its parent', (
    tester,
  ) async {
    await tester.pumpWidget(
      _app(
        const Center(
          child: SizedBox.square(
            dimension: 40,
            child: AcademyRingProgress.fill(value: .5),
          ),
        ),
      ),
    );
    expect(
      tester.getSize(find.byType(AcademyRingProgress)),
      const Size(40, 40),
    );
    await tester.pumpWidget(
      _app(const Center(child: AcademyRingProgress(value: .5))),
    );
    expect(
      tester.getSize(find.byType(AcademyRingProgress)),
      const Size(36, 36),
    );
  });

  testWidgets('AcademyInfoButton.inline is a bare symbol button', (
    tester,
  ) async {
    var pressed = 0;
    await tester.pumpWidget(
      _app(Center(child: AcademyInfoButton.inline(onPressed: () => pressed++))),
    );
    await tester.tap(find.byType(CupertinoButton));
    expect(pressed, 1);
    expect(find.byType(AcademyIconButton), findsNothing);
  });
}
