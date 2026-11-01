import 'package:cupertino_ui/cupertino_ui.dart';

Color _parseHex(String hex) {
  // Accepts formats: "#RRGGBB", "RRGGBB", "#AARRGGBB", "AARRGGBB"
  String normalized = hex.trim();
  if (normalized.startsWith('#')) normalized = normalized.substring(1);
  if (normalized.length == 6) normalized = 'FF$normalized'; // add opaque alpha
  final value = int.parse(normalized, radix: 16);
  return Color(value);
}

/// Platform colours for native Cupertino controls, independent of app palettes.
abstract final class AppSystemColors {
  static const alertAction = CupertinoColors.systemBlue;

  static Color errorOf(BuildContext context) =>
      AppColorsProvider.maybeOf(context)?.errorColor ??
      CupertinoColors.systemRed.resolveFrom(context);

  static Color warningOf(BuildContext context) =>
      AppColorsProvider.maybeOf(context)?.warningColor ??
      CupertinoColors.systemOrange.resolveFrom(context);

  static Color actionOf(BuildContext context) =>
      AppColorsProvider.maybeOf(context)?.actionAccent ??
      alertAction.resolveFrom(context);
}

/// Independent material colours for the reader's recolourable artwork.
typedef ReaderOrnamentPalette = ({Color line, Color field, Color panel});

/// Design tokens, mirrors iOS ThemeColors
class AppColors {
  // Tint
  final Color accent;

  /// Reader ornaments and playback controls may use a quieter tint.
  final Color? readerAccent;

  /// Decorative contours and surfaces, separate from selection/playback roles.
  final ReaderOrnamentPalette? readerOrnamentPalette;

  /// Blue actions and quiet media surfaces can be styled independently.
  final Color? actionAccent;
  final Color? mediaAccent;
  final Color sectionHeader;
  final Color? errorColor;
  final Color? warningColor;
  final Color? indigoColor;

  /// Optional control-specific colors; other palettes retain accent styling.
  final Color? tabSelectionBackground;
  final Color? tabInactiveForeground;
  final Color iconDisclosure;
  final Color? switchActive;

  // Background
  final Color backgroundPrimary;
  final Color backgroundSecondary;

  /// Mushaf reading page ("paper") background. Defaults to [backgroundSecondary]
  /// for every theme; a theme may override it (e.g. a tinted mushaf page) without
  /// affecting cards/sheets that keep using [backgroundSecondary].
  final Color backgroundMushaf;

  /// Explicit reader tile surface; null retains the v1 derivation.
  final Color? backgroundTranslation;
  final Color backgroundTertiary;

  /// Shared selected-row and reader ayah highlight, behind word tiles.
  final Color ayahSelectionBackground;
  final Color backgroundControl;
  final Color backgroundInverted;
  final Color backgroundList;
  final Color backgroundStroke;
  final Color backgroundNavBar;
  final Color backgroundSlider;
  final Color backgroundOverlay;

  // Text
  final Color textPrimary;
  final Color textSecondary;
  final Color textTertiary;
  final Color textInactiveTabBar;
  final Color mushafText;
  final Color translationHighlight;

  // Icon
  final Color iconPrimary;
  final Color iconSecondary;
  final Color iconTertiary;
  final Color iconInactive;

  // Fill
  final Color fillPrimary;
  final Color fillSecondary;

  // Other
  final Color disabled;
  final Color strokePrimary;

  // Separator
  final Color separator;

  const AppColors({
    // Tint
    required this.accent,
    this.readerAccent,
    this.readerOrnamentPalette,
    this.actionAccent,
    this.mediaAccent,
    Color? sectionHeader,
    this.errorColor,
    this.warningColor,
    this.indigoColor,
    this.tabSelectionBackground,
    this.tabInactiveForeground,
    Color? iconDisclosure,
    this.switchActive,
    // Background
    required this.backgroundPrimary,
    required this.backgroundSecondary,
    required this.backgroundMushaf,
    this.backgroundTranslation,
    required this.backgroundTertiary,
    Color? ayahSelectionBackground,
    required this.backgroundControl,
    required this.backgroundInverted,
    required this.backgroundList,
    required this.backgroundStroke,
    required this.backgroundNavBar,
    required this.backgroundSlider,
    required this.backgroundOverlay,
    // Text
    required this.textPrimary,
    required this.textSecondary,
    required this.textTertiary,
    required this.textInactiveTabBar,
    required this.mushafText,
    required this.translationHighlight,
    // Icon
    required this.iconPrimary,
    required this.iconSecondary,
    required this.iconTertiary,
    required this.iconInactive,
    // Fill
    required this.fillPrimary,
    required this.fillSecondary,
    // Other
    required this.disabled,
    required this.strokePrimary,
    // Separator
    required this.separator,
  }) : sectionHeader = sectionHeader ?? textPrimary,
       iconDisclosure = iconDisclosure ?? iconPrimary,
       ayahSelectionBackground = ayahSelectionBackground ?? backgroundTertiary;

  AppColors copyWith({
    Color? accent,
    Color? readerAccent,
    ReaderOrnamentPalette? readerOrnamentPalette,
    Color? actionAccent,
    Color? mediaAccent,
    Color? sectionHeader,
    Color? errorColor,
    Color? warningColor,
    Color? indigoColor,
    Color? tabSelectionBackground,
    Color? tabInactiveForeground,
    Color? iconDisclosure,
    Color? switchActive,
    Color? backgroundPrimary,
    Color? backgroundSecondary,
    Color? backgroundMushaf,
    Color? backgroundTranslation,
    Color? backgroundTertiary,
    Color? ayahSelectionBackground,
    Color? backgroundControl,
    Color? backgroundInverted,
    Color? backgroundList,
    Color? backgroundStroke,
    Color? backgroundNavBar,
    Color? backgroundSlider,
    Color? backgroundOverlay,
    Color? textPrimary,
    Color? textSecondary,
    Color? textTertiary,
    Color? textInactiveTabBar,
    Color? mushafText,
    Color? translationHighlight,
    Color? iconPrimary,
    Color? iconSecondary,
    Color? iconTertiary,
    Color? iconInactive,
    Color? fillPrimary,
    Color? fillSecondary,
    Color? disabled,
    Color? strokePrimary,
    Color? separator,
  }) {
    return AppColors(
      accent: accent ?? this.accent,
      readerAccent: readerAccent ?? this.readerAccent,
      readerOrnamentPalette:
          readerOrnamentPalette ?? this.readerOrnamentPalette,
      actionAccent: actionAccent ?? this.actionAccent,
      mediaAccent: mediaAccent ?? this.mediaAccent,
      sectionHeader: sectionHeader ?? this.sectionHeader,
      errorColor: errorColor ?? this.errorColor,
      warningColor: warningColor ?? this.warningColor,
      indigoColor: indigoColor ?? this.indigoColor,
      tabSelectionBackground:
          tabSelectionBackground ?? this.tabSelectionBackground,
      tabInactiveForeground:
          tabInactiveForeground ?? this.tabInactiveForeground,
      iconDisclosure: iconDisclosure ?? this.iconDisclosure,
      switchActive: switchActive ?? this.switchActive,
      backgroundPrimary: backgroundPrimary ?? this.backgroundPrimary,
      backgroundSecondary: backgroundSecondary ?? this.backgroundSecondary,
      backgroundMushaf: backgroundMushaf ?? this.backgroundMushaf,
      backgroundTranslation:
          backgroundTranslation ?? this.backgroundTranslation,
      backgroundTertiary: backgroundTertiary ?? this.backgroundTertiary,
      ayahSelectionBackground:
          ayahSelectionBackground ?? this.ayahSelectionBackground,
      backgroundControl: backgroundControl ?? this.backgroundControl,
      backgroundInverted: backgroundInverted ?? this.backgroundInverted,
      backgroundList: backgroundList ?? this.backgroundList,
      backgroundStroke: backgroundStroke ?? this.backgroundStroke,
      backgroundNavBar: backgroundNavBar ?? this.backgroundNavBar,
      backgroundSlider: backgroundSlider ?? this.backgroundSlider,
      backgroundOverlay: backgroundOverlay ?? this.backgroundOverlay,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      textTertiary: textTertiary ?? this.textTertiary,
      textInactiveTabBar: textInactiveTabBar ?? this.textInactiveTabBar,
      mushafText: mushafText ?? this.mushafText,
      translationHighlight: translationHighlight ?? this.translationHighlight,
      iconPrimary: iconPrimary ?? this.iconPrimary,
      iconSecondary: iconSecondary ?? this.iconSecondary,
      iconTertiary: iconTertiary ?? this.iconTertiary,
      iconInactive: iconInactive ?? this.iconInactive,
      fillPrimary: fillPrimary ?? this.fillPrimary,
      fillSecondary: fillSecondary ?? this.fillSecondary,
      disabled: disabled ?? this.disabled,
      strokePrimary: strokePrimary ?? this.strokePrimary,
      separator: separator ?? this.separator,
    );
  }

  AppColors lerp(AppColors? other, double t) {
    if (other == null) return this;

    return AppColors(
      accent: Color.lerp(accent, other.accent, t)!,
      readerAccent: Color.lerp(readerAccent, other.readerAccent, t),
      readerOrnamentPalette: _lerpReaderOrnamentPalette(other, t),
      actionAccent: Color.lerp(actionAccent, other.actionAccent, t),
      mediaAccent: Color.lerp(mediaAccent, other.mediaAccent, t),
      sectionHeader: Color.lerp(sectionHeader, other.sectionHeader, t)!,
      errorColor: Color.lerp(errorColor, other.errorColor, t),
      warningColor: Color.lerp(warningColor, other.warningColor, t),
      indigoColor: Color.lerp(indigoColor, other.indigoColor, t),
      tabSelectionBackground: Color.lerp(
        tabSelectionBackground,
        other.tabSelectionBackground,
        t,
      ),
      tabInactiveForeground: Color.lerp(
        tabInactiveForeground,
        other.tabInactiveForeground,
        t,
      ),
      iconDisclosure: Color.lerp(iconDisclosure, other.iconDisclosure, t)!,
      switchActive: Color.lerp(switchActive, other.switchActive, t),
      backgroundPrimary: Color.lerp(
        backgroundPrimary,
        other.backgroundPrimary,
        t,
      )!,
      backgroundSecondary: Color.lerp(
        backgroundSecondary,
        other.backgroundSecondary,
        t,
      )!,
      backgroundMushaf: Color.lerp(
        backgroundMushaf,
        other.backgroundMushaf,
        t,
      )!,
      backgroundTranslation: Color.lerp(
        backgroundTranslation,
        other.backgroundTranslation,
        t,
      ),
      backgroundTertiary: Color.lerp(
        backgroundTertiary,
        other.backgroundTertiary,
        t,
      )!,
      ayahSelectionBackground: Color.lerp(
        ayahSelectionBackground,
        other.ayahSelectionBackground,
        t,
      )!,
      backgroundControl: Color.lerp(
        backgroundControl,
        other.backgroundControl,
        t,
      )!,
      backgroundInverted: Color.lerp(
        backgroundInverted,
        other.backgroundInverted,
        t,
      )!,
      backgroundList: Color.lerp(backgroundList, other.backgroundList, t)!,
      backgroundStroke: Color.lerp(
        backgroundStroke,
        other.backgroundStroke,
        t,
      )!,
      backgroundNavBar: Color.lerp(
        backgroundNavBar,
        other.backgroundNavBar,
        t,
      )!,
      backgroundSlider: Color.lerp(
        backgroundSlider,
        other.backgroundSlider,
        t,
      )!,
      backgroundOverlay: Color.lerp(
        backgroundOverlay,
        other.backgroundOverlay,
        t,
      )!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      textTertiary: Color.lerp(textTertiary, other.textTertiary, t)!,
      textInactiveTabBar: Color.lerp(
        textInactiveTabBar,
        other.textInactiveTabBar,
        t,
      )!,
      mushafText: Color.lerp(mushafText, other.mushafText, t)!,
      translationHighlight: Color.lerp(
        translationHighlight,
        other.translationHighlight,
        t,
      )!,
      iconPrimary: Color.lerp(iconPrimary, other.iconPrimary, t)!,
      iconSecondary: Color.lerp(iconSecondary, other.iconSecondary, t)!,
      iconTertiary: Color.lerp(iconTertiary, other.iconTertiary, t)!,
      iconInactive: Color.lerp(iconInactive, other.iconInactive, t)!,
      fillPrimary: Color.lerp(fillPrimary, other.fillPrimary, t)!,
      fillSecondary: Color.lerp(fillSecondary, other.fillSecondary, t)!,
      disabled: Color.lerp(disabled, other.disabled, t)!,
      strokePrimary: Color.lerp(strokePrimary, other.strokePrimary, t)!,
      separator: Color.lerp(separator, other.separator, t)!,
    );
  }

  ReaderOrnamentPalette? _lerpReaderOrnamentPalette(AppColors other, double t) {
    if (readerOrnamentPalette == null && other.readerOrnamentPalette == null) {
      return null;
    }
    final begin =
        readerOrnamentPalette ??
        (
          line: readerAccent ?? accent,
          field: ayahSelectionBackground,
          panel: backgroundPrimary,
        );
    final end =
        other.readerOrnamentPalette ??
        (
          line: other.readerAccent ?? other.accent,
          field: other.ayahSelectionBackground,
          panel: other.backgroundPrimary,
        );
    return (
      line: Color.lerp(begin.line, end.line, t)!,
      field: Color.lerp(begin.field, end.field, t)!,
      panel: Color.lerp(begin.panel, end.panel, t)!,
    );
  }
}

/// InheritedWidget for providing AppColors without extra design-system dependencies.
class AppColorsProvider extends InheritedWidget {
  final AppColors colors;

  const AppColorsProvider({
    super.key,
    required this.colors,
    required super.child,
  });

  static AppColors of(BuildContext context) {
    final provider = context
        .dependOnInheritedWidgetOfExactType<AppColorsProvider>();
    assert(provider != null, 'AppColorsProvider not found in context');
    return provider!.colors;
  }

  static AppColors? maybeOf(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<AppColorsProvider>()
        ?.colors;
  }

  @override
  bool updateShouldNotify(AppColorsProvider oldWidget) {
    return colors != oldWidget.colors;
  }
}

/// Convenience access to AppColors from BuildContext.
extension AppColorsContext on BuildContext {
  AppColors get appColors => AppColorsProvider.of(this);
}

// Expose helper for hex parsing
typedef HexColor = Color Function(String hex);
final HexColor hex = _parseHex;
