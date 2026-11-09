import 'package:academy_ui/academy_ui.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('container radius roles are independent', () {
    const defaults = AcademyRadii();
    expect(
      [defaults.table, defaults.surface, defaults.disclosure],
      [24, 14, 14],
    );
    const radii = AcademyRadii(table: 24, surface: 8, disclosure: 12);
    expect(radii.surface, 8);
    expect(radii.disclosure, 12);
    expect(radii.copyWith(surface: 16).table, 24);
    expect(radii.withValue(AcademyRadiusRole.disclosure, 32).surface, 8);
    expect(const AcademyRadii(surface: 8).table, 24);
    expect(const AcademyRadii(disclosure: 12).surface, 14);
  });

  test(
    'custom fonts use their own tracking and preserve default role sizes',
    () {
      final custom = AcademyTypography(
        const Color(0xff123456),
        settings: const AcademyTypographySettings(
          fontFamily: 'Inter',
          displayFontFamily: 'Inter',
          fontPackage: 'academy_ui',
        ),
      );
      expect(custom.bodyLarge.fontSize, 17);
      expect(custom.bodyLarge.letterSpacing, 0);
      expect(custom.titleLarge.fontFamily, 'packages/academy_ui/Inter');
    },
  );
}
