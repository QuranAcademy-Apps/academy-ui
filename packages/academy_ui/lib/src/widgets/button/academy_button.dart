import 'dart:math' as math;

import 'package:flutter/cupertino.dart';

import '../../theme/academy_theme.dart';
import '../../foundation/localizations/academy_localizations.dart';
import 'academy_button_visual_state.dart';
import '../../foundation/motion/academy_press_effect.dart';

enum AcademyButtonStyle {
  /// Call to action on [AcademyColors.actionFill].
  primary,

  /// Accent tint on [AcademyColors.secondaryContainer].
  tinted,

  /// Neutral raised fill with ordinary text and the chrome border.
  neutral,

  /// Card surface with ordinary text and no border.
  plain,
}

class AcademyButton extends StatelessWidget {
  const AcademyButton({
    super.key,
    required this.label,
    this.onPressed,
    this.pending = false,
    this.secondary = false,
    this.style,
    this.content,
    this.backgroundColor,
    this.foregroundColor,
    this.borderColor,
    this.disabledBackgroundColor,
    this.disabledForegroundColor,
    this.minimumHeight,
    this.radius,
    this.textStyle,
  });
  final String label;
  final VoidCallback? onPressed;
  final bool pending;
  final bool secondary;

  /// [secondary] remains a compatibility alias for the tinted style.
  final AcademyButtonStyle? style;

  /// Visual composition in place of the label text; [label] still names the
  /// button for accessibility, and pending/disabled behavior is unchanged.
  final Widget? content;

  /// Explicit fills (for example a destructive action); the label color
  /// follows the fill unless [foregroundColor] is given.
  final Color? backgroundColor, foregroundColor, borderColor;
  final Color? disabledBackgroundColor, disabledForegroundColor;

  /// Default: the theme's button height.
  final double? minimumHeight;

  /// Corner radius; default: [AcademyRadii.button].
  final double? radius;

  /// Label style; default: [AcademyTypography.buttonLabel] for primary,
  /// [AcademyTypography.labelLarge] otherwise.
  final TextStyle? textStyle;

  @override
  Widget build(BuildContext context) {
    final theme = AcademyTheme.of(context);
    final p = theme.colorScheme;
    final resolved =
        style ??
        (secondary ? AcademyButtonStyle.tinted : AcademyButtonStyle.primary);
    final state = AcademyButtonVisualState(
      colors: p,
      onPressed: onPressed,
      pending: pending,
      tinted: resolved == AcademyButtonStyle.tinted,
    );
    final disabled = state.disabled;
    final background = disabled
        ? disabledBackgroundColor ?? state.background
        : switch (resolved) {
            AcademyButtonStyle.neutral => p.surfaceContainerHighest,
            AcademyButtonStyle.plain => p.surface,
            AcademyButtonStyle.tinted => state.background,
            AcademyButtonStyle.primary => backgroundColor ?? state.background,
          };
    final foreground = disabled
        ? disabledForegroundColor ?? state.foreground
        : switch (resolved) {
            AcademyButtonStyle.neutral ||
            AcademyButtonStyle.plain => p.onSurface,
            AcademyButtonStyle.tinted => state.foreground,
            AcademyButtonStyle.primary =>
              foregroundColor ??
                  (backgroundColor == null
                      ? state.foreground
                      : AcademyContrast.foreground(
                          p.onActionFill,
                          backgroundColor!,
                        )),
          };
    final border = disabled
        ? disabledBackgroundColor ?? state.border
        : borderColor ??
              switch (resolved) {
                AcademyButtonStyle.neutral => p.chromeBorder,
                AcademyButtonStyle.plain => const Color(0x00000000),
                AcademyButtonStyle.tinted => state.border,
                AcademyButtonStyle.primary => background,
              };
    final corners = BorderRadius.circular(radius ?? theme.radii.button);
    final labelStyle =
        textStyle ??
        (resolved == AcademyButtonStyle.primary
            ? theme.textTheme.buttonLabel
            : theme.textTheme.labelLarge);
    return Semantics(
      container: true,
      liveRegion: pending,
      label: label,
      value: pending ? AcademyLocalizations.of(context).loading : null,
      enabled: state.enabled,
      button: true,
      onTap: state.enabled ? onPressed : null,
      child: ExcludeSemantics(
        child: AcademyPressEffect(
          enabled: state.enabled,
          child: DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: corners,
              border: Border.all(color: border),
            ),
            child: CupertinoButton(
              onPressed: pending ? null : onPressed,
              color: background,
              disabledColor: background,
              borderRadius: corners,
              minimumSize: Size(
                AcademyTokens.target,
                minimumHeight ?? AcademyTheme.of(context).sizes.buttonHeight,
              ),
              padding: theme.paddings.button,
              child: DefaultTextStyle(
                style: labelStyle.copyWith(color: foreground),
                textAlign: TextAlign.center,
                child: pending
                    ? Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CupertinoActivityIndicator(
                            radius: 9,
                            color: foreground,
                            animating: !MediaQuery.disableAnimationsOf(context),
                          ),
                          const SizedBox(width: 10),
                          Flexible(child: Text(label)),
                        ],
                      )
                    : content ?? Text(label),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class AcademyTextButton extends StatelessWidget {
  const AcademyTextButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.textStyle,
  });
  final String label;
  final VoidCallback? onPressed;

  /// Label style; default: [AcademyTypography.labelLarge].
  final TextStyle? textStyle;

  /// Size the button takes at the current text scale, so a parent can decide
  /// whether it fits beside other content before laying it out.
  Size measure(BuildContext context) {
    final theme = AcademyTheme.of(context);
    final padding = theme.paddings.textButton;
    final painter = TextPainter(
      text: TextSpan(
        text: label,
        style: textStyle ?? theme.textTheme.labelLarge,
      ),
      textDirection: Directionality.of(context),
      textScaler: MediaQuery.textScalerOf(context),
    )..layout();
    final size = Size(
      math.max(AcademyTokens.target, painter.width + padding.horizontal),
      math.max(AcademyTokens.target, painter.height + padding.vertical),
    );
    painter.dispose();
    return size;
  }

  @override
  Widget build(BuildContext context) {
    final theme = AcademyTheme.of(context);
    return AcademyPressEffect(
      enabled: onPressed != null,
      child: CupertinoButton(
        padding: AcademyTheme.of(context).paddings.textButton,
        minimumSize: const Size(AcademyTokens.target, AcademyTokens.target),
        onPressed: onPressed,
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: (textStyle ?? theme.textTheme.labelLarge).copyWith(
            color: onPressed == null
                ? theme.colorScheme.onSurfaceVariant
                : theme.colorScheme.accentForeground,
          ),
        ),
      ),
    );
  }
}
