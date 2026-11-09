import 'package:academy_ui/academy_ui.dart';
import 'package:academy_ui_catalog/product/product.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/academy_test_host.dart';

void main() {
  Widget table(Widget row) =>
      academyHost(SizedBox(width: 320, child: AcademyTableBody(rows: [row])));

  testWidgets('a three-digit index badge stays on one line', (tester) async {
    await tester.pumpWidget(
      table(
        const AcademyRow(title: 'Глава 111', leading: AcademyIndexBadge(111)),
      ),
    );
    expect(tester.takeException(), isNull);
    final text = tester.getRect(find.text('111'));
    final badge = tester.getRect(find.byType(AcademyIndexBadge));
    expect(text.width, lessThanOrEqualTo(badge.width));
    expect(tester.widget<Text>(find.text('111')).softWrap, isFalse);
  });
}
