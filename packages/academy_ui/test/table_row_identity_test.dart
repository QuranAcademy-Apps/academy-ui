import 'package:academy_ui/academy_ui.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/academy_test_host.dart';

final _created = <String>[];

class _Probe extends StatefulWidget {
  const _Probe(this.name, {super.key});
  final String name;
  @override
  State<_Probe> createState() => _ProbeState();
}

class _ProbeState extends State<_Probe> {
  @override
  void initState() {
    super.initState();
    _created.add(widget.name);
  }

  @override
  Widget build(BuildContext context) => Text(widget.name);
}

void main() {
  setUp(_created.clear);

  Widget table(List<String> names, {bool animated = false}) => academyHost(
    SizedBox(
      width: 320,
      child: AcademyTableBody(
        animated: animated,
        rows: [for (final name in names) _Probe(name, key: ValueKey(name))],
      ),
    ),
  );

  testWidgets('reordering keyed rows keeps their state', (tester) async {
    await tester.pumpWidget(table(['a', 'b']));
    expect(_created, ['a', 'b']);
    await tester.pumpWidget(table(['b', 'a']));
    expect(_created, ['a', 'b']);
  });

  testWidgets('inserting a row creates only that row', (tester) async {
    await tester.pumpWidget(table(['a', 'b']));
    await tester.pumpWidget(table(['new', 'a', 'b']));
    expect(_created, ['a', 'b', 'new']);
  });

  testWidgets('an animated insert fades in only the new row', (tester) async {
    await tester.pumpWidget(table(['a', 'b'], animated: true));
    await tester.pumpAndSettle();
    await tester.pumpWidget(table(['new', 'a', 'b'], animated: true));
    await tester.pump();
    double opacityOf(String name) => tester
        .widget<FadeTransition>(
          find
              .ancestor(
                of: find.text(name),
                matching: find.byType(FadeTransition),
              )
              .first,
        )
        .opacity
        .value;
    expect(opacityOf('a'), 1);
    expect(opacityOf('b'), 1);
    expect(opacityOf('new'), lessThan(1));
    await tester.pumpAndSettle();
  });

  testWidgets('a row is still found by its own key, only once', (tester) async {
    await tester.pumpWidget(table(['a']));
    expect(find.byKey(const ValueKey('a')), findsOneWidget);
    expect(find.byType(_Probe), findsOneWidget);
  });

  testWidgets('a row may carry a global key in an animated table', (
    tester,
  ) async {
    final key = GlobalKey();
    await tester.pumpWidget(
      academyHost(
        SizedBox(
          width: 320,
          child: AcademyTableBody(
            animated: true,
            rows: [_Probe('a', key: key)],
          ),
        ),
      ),
    );
    expect(tester.takeException(), isNull);
    expect(find.byKey(key), findsOneWidget);
    await tester.pumpAndSettle();
  });
}
