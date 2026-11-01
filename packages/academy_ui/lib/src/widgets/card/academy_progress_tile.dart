import 'package:flutter/cupertino.dart';

import '../../foundation/interaction/academy_interaction.dart';
import '../../foundation/motion/press_scale.dart';
import '../../theme/academy_theme.dart';
import '../icon/academy_sf_image.dart';

/// Grid tile of a daily routine (morning adhkar, …): a large tinted icon,
/// centered title, «5/17» caption and a thin progress line. `highlighted` draws the
/// accent outline Quran uses for the last-read row.
class AcademyProgressTile extends StatelessWidget {
  const AcademyProgressTile({
    super.key,
    required this.title,
    required this.caption,
    required this.progress,
    required this.icon,
    this.iconColor,
    this.highlighted = false,
    this.onPressed,
  }) : assert(progress >= 0 && progress <= 1);
  final String title, caption;
  final double progress;
  final IconData icon;
  final Color? iconColor;
  final bool highlighted;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final theme = AcademyTheme.of(context);
    final accent = CupertinoTheme.of(context).primaryColor;
    final tint = iconColor ?? accent;
    final done = progress >= 1;
    final animate = !MediaQuery.disableAnimationsOf(context);
    final tile = DecoratedBox(
      decoration: ShapeDecoration(
        color: theme.colorScheme.surface,
        shape: RoundedSuperellipseBorder(
          borderRadius: BorderRadius.circular(theme.radii.surface),
          side: highlighted
              ? BorderSide(color: tint, width: 1.5)
              : BorderSide.none,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 18, 14, 14),
        child: Column(
          children: [
            AcademySfImage(
              icon,
              frameSize: 60,
              symbolSize: 30,
              foreground: tint,
              background: tint.withValues(alpha: .14),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              maxLines: 2,
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 4),
            SizedBox(
              height: 18,
              child: done
                  ? AcademySfIcon(
                      AcademySymbols.completeFill,
                      size: 16,
                      color: tint,
                    )
                  : Text(
                      caption,
                      style: theme.textTheme.caption.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                        fontFeatures: const [FontFeature.tabularFigures()],
                      ),
                    ),
            ),
            const SizedBox(height: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(2),
              child: SizedBox(
                height: 4,
                child: ColoredBox(
                  color: theme.colorScheme.surfaceContainerHighest,
                  child: Align(
                    alignment: AlignmentDirectional.centerStart,
                    child: TweenAnimationBuilder<double>(
                      tween: Tween(end: progress),
                      duration: animate
                          ? AcademyTokens.progressMotion
                          : Duration.zero,
                      builder: (context, value, _) => FractionallySizedBox(
                        widthFactor: value,
                        child: ColoredBox(
                          color: tint,
                          child: const SizedBox.expand(),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
    return AcademyActionSemantics(
      label: title,
      value: caption,
      enabled: onPressed != null,
      child: PressScale(
        enabled: onPressed != null,
        pressedScale: .97,
        onTap: onPressed,
        child: ExcludeSemantics(child: tile),
      ),
    );
  }
}
