import 'academy_interaction_theme.dart';
export 'academy_interaction_theme.dart';
import 'academy_palette.dart';
export 'academy_palette.dart';
import 'academy_radii.dart';
import 'academy_paddings.dart';
import 'academy_typography.dart';
export 'academy_radii.dart';
export 'academy_paddings.dart';
export 'academy_typography.dart';

import 'package:flutter/cupertino.dart';

import 'academy_colors.dart';
export 'academy_colors.dart';

abstract final class AcademyTokens {
  static const space = 8.0;
  static const inlineGap = 12.0;
  static const labelGap = 6.0;
  static const tableInset = 16.0;
  static const gutter = 20.0;
  static const radius = AcademyRadii.defaultSurface;
  static const controlRadius = AcademyRadii.defaultButton;
  static const fieldRadius = AcademyRadii.defaultField;
  static const target = 44.0;
  static const largeTarget = 48.0;
  static const buttonHeight = 52.0;
  static const tableIconExtent = 30.0;
  static const motion = Duration(milliseconds: 180);
  static const searchOpenMotion = Duration(milliseconds: 220);
  static const selectionMotion = Duration(milliseconds: 240);
  static const pressMotion = Duration(milliseconds: 260);
  static const buttonPressMotion = Duration(milliseconds: 100);
  static const buttonReleaseMotion = Duration(milliseconds: 100);
  static const buttonPressedScale = 0.97;
  static const buttonMaximumShrink = 5.0;
  // Backdrop color correction, not a painted overlay or child opacity.
  static const chromeBlurToneStrength = 0.54;
  static const chromeBlurSaturation = 1.25;
  // Compatibility name: now controls backdrop tone correction.
  static const chromeBlurTintOpacity = chromeBlurToneStrength;
  static const layoutMotion = Duration(milliseconds: 280);
  static const toastMotion = Duration(milliseconds: 300);
  static const progressMotion = Duration(milliseconds: 320);
  static const sheetMotion = Duration(milliseconds: 350);
  static const brand = AcademyBrandColors.brand;
  static const action = AcademyBrandColors.action;
  static const canvas = AcademyBrandColors.canvas;
  static const ink = AcademyBrandColors.ink;
  static const muted = AcademyBrandColors.muted;
  static const border = AcademyBrandColors.border;
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
  AcademyThemeData(
    this.brightness,
    Color accent, {
    AcademyColors? colors,
    this.radii = const AcademyRadii(),
    this.paddings = const AcademyPaddings(),
    this.typography = const AcademyTypographySettings(),
    this.interaction = const AcademyInteractionTheme(),
  }) : colorScheme = colors ?? AcademyPalette(brightness, accent);
  final AcademyInteractionTheme interaction;
  final Brightness brightness;
  final AcademyRadii radii;
  final AcademyPaddings paddings;
  final AcademyTypographySettings typography;
  final AcademyColors colorScheme;
  AcademyThemeData copyWith({
    AcademyColors? colors,
    AcademyRadii? radii,
    AcademyPaddings? paddings,
    AcademyTypographySettings? typography,
    AcademyInteractionTheme? interaction,
  }) => AcademyThemeData(
    brightness,
    colorScheme.accentColor,
    colors: colors ?? colorScheme,
    radii: radii ?? this.radii,
    paddings: paddings ?? this.paddings,
    typography: typography ?? this.typography,
    interaction: interaction ?? this.interaction,
  );
  Color get scaffoldBackgroundColor => colorScheme.scaffoldBackground;
  AcademyTypography get textTheme =>
      AcademyTypography(colorScheme.onSurface, settings: typography);
  CupertinoThemeData get cupertino => CupertinoThemeData(
    brightness: brightness,
    primaryColor: colorScheme.accentForeground,
    scaffoldBackgroundColor: scaffoldBackgroundColor,
    barBackgroundColor: scaffoldBackgroundColor,
    textTheme: CupertinoTextThemeData(
      textStyle: textTheme.bodyLarge,
      navTitleTextStyle: textTheme.titleMedium,
      navActionTextStyle: textTheme.bodyLarge.copyWith(
        color: colorScheme.accentForeground,
      ),
      navLargeTitleTextStyle: textTheme.displaySmall,
      actionTextStyle: textTheme.bodyLarge.copyWith(
        color: colorScheme.accentForeground,
      ),
    ),
  );
}

AcademyThemeData academyTheme(
  Brightness brightness, {
  Color accent = AcademyTokens.brand,
  AcademyColors? colors,
  AcademyRadii radii = const AcademyRadii(),
  AcademyPaddings paddings = const AcademyPaddings(),
  AcademyTypographySettings typography = const AcademyTypographySettings(),
  AcademyInteractionTheme interaction = const AcademyInteractionTheme(),
}) => AcademyThemeData(
  brightness,
  accent,
  colors: colors,
  radii: radii,
  paddings: paddings,
  typography: typography,
  interaction: interaction,
);
