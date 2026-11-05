import 'package:flutter/cupertino.dart';

enum AcademyTone { neutral, success, warning, error }

/// Semantic color contract. Clients may implement it or override the defaults.
abstract interface class AcademyColors {
  /// The selected accent seed, before contrast or theme adjustments.
  Color get accentColor;

  /// Solid action fill; independent of the accent used for text.
  Color get accentFill;

  /// Readable text and icons on accentFill.
  Color get onAccentFill;

  /// Main call-to-action fill ([AcademyButtonStyle.primary]). Defaults to
  /// [accentFill]; a brand may use a companion color while selection controls
  /// keep the accent.
  Color get actionFill;

  /// Readable text on [actionFill].
  Color get onActionFill;

  /// Accent text and icons on neutral backgrounds.
  Color get accentForeground;

  /// Opaque resting field fill, independent of cards and navigation.
  Color get textFieldBackground;

  /// Inset search field fill inside a panel or card.
  Color get textFieldSecondaryBackground;

  /// Opaque disabled field fill.
  Color get textFieldDisabledBackground;

  /// Entered text and selected values.
  Color get textFieldForeground;

  /// Placeholder, label, helper text and field accessories.
  Color get textFieldSecondaryForeground;

  /// Disabled values and accessories.
  Color get textFieldDisabledForeground;

  /// Resting field boundary; transparent in the default filled style.
  Color get textFieldBorder;

  /// Visible disabled field boundary.
  Color get textFieldDisabledBorder;

  /// Focus ring on a field background.
  Color get textFieldFocusBorder;

  /// Field validation message.
  Color get textFieldErrorForeground;

  /// Legacy accent foreground. Use accentFill for solid buttons.
  Color get primary;
  Color get onPrimary;

  /// Foreground of a tinted button on [secondaryContainer].
  Color get secondary;

  /// Foreground available to clients using [secondary] as a solid surface.
  Color get onSecondary;
  Color get surface;
  Color get onSurface;
  Color get onSurfaceVariant;

  /// Pointers such as chevrons and placeholders; defaults to [onSurfaceVariant].
  Color get labelTertiary;
  Color get surfaceContainerHighest;
  Color get outline;
  Color get outlineVariant;
  Color get primaryContainer;
  Color get onPrimaryContainer;
  Color get secondaryContainer;
  Color get error;
  Color get complementary;
  Color get complementaryContainer;
  Color get scaffoldBackground;

  /// Opaque track and compact utility button fill, independent of page/cards.
  Color get segmentBackground;

  /// Opaque selected segment fill, distinct from [segmentBackground].
  Color get segmentSelected;
  Color get segmentShadow;

  /// Resting fill of menu rows; defaults to [surface].
  Color get menuSurface;
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
    Color? accentColor,
    Color? accentFill,
    Color? onAccentFill,
    Color? actionFill,
    Color? onActionFill,
    Color? accentForeground,
    Color? textFieldBackground,
    Color? textFieldSecondaryBackground,
    Color? textFieldDisabledBackground,
    Color? textFieldForeground,
    Color? textFieldSecondaryForeground,
    Color? textFieldDisabledForeground,
    Color? textFieldBorder,
    Color? textFieldDisabledBorder,
    Color? textFieldFocusBorder,
    Color? textFieldErrorForeground,
    required this.primary,
    required this.onPrimary,
    required this.secondary,
    required this.onSecondary,
    required this.surface,
    required this.onSurface,
    required this.onSurfaceVariant,
    Color? labelTertiary,
    required this.surfaceContainerHighest,
    required this.outline,
    required this.outlineVariant,
    required this.primaryContainer,
    Color? onPrimaryContainer,
    required this.secondaryContainer,
    required this.error,
    required this.complementary,
    required this.complementaryContainer,
    required this.scaffoldBackground,
    required this.segmentBackground,
    required this.segmentSelected,
    required this.segmentShadow,
    Color? menuSurface,
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
  }) : accentColor = accentColor ?? primary,
       menuSurface = menuSurface ?? surface,
       labelTertiary = labelTertiary ?? onSurfaceVariant,
       accentFill = accentFill ?? primary,
       onAccentFill =
           onAccentFill ??
           AcademyContrast.foreground(onPrimary, accentFill ?? primary),
       actionFill = actionFill ?? accentFill ?? primary,
       onActionFill =
           onActionFill ??
           (actionFill == null
               ? onAccentFill ??
                     AcademyContrast.foreground(
                       onPrimary,
                       accentFill ?? primary,
                     )
               : AcademyContrast.foreground(onPrimary, actionFill)),
       accentForeground = accentForeground ?? primary,
       textFieldBackground = textFieldBackground ?? surface,
       textFieldSecondaryBackground =
           textFieldSecondaryBackground ?? surfaceContainerHighest,
       textFieldDisabledBackground =
           textFieldDisabledBackground ?? surfaceContainerHighest,
       textFieldForeground = textFieldForeground ?? onSurface,
       textFieldSecondaryForeground =
           textFieldSecondaryForeground ?? onSurfaceVariant,
       textFieldDisabledForeground =
           textFieldDisabledForeground ?? onSurfaceVariant,
       textFieldBorder = textFieldBorder ?? const Color(0x00000000),
       textFieldDisabledBorder = textFieldDisabledBorder ?? outline,
       textFieldFocusBorder = textFieldFocusBorder ?? primary,
       textFieldErrorForeground = textFieldErrorForeground ?? error,
       onPrimaryContainer =
           onPrimaryContainer ??
           AcademyContrast.foreground(primary, primaryContainer),
       _toneForegrounds = Map.unmodifiable(toneForegrounds),
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
    accentColor: colors.accentColor,
    accentFill: colors.accentFill,
    onAccentFill: colors.onAccentFill,
    actionFill: colors.actionFill,
    onActionFill: colors.onActionFill,
    accentForeground: colors.accentForeground,
    textFieldBackground: colors.textFieldBackground,
    textFieldSecondaryBackground: colors.textFieldSecondaryBackground,
    textFieldDisabledBackground: colors.textFieldDisabledBackground,
    textFieldForeground: colors.textFieldForeground,
    textFieldSecondaryForeground: colors.textFieldSecondaryForeground,
    textFieldDisabledForeground: colors.textFieldDisabledForeground,
    textFieldBorder: colors.textFieldBorder,
    textFieldDisabledBorder: colors.textFieldDisabledBorder,
    textFieldFocusBorder: colors.textFieldFocusBorder,
    textFieldErrorForeground: colors.textFieldErrorForeground,
    primary: colors.primary,
    onPrimary: colors.onPrimary,
    secondary: colors.secondary,
    onSecondary: colors.onSecondary,
    surface: colors.surface,
    onSurface: colors.onSurface,
    onSurfaceVariant: colors.onSurfaceVariant,
    labelTertiary: colors.labelTertiary,
    surfaceContainerHighest: colors.surfaceContainerHighest,
    outline: colors.outline,
    outlineVariant: colors.outlineVariant,
    primaryContainer: colors.primaryContainer,
    onPrimaryContainer: colors.onPrimaryContainer,
    secondaryContainer: colors.secondaryContainer,
    error: colors.error,
    complementary: colors.complementary,
    complementaryContainer: colors.complementaryContainer,
    scaffoldBackground: colors.scaffoldBackground,
    segmentBackground: colors.segmentBackground,
    segmentSelected: colors.segmentSelected,
    segmentShadow: colors.segmentShadow,
    menuSurface: colors.menuSurface,
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
  final Color accentColor;
  @override
  final Color menuSurface;
  @override
  final Color labelTertiary;
  @override
  final Color actionFill;
  @override
  final Color onActionFill;
  @override
  final Color accentFill;
  @override
  final Color onAccentFill;
  @override
  final Color accentForeground;
  @override
  final Color textFieldBackground;
  @override
  final Color textFieldSecondaryBackground;
  @override
  final Color textFieldDisabledBackground;
  @override
  final Color textFieldForeground;
  @override
  final Color textFieldSecondaryForeground;
  @override
  final Color textFieldDisabledForeground;
  @override
  final Color textFieldBorder;
  @override
  final Color textFieldDisabledBorder;
  @override
  final Color textFieldFocusBorder;
  @override
  final Color textFieldErrorForeground;
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
  final Color onPrimaryContainer;
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
  /// Interactive boundaries are stronger than decorative table separators.
  Color get controlBorder => AcademyContrast.foreground(
    AcademyContrast.foreground(outlineVariant, surface, minimum: 3),
    scaffoldBackground,
    minimum: 3,
  );

  /// High-contrast boundary is derived from field roles, never card surfaces.
  Color get textFieldControlBorder => AcademyContrast.foreground(
    textFieldDisabledBorder,
    textFieldBackground,
    minimum: 3,
  );

  /// Overrides are resolved roles: changing a card does not recolor fields.
  /// Change the accent seed through AcademyAppearance/colorsBuilder to resolve
  /// the whole accent family for the active brightness.
  AcademyColorsData copyWith({
    Color? accentColor,
    Color? accentFill,
    Color? onAccentFill,
    Color? actionFill,
    Color? onActionFill,
    Color? accentForeground,
    Color? textFieldBackground,
    Color? textFieldSecondaryBackground,
    Color? textFieldDisabledBackground,
    Color? textFieldForeground,
    Color? textFieldSecondaryForeground,
    Color? textFieldDisabledForeground,
    Color? textFieldBorder,
    Color? textFieldDisabledBorder,
    Color? textFieldFocusBorder,
    Color? textFieldErrorForeground,
    Color? primary,
    Color? onPrimary,
    Color? secondary,
    Color? onSecondary,
    Color? surface,
    Color? onSurface,
    Color? onSurfaceVariant,
    Color? labelTertiary,
    Color? surfaceContainerHighest,
    Color? outline,
    Color? outlineVariant,
    Color? primaryContainer,
    Color? onPrimaryContainer,
    Color? secondaryContainer,
    Color? error,
    Color? complementary,
    Color? complementaryContainer,
    Color? scaffoldBackground,
    Color? segmentBackground,
    Color? segmentSelected,
    Color? segmentShadow,
    Color? menuSurface,
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
    accentColor: accentColor ?? this.accentColor,
    accentFill: accentFill ?? this.accentFill,
    onAccentFill:
        onAccentFill ??
        (accentFill != null
            ? AcademyContrast.foreground(this.onAccentFill, accentFill)
            : this.onAccentFill),
    // An action fill that follows the accent keeps following it.
    actionFill:
        actionFill ??
        (accentFill != null && this.actionFill == this.accentFill
            ? accentFill
            : this.actionFill),
    onActionFill:
        onActionFill ??
        (actionFill != null
            ? AcademyContrast.foreground(this.onActionFill, actionFill)
            : accentFill != null && this.actionFill == this.accentFill
            ? onAccentFill ??
                  AcademyContrast.foreground(this.onAccentFill, accentFill)
            : this.onActionFill),
    accentForeground: accentForeground ?? this.accentForeground,
    textFieldBackground: textFieldBackground ?? this.textFieldBackground,
    textFieldSecondaryBackground:
        textFieldSecondaryBackground ?? this.textFieldSecondaryBackground,
    textFieldDisabledBackground:
        textFieldDisabledBackground ?? this.textFieldDisabledBackground,
    textFieldForeground: textFieldForeground ?? this.textFieldForeground,
    textFieldSecondaryForeground:
        textFieldSecondaryForeground ?? this.textFieldSecondaryForeground,
    textFieldDisabledForeground:
        textFieldDisabledForeground ?? this.textFieldDisabledForeground,
    textFieldBorder: textFieldBorder ?? this.textFieldBorder,
    textFieldDisabledBorder:
        textFieldDisabledBorder ?? this.textFieldDisabledBorder,
    textFieldFocusBorder: textFieldFocusBorder ?? this.textFieldFocusBorder,
    textFieldErrorForeground:
        textFieldErrorForeground ?? this.textFieldErrorForeground,
    primary: primary ?? this.primary,
    onPrimary: onPrimary ?? this.onPrimary,
    secondary: secondary ?? this.secondary,
    onSecondary: onSecondary ?? this.onSecondary,
    surface: surface ?? this.surface,
    onSurface: onSurface ?? this.onSurface,
    onSurfaceVariant: onSurfaceVariant ?? this.onSurfaceVariant,
    labelTertiary:
        labelTertiary ??
        (onSurfaceVariant != null &&
                this.labelTertiary == this.onSurfaceVariant
            ? onSurfaceVariant
            : this.labelTertiary),
    surfaceContainerHighest:
        surfaceContainerHighest ?? this.surfaceContainerHighest,
    outline: outline ?? this.outline,
    outlineVariant: outlineVariant ?? this.outlineVariant,
    primaryContainer: primaryContainer ?? this.primaryContainer,
    onPrimaryContainer:
        onPrimaryContainer ??
        (primary != null || primaryContainer != null
            ? AcademyContrast.foreground(
                primary ?? this.primary,
                primaryContainer ?? this.primaryContainer,
              )
            : this.onPrimaryContainer),
    secondaryContainer: secondaryContainer ?? this.secondaryContainer,
    error: error ?? this.error,
    complementary: complementary ?? this.complementary,
    complementaryContainer:
        complementaryContainer ?? this.complementaryContainer,
    scaffoldBackground: scaffoldBackground ?? this.scaffoldBackground,
    segmentBackground: segmentBackground ?? this.segmentBackground,
    segmentSelected: segmentSelected ?? this.segmentSelected,
    segmentShadow: segmentShadow ?? this.segmentShadow,
    // A menu surface that follows the card surface keeps following it.
    menuSurface:
        menuSurface ??
        (surface != null && this.menuSurface == this.surface
            ? surface
            : this.menuSurface),
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

/// Contrast is checked against the actual surface, rather than an accent alone.
abstract final class AcademyContrast {
  static double ratio(Color foreground, Color background) {
    final a = Color.alphaBlend(foreground, background).computeLuminance();
    final b = background.computeLuminance();
    return a > b ? (a + .05) / (b + .05) : (b + .05) / (a + .05);
  }

  static Color foreground(
    Color preferred,
    Color background, {
    double minimum = 4.5,
  }) {
    if (ratio(preferred, background) >= minimum) return preferred;
    final target =
        ratio(CupertinoColors.black, background) >
            ratio(CupertinoColors.white, background)
        ? CupertinoColors.black
        : CupertinoColors.white;
    var color = preferred;
    for (var i = 0; i < 64; i++) {
      color = Color.lerp(color, target, .08)!;
      if (ratio(color, background) >= minimum) return color;
    }
    return target;
  }
}

/// Editable semantic roles, including each status pair.
enum AcademyColorRole {
  accentColor,
  accentFill,
  onAccentFill,
  actionFill,
  onActionFill,
  accentForeground,
  textFieldBackground,
  textFieldSecondaryBackground,
  textFieldDisabledBackground,
  textFieldForeground,
  textFieldSecondaryForeground,
  textFieldDisabledForeground,
  textFieldBorder,
  textFieldDisabledBorder,
  textFieldFocusBorder,
  textFieldErrorForeground,
  primary,
  onPrimary,
  secondary,
  onSecondary,
  surface,
  onSurface,
  onSurfaceVariant,
  labelTertiary,
  surfaceContainerHighest,
  outline,
  outlineVariant,
  primaryContainer,
  onPrimaryContainer,
  secondaryContainer,
  error,
  complementary,
  complementaryContainer,
  scaffoldBackground,
  segmentBackground,
  segmentSelected,
  segmentShadow,
  menuSurface,
  menuHighlight,
  iconOnColoredSurface,
  modalBarrier,
  chromeGradientStart,
  chromeGradientEnd,
  chromeSurface,
  chromeTintedSurface,
  chromeBorder,
  neutralForeground,
  neutralContainer,
  successForeground,
  successContainer,
  warningForeground,
  warningContainer,
  errorForeground,
  errorContainer,
}

extension AcademyColorRoles on AcademyColors {
  Color value(AcademyColorRole role) => switch (role) {
    AcademyColorRole.accentColor => accentColor,
    AcademyColorRole.accentFill => accentFill,
    AcademyColorRole.onAccentFill => onAccentFill,
    AcademyColorRole.actionFill => actionFill,
    AcademyColorRole.onActionFill => onActionFill,
    AcademyColorRole.accentForeground => accentForeground,
    AcademyColorRole.textFieldBackground => textFieldBackground,
    AcademyColorRole.textFieldSecondaryBackground =>
      textFieldSecondaryBackground,
    AcademyColorRole.textFieldDisabledBackground => textFieldDisabledBackground,
    AcademyColorRole.textFieldForeground => textFieldForeground,
    AcademyColorRole.textFieldSecondaryForeground =>
      textFieldSecondaryForeground,
    AcademyColorRole.textFieldDisabledForeground => textFieldDisabledForeground,
    AcademyColorRole.textFieldBorder => textFieldBorder,
    AcademyColorRole.textFieldDisabledBorder => textFieldDisabledBorder,
    AcademyColorRole.textFieldFocusBorder => textFieldFocusBorder,
    AcademyColorRole.textFieldErrorForeground => textFieldErrorForeground,
    AcademyColorRole.primary => primary,
    AcademyColorRole.onPrimary => onPrimary,
    AcademyColorRole.secondary => secondary,
    AcademyColorRole.onSecondary => onSecondary,
    AcademyColorRole.surface => surface,
    AcademyColorRole.onSurface => onSurface,
    AcademyColorRole.onSurfaceVariant => onSurfaceVariant,
    AcademyColorRole.labelTertiary => labelTertiary,
    AcademyColorRole.surfaceContainerHighest => surfaceContainerHighest,
    AcademyColorRole.outline => outline,
    AcademyColorRole.outlineVariant => outlineVariant,
    AcademyColorRole.primaryContainer => primaryContainer,
    AcademyColorRole.onPrimaryContainer => onPrimaryContainer,
    AcademyColorRole.secondaryContainer => secondaryContainer,
    AcademyColorRole.error => error,
    AcademyColorRole.complementary => complementary,
    AcademyColorRole.complementaryContainer => complementaryContainer,
    AcademyColorRole.scaffoldBackground => scaffoldBackground,
    AcademyColorRole.segmentBackground => segmentBackground,
    AcademyColorRole.segmentSelected => segmentSelected,
    AcademyColorRole.segmentShadow => segmentShadow,
    AcademyColorRole.menuSurface => menuSurface,
    AcademyColorRole.menuHighlight => menuHighlight,
    AcademyColorRole.iconOnColoredSurface => iconOnColoredSurface,
    AcademyColorRole.modalBarrier => modalBarrier,
    AcademyColorRole.chromeGradientStart => chromeGradientStart,
    AcademyColorRole.chromeGradientEnd => chromeGradientEnd,
    AcademyColorRole.chromeSurface => chromeSurface,
    AcademyColorRole.chromeTintedSurface => chromeTintedSurface,
    AcademyColorRole.chromeBorder => chromeBorder,
    AcademyColorRole.neutralForeground => toneForeground(AcademyTone.neutral),
    AcademyColorRole.neutralContainer => toneContainer(AcademyTone.neutral),
    AcademyColorRole.successForeground => toneForeground(AcademyTone.success),
    AcademyColorRole.successContainer => toneContainer(AcademyTone.success),
    AcademyColorRole.warningForeground => toneForeground(AcademyTone.warning),
    AcademyColorRole.warningContainer => toneContainer(AcademyTone.warning),
    AcademyColorRole.errorForeground => toneForeground(AcademyTone.error),
    AcademyColorRole.errorContainer => toneContainer(AcademyTone.error),
  };
  AcademyColorsData withValue(
    AcademyColorRole role,
    Color color,
  ) => switch (role) {
    AcademyColorRole.accentColor => copyWith(accentColor: color),
    AcademyColorRole.accentFill => copyWith(accentFill: color),
    AcademyColorRole.onAccentFill => copyWith(onAccentFill: color),
    AcademyColorRole.actionFill => copyWith(actionFill: color),
    AcademyColorRole.onActionFill => copyWith(onActionFill: color),
    AcademyColorRole.accentForeground => copyWith(accentForeground: color),
    AcademyColorRole.textFieldBackground => copyWith(
      textFieldBackground: color,
    ),
    AcademyColorRole.textFieldSecondaryBackground => copyWith(
      textFieldSecondaryBackground: color,
    ),
    AcademyColorRole.textFieldDisabledBackground => copyWith(
      textFieldDisabledBackground: color,
    ),
    AcademyColorRole.textFieldForeground => copyWith(
      textFieldForeground: color,
    ),
    AcademyColorRole.textFieldSecondaryForeground => copyWith(
      textFieldSecondaryForeground: color,
    ),
    AcademyColorRole.textFieldDisabledForeground => copyWith(
      textFieldDisabledForeground: color,
    ),
    AcademyColorRole.textFieldBorder => copyWith(textFieldBorder: color),
    AcademyColorRole.textFieldDisabledBorder => copyWith(
      textFieldDisabledBorder: color,
    ),
    AcademyColorRole.textFieldFocusBorder => copyWith(
      textFieldFocusBorder: color,
    ),
    AcademyColorRole.textFieldErrorForeground => copyWith(
      textFieldErrorForeground: color,
    ),
    AcademyColorRole.primary => copyWith(primary: color),
    AcademyColorRole.onPrimary => copyWith(onPrimary: color),
    AcademyColorRole.secondary => copyWith(secondary: color),
    AcademyColorRole.onSecondary => copyWith(onSecondary: color),
    AcademyColorRole.surface => copyWith(surface: color),
    AcademyColorRole.onSurface => copyWith(onSurface: color),
    AcademyColorRole.onSurfaceVariant => copyWith(onSurfaceVariant: color),
    AcademyColorRole.labelTertiary => copyWith(labelTertiary: color),
    AcademyColorRole.surfaceContainerHighest => copyWith(
      surfaceContainerHighest: color,
    ),
    AcademyColorRole.outline => copyWith(outline: color),
    AcademyColorRole.outlineVariant => copyWith(outlineVariant: color),
    AcademyColorRole.primaryContainer => copyWith(primaryContainer: color),
    AcademyColorRole.onPrimaryContainer => copyWith(onPrimaryContainer: color),
    AcademyColorRole.secondaryContainer => copyWith(secondaryContainer: color),
    AcademyColorRole.error => copyWith(error: color),
    AcademyColorRole.complementary => copyWith(complementary: color),
    AcademyColorRole.complementaryContainer => copyWith(
      complementaryContainer: color,
    ),
    AcademyColorRole.scaffoldBackground => copyWith(scaffoldBackground: color),
    AcademyColorRole.segmentBackground => copyWith(segmentBackground: color),
    AcademyColorRole.segmentSelected => copyWith(segmentSelected: color),
    AcademyColorRole.segmentShadow => copyWith(segmentShadow: color),
    AcademyColorRole.menuSurface => copyWith(menuSurface: color),
    AcademyColorRole.menuHighlight => copyWith(menuHighlight: color),
    AcademyColorRole.iconOnColoredSurface => copyWith(
      iconOnColoredSurface: color,
    ),
    AcademyColorRole.modalBarrier => copyWith(modalBarrier: color),
    AcademyColorRole.chromeGradientStart => copyWith(
      chromeGradientStart: color,
    ),
    AcademyColorRole.chromeGradientEnd => copyWith(chromeGradientEnd: color),
    AcademyColorRole.chromeSurface => copyWith(chromeSurface: color),
    AcademyColorRole.chromeTintedSurface => copyWith(
      chromeTintedSurface: color,
    ),
    AcademyColorRole.chromeBorder => copyWith(chromeBorder: color),
    AcademyColorRole.neutralForeground => copyWith(
      toneForegrounds: {AcademyTone.neutral: color},
    ),
    AcademyColorRole.neutralContainer => copyWith(
      toneContainers: {AcademyTone.neutral: color},
    ),
    AcademyColorRole.successForeground => copyWith(
      toneForegrounds: {AcademyTone.success: color},
    ),
    AcademyColorRole.successContainer => copyWith(
      toneContainers: {AcademyTone.success: color},
    ),
    AcademyColorRole.warningForeground => copyWith(
      toneForegrounds: {AcademyTone.warning: color},
    ),
    AcademyColorRole.warningContainer => copyWith(
      toneContainers: {AcademyTone.warning: color},
    ),
    AcademyColorRole.errorForeground => copyWith(
      toneForegrounds: {AcademyTone.error: color},
    ),
    AcademyColorRole.errorContainer => copyWith(
      toneContainers: {AcademyTone.error: color},
    ),
  };
}
