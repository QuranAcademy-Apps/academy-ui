import 'package:flutter/cupertino.dart';

enum AcademyTone { neutral, success, warning, error }

/// Semantic color contract. Clients may implement it or override the defaults.
abstract interface class AcademyColors {
  Color get primary;
  Color get onPrimary;
  Color get secondary;
  Color get onSecondary;
  Color get surface;
  Color get onSurface;
  Color get onSurfaceVariant;
  Color get surfaceContainerHighest;
  Color get outline;
  Color get outlineVariant;
  Color get primaryContainer;
  Color get secondaryContainer;
  Color get error;
  Color get complementary;
  Color get complementaryContainer;
  Color get scaffoldBackground;
  Color get segmentBackground;
  Color get segmentSelected;
  Color get segmentShadow;
  Color get menuHighlight;
  Color get iconOnColoredSurface;
  Color get modalBarrier;
  Color get chromeGradientStart;
  Color get chromeGradientEnd;
  Color get chromeSurface;
  Color get chromeTintedSurface;
  Color get chromeBorder;
  Color toneForeground(AcademyTone tone);
  Color toneContainer(AcademyTone tone);
}

/// Resolve a client palette for the active brightness and accent.
typedef AcademyColorsBuilder = AcademyColors Function(
  Brightness brightness,
  Color accent,
);

/// Immutable resolved palette, with partial overrides and complete replacement.
@immutable
class AcademyColorsData implements AcademyColors {
  AcademyColorsData({
    required this.primary,
    required this.onPrimary,
    required this.secondary,
    required this.onSecondary,
    required this.surface,
    required this.onSurface,
    required this.onSurfaceVariant,
    required this.surfaceContainerHighest,
    required this.outline,
    required this.outlineVariant,
    required this.primaryContainer,
    required this.secondaryContainer,
    required this.error,
    required this.complementary,
    required this.complementaryContainer,
    required this.scaffoldBackground,
    required this.segmentBackground,
    required this.segmentSelected,
    required this.segmentShadow,
    required this.menuHighlight,
    required this.iconOnColoredSurface,
    required this.modalBarrier,
    required this.chromeGradientStart,
    required this.chromeGradientEnd,
    required this.chromeSurface,
    required this.chromeTintedSurface,
    required this.chromeBorder,
    required Map<AcademyTone, Color> toneForegrounds,
    required Map<AcademyTone, Color> toneContainers,
  }) : _toneForegrounds = Map.unmodifiable(toneForegrounds),
       _toneContainers = Map.unmodifiable(toneContainers) {
    for (final tone in AcademyTone.values) {
      if (!_toneForegrounds.containsKey(tone) ||
          !_toneContainers.containsKey(tone)) {
        throw ArgumentError(
          'Each status tone requires foreground and container colors: $tone',
        );
      }
    }
  }

  factory AcademyColorsData.from(AcademyColors colors) => AcademyColorsData(
    primary: colors.primary,
    onPrimary: colors.onPrimary,
    secondary: colors.secondary,
    onSecondary: colors.onSecondary,
    surface: colors.surface,
    onSurface: colors.onSurface,
    onSurfaceVariant: colors.onSurfaceVariant,
    surfaceContainerHighest: colors.surfaceContainerHighest,
    outline: colors.outline,
    outlineVariant: colors.outlineVariant,
    primaryContainer: colors.primaryContainer,
    secondaryContainer: colors.secondaryContainer,
    error: colors.error,
    complementary: colors.complementary,
    complementaryContainer: colors.complementaryContainer,
    scaffoldBackground: colors.scaffoldBackground,
    segmentBackground: colors.segmentBackground,
    segmentSelected: colors.segmentSelected,
    segmentShadow: colors.segmentShadow,
    menuHighlight: colors.menuHighlight,
    iconOnColoredSurface: colors.iconOnColoredSurface,
    modalBarrier: colors.modalBarrier,
    chromeGradientStart: colors.chromeGradientStart,
    chromeGradientEnd: colors.chromeGradientEnd,
    chromeSurface: colors.chromeSurface,
    chromeTintedSurface: colors.chromeTintedSurface,
    chromeBorder: colors.chromeBorder,
    toneForegrounds: {
      for (final tone in AcademyTone.values) tone: colors.toneForeground(tone),
    },
    toneContainers: {
      for (final tone in AcademyTone.values) tone: colors.toneContainer(tone),
    },
  );
  @override
  final Color primary;
  @override
  final Color onPrimary;
  @override
  final Color secondary;
  @override
  final Color onSecondary;
  @override
  final Color surface;
  @override
  final Color onSurface;
  @override
  final Color onSurfaceVariant;
  @override
  final Color surfaceContainerHighest;
  @override
  final Color outline;
  @override
  final Color outlineVariant;
  @override
  final Color primaryContainer;
  @override
  final Color secondaryContainer;
  @override
  final Color error;
  @override
  final Color complementary;
  @override
  final Color complementaryContainer;
  @override
  final Color scaffoldBackground;
  @override
  final Color segmentBackground;
  @override
  final Color segmentSelected;
  @override
  final Color segmentShadow;
  @override
  final Color menuHighlight;
  @override
  final Color iconOnColoredSurface;
  @override
  final Color modalBarrier;
  @override
  final Color chromeGradientStart;
  @override
  final Color chromeGradientEnd;
  @override
  final Color chromeSurface;
  @override
  final Color chromeTintedSurface;
  @override
  final Color chromeBorder;
  final Map<AcademyTone, Color> _toneForegrounds, _toneContainers;
  @override
  Color toneForeground(AcademyTone tone) => _toneForegrounds[tone]!;
  @override
  Color toneContainer(AcademyTone tone) => _toneContainers[tone]!;
}

/// Any palette supports partial overrides; omitted values retain their defaults.
extension AcademyColorsOverrides on AcademyColors {
  AcademyColorsData copyWith({
    Color? primary,
    Color? onPrimary,
    Color? secondary,
    Color? onSecondary,
    Color? surface,
    Color? onSurface,
    Color? onSurfaceVariant,
    Color? surfaceContainerHighest,
    Color? outline,
    Color? outlineVariant,
    Color? primaryContainer,
    Color? secondaryContainer,
    Color? error,
    Color? complementary,
    Color? complementaryContainer,
    Color? scaffoldBackground,
    Color? segmentBackground,
    Color? segmentSelected,
    Color? segmentShadow,
    Color? menuHighlight,
    Color? iconOnColoredSurface,
    Color? modalBarrier,
    Color? chromeGradientStart,
    Color? chromeGradientEnd,
    Color? chromeSurface,
    Color? chromeTintedSurface,
    Color? chromeBorder,
    Map<AcademyTone, Color>? toneForegrounds,
    Map<AcademyTone, Color>? toneContainers,
  }) => AcademyColorsData(
    primary: primary ?? this.primary,
    onPrimary: onPrimary ?? this.onPrimary,
    secondary: secondary ?? this.secondary,
    onSecondary: onSecondary ?? this.onSecondary,
    surface: surface ?? this.surface,
    onSurface: onSurface ?? this.onSurface,
    onSurfaceVariant: onSurfaceVariant ?? this.onSurfaceVariant,
    surfaceContainerHighest:
        surfaceContainerHighest ?? this.surfaceContainerHighest,
    outline: outline ?? this.outline,
    outlineVariant: outlineVariant ?? this.outlineVariant,
    primaryContainer: primaryContainer ?? this.primaryContainer,
    secondaryContainer: secondaryContainer ?? this.secondaryContainer,
    error: error ?? this.error,
    complementary: complementary ?? this.complementary,
    complementaryContainer:
        complementaryContainer ?? this.complementaryContainer,
    scaffoldBackground: scaffoldBackground ?? this.scaffoldBackground,
    segmentBackground: segmentBackground ?? this.segmentBackground,
    segmentSelected: segmentSelected ?? this.segmentSelected,
    segmentShadow: segmentShadow ?? this.segmentShadow,
    menuHighlight: menuHighlight ?? this.menuHighlight,
    iconOnColoredSurface: iconOnColoredSurface ?? this.iconOnColoredSurface,
    modalBarrier: modalBarrier ?? this.modalBarrier,
    chromeGradientStart: chromeGradientStart ?? this.chromeGradientStart,
    chromeGradientEnd: chromeGradientEnd ?? this.chromeGradientEnd,
    chromeSurface: chromeSurface ?? this.chromeSurface,
    chromeTintedSurface: chromeTintedSurface ?? this.chromeTintedSurface,
    chromeBorder: chromeBorder ?? this.chromeBorder,
    toneForegrounds: {
      for (final tone in AcademyTone.values)
        tone: toneForegrounds?[tone] ?? toneForeground(tone),
    },
    toneContainers: {
      for (final tone in AcademyTone.values)
        tone: toneContainers?[tone] ?? toneContainer(tone),
    },
  );
}
