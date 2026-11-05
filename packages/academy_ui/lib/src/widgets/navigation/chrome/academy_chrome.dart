import '../../../foundation/localizations/academy_localizations.dart';
import '../../menu/academy_menu_anchor.dart';
import '../../../foundation/interaction/academy_interaction.dart';
import '../../menu/academy_menu_item.dart';

import 'dart:math' as math;
import 'dart:ui' show ImageFilter;

import 'package:flutter/cupertino.dart';

import '../../../foundation/layout/academy_text_fit.dart';
import '../../button/academy_button.dart' show AcademyTextButton;

import '../../icon/academy_sf_image.dart';
import '../../../theme/academy_theme.dart';
import '../../../foundation/layout/academy_page_insets.dart';
import '../../../foundation/motion/press_scale.dart';
import 'academy_chrome_metrics.dart';
import 'academy_glass_material.dart';

enum AcademyChromeStyle {
  gradient,
  flat,
  blur,
  tinted,
  outlined,

  /// Near-opaque tinted glass of iOS 26 navigation (see [AcademyGlassMaterial]).
  glass,
  none;

  static const panelStyles = [flat, gradient, blur, glass];

  /// Legacy Russian label. Prefer [labelFor] for localized UI.
  String get label =>
      const AcademyLocalizations(Locale('ru')).chromeStyle(name);
  String labelFor(BuildContext context) =>
      AcademyLocalizations.of(context).chromeStyle(name);
}

/// Inherited appearance shared by every chrome surface, including route overlays.
enum AcademyTabBarDensity {
  standard,
  compact,
  telegram;

  String get label => const AcademyLocalizations(Locale('ru')).tabDensity(name);
  String labelFor(BuildContext context) =>
      AcademyLocalizations.of(context).tabDensity(name);
}

/// Navigation colors that may differ from the content palette, for example a
/// neutral tab highlight with a saturated selected symbol. A null role keeps
/// the palette default noted on it.
@immutable
class AcademyChromeColors {
  const AcademyChromeColors({
    this.buttonForeground,
    this.selection,
    this.selectedIcon,
    this.selectedLabel,
    this.unselectedForeground,
    this.unselectedLabel,
    this.border,
    this.shadow,
    this.glassFill,
    this.glassRim,
    this.glassEdge,
    this.glassShadow,
  });

  /// Fill of the [AcademyChromeStyle.glass] material; default: a neutral tint.
  final Color? glassFill;

  /// Inner highlight of the glass rim; default: white.
  final Color? glassRim;

  /// Thin contact line around the glass; default: black.
  final Color? glassEdge;

  /// Soft shadow under the glass; default: black.
  final Color? glassShadow;

  /// Chrome button symbols; default: the Cupertino primary color.
  final Color? buttonForeground;

  /// Selected tab pill and selected chrome button; default: primaryContainer.
  final Color? selection;

  /// Selected tab symbol and selected button symbol; default: onPrimaryContainer.
  final Color? selectedIcon;

  /// Selected tab label; default: onPrimaryContainer.
  final Color? selectedLabel;

  /// Unselected tab symbol and label; default: onSurfaceVariant, contrast-fixed.
  final Color? unselectedForeground;

  /// Unselected tab label; default: [unselectedForeground].
  final Color? unselectedLabel;

  /// Group separators and the selected button rim; default: outlineVariant.
  final Color? border;

  /// Elevation of opaque chrome (soft, chrome, tinted, outlined) and of the
  /// selected button; default: none.
  final Color? shadow;

  @override
  bool operator ==(Object other) =>
      other is AcademyChromeColors &&
      other.buttonForeground == buttonForeground &&
      other.selection == selection &&
      other.selectedIcon == selectedIcon &&
      other.selectedLabel == selectedLabel &&
      other.unselectedForeground == unselectedForeground &&
      other.unselectedLabel == unselectedLabel &&
      other.border == border &&
      other.shadow == shadow &&
      other.glassFill == glassFill &&
      other.glassRim == glassRim &&
      other.glassEdge == glassEdge &&
      other.glassShadow == glassShadow;

  @override
  int get hashCode => Object.hash(
    buttonForeground,
    selection,
    selectedIcon,
    selectedLabel,
    unselectedForeground,
    unselectedLabel,
    border,
    shadow,
    glassFill,
    glassRim,
    glassEdge,
    glassShadow,
  );
}

class AcademyChromeTheme extends InheritedTheme {
  const AcademyChromeTheme({
    super.key,
    required this.style,
    required super.child,
    this.blurSigma = 20,
    double? blurToneStrength,
    double? blurTintOpacity,
    this.tabBarDensity = AcademyTabBarDensity.standard,
    this.colors,
    this.reduceTransparency = false,
  }) : blurToneStrength =
           blurToneStrength ??
           blurTintOpacity ??
           AcademyTokens.chromeBlurToneStrength,
       assert(
         blurToneStrength == null ||
             blurToneStrength >= 0 && blurToneStrength <= 1,
       ),
       assert(
         blurTintOpacity == null ||
             blurTintOpacity >= 0 && blurTintOpacity <= 1,
       );
  final AcademyChromeStyle style;
  final double blurSigma;
  final double blurToneStrength;

  /// Compatibility alias for backdrop tone correction; no overlay is painted.
  double get blurTintOpacity => blurToneStrength;
  final AcademyTabBarDensity tabBarDensity;

  /// Overrides [AcademyThemeData.chromeColors] below this theme.
  final AcademyChromeColors? colors;

  /// Paints chrome as flat opaque controls and drops edge fades.
  final bool reduceTransparency;

  /// Navigation colors: the nearest override, else the active theme's.
  static AcademyChromeColors colorsOf(BuildContext context) =>
      maybeOf(context)?.colors ?? AcademyTheme.of(context).chromeColors;
  static AcademyChromeTheme? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<AcademyChromeTheme>();
  @override
  bool updateShouldNotify(AcademyChromeTheme oldWidget) =>
      style != oldWidget.style ||
      blurSigma != oldWidget.blurSigma ||
      blurToneStrength != oldWidget.blurToneStrength ||
      tabBarDensity != oldWidget.tabBarDensity ||
      colors != oldWidget.colors ||
      reduceTransparency != oldWidget.reduceTransparency;
  @override
  Widget wrap(BuildContext context, Widget child) => AcademyChromeTheme(
    style: style,
    blurSigma: blurSigma,
    blurToneStrength: blurToneStrength,
    tabBarDensity: tabBarDensity,
    colors: colors,
    reduceTransparency: reduceTransparency,
    child: child,
  );
}

/// Shared opaque chrome and classic clipped iOS blur, without refraction.
class AcademyChrome extends StatelessWidget {
  const AcademyChrome({
    super.key,
    required this.child,
    this.radius,
    this.surfaceOpacity = 1,
    this.style,
    this.blurSigma,
    double? blurToneStrength,
    double? blurTintOpacity,
    this.showShadow = true,
    this.shadows,
    this.borderWidth,
    this.frostsBackdrop = false,
  }) : blurToneStrength = blurToneStrength ?? blurTintOpacity,
       assert(surfaceOpacity >= 0 && surfaceOpacity <= 1),
       assert(
         blurToneStrength == null ||
             blurToneStrength >= 0 && blurToneStrength <= 1,
       ),
       assert(
         blurTintOpacity == null ||
             blurTintOpacity >= 0 && blurTintOpacity <= 1,
       );
  final Widget child;
  final double? radius;
  final double surfaceOpacity;
  final AcademyChromeStyle? style;
  final double? blurSigma;
  final double? blurToneStrength;

  /// Lets elevation fall on the content under this surface.
  final bool showShadow;

  /// Elevation; default: [AcademyChromeMaterial.shadows].
  final List<BoxShadow>? shadows;

  /// Stroke; default: [AcademyChromeMaterial.borderWidth].
  final double? borderWidth;

  /// Blurs live content behind the surface. Under reduced transparency the
  /// surface goes away, so that content shows through.
  final bool frostsBackdrop;

  /// Compatibility alias for backdrop tone correction.
  double? get blurTintOpacity => blurToneStrength;

  static double _toneStrengthOf(
    BuildContext context, {
    double surfaceOpacity = 1,
    double? blurToneStrength,
  }) =>
      (blurToneStrength ??
          AcademyChromeTheme.maybeOf(context)?.blurToneStrength ??
          AcademyTokens.chromeBlurToneStrength) *
      surfaceOpacity;

  static double _saturation(double strength) =>
      1 +
      (AcademyTokens.chromeBlurSaturation - 1) *
          strength /
          AcademyTokens.chromeBlurToneStrength;

  /// Color of a uniform backdrop after the material's color correction.
  /// This describes the filtered image; it is never a painted surface color.
  static Color blurBackgroundOf(
    BuildContext context,
    Color backdrop, {
    double surfaceOpacity = 1,
    double? blurToneStrength,
  }) {
    final theme = AcademyTheme.of(context);
    if (MediaQuery.highContrastOf(context)) {
      return theme.colorScheme.chromeSurface.withValues(alpha: 1);
    }
    final strength = _toneStrengthOf(
      context,
      surfaceOpacity: surfaceOpacity,
      blurToneStrength: blurToneStrength,
    );
    final saturation = _saturation(strength);
    final luminance =
        backdrop.r * .2126 + backdrop.g * .7152 + backdrop.b * .0722;
    final gain = 1 - strength;
    final offset = theme.brightness == Brightness.light ? strength : 0.0;
    double channel(double value) =>
        (luminance + (value - luminance) * saturation).clamp(0.0, 1.0) * gain +
        offset;
    return Color.from(
      alpha: backdrop.a,
      red: channel(backdrop.r),
      green: channel(backdrop.g),
      blue: channel(backdrop.b),
    );
  }

  /// Compatibility helper. Normal blur has no overlay; high contrast uses fill.
  static Color blurTintOf(
    BuildContext context, {
    double surfaceOpacity = 1,
    double? blurTintOpacity,
  }) =>
      AcademyTheme.of(context).colorScheme.chromeSurface
          .withValues(alpha: MediaQuery.highContrastOf(context) ? 1 : 0);

  static ImageFilter _backdropFilter(
    BuildContext context,
    double sigma, {
    double surfaceOpacity = 1,
    double? blurToneStrength,
  }) {
    final strength = _toneStrengthOf(
      context,
      surfaceOpacity: surfaceOpacity,
      blurToneStrength: blurToneStrength,
    );
    final gain = 1 - strength;
    final offset = AcademyTheme.of(context).brightness == Brightness.light
        ? strength * 255
        : 0.0;
    return ImageFilter.compose(
      outer: ColorFilter.matrix([
        gain,
        0,
        0,
        0,
        offset,
        0,
        gain,
        0,
        0,
        offset,
        0,
        0,
        gain,
        0,
        offset,
        0,
        0,
        0,
        1,
        0,
      ]),
      inner: ImageFilter.compose(
        outer: ColorFilter.saturation(_saturation(strength)),
        inner: ImageFilter.blur(sigmaX: sigma, sigmaY: sigma),
      ),
    );
  }

  /// Protect labels/icons over the worst light/dark background allowed by the
  /// material. This is a contrast adjustment, not native Apple vibrancy.
  static Color foregroundColor(
    BuildContext context,
    Color preferred, {
    AcademyChromeStyle? style,
    double surfaceOpacity = 1,
    double minimumContrast = 4.5,
  }) {
    final resolved =
        style ??
        AcademyChromeTheme.maybeOf(context)?.style ??
        AcademyChromeStyle.gradient;
    if (resolved != AcademyChromeStyle.blur) return preferred;
    final theme = AcademyTheme.of(context);
    final background = blurBackgroundOf(
      context,
      theme.brightness == Brightness.light
          ? CupertinoColors.black
          : CupertinoColors.white,
      surfaceOpacity: surfaceOpacity,
    );
    return AcademyContrast.foreground(
      preferred,
      background,
      minimum: minimumContrast,
    );
  }

  Widget _reduced(BuildContext context, AcademyChromeMaterial material) {
    if (frostsBackdrop) return child;
    final theme = AcademyTheme.of(context);
    final width = borderWidth ?? material.borderWidth;
    return DecoratedBox(
      decoration: BoxDecoration(
        color:
            material.reducedFill ??
            theme.colorScheme.chromeSurface.withValues(alpha: 1),
        borderRadius: BorderRadius.circular(radius ?? theme.radii.chrome),
        border: Border.all(
          color: CupertinoDynamicColor.resolve(
            material.reducedBorder ?? theme.colorScheme.chromeBorder,
            context,
          ),
          width: width <= 0 ? 1 : width,
        ),
      ),
      child: child,
    );
  }

  Widget _stroked(BuildContext context, AcademyChromeMaterial material) {
    final theme = AcademyTheme.of(context);
    final resolvedRadius = radius ?? theme.radii.chrome;
    final borderRadius = BorderRadius.circular(resolvedRadius);
    final painted = CustomPaint(
      foregroundPainter: _ChromeStrokePainter(
        gradient: material.borderGradient!,
        radius: resolvedRadius,
        width: borderWidth ?? material.borderWidth,
      ),
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: borderRadius,
          gradient:
              material.fill ??
              LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  theme.colorScheme.chromeGradientStart,
                  theme.colorScheme.chromeGradientEnd,
                ],
              ),
        ),
        child: child,
      ),
    );
    final sigma = material.backdropBlurSigma;
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: borderRadius,
        boxShadow: showShadow ? shadows ?? material.shadows : const [],
      ),
      child: frostsBackdrop
          ? ClipRRect(
              borderRadius: borderRadius,
              child: BackdropFilter.grouped(
                filter: ImageFilter.blur(sigmaX: sigma, sigmaY: sigma),
                child: painted,
              ),
            )
          : painted,
    );
  }

  @override
  Widget build(BuildContext context) {
    final appearance = AcademyChromeTheme.maybeOf(context);
    final style =
        this.style ?? appearance?.style ?? AcademyChromeStyle.gradient;
    final blurSigma = this.blurSigma ?? appearance?.blurSigma ?? 20;
    if (style == AcademyChromeStyle.none) return child;
    final theme = AcademyTheme.of(context);
    final p = theme.colorScheme;
    final material = theme.chromeMaterial;
    if (appearance?.reduceTransparency ?? false) {
      return _reduced(context, material);
    }
    if (style == AcademyChromeStyle.gradient &&
        material.borderGradient != null) {
      return _stroked(context, material);
    }
    final highContrast = MediaQuery.highContrastOf(context);
    if (style == AcademyChromeStyle.glass && !highContrast) {
      return AcademyGlassMaterial(
        radius: radius ?? AcademyTheme.of(context).radii.chrome,
        blurSigma: blurSigma,
        child: child,
      );
    }
    final surface = DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(
          radius ?? AcademyTheme.of(context).radii.chrome,
        ),
        color: style == AcademyChromeStyle.gradient
            ? null
            : style == AcademyChromeStyle.blur
            ? (highContrast ? p.chromeSurface.withValues(alpha: 1) : null)
            : (style == AcademyChromeStyle.tinted
                      ? p.chromeTintedSurface
                      : p.chromeSurface)
                  .withValues(alpha: surfaceOpacity),
        gradient: style == AcademyChromeStyle.gradient
            ? LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  p.chromeGradientStart.withValues(alpha: surfaceOpacity),
                  p.chromeGradientEnd.withValues(alpha: surfaceOpacity),
                ],
              )
            : null,
        border: Border.all(
          color: style == AcademyChromeStyle.outlined
              ? p.primary
              : p.chromeBorder,
          width: style == AcademyChromeStyle.outlined ? 1.2 : .7,
        ),
      ),
      child: child,
    );
    if (style != AcademyChromeStyle.blur || highContrast) {
      final shadow = AcademyChromeTheme.colorsOf(context).shadow;
      if (shadow == null) return surface;
      return DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(
            radius ?? AcademyTheme.of(context).radii.chrome,
          ),
          boxShadow: [
            BoxShadow(color: shadow, blurRadius: 8, offset: const Offset(0, 2)),
          ],
        ),
        child: surface,
      );
    }
    return ClipRRect(
      borderRadius: BorderRadius.circular(
        radius ?? AcademyTheme.of(context).radii.chrome,
      ),
      child: BackdropFilter(
        filter: _backdropFilter(
          context,
          blurSigma,
          surfaceOpacity: surfaceOpacity,
          blurToneStrength: blurToneStrength,
        ),
        child: surface,
      ),
    );
  }
}

class _ChromeStrokePainter extends CustomPainter {
  const _ChromeStrokePainter({
    required this.gradient,
    required this.radius,
    required this.width,
  });

  final Gradient gradient;
  final double radius, width;

  @override
  void paint(Canvas canvas, Size size) {
    if (width <= 0) return;
    final rect = Offset.zero & size;
    final inset = width / 2;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        rect.deflate(inset),
        Radius.circular(radius > inset ? radius - inset : 0),
      ),
      Paint()
        ..shader = gradient.createShader(rect)
        ..style = PaintingStyle.stroke
        ..strokeWidth = width,
    );
  }

  @override
  bool shouldRepaint(_ChromeStrokePainter oldDelegate) =>
      oldDelegate.gradient != gradient ||
      oldDelegate.radius != radius ||
      oldDelegate.width != width;
}

class AcademyChromeButton extends StatelessWidget {
  const AcademyChromeButton({
    super.key,
    required this.icon,
    required this.label,
    this.onPressed,
    this.style,
    this.blurSigma,
    this.selected,
    this.foreground,
    this.semanticsValue,
    this.semanticsExpanded,
  });
  final IconData icon;
  final String label;

  /// Open state of the menu this button controls.
  final bool? semanticsExpanded;

  /// Current state read after [label], for example the selected list style.
  final String? semanticsValue;
  final VoidCallback? onPressed;
  final AcademyChromeStyle? style;
  final double? blurSigma;

  /// A toggled button: an opaque selection disc instead of the material.
  final bool? selected;

  /// Symbol color; default: [AcademyChromeColors.buttonForeground].
  final Color? foreground;
  @override
  Widget build(BuildContext context) {
    final colors = AcademyTheme.of(context).colorScheme;
    final chrome = AcademyChromeTheme.colorsOf(context);
    final button = CupertinoButton(
      padding: EdgeInsets.zero,
      minimumSize: Size.zero,
      onPressed: onPressed,
      child: AnimatedSwitcher(
        duration: MediaQuery.disableAnimationsOf(context)
            ? Duration.zero
            : AcademyTokens.motion,
        child: AcademySfImage(
          icon,
          key: ValueKey(icon),
          foreground: onPressed == null
              ? AcademyChrome.foregroundColor(
                  context,
                  colors.onSurfaceVariant,
                  style: style,
                  minimumContrast: 3,
                )
              : selected == true
              ? chrome.selectedIcon ?? colors.onPrimaryContainer
              : AcademyChrome.foregroundColor(
                  context,
                  foreground ??
                      chrome.buttonForeground ??
                      CupertinoTheme.of(context).primaryColor,
                  style: style,
                  minimumContrast: 3,
                ),
        ),
      ),
    );
    return AcademyActionSemantics(
      label: label,
      value: semanticsValue,
      enabled: onPressed != null,
      selected: selected,
      expanded: semanticsExpanded,
      child: PressScale(
        pressedScale: AcademyTheme.of(context).interaction.chromePressedScale,
        enabled: onPressed != null && !MediaQuery.disableAnimationsOf(context),
        child: SizedBox.square(
          dimension: academyChromeBarHeight,
          child: selected == true
              ? DecoratedBox(
                  decoration: BoxDecoration(
                    color: chrome.selection ?? colors.primaryContainer,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: chrome.border ?? colors.outlineVariant,
                      width: .5,
                    ),
                    boxShadow: [
                      if (chrome.shadow != null)
                        BoxShadow(
                          color: chrome.shadow!,
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                    ],
                  ),
                  child: button,
                )
              : AcademyChrome(
                  radius: AcademyTheme.of(context).radii.chromeButton,
                  style: style,
                  blurSigma: blurSigma,
                  child: button,
                ),
        ),
      ),
    );
  }
}

class AcademyChromeMenu extends StatelessWidget {
  const AcademyChromeMenu({
    super.key,
    required this.label,
    required this.value,
    required this.options,
    required this.onSelected,
    this.style,
    this.blurSigma,
  });
  final String label;
  final String value;
  final List<String> options;
  final ValueChanged<String> onSelected;
  final AcademyChromeStyle? style;
  final double? blurSigma;

  @override
  Widget build(BuildContext context) => AcademyMenuAnchor(
    consumeOutsideTaps: true,
    menuChildren: [
      for (final option in options)
        AcademyMenuItem(
          // The current option still closes the menu, without repeating the
          // side effects of selecting it.
          onPressed: () {
            if (option != value) onSelected(option);
          },
          checked: option == value,
          title: option,
        ),
    ],
    builder: (context, controller, child) => AcademyActionSemantics(
      label: label,
      value: value,
      enabled: true,
      expanded: controller.isOpen,
      child: PressScale(
        pressedScale: AcademyTheme.of(context).interaction.chromePressedScale,
        enabled: !MediaQuery.disableAnimationsOf(context),
        child: AcademyChrome(
          radius: AcademyTheme.of(context).radii.chromeButton,
          style: style,
          blurSigma: blurSigma,
          child: SizedBox(
            height: academyChromeBarHeight,
            child: CupertinoButton(
              padding: AcademyTheme.of(context).paddings.chromeMenu,
              minimumSize: Size.zero,
              onPressed: () =>
                  controller.isOpen ? controller.close() : controller.open(),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 184),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Flexible(
                      child: ExcludeSemantics(
                        child: Text(
                          value,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AcademyTheme.of(context).textTheme.bodyMedium,
                        ),
                      ),
                    ),
                    const SizedBox(width: AcademyTokens.labelGap),
                    AcademySfIcon(
                      AcademyTheme.of(context).icons.down,
                      size: AcademyTheme.of(context).sizes.indicatorIcon,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    ),
  );
}

class AcademyChromeCapsule extends StatelessWidget {
  const AcademyChromeCapsule({
    super.key,
    required this.child,
    this.style,
    this.blurSigma,
  });
  final Widget child;
  final AcademyChromeStyle? style;
  final double? blurSigma;
  @override
  Widget build(BuildContext context) => AcademyChrome(
    style: style,
    blurSigma: blurSigma,
    child: Padding(
      padding: AcademyTheme.of(context).paddings.chromeCapsule,
      child: child,
    ),
  );
}

class AcademyChromeAction {
  const AcademyChromeAction(this.icon, this.label, this.onPressed);
  final IconData icon;
  final String label;
  final VoidCallback? onPressed;
}

class AcademyChromeGroup extends StatelessWidget {
  const AcademyChromeGroup({
    super.key,
    required this.actions,
    this.style,
    this.blurSigma,
  });
  final List<AcademyChromeAction> actions;
  final AcademyChromeStyle? style;
  final double? blurSigma;
  @override
  Widget build(BuildContext context) => AcademyChrome(
    style: style,
    blurSigma: blurSigma,
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 0; i < actions.length; i++) ...[
          if (i > 0)
            Container(
              width: .5,
              height: 20,
              color:
                  AcademyChromeTheme.colorsOf(context).border ??
                  AcademyTheme.of(context).colorScheme.outlineVariant,
            ),
          AcademyChromeButton(
            icon: actions[i].icon,
            label: actions[i].label,
            onPressed: actions[i].onPressed,
            style: AcademyChromeStyle.none,
          ),
        ],
      ],
    ),
  );
}

/// Title is optional; style.none removes all chrome decoration independently.
class AcademyChromeBar extends StatelessWidget {
  const AcademyChromeBar({
    super.key,
    this.title,
    this.middle,
    this.subtitle,
    this.height,
    this.leading,
    this.trailing,
    this.actions = const [],
    this.style,
    this.blurSigma,
  });
  final String? title;
  final Widget? middle;
  final String? subtitle;

  /// Bar height; default: [academyChromeHeightOf] for the title and subtitle.
  final double? height;
  final Widget? leading;
  final Widget? trailing;
  final List<AcademyChromeAction> actions;
  final AcademyChromeStyle? style;
  final double? blurSigma;
  @override
  Widget build(BuildContext context) => Padding(
    padding: AcademyTheme.of(context).paddings.chromeBar,
    child: SizedBox(
      height:
          height ?? academyChromeHeightOf(context, subtitle: subtitle != null),
      child: NavigationToolbar(
        centerMiddle: true,
        middleSpacing: 8,
        leading: leading,
        trailing: actions.isEmpty
            ? trailing
            : Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (trailing != null) ...[
                    trailing!,
                    const SizedBox(width: AcademyTokens.space),
                  ],
                  AcademyChromeGroup(
                    actions: actions,
                    style: style,
                    blurSigma: blurSigma,
                  ),
                ],
              ),
        middle:
            middle ??
            (title == null
                ? null
                : Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        title!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AcademyTheme.of(context).textTheme.titleMedium,
                      ),
                      if (subtitle != null)
                        Text(
                          subtitle!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AcademyTheme.of(context).textTheme.bodySmall,
                        ),
                    ],
                  )),
      ),
    ),
  );
}

/// Edge fade into the page color. `solidExtent` keeps the edge opaque (for
/// example under the status bar and a floating bar) before `fadeExtent`.
class AcademyChromeFade extends StatelessWidget {
  const AcademyChromeFade({
    super.key,
    this.bottom = false,
    this.solidExtent = 0,
    this.fadeExtent = 24,
  }) : assert(solidExtent >= 0 && fadeExtent > 0);
  final bool bottom;
  final double solidExtent, fadeExtent;
  @override
  Widget build(BuildContext context) {
    final color = AcademyTheme.of(context).scaffoldBackgroundColor;
    final height = solidExtent + fadeExtent;
    return IgnorePointer(
      child: SizedBox(
        height: height,
        child: DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: bottom ? Alignment.bottomCenter : Alignment.topCenter,
              end: bottom ? Alignment.topCenter : Alignment.bottomCenter,
              colors: [color, color, color.withValues(alpha: 0)],
              stops: [0, solidExtent / height, 1],
            ),
          ),
        ),
      ),
    );
  }
}

class AcademyChromePage extends StatelessWidget {
  const AcademyChromePage({
    super.key,
    this.title,
    this.style,
    this.blurSigma,
    this.actions = const [],
    required this.child,
  });
  final String? title;
  final AcademyChromeStyle? style;
  final double? blurSigma;
  final List<AcademyChromeAction> actions;
  final Widget child;
  @override
  Widget build(BuildContext context) => CupertinoPageScaffold(
    child: Stack(
      children: [
        Positioned.fill(
          child: Center(
            child: SizedBox(
              width: 430,
              child: AcademyPageInsets(
                top: academyChromeContentTopOf(context),
                child: child,
              ),
            ),
          ),
        ),
        const Positioned(top: 0, left: 0, right: 0, child: AcademyChromeFade()),
        Positioned(
          top: academyChromeTopOf(context),
          left: 0,
          right: 0,
          child: AcademyChromeBar(
            title: title,
            style: style,
            blurSigma: blurSigma,
            actions: actions,
            leading: Navigator.of(context).canPop()
                ? AcademyChromeButton(
                    icon: AcademyTheme.of(context).icons.back,
                    label: AcademyLocalizations.of(context).back,
                    style: style,
                    blurSigma: blurSigma,
                    onPressed: () => Navigator.maybePop(context),
                  )
                : null,
          ),
        ),
      ],
    ),
  );
}

class AcademyChromeModalHeader extends StatelessWidget {
  const AcademyChromeModalHeader({
    super.key,
    this.title,
    this.style,
    this.blurSigma,
    this.leading,
    this.trailing,
    this.closeOnLeading = false,
    this.onClose,
    this.actions = const [],
  }) : assert(!closeOnLeading || leading == null),
       assert(trailing == null || closeOnLeading);
  final String? title;
  final AcademyChromeStyle? style;
  final double? blurSigma;
  final Widget? leading;

  /// Trailing control when close sits on the leading side (for example a
  /// "Reset" [AcademyTextButton]).
  final Widget? trailing;

  /// Places close on the leading side, freeing the trailing side.
  final bool closeOnLeading;
  final VoidCallback? onClose;
  final List<AcademyChromeAction> actions;

  /// A text action wider than the room beside the title would squeeze the
  /// title out or clip the action at large text, so it takes its own row.
  bool _stacksTrailing(BuildContext context, double width) {
    final action = trailing;
    if (title == null || action is! AcademyTextButton) return false;
    final actionSize = action.measure(context);
    final titleWidth = academyTextWidth(
      context,
      title!,
      AcademyTheme.of(context).textTheme.titleMedium,
    );
    final barPadding = AcademyTheme.of(context).paddings.chromeBar.horizontal;
    const middleSpacing = 8.0;
    final side = math.max(academyChromeBarHeight, actionSize.width);
    final middle = width - barPadding - 2 * side - 2 * middleSpacing;
    return titleWidth > middle ||
        actionSize.height > academyChromeHeightOf(context);
  }

  @override
  Widget build(BuildContext context) {
    final close = onClose ?? () => Navigator.pop(context);
    final closeLabel = AcademyLocalizations.of(context).close;
    return Padding(
      // Modal spacing is independent of the screen navigation bar metrics.
      padding: AcademyTheme.of(context).paddings.chromeBottom,
      child: LayoutBuilder(
        builder: (context, box) {
          final stacked = _stacksTrailing(context, box.maxWidth);
          final bar = AcademyChromeBar(
            title: title,
            leading: closeOnLeading
                ? AcademyChromeButton(
                    icon: AcademyTheme.of(context).icons.close,
                    label: closeLabel,
                    onPressed: close,
                    style: style,
                    blurSigma: blurSigma,
                  )
                : leading,
            trailing: stacked ? null : trailing,
            style: style,
            blurSigma: blurSigma,
            actions: [
              ...actions,
              if (!closeOnLeading)
                AcademyChromeAction(
                  AcademyTheme.of(context).icons.close,
                  closeLabel,
                  close,
                ),
            ],
          );
          if (!stacked) return bar;
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              bar,
              Padding(
                padding: AcademyTheme.of(context).paddings.chromeBar,
                child: Align(
                  alignment: AlignmentDirectional.centerEnd,
                  child: trailing,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
