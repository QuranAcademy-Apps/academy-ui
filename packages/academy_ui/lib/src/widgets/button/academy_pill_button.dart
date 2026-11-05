import 'package:flutter/cupertino.dart';

import '../../theme/academy_theme.dart';
import '../../foundation/motion/academy_press_effect.dart';
import '../../foundation/interaction/academy_interaction.dart';
import '../icon/academy_sf_image.dart';

/// Compact action with a 36pt resting fill and at least a 44pt hit target.
/// Large text grows the fill. Does not open or own a menu.
class AcademyPillButton extends StatelessWidget {
  const AcademyPillButton({
    super.key,
    required this.label,
    this.icon,
    this.onPressed,
    this.tinted = true,
    this.padding,
    this.accent = false,
  });
  final String label;
  final IconData? icon;
  final VoidCallback? onPressed;

  /// false is the quiet text action used by section headers.
  final bool tinted;

  /// Insets of the visible content; the outer 44pt target is preserved.
  final EdgeInsetsGeometry? padding;

  /// Accent tint ([AcademyColors.primaryContainer]) instead of the secondary
  /// one, for brands whose secondary color is the call-to-action fill.
  final bool accent;
  @override
  Widget build(BuildContext context) {
    final theme = AcademyTheme.of(context);
    final p = theme.colorScheme;
    final foreground = onPressed == null
        ? p.onSurfaceVariant
        : accent
        ? p.onPrimaryContainer
        : p.secondary;
    return AcademyActionSemantics(
      label: label,
      enabled: onPressed != null,
      child: AcademyPressEffect(
        enabled: onPressed != null,
        child: CupertinoButton(
          onPressed: onPressed,
          padding: EdgeInsets.zero,
          minimumSize: const Size(AcademyTokens.target, AcademyTokens.target),
          child: ExcludeSemantics(
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                minHeight: AcademyTokens.pillHeight,
              ),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: !tinted
                      ? null
                      : accent
                      ? p.primaryContainer
                      : p.secondaryContainer,
                  borderRadius: BorderRadius.circular(theme.radii.pillButton),
                ),
                child: Padding(
                  padding: padding ?? theme.paddings.pillButton,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (icon != null) ...[
                        AcademySfIcon(
                          icon!,
                          size: AcademyTokens.pillIconExtent,
                          color: foreground,
                        ),
                        const SizedBox(width: AcademyTokens.labelGap),
                      ],
                      Flexible(
                        child: Text(
                          label,
                          textAlign: TextAlign.center,
                          style: theme.textTheme.labelMedium.copyWith(
                            color: foreground,
                          ),
                        ),
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
}
