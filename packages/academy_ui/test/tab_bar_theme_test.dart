import 'package:academy_ui/academy_ui.dart';
import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Widget app(
    Widget child, {
    AcademyTabBarTheme tabBar = const AcademyTabBarTheme(),
    AcademyChromeMaterial material = const AcademyChromeMaterial(),
    bool reduced = false,
    double textScale = 1,
  }) => CupertinoApp(
    home: MediaQuery(
      data: MediaQueryData(
        size: const Size(390, 800),
        textScaler: TextScaler.linear(textScale),
      ),
      child: AcademyTheme(
        data: academyTheme(
          Brightness.light,
          tabBar: tabBar,
          chromeMaterial: material,
        ),
        child: AcademyChromeTheme(
          style: AcademyChromeStyle.gradient,
          reduceTransparency: reduced,
          child: child,
        ),
      ),
    ),
  );

  List<AcademyTab> tabs(List<String> built) => [
    for (final name in ['Один', 'Два'])
      AcademyTab(
        label: name,
        icon: AcademySymbols.close,
        builder: (_) {
          built.add(name);
          return const SizedBox();
        },
      ),
  ];

  testWidgets('pages are built on first visit and report the change', (
    tester,
  ) async {
    final built = <String>[];
    final changes = <int>[];
    await tester.pumpWidget(
      app(AcademyTabScaffold(tabs: tabs(built), onTabChanged: changes.add)),
    );
    expect(built.toSet(), {'Один'});
    await tester.tap(find.text('Два'));
    await tester.pump();
    expect(built.toSet(), {'Один', 'Два'});
    expect(changes, [1]);
  });

  testWidgets('a controller selects the tab from outside', (tester) async {
    final built = <String>[];
    final changes = <int>[];
    final controller = AcademyTabController();
    addTearDown(controller.dispose);
    await tester.pumpWidget(
      app(
        AcademyTabScaffold(
          tabs: tabs(built),
          controller: controller,
          onTabChanged: changes.add,
        ),
      ),
    );
    controller.index = 1;
    await tester.pump();
    expect(built.toSet(), {'Один', 'Два'});
    expect(changes, [1]);
    expect(
      tester
          .widget<AcademyFloatingTabBar>(find.byType(AcademyFloatingTabBar))
          .index,
      1,
    );
  });

  testWidgets('the theme places the bar and adds the fade', (tester) async {
    await tester.pumpWidget(
      app(
        AcademyTabScaffold(tabs: tabs([])),
        tabBar: AcademyTabBarTheme(
          sideMargin: 40,
          showBottomFade: true,
          bottomInsetOf: (_) => 30,
        ),
      ),
    );
    final bar = tester.getRect(find.byType(AcademyFloatingTabBar));
    expect(bar.left, 40);
    expect(
      bar.bottom,
      tester.getRect(find.byType(AcademyTabScaffold)).bottom - 30,
    );
    expect(find.byType(AcademyChromeFadeMaterial), findsOneWidget);
  });

  testWidgets('a fixed height ignores the text scale', (tester) async {
    await tester.pumpWidget(
      app(
        Builder(
          builder: (context) =>
              Text('${AcademyFloatingTabBar.heightOf(context)}'),
        ),
        tabBar: const AcademyTabBarTheme(fixedHeight: true),
        textScale: 2,
      ),
    );
    expect(find.text('60.0'), findsOneWidget);
  });

  testWidgets('pressing can scale instead of fade', (tester) async {
    await tester.pumpWidget(
      app(
        AcademyTabScaffold(tabs: tabs([])),
        tabBar: const AcademyTabBarTheme(pressedScale: .9),
      ),
    );
    expect(
      find.descendant(
        of: find.byType(AcademyFloatingTabBar),
        matching: find.byType(PressScale),
      ),
      findsNWidgets(2),
    );
  });

  testWidgets('the material strokes, elevates and flattens the surface', (
    tester,
  ) async {
    const stroke = LinearGradient(
      colors: [Color(0xFFFF0000), Color(0xFF00FF00)],
    );
    const shadow = BoxShadow(color: Color(0x33000000), blurRadius: 9);
    const material = AcademyChromeMaterial(
      borderGradient: stroke,
      shadows: [shadow],
      reducedFill: Color(0xFF123456),
    );
    BoxDecoration outer() =>
        tester
                .widget<DecoratedBox>(
                  find
                      .descendant(
                        of: find.byType(AcademyChrome),
                        matching: find.byType(DecoratedBox),
                      )
                      .first,
                )
                .decoration
            as BoxDecoration;

    await tester.pumpWidget(
      app(const AcademyChrome(child: SizedBox()), material: material),
    );
    expect(outer().boxShadow, [shadow]);

    await tester.pumpWidget(
      app(
        const AcademyChrome(showShadow: false, child: SizedBox()),
        material: material,
      ),
    );
    expect(outer().boxShadow, isEmpty);

    await tester.pumpWidget(
      app(
        const AcademyChrome(child: SizedBox()),
        material: material,
        reduced: true,
      ),
    );
    expect(outer().color, const Color(0xFF123456));

    await tester.pumpWidget(
      app(
        const AcademyChrome(frostsBackdrop: true, child: SizedBox()),
        material: material,
        reduced: true,
      ),
    );
    expect(
      find.descendant(
        of: find.byType(AcademyChrome),
        matching: find.byType(DecoratedBox),
      ),
      findsNothing,
    );
  });

  testWidgets('reduced transparency removes the edge fade', (tester) async {
    await tester.pumpWidget(
      app(const AcademyChromeFadeMaterial(), reduced: true),
    );
    expect(
      find.descendant(
        of: find.byType(AcademyChromeFadeMaterial),
        matching: find.byType(DecoratedBox),
      ),
      findsNothing,
    );
  });
}
