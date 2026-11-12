import 'package:academy_ui/academy_ui.dart';
import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const color = Color(0xFF000000);

  test('default tracking is unchanged when no curve is supplied', () {
    final typography = AcademyTypography(color);
    expect(typography.displaySmall.letterSpacing, -.6);
    expect(
      typography.bodyLarge.letterSpacing,
      AcademyTypography.trackingForSize(17),
    );
  });

  test('custom tracking curve replaces every system role', () {
    final typography = AcademyTypography(
      color,
      settings: AcademyTypographySettings(
        tracking: (size) => size >= 20 ? 0 : -1,
      ),
    );
    expect(typography.bodyLarge.letterSpacing, -1);
    expect(typography.displaySmall.letterSpacing, 0);
    expect(typography.headlineMedium.letterSpacing, 0);
  });

  test('custom font family ignores the tracking curve', () {
    final typography = AcademyTypography(
      color,
      settings: AcademyTypographySettings(
        fontFamily: 'Inter',
        tracking: (_) => -1,
      ),
    );
    expect(typography.bodyLarge.letterSpacing, 0);
  });

  test('copyWith keeps and replaces the tracking curve', () {
    final base = AcademyTypographySettings(tracking: (_) => -1);
    expect(base.copyWith(fontPackage: 'x').tracking, same(base.tracking));
    expect(base.copyWith(tracking: (_) => 2).tracking!(10), 2);
  });
}
