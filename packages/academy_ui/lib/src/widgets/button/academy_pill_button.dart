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
  });
  final String label;
  final IconData? icon;
  final VoidCallback? onPressed;

  /// false is the quiet text action used by section headers.
  final bool tinted;

  /// Insets of the visible content; the outer 44pt target is preserved.
  final EdgeInsetsGeometry? padding;
  @override
  Widget build(BuildContext context) {
    final theme = AcademyTheme.of(context);
    final p = theme.colorScheme;
    final foreground = onPressed == null ? p.onSurfaceVariant : p.secondary;
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
                  color: tinted ? p.secondaryContainer : null,
                  borderRadius: BorderRadius.circular(theme.radii.menuButton),
                ),
                child: Padding(
                  padding:
                      padding ??
                      EdgeInsets.symmetric(
                        horizontal: theme.paddings.menuButton.left,
                        vertical: AcademyTokens.space / 2,
                      ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (icon != null) ...[
                        AcademySfIcon(
                          icon!,
                          size: AcademyTokens.tableIconExtent / 2,
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
