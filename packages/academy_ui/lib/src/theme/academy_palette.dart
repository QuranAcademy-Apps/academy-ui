import 'package:flutter/cupertino.dart';

import 'academy_colors.dart';

abstract final class AcademyBrandColors {
  static const brand = Color(0xFF007AFF);
  static const action = Color(0xFFE8CA79);
  static const canvas = Color(0xFFF2F2F7);
  static const ink = Color(0xFF000000);
  static const muted = Color(0xFF6C6C70);
  static const border = Color(0xFFC6C6C8);
}

extension AcademyToneColors on AcademyTone {
  Color foreground(Brightness brightness) {
    final dark = brightness == Brightness.dark;
    return switch (this) {
      AcademyTone.neutral =>
        dark ? const Color(0xFFCCD5E2) : AcademyBrandColors.muted,
      AcademyTone.success =>
        dark ? const Color(0xFF9BE2B8) : const Color(0xFF185C38),
      AcademyTone.warning =>
        dark ? const Color(0xFFFFD597) : const Color(0xFF754500),
      AcademyTone.error =>
        dark ? const Color(0xFFFFB4AB) : const Color(0xFFA22B28),
    };
  }

  Color background(Brightness brightness) {
    final dark = brightness == Brightness.dark;
    return switch (this) {
      AcademyTone.neutral =>
        dark ? const Color(0xFF2B3442) : const Color(0xFFEDF1F6),
      AcademyTone.success =>
        dark ? const Color(0xFF203D2B) : const Color(0xFFE2F2E5),
      AcademyTone.warning =>
        dark ? const Color(0xFF45341F) : const Color(0xFFFFEBC9),
      AcademyTone.error =>
        dark ? const Color(0xFF4C2826) : const Color(0xFFFFE8E3),
    };
  }
}

class AcademyPalette implements AcademyColors {
  AcademyPalette(this.brightness, this.accent);
  final Brightness brightness;
  final Color accent;
  bool get dark => brightness == Brightness.dark;
  Color _system(CupertinoDynamicColor color) =>
      dark ? color.darkColor : color.color;
  Color get _themedAccent {
    const darkAccents = <int, Color>{
      0xFF007AFF: Color(0xFF0A84FF),
      0xFF263E59: Color(0xFF5CA8FF),
      0xFF246A89: Color(0xFF48B9D8),
      0xFF326555: Color(0xFF66C6A2),
      0xFF74537B: Color(0xFFC18BE0),
      0xFF98513D: Color(0xFFF09B79),
      0xFFE8CA79: Color(0xFFE8CA79),
    };
    final color = dark ? darkAccents[accent.toARGB32()] ?? accent : accent;
    return color.withValues(alpha: 1);
  }

  @override
  Color get accentColor => accent;
  @override
  Color get accentFill =>
      AcademyContrast.foreground(_themedAccent, onAccentFill);
  @override
  Color get onAccentFill => _themedAccent.computeLuminance() > .35
      ? CupertinoColors.black
      : CupertinoColors.white;
  @override
  Color get menuSurface => surface;
  @override
  Color get actionFill => accentFill;
  @override
  Color get onActionFill => onAccentFill;
  @override
  Color get accentForeground => AcademyContrast.foreground(
    AcademyContrast.foreground(
      AcademyContrast.foreground(_themedAccent, textFieldBackground),
      textFieldSecondaryBackground,
    ),
    _system(CupertinoColors.systemGroupedBackground),
  );
  @override
  Color get primary => accentForeground;

  // Field colors are component roles. They must not depend on surface,
  // surfaceContainerHighest, chrome style, or the selected accent seed.
  @override
  Color get textFieldBackground =>
      dark ? const Color(0xFF1C1C1E) : CupertinoColors.white;
  @override
  Color get textFieldSecondaryBackground =>
      dark ? const Color(0xFF2C2C2E) : const Color(0xFFF2F2F7);
  @override
  Color get textFieldDisabledBackground =>
      dark ? const Color(0xFF2C2C2E) : const Color(0xFFE5E5EA);
  @override
  Color get textFieldForeground =>
      dark ? CupertinoColors.white : CupertinoColors.black;
  @override
  Color get textFieldSecondaryForeground =>
      dark ? const Color(0xFFAEAEB2) : const Color(0xFF6C6C70);
  @override
  Color get textFieldDisabledForeground => AcademyContrast.foreground(
    textFieldSecondaryForeground,
    textFieldDisabledBackground,
  );
  @override
  Color get textFieldBorder => const Color(0x00000000);
  @override
  Color get textFieldDisabledBorder =>
      dark ? const Color(0xFF636366) : const Color(0xFFC7C7CC);
  @override
  Color get textFieldFocusBorder => AcademyContrast.foreground(
    _themedAccent,
    textFieldBackground,
    minimum: 3,
  );
  @override
  Color get textFieldErrorForeground =>
      AcademyTone.error.foreground(brightness);

  @override
  Color get onPrimary => primary.computeLuminance() > .179
      ? CupertinoColors.black
      : CupertinoColors.white;
  @override
  Color get secondary =>
      AcademyContrast.foreground(primary, secondaryContainer);
  @override
  Color get onSecondary => AcademyContrast.foreground(onSurface, secondary);
  @override
  Color get surface =>
      _system(CupertinoColors.secondarySystemGroupedBackground);
  @override
  Color get onSurface => _system(CupertinoColors.label);
  @override
  Color get onSurfaceVariant => AcademyContrast.foreground(
    AcademyContrast.foreground(
      Color.alphaBlend(_system(CupertinoColors.secondaryLabel), surface),
      surface,
    ),
    scaffoldBackground,
  );
  @override
  Color get surfaceContainerHighest =>
      _system(CupertinoColors.tertiarySystemGroupedBackground);
  @override
  Color get outline => _system(CupertinoColors.opaqueSeparator);
  @override
  Color get outlineVariant => _system(CupertinoColors.separator);
  @override
  Color get primaryContainer => Color.lerp(_themedAccent, surface, .88)!;
  @override
  Color get onPrimaryContainer =>
      AcademyContrast.foreground(primary, primaryContainer);
  @override
  Color get secondaryContainer => Color.lerp(_themedAccent, surface, .84)!;
  @override
  Color get error => AcademyTone.error.foreground(brightness);
  @override
  Color get scaffoldBackground =>
      _system(CupertinoColors.systemGroupedBackground);
  @override
  Color get segmentBackground =>
      // Stable, opaque control fill shared by segments and compact buttons.
      // Do not blend with surface: card/page palette changes must not wash out
      // these controls. Clients can override the semantic role explicitly.
      dark ? const Color(0xFF3A3A3C) : const Color(0xFFE1E3E7);
  @override
  Color get segmentSelected =>
      dark ? const Color(0xFF636366) : CupertinoColors.white;
  @override
  Color get segmentShadow =>
      dark ? const Color(0x50000000) : const Color(0x1A000000);
  @override
  Color get menuHighlight =>
      Color.alphaBlend(primary.withValues(alpha: .08), surface);
  @override
  Color get iconOnColoredSurface => CupertinoColors.white;
  @override
  Color get modalBarrier => const Color(0x40000000);
  @override
  Color get chromeGradientStart => surfaceContainerHighest;
  @override
  Color get chromeGradientEnd => surface;
  @override
  // Navigation tint is independent of card/form surface changes.
  Color get chromeSurface =>
      dark ? const Color(0xFF1C1C1E) : CupertinoColors.white;
  @override
  Color get chromeTintedSurface => primaryContainer;
  @override
  Color get chromeBorder => outlineVariant;

  /// A restrained companion hue: gold for the default navy, coordinated with
  /// the selected accent for other themes (adjacent rather than opposite hue). Shared by date and duration icons.
  @override
  Color get complementary {
    final hue =
        (HSLColor.fromColor(accent).hue +
            (accent.toARGB32() == AcademyBrandColors.brand.toARGB32()
                ? 190
                : 16)) %
        360;
    var color = HSLColor.fromAHSL(1, hue, .58, dark ? .72 : .34).toColor();
    for (var step = 0; step < 24; step++) {
      final foreground = color.computeLuminance();
      final background = Color.lerp(
        color,
        surface,
        dark ? .85 : .90,
      )!.computeLuminance();
      final contrast = foreground > background
          ? (foreground + .05) / (background + .05)
          : (background + .05) / (foreground + .05);
      if (contrast >= 4.5) break;
      color = Color.lerp(
        color,
        dark ? CupertinoColors.white : CupertinoColors.black,
        .08,
      )!;
    }
    return color;
  }

  @override
  Color get complementaryContainer =>
      Color.lerp(complementary, surface, dark ? .85 : .90)!;

  // Keep status meaning while subtly harmonizing with the selected accent.
  @override
  Color toneForeground(AcademyTone tone) => AcademyContrast.foreground(
    Color.lerp(tone.foreground(brightness), primary, .08)!,
    toneContainer(tone),
  );

  @override
  Color toneContainer(AcademyTone tone) => Color.lerp(
    Color.lerp(tone.background(brightness), surface, .2),
    primary,
    .04,
  )!;
}
