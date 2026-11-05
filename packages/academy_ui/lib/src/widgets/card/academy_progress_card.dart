import 'package:flutter/cupertino.dart';

import '../../foundation/interaction/academy_interaction.dart';
import '../../foundation/motion/press_scale.dart';
import '../../theme/academy_theme.dart';
import '../icon/academy_sf_image.dart';
import '../progress/academy_ring_progress.dart';

/// Opaque card for a collection with daily progress (for example morning
/// adhkar): tinted icon, title, subtitle and a ring that turns into a check.
/// `highlighted` marks the collection that is relevant right now.
class AcademyProgressCard extends StatelessWidget {
  const AcademyProgressCard({
    super.key,
    required this.title,
    required this.progress,
    this.subtitle,
    this.icon,
    this.iconColor,
    this.badge,
    this.highlighted = false,
    this.onPressed,
  }) : assert(progress >= 0 && progress <= 1);
  final String title;
  final String? subtitle;
  final IconData? icon;
  final Color? iconColor;

  /// Small accent label above the title, e.g. «Сейчас».
  final String? badge;
  final double progress;
  final bool highlighted;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final theme = AcademyTheme.of(context);
    final accent = CupertinoTheme.of(context).primaryColor;
    final tint = iconColor ?? accent;
    final radius = BorderRadius.circular(theme.radii.surface);
    final done = progress >= 1;
    final card = DecoratedBox(
      decoration: ShapeDecoration(
        color: theme.colorScheme.surface,
        shape: RoundedSuperellipseBorder(
          borderRadius: radius,
          side: highlighted
              ? BorderSide(color: tint.withValues(alpha: .55), width: 1.5)
              : BorderSide.none,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AcademyTokens.tableInset),
        child: Row(
          children: [
            if (icon != null) ...[
              AcademySfImage(
                icon!,
                frameSize: 44,
                symbolSize: 22,
                foreground: tint,
                background: tint.withValues(alpha: .14),
              ),
              const SizedBox(width: AcademyTokens.inlineGap),
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (badge != null)
                    Text(
                      badge!,
                      style: theme.textTheme.caption.copyWith(
                        color: tint,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  Text(title, style: theme.textTheme.titleMedium),
                  if (subtitle != null)
                    Text(
                      subtitle!,
                      style: theme.textTheme.bodySmall.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(width: AcademyTokens.inlineGap),
            done
                ? AcademySfIcon(
                    AcademyTheme.of(context).icons.complete,
                    fontSize: AcademyTheme.of(context).sizes.progressCardIcon,
                    boxSize: 36,
                    color: tint,
                  )
                : AcademyRingProgress(value: progress),
          ],
        ),
      ),
    );
    return AcademyActionSemantics(
      label: title,
      value: subtitle,
      enabled: onPressed != null,
      child: PressScale(
        enabled: onPressed != null,
        pressedScale: .97,
        onTap: onPressed,
        child: ExcludeSemantics(child: card),
      ),
    );
  }
}
