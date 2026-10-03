import 'package:flutter/cupertino.dart';

import '../../theme/academy_theme.dart';
import '../../foundation/motion/academy_press_effect.dart';

enum AcademyButtonStyle { primary, tinted }

class AcademyButton extends StatelessWidget {
  const AcademyButton({
    super.key,
    required this.label,
    this.onPressed,
    this.pending = false,
    this.secondary = false,
    this.style,
  });
  final String label;
  final VoidCallback? onPressed;
  final bool pending;
  final bool secondary;

  /// [secondary] remains a compatibility alias for the tinted style.
  final AcademyButtonStyle? style;

  @override
  Widget build(BuildContext context) {
    final theme = AcademyTheme.of(context);
    final p = theme.colorScheme;
    final disabled = !pending && onPressed == null;
    final tinted =
        style == AcademyButtonStyle.tinted || style == null && secondary;
    final background = disabled
        ? Color.lerp(p.onSurface, p.surface, .88)!
        : tinted
        ? p.secondaryContainer
        : p.accentFill;
    final foreground = disabled
        ? p.onSurfaceVariant
        : tinted
        ? p.secondary
        : p.onAccentFill;
    return Semantics(
      liveRegion: pending,
      child: AcademyPressEffect(
        enabled: !pending && onPressed != null,
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(
              AcademyTheme.of(context).radii.button,
            ),
            border: Border.all(
              color: disabled
                  ? p.outlineVariant
                  : tinted
                  ? p.secondary.withValues(alpha: .24)
                  : background,
            ),
          ),
          child: CupertinoButton(
            onPressed: pending ? null : onPressed,
            color: background,
            disabledColor: background,
            borderRadius: BorderRadius.circular(
              AcademyTheme.of(context).radii.button,
            ),
            minimumSize: const Size(
              AcademyTokens.target,
              AcademyTokens.buttonHeight,
            ),
            padding: AcademyTheme.of(context).paddings.button,
            child: DefaultTextStyle(
              style: theme.textTheme.labelLarge.copyWith(color: foreground),
              textAlign: TextAlign.center,
              child: pending
                  ? Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CupertinoActivityIndicator(
                          radius: 9,
                          color: foreground,
                        ),
                        const SizedBox(width: 10),
                        Flexible(child: Text(label)),
                      ],
                    )
                  : Text(label),
            ),
          ),
        ),
      ),
    );
  }
}

/// Quiet auxiliary action; retains a full Cupertino touch target.
class AcademyTextButton extends StatelessWidget {
  const AcademyTextButton({
    super.key,
    required this.label,
    required this.onPressed,
  });
  final String label;
  final VoidCallback? onPressed;
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
          style: theme.textTheme.labelLarge.copyWith(
            color: onPressed == null
                ? theme.colorScheme.onSurfaceVariant
                : theme.colorScheme.accentForeground,
          ),
        ),
      ),
    );
  }
}
