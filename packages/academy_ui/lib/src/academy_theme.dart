import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';

import 'academy_colors.dart';
export 'academy_colors.dart';

abstract final class AcademyTokens {
  static const space = 8.0;
  static const gutter = 20.0;
  static const radius = 20.0;
  static const controlRadius = 16.0;
  static const target = 48.0;
  static const tableIconExtent = 30.0;
  static const motion = Duration(milliseconds: 180);
  static const brand = Color(0xFF263E59);
  static const action = Color(0xFFE8CA79);
  static const canvas = Color(0xFFF5F4F1);
  static const ink = Color(0xFF171D26);
  static const muted = Color(0xFF596575);
  static const border = Color(0xFF697584);
}

extension AcademyToneColors on AcademyTone {
  Color foreground(Brightness brightness) {
    final dark = brightness == Brightness.dark;
    return switch (this) {
      AcademyTone.neutral =>
        dark ? const Color(0xFFCCD5E2) : AcademyTokens.muted,
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

enum AcademyAppearanceMode { system, light, dark }

class AcademyTheme extends InheritedTheme {
  const AcademyTheme({super.key, required this.data, required super.child});
  final AcademyThemeData data;
  static AcademyThemeData of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<AcademyTheme>()?.data ??
      academyTheme(CupertinoTheme.brightnessOf(context));
  @override
  Widget wrap(BuildContext context, Widget child) =>
      AcademyTheme(data: data, child: child);

  @override
  bool updateShouldNotify(AcademyTheme oldWidget) => data != oldWidget.data;
}

class AcademyThemeData {
  AcademyThemeData(this.brightness, Color accent, {AcademyColors? colors})
    : colorScheme = colors ?? AcademyPalette(brightness, accent);
  final Brightness brightness;
  final AcademyColors colorScheme;
  Color get scaffoldBackgroundColor => colorScheme.scaffoldBackground;
  AcademyTypography get textTheme => AcademyTypography(colorScheme.onSurface);
  CupertinoThemeData get cupertino => CupertinoThemeData(
    brightness: brightness,
    primaryColor: colorScheme.primary,
    scaffoldBackgroundColor: scaffoldBackgroundColor,
    barBackgroundColor: scaffoldBackgroundColor,
    textTheme: CupertinoTextThemeData(
      textStyle: textTheme.bodyLarge,
      navTitleTextStyle: textTheme.titleMedium,
      navActionTextStyle: textTheme.bodyLarge.copyWith(
        color: colorScheme.primary,
      ),
      navLargeTitleTextStyle: textTheme.displaySmall,
      actionTextStyle: textTheme.bodyLarge.copyWith(color: colorScheme.primary),
    ),
  );
}

AcademyThemeData academyTheme(
  Brightness brightness, {
  Color accent = AcademyTokens.brand,
  AcademyColors? colors,
}) => AcademyThemeData(brightness, accent, colors: colors);

class AcademyPalette implements AcademyColors {
  AcademyPalette(this.brightness, this.accent);
  final Brightness brightness;
  final Color accent;
  bool get dark => brightness == Brightness.dark;
  @override
  Color get primary {
    const darkAccents = <int, Color>{
      0xFF263E59: Color(0xFF5CA8FF),
      0xFF246A89: Color(0xFF48B9D8),
      0xFF326555: Color(0xFF66C6A2),
      0xFF74537B: Color(0xFFC18BE0),
      0xFF98513D: Color(0xFFF09B79),
      0xFFE8CA79: Color(0xFFE8CA79),
    };
    var color = dark ? darkAccents[accent.toARGB32()] ?? accent : accent;
    while (dark && color.computeLuminance() < .28) {
      color = Color.lerp(color, CupertinoColors.white, .08)!;
    }
    // Active text/icons must remain readable on a light surface.
    while (!dark && color.computeLuminance() > .18) {
      color = Color.lerp(color, CupertinoColors.black, .08)!;
    }
    return color;
  }

  @override
  Color get onPrimary => primary.computeLuminance() > .179
      ? CupertinoColors.black
      : CupertinoColors.white;
  @override
  Color get secondary => AcademyTokens.action;
  @override
  Color get onSecondary => AcademyTokens.ink;
  @override
  Color get surface => dark ? const Color(0xFF222936) : CupertinoColors.white;
  @override
  Color get onSurface => dark ? const Color(0xFFEDF1F7) : AcademyTokens.ink;
  @override
  Color get onSurfaceVariant =>
      dark ? const Color(0xFFBBC5D3) : AcademyTokens.muted;
  @override
  Color get surfaceContainerHighest =>
      dark ? const Color(0xFF30363E) : const Color(0xFFF0F0EE);
  @override
  Color get outline => dark ? const Color(0xFF929EAF) : AcademyTokens.border;
  @override
  Color get outlineVariant =>
      dark ? const Color(0xFF414B5B) : const Color(0xFFDFE4EC);
  @override
  Color get primaryContainer => Color.lerp(primary, surface, .88)!;
  @override
  Color get secondaryContainer =>
      dark ? const Color(0xFF292A2C) : const Color(0xFFEEEBE5);
  @override
  Color get error => AcademyTone.error.foreground(brightness);
  @override
  Color get scaffoldBackground =>
      dark ? const Color(0xFF141A24) : AcademyTokens.canvas;
  @override
  Color get segmentBackground =>
      dark ? const Color(0xFF404A5A) : const Color(0xFFE1E3E7);
  @override
  Color get segmentSelected => surface;
  @override
  Color get segmentShadow => const Color(0x1A000000);
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
  Color get chromeSurface => surface;
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
            (accent.toARGB32() == AcademyTokens.brand.toARGB32() ? 190 : 16)) %
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
  Color toneForeground(AcademyTone tone) =>
      Color.lerp(tone.foreground(brightness), primary, .08)!;

  @override
  Color toneContainer(AcademyTone tone) => Color.lerp(
    Color.lerp(tone.background(brightness), surface, .2),
    primary,
    .04,
  )!;
}

class AcademyTypography {
  const AcademyTypography(this.color);
  final Color color;
  static double trackingForSize(double size) {
    if (defaultTargetPlatform != TargetPlatform.iOS &&
            defaultTargetPlatform != TargetPlatform.macOS ||
        size >= 20) {
      return 0;
    }
    const anchors = <List<double>>[
      [10, .12],
      [13, -.08],
      [15, -.24],
      [17, -.43],
    ];
    if (size <= 10) return .12;
    if (size >= 17) return -.43;
    for (var i = 0; i < anchors.length - 1; i++) {
      final lo = anchors[i], hi = anchors[i + 1];
      if (size >= lo[0] && size <= hi[0]) {
        return lo[1] + (hi[1] - lo[1]) * (size - lo[0]) / (hi[0] - lo[0]);
      }
    }
    return 0;
  }

  TextStyle _system(double size, {FontWeight weight = FontWeight.w400}) =>
      TextStyle(
        inherit: false,
        fontFamily: size >= 20
            ? 'CupertinoSystemDisplay'
            : 'CupertinoSystemText',
        fontSize: size,
        fontWeight: weight,
        letterSpacing: trackingForSize(size),
        color: color,
      );
  TextStyle get bodyLarge => _system(17);
  TextStyle get bodyMedium => _system(15);
  TextStyle get bodySmall => _system(13);
  TextStyle get sectionLabel => _system(12);
  TextStyle get labelLarge => bodyLarge.copyWith(fontWeight: FontWeight.w600);
  TextStyle get titleSmall => labelLarge;
  TextStyle get titleMedium => labelLarge;
  TextStyle get titleLarge => _system(22, weight: FontWeight.w600);
  TextStyle get headlineMedium => labelLarge.copyWith(
    fontSize: 28,
    fontWeight: FontWeight.w700,
    letterSpacing: -.6,
  );
  TextStyle get displaySmall => headlineMedium.copyWith(fontSize: 32);
}
