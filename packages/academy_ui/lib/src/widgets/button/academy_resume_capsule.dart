import 'package:flutter/cupertino.dart';

import '../../foundation/interaction/academy_interaction.dart';
import '../../foundation/motion/press_scale.dart';
import '../../theme/academy_theme.dart';
import '../icon/academy_sf_image.dart';
import '../navigation/chrome/academy_chrome.dart';

/// Floating chrome capsule that offers to continue where the person stopped
/// («Утренние азкары · 4/17»). The owner decides when to show it ([visible])
/// and when to withdraw it; it slides up from the bottom edge and never takes
/// touches while hidden. Place it with `Positioned` over the content.
class AcademyResumeCapsule extends StatelessWidget {
  const AcademyResumeCapsule({
    super.key,
    required this.visible,
    required this.title,
    this.caption,
    this.icon,
    this.onPressed,
  });

  final bool visible;
  final String title;

  /// Second line, «4/17».
  final String? caption;

  /// Default: the theme's [AcademyIcons.play].
  final IconData? icon;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final theme = AcademyTheme.of(context);
    final accent = CupertinoTheme.of(context).primaryColor;
    final duration = MediaQuery.disableAnimationsOf(context)
        ? Duration.zero
        : AcademyTokens.toastMotion;
    return IgnorePointer(
      ignoring: !visible,
      child: ExcludeSemantics(
        excluding: !visible,
        child: AnimatedSlide(
          offset: visible ? Offset.zero : const Offset(0, 1.6),
          duration: duration,
          curve: Curves.easeOutCubic,
          child: AnimatedOpacity(
            opacity: visible ? 1 : 0,
            duration: duration,
            child: AcademyActionSemantics(
              label: title,
              value: caption,
              enabled: onPressed != null,
              child: PressScale(
                enabled: onPressed != null,
                pressedScale: AcademyTheme.of(context).interaction.pressedScale,
                onTap: onPressed,
                child: ExcludeSemantics(
                  child: AcademyChromeCapsule(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        AcademySfImage(
                          icon ?? AcademyTheme.of(context).icons.play,
                          frameSize: 32,
                          symbolSize: 16,
                          foreground: accent,
                          background: accent.withValues(alpha: .14),
                        ),
                        const SizedBox(width: 10),
                        Flexible(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: theme.textTheme.bodyStrong,
                              ),
                              if (caption case final caption?)
                                Text(
                                  caption,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: theme.textTheme.caption.copyWith(
                                    color: theme.colorScheme.onSurfaceVariant,
                                    fontFeatures: const [
                                      FontFeature.tabularFigures(),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 6),
                      ],
                    ),
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
