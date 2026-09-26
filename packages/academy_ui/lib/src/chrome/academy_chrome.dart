import '../academy_menu_anchor.dart';
import '../academy_reader_controls.dart';

import 'dart:ui' show ImageFilter;

import 'package:flutter/cupertino.dart';

import '../academy_sf_image.dart';
import '../academy_theme.dart';
import '../academy_page_insets.dart';
import '../motion/press_scale.dart';
import 'academy_chrome_metrics.dart';

enum AcademyChromeStyle {
  gradient,
  flat,
  blur,
  tinted,
  outlined,
  none;

  static const panelStyles = [flat, gradient, blur];
  String get label => switch (this) {
    gradient => 'Хром',
    flat => 'Мягкий',
    blur => 'Блюр',
    tinted => 'Акцентный',
    outlined => 'Контур',
    none => 'Без chrome',
  };
}

enum AcademyInterfaceTransparency {
  normal,
  softBlur;

  String get label => switch (this) {
    normal => 'Обычная',
    softBlur => 'Мягкий blur',
  };

  AcademyChromeStyle get chromeStyle => switch (this) {
    normal => AcademyChromeStyle.flat,
    softBlur => AcademyChromeStyle.blur,
  };

  double get blurSigma => switch (this) {
    normal => 20,
    softBlur => 20,
  };
}

/// Inherited appearance shared by every chrome surface, including route overlays.
enum AcademyTabBarDensity {
  standard,
  compact,
  telegram;

  String get label => switch (this) {
    standard => 'Обычный',
    compact => 'Компактный',
    telegram => 'Telegram',
  };
}

class AcademyChromeTheme extends InheritedTheme {
  const AcademyChromeTheme({
    super.key,
    required this.style,
    required super.child,
    this.blurSigma = 20,
    this.tabBarDensity = AcademyTabBarDensity.standard,
  });
  final AcademyChromeStyle style;
  final double blurSigma;
  final AcademyTabBarDensity tabBarDensity;
  static AcademyChromeTheme? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<AcademyChromeTheme>();
  @override
  bool updateShouldNotify(AcademyChromeTheme oldWidget) =>
      style != oldWidget.style ||
      blurSigma != oldWidget.blurSigma ||
      tabBarDensity != oldWidget.tabBarDensity;
  @override
  Widget wrap(BuildContext context, Widget child) => AcademyChromeTheme(
    style: style,
    blurSigma: blurSigma,
    tabBarDensity: tabBarDensity,
    child: child,
  );
}

/// Shared opaque chrome and classic clipped iOS blur, without refraction.
class AcademyChrome extends StatelessWidget {
  const AcademyChrome({
    super.key,
    required this.child,
    this.radius = 28,
    this.surfaceOpacity = 1,
    this.style,
    this.blurSigma,
  });
  final Widget child;
  final double radius;
  final double surfaceOpacity;
  final AcademyChromeStyle? style;
  final double? blurSigma;
  @override
  Widget build(BuildContext context) {
    final appearance = AcademyChromeTheme.maybeOf(context);
    final style =
        this.style ?? appearance?.style ?? AcademyChromeStyle.gradient;
    final blurSigma = this.blurSigma ?? appearance?.blurSigma ?? 20;
    if (style == AcademyChromeStyle.none) return child;
    final p = AcademyTheme.of(context).colorScheme;
    final surface = DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radius),
        color: style == AcademyChromeStyle.gradient
            ? null
            : (style == AcademyChromeStyle.tinted
                      ? p.chromeTintedSurface
                      : p.chromeSurface)
                  .withValues(
                    alpha: style == AcademyChromeStyle.blur
                        ? .22
                        : surfaceOpacity,
                  ),
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
    if (style != AcademyChromeStyle.blur) return surface;
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
        child: surface,
      ),
    );
  }
}

class AcademyChromeButton extends StatelessWidget {
  const AcademyChromeButton({
    super.key,
    required this.icon,
    required this.label,
    this.onPressed,
    this.style,
    this.blurSigma,
  });
  final IconData icon;
  final String label;
  final VoidCallback? onPressed;
  final AcademyChromeStyle? style;
  final double? blurSigma;
  @override
  Widget build(BuildContext context) => Semantics(
    label: label,
    button: true,
    enabled: onPressed != null,
    excludeSemantics: true,
    onTap: onPressed,
    child: PressScale(
      enabled: onPressed != null && !MediaQuery.disableAnimationsOf(context),
      child: SizedBox.square(
        dimension: academyChromeBarHeight,
        child: AcademyChrome(
          radius: academyChromeBarHeight / 2,
          style: style,
          blurSigma: blurSigma,
          child: CupertinoButton(
            padding: EdgeInsets.zero,
            minimumSize: Size.zero,
            onPressed: onPressed,
            child: AnimatedSwitcher(
              duration: MediaQuery.disableAnimationsOf(context)
                  ? Duration.zero
                  : const Duration(milliseconds: 180),
              child: AcademySfImage(
                icon,
                key: ValueKey(icon),
                foreground: onPressed == null
                    ? AcademyTheme.of(context).colorScheme.onSurfaceVariant
                    : CupertinoTheme.of(context).primaryColor,
              ),
            ),
          ),
        ),
      ),
    ),
  );
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
          onPressed: () => onSelected(option),
          checked: option == value,
          title: option,
        ),
    ],
    builder: (context, controller, child) => Semantics(
      label: label,
      value: value,
      button: true,
      excludeSemantics: true,
      onTap: () => controller.isOpen ? controller.close() : controller.open(),
      child: PressScale(
        enabled: !MediaQuery.disableAnimationsOf(context),
        child: AcademyChrome(
          radius: academyChromeBarHeight / 2,
          style: style,
          blurSigma: blurSigma,
          child: SizedBox(
            height: academyChromeBarHeight,
            child: CupertinoButton(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              minimumSize: Size.zero,
              onPressed: () =>
                  controller.isOpen ? controller.close() : controller.open(),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 184),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Flexible(
                      child: Text(
                        value,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AcademyTheme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                    const SizedBox(width: 6),
                    const AcademySfIcon(AcademySymbols.down, size: 15),
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
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
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
              color: AcademyTheme.of(context).colorScheme.outlineVariant,
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
    this.leading,
    this.actions = const [],
    this.style,
    this.blurSigma,
  });
  final String? title;
  final Widget? middle;
  final String? subtitle;
  final Widget? leading;
  final List<AcademyChromeAction> actions;
  final AcademyChromeStyle? style;
  final double? blurSigma;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16),
    child: SizedBox(
      height: academyChromeHeightOf(context, subtitle: subtitle != null),
      child: NavigationToolbar(
        centerMiddle: true,
        middleSpacing: 8,
        leading: leading,
        trailing: actions.isEmpty
            ? null
            : AcademyChromeGroup(
                actions: actions,
                style: style,
                blurSigma: blurSigma,
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

class AcademyChromeFade extends StatelessWidget {
  const AcademyChromeFade({super.key, this.bottom = false});
  final bool bottom;
  @override
  Widget build(BuildContext context) => IgnorePointer(
    child: SizedBox(
      height: 24,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: bottom ? Alignment.bottomCenter : Alignment.topCenter,
            end: bottom ? Alignment.topCenter : Alignment.bottomCenter,
            colors: [
              AcademyTheme.of(context).scaffoldBackgroundColor,
              AcademyTheme.of(context).scaffoldBackgroundColor
                  .withValues(alpha: 0),
            ],
          ),
        ),
      ),
    ),
  );
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
                    icon: AcademySymbols.back,
                    label: 'Назад',
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
    this.onClose,
    this.actions = const [],
  });
  final String? title;
  final AcademyChromeStyle? style;
  final double? blurSigma;
  final Widget? leading;
  final VoidCallback? onClose;
  final List<AcademyChromeAction> actions;
  @override
  Widget build(BuildContext context) => Padding(
    // Modal spacing is independent of the screen navigation bar metrics.
    padding: const EdgeInsets.symmetric(vertical: 8),
    child: AcademyChromeBar(
      title: title,
      leading: leading,
      style: style,
      blurSigma: blurSigma,
      actions: [
        ...actions,
        AcademyChromeAction(
          AcademySymbols.close,
          'Закрыть',
          onClose ?? () => Navigator.pop(context),
        ),
      ],
    ),
  );
}
