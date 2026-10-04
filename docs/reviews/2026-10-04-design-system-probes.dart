// Post-fix checks replacing the original audit measurements.
// Original findings and their pre-fix evidence are described in the audit report.
import 'package:academy_ui/academy_ui.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_sficon/flutter_sficon.dart' as sf;
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('record standalone chevron resolution in RTL', (tester) async {
    await tester.pumpWidget(
      const AcademyApp(
        home: Directionality(
          textDirection: TextDirection.rtl,
          child: Center(child: AcademyChevron()),
        ),
      ),
    );
    final icon = tester.widget<sf.SFIcon>(find.byType(sf.SFIcon));
    expect(icon.icon, AcademySymbols.back);
    // Only the renderer resolves logical direction.
    print('FIX VERIFIED: standalone RTL chevron resolves to back');
  });

  test('record container radius coupling and typography roles', () {
    final theme = academyTheme(Brightness.light);
    expect(theme.radii.table, 24);
    expect(theme.radii.surface, 14);
    expect(theme.radii.disclosure, 14);
    expect(theme.radii.copyWith(surface: 8).table, 24);
    expect(theme.textTheme.bodyRow.height, 22 / 17);
    expect(theme.textTheme.bodyLarge.height, isNull);
    print(
      'FIX VERIFIED: table/surface/disclosure = 24/14/14; overrides independent',
    );
    print(
      'FIX VERIFIED: canonical table bodyRow height = 22/17; bodyLarge remains independent',
    );
  });
}
