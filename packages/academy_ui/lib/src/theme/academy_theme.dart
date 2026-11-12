import 'academy_interaction_theme.dart';
import 'academy_icons.dart';
import 'academy_sizes.dart';
import 'academy_button_theme.dart';
import 'academy_chrome_button_theme.dart';
import 'academy_chrome_material.dart';
import 'academy_segmented_theme.dart';
import 'academy_tab_bar_theme.dart';
import 'academy_table_theme.dart';
import 'academy_toast_theme.dart';
import 'academy_row_icons.dart';
export 'academy_interaction_theme.dart';
import 'academy_palette.dart';
export 'academy_palette.dart';
import 'academy_radii.dart';
import 'academy_paddings.dart';
import 'academy_typography.dart';
export 'academy_icons.dart';
export 'academy_sizes.dart';
export 'academy_button_theme.dart';
export 'academy_chrome_button_theme.dart';
export 'academy_chrome_material.dart';
export 'academy_segmented_theme.dart';
export 'academy_tab_bar_theme.dart';
export 'academy_table_theme.dart';
export 'academy_toast_theme.dart';
export 'academy_radii.dart';
export 'academy_paddings.dart';
export 'academy_typography.dart';

import 'package:cupertino_ui/cupertino_ui.dart';

import '../widgets/navigation/chrome/academy_chrome.dart'
    show AcademyChromeColors;

import 'academy_colors.dart';
export 'academy_colors.dart';

abstract final class AcademyTokens {
  static const space = 8.0;
  static const inlineGap = 12.0;
  static const labelGap = 6.0;
  static const tableInset = 16.0;
  static const tableRowHeight = 52.0;
  static const gutter = 20.0;
  static const radius = AcademyRadii.defaultSurface;
  static const controlRadius = AcademyRadii.defaultButton;
  static const fieldRadius = AcademyRadii.defaultField;
  static const target = 44.0;
  static const largeTarget = 48.0;
  static const buttonHeight = 52.0;
  static const actionButtonHeight = 64.0;
  static const pillHeight = 36.0;
  static const pillIconExtent = 15.0;
  static const actionIconExtent = 24.0;
  static const timelineDotExtent = 24.0;
  static const timelineLineWidth = 2.0;
  static const adaptiveTextScale = 1.5;
  static const metadataHorizontalWidth = 280.0;
  static const tableIconExtent = 30.0;
  static const motion = Duration(milliseconds: 180);
  static const searchOpenMotion = Duration(milliseconds: 220);
  static const selectionMotion = Duration(milliseconds: 240);
  static const pressMotion = Duration(milliseconds: 260);
  static const buttonPressMotion = Duration(milliseconds: 100);
  static const buttonReleaseMotion = Duration(milliseconds: 100);
  static const buttonMaximumShrink = 5.0;
  // Backdrop color correction, not a painted overlay or child opacity.
  static const chromeBlurToneStrength = 0.54;
  static const chromeBlurSaturation = 1.25;
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
    this.chromeColors = const AcademyChromeColors(),
    this.icons = const AcademyIcons(),
    this.sizes = const AcademySizes(),
    this.toast = const AcademyToastTheme(),
    this.table = const AcademyTableTheme(),
    this.tabBar = const AcademyTabBarTheme(),
    this.chromeMaterial = const AcademyChromeMaterial(),
    this.chromeButton = const AcademyChromeButtonTheme(),
    this.segmented = const AcademySegmentedTheme(),
    this.button = const AcademyButtonTheme(),
    this.surfaceContinuousCorners = true,
    this.inlineInfoColor,
    this.chromeBottomInsetOf,
    this.switchColor,
    this.checkmarkColor,
    this.feedbackLoadingIndicator,
    this.rowIconColors = const {},
  }) : colorScheme = colors ?? AcademyPalette(brightness, accent);
  final AcademyInteractionTheme interaction;

  /// Glyphs the library draws on its own.
  final AcademyIcons icons;

  /// Component sizes.
  final AcademySizes sizes;

  /// Look and placement of [AcademyToastOverlay].
  final AcademyToastTheme toast;

  /// Look of tables and rows.
  final AcademyTableTheme table;

  /// Look and placement of the tab bar.
  final AcademyTabBarTheme tabBar;

  /// Replaces [academyChromeBottomOf], for example with
  /// [academyAndroidChromeBottomInset]. Must not call it back.
  final double Function(BuildContext context)? chromeBottomInsetOf;

  /// Surface of chrome controls.
  final AcademyChromeMaterial chromeMaterial;

  /// Look of chrome buttons, groups and title capsules.
  final AcademyChromeButtonTheme chromeButton;

  /// Look of the fitted segmented control.
  final AcademySegmentedTheme segmented;

  /// Look of buttons.
  final AcademyButtonTheme button;

  /// Superellipse corners on [AcademySurface]; false draws circular ones.
  final bool surfaceContinuousCorners;

  /// [AcademyInfoButton.inline] symbol; default: the accent.
  final Color? inlineInfoColor;

  /// [AcademySwitch] track; default: the accent fill.
  final Color? switchColor;

  /// [AcademyCheckmark] color; default: the text color.
  final Color? checkmarkColor;

  /// Loading state of [AcademyFeedback]; default: an activity indicator.
  final Widget? feedbackLoadingIndicator;

  /// Replaces the default tile color of an [AcademyRowIcons] role.
  final Map<AcademyRowIcons, Color> rowIconColors;

  /// Navigation colors for this brightness; [AcademyChromeTheme] may override.
  final AcademyChromeColors chromeColors;
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
    AcademyChromeColors? chromeColors,
    AcademyIcons? icons,
    AcademySizes? sizes,
    AcademyToastTheme? toast,
    AcademyTableTheme? table,
    AcademyTabBarTheme? tabBar,
    AcademyChromeMaterial? chromeMaterial,
    AcademyChromeButtonTheme? chromeButton,
    AcademySegmentedTheme? segmented,
    AcademyButtonTheme? button,
    bool? surfaceContinuousCorners,
    Color? inlineInfoColor,
    double Function(BuildContext context)? chromeBottomInsetOf,
    Color? switchColor,
    Color? checkmarkColor,
    Widget? feedbackLoadingIndicator,
    Map<AcademyRowIcons, Color>? rowIconColors,
  }) => AcademyThemeData(
    brightness,
    colorScheme.accentColor,
    colors: colors ?? colorScheme,
    radii: radii ?? this.radii,
    paddings: paddings ?? this.paddings,
    typography: typography ?? this.typography,
    interaction: interaction ?? this.interaction,
    chromeColors: chromeColors ?? this.chromeColors,
    icons: icons ?? this.icons,
    sizes: sizes ?? this.sizes,
    toast: toast ?? this.toast,
    table: table ?? this.table,
    tabBar: tabBar ?? this.tabBar,
    chromeMaterial: chromeMaterial ?? this.chromeMaterial,
    chromeButton: chromeButton ?? this.chromeButton,
    segmented: segmented ?? this.segmented,
    button: button ?? this.button,
    surfaceContinuousCorners:
        surfaceContinuousCorners ?? this.surfaceContinuousCorners,
    inlineInfoColor: inlineInfoColor ?? this.inlineInfoColor,
    chromeBottomInsetOf: chromeBottomInsetOf ?? this.chromeBottomInsetOf,
    switchColor: switchColor ?? this.switchColor,
    checkmarkColor: checkmarkColor ?? this.checkmarkColor,
    feedbackLoadingIndicator:
        feedbackLoadingIndicator ?? this.feedbackLoadingIndicator,
    rowIconColors: rowIconColors ?? this.rowIconColors,
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
  AcademyChromeColors chromeColors = const AcademyChromeColors(),
  AcademyIcons icons = const AcademyIcons(),
  AcademySizes sizes = const AcademySizes(),
  AcademyToastTheme toast = const AcademyToastTheme(),
  AcademyTableTheme table = const AcademyTableTheme(),
  AcademyTabBarTheme tabBar = const AcademyTabBarTheme(),
  AcademyChromeMaterial chromeMaterial = const AcademyChromeMaterial(),
  double Function(BuildContext context)? chromeBottomInsetOf,
  AcademyChromeButtonTheme chromeButton = const AcademyChromeButtonTheme(),
  AcademySegmentedTheme segmented = const AcademySegmentedTheme(),
  AcademyButtonTheme button = const AcademyButtonTheme(),
  bool surfaceContinuousCorners = true,
  Color? inlineInfoColor,
  Color? switchColor,
  Color? checkmarkColor,
  Widget? feedbackLoadingIndicator,
  Map<AcademyRowIcons, Color> rowIconColors = const {},
}) => AcademyThemeData(
  brightness,
  accent,
  colors: colors,
  radii: radii,
  paddings: paddings,
  typography: typography,
  interaction: interaction,
  chromeColors: chromeColors,
  icons: icons,
  sizes: sizes,
  toast: toast,
  table: table,
  tabBar: tabBar,
  chromeMaterial: chromeMaterial,
  chromeButton: chromeButton,
  segmented: segmented,
  button: button,
  surfaceContinuousCorners: surfaceContinuousCorners,
  inlineInfoColor: inlineInfoColor,
  chromeBottomInsetOf: chromeBottomInsetOf,
  switchColor: switchColor,
  checkmarkColor: checkmarkColor,
  feedbackLoadingIndicator: feedbackLoadingIndicator,
  rowIconColors: rowIconColors,
);
