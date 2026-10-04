import 'package:flutter/cupertino.dart';

import '../../theme/academy_theme.dart';
import '../../foundation/motion/academy_press_effect.dart';
import '../../foundation/interaction/academy_interaction.dart';
import '../../foundation/localizations/academy_localizations.dart';
import '../icon/academy_sf_image.dart';
import 'academy_button.dart';
import 'academy_button_visual_state.dart';

/// Prominent two-line action. The client owns pending and disabled state.
class AcademyActionButton extends StatelessWidget {
  const AcademyActionButton({
    super.key,
    required this.title,
    required this.icon,
    this.subtitle,
    this.onPressed,
    this.pending = false,
    this.style = AcademyButtonStyle.primary,
  });
  final String title;
  final String? subtitle;
  final IconData icon;
  final VoidCallback? onPressed;
  final bool pending;
  final AcademyButtonStyle style;

  @override
  Widget build(BuildContext context) {
    final theme = AcademyTheme.of(context);
    final p = theme.colorScheme;
    final tinted = style == AcademyButtonStyle.tinted;
    final state = AcademyButtonVisualState(
      colors: p,
      onPressed: onPressed,
      pending: pending,
      tinted: tinted,
    );
    final enabled = state.enabled;
    final disabled = state.disabled;
    final background = state.background;
    final foreground = state.foreground;
    return Semantics(
      liveRegion: pending,
      child: AcademyActionSemantics(
        label: [title, ?subtitle].join(', '),
        value: pending ? AcademyLocalizations.of(context).loading : null,
        enabled: enabled,
        child: AcademyPressEffect(
          enabled: enabled,
          child: CupertinoButton(
            onPressed: enabled ? onPressed : null,
            color: background,
            disabledColor: background,
            minimumSize: const Size(
              AcademyTokens.target,
              AcademyTokens.actionButtonHeight,
            ),
            borderRadius: BorderRadius.circular(theme.radii.button),
            padding: theme.paddings.button,
            child: ExcludeSemantics(
              child: Row(
                children: [
                  Container(
                    width: AcademyTokens.target,
                    height: AcademyTokens.target,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: tinted && !disabled
                          ? p.surface
                          : foreground.withValues(alpha: .12),
                    ),
                    alignment: Alignment.center,
                    child: pending
                        ? CupertinoActivityIndicator(
                            color: foreground,
                            animating: !MediaQuery.disableAnimationsOf(context),
                          )
                        : AcademySfIcon(
                            icon,
                            size: AcademyTokens.actionIconExtent,
                            color: foreground,
                          ),
                  ),
                  const SizedBox(width: AcademyTokens.inlineGap),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          title,
                          style: theme.textTheme.actionTitle.copyWith(
                            color: foreground,
                          ),
                        ),
                        if (subtitle != null)
                          Padding(
                            padding: theme.paddings.rowSubtitle,
                            child: Text(
                              subtitle!,
                              style: theme.textTheme.footnote.copyWith(
                                color: tinted && !disabled
                                    ? p.onSurfaceVariant
                                    : foreground,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
