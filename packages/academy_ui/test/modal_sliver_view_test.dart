import 'package:academy_ui/academy_ui.dart';
import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:flutter_test/flutter_test.dart';

import 'modal_contract_test.dart' show host;

void main() {
  Future<double> firstTop(WidgetTester tester, bool slivers) async {
    final context = await host(tester);
    Widget row(int i) => SizedBox(
      key: ValueKey('row-$i'),
      height: 44,
      child: Text('Строка $i'),
    );
    showAcademyModal<void>(
      context,
      title: 'Список',
      builder: (_) => slivers
          ? AcademyModalSliverView(
              slivers: [
                SliverList.builder(itemCount: 500, itemBuilder: (_, i) => row(i)),
              ],
            )
          : AcademyModalListView(children: [row(0)]),
    );
    await tester.pumpAndSettle();
    return tester.getRect(find.byKey(const ValueKey('row-0'))).top;
  }

  testWidgets('sliver view keeps the list view insets and builds lazily', (
    tester,
  ) async {
    final listTop = await firstTop(tester, false);
    await tester.pumpWidget(const SizedBox());
    final sliverTop = await firstTop(tester, true);
    expect(sliverTop, closeTo(listTop, .1));
    expect(find.byKey(const ValueKey('row-499')), findsNothing);
  });
}
