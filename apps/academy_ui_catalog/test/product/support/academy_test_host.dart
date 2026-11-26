import 'package:academy_ui/academy_ui.dart';
import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:flutter_test/flutter_test.dart';

/// Gives the test a phone-sized view at 1x.
void phone(WidgetTester tester, {Size size = const Size(390, 844)}) {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
}

/// Opens a sheet from a button; the caller pumps the transition.
Future<void> openSheet(
  WidgetTester tester, {
  required WidgetBuilder builder,
  bool nestedNavigation = false,
  bool initiallyExpanded = false,
  ModalSheetDetent? initialDetent,
  AcademyModalHeaderBehavior headerBehavior =
      AcademyModalHeaderBehavior.separate,
  bool clipContent = true,
}) async {
  await tester.pumpWidget(
    AcademyApp(
      home: Builder(
        builder: (context) => CupertinoButton(
          onPressed: () => showAcademyModal<void>(
            context,
            title: 'Sheet',
            initialDetent: initialDetent,
            nestedNavigation: nestedNavigation,
            initiallyExpanded: initiallyExpanded,
            headerBehavior: headerBehavior,
            clipContent: clipContent,
            builder: builder,
          ),
          child: const Text('open'),
        ),
      ),
    ),
  );
  await tester.tap(find.text('open'));
}

/// [child] under [AcademyApp], at the top of the screen, in the given
/// accessibility conditions.
Widget academyHost(
  Widget child, {
  TextDirection direction = TextDirection.ltr,
  double textScale = 1,
  bool highContrast = false,
  AcademyTableTheme table = const AcademyTableTheme(),
  AcademyInteractionTheme interaction = const AcademyInteractionTheme(),
}) => AcademyApp(
  table: table,
  interaction: interaction,
  home: Builder(
    builder: (context) => MediaQuery(
      data: MediaQuery.of(context).copyWith(
        textScaler: TextScaler.linear(textScale),
        highContrast: highContrast,
      ),
      child: Directionality(
        textDirection: direction,
        child: Align(alignment: Alignment.topCenter, child: child),
      ),
    ),
  ),
);
