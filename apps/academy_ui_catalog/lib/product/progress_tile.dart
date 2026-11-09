import 'package:flutter/cupertino.dart';

import 'package:academy_ui/academy_ui.dart';

/// Compact grid tile of a routine (morning adhkar, …): tinted icon, centered
/// title, optional «5/17» caption and thin progress line. `highlighted` draws the
/// accent outline Quran uses for the last-read row.
class AcademyProgressTile extends StatelessWidget {
  const AcademyProgressTile({
    super.key,
    required this.title,
    required this.icon,
    this.caption,
    this.progress,
    this.iconColor,
    this.highlighted = false,
    this.compact = false,
    this.onPressed,
  }) : assert(progress == null || (progress >= 0 && progress <= 1));
  final String title;

  /// «5/17»; omit together with [progress] for a plain launcher tile.
  final String? caption;
  final double? progress;
  final IconData icon;
  final Color? iconColor;
  final bool highlighted;

  /// Miniature layout: small icon and title side by side in one row.
  final bool compact;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final theme = AcademyTheme.of(context);
    final accent = CupertinoTheme.of(context).primaryColor;
    final tint = iconColor ?? accent;
    final done = (progress ?? 0) >= 1;
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
        padding: EdgeInsets.symmetric(
          horizontal: 12,
          vertical: compact ? 10 : 14,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (compact)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AcademySfImage(
                    icon,
                    frameSize: 32,
                    symbolSize: 17,
                    foreground: tint,
                    background: tint.withValues(alpha: .14),
                  ),
                  const SizedBox(width: 10),
                  Flexible(
                    child: Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodyStrong,
                    ),
                  ),
                ],
              )
            else ...[
              AcademySfImage(
                icon,
                frameSize: 44,
                symbolSize: 22,
                foreground: tint,
                background: tint.withValues(alpha: .14),
              ),
              const SizedBox(height: 8),
              Text(
                title,
                maxLines: 2,
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodyStrong,
              ),
            ],
            if (caption case final caption?) ...[
              const SizedBox(height: 2),
              done
                  ? AcademySfIcon(
                      AcademyTheme.of(context).icons.complete,
                      size: AcademyTheme.of(context).sizes.progressIcon,
                      color: tint,
                    )
                  : Text(
                      caption,
                      style: theme.textTheme.caption.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                        fontFeatures: const [FontFeature.tabularFigures()],
                      ),
                    ),
            ],
            if (progress case final progress?) ...[
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(theme.radii.progress),
                child: SizedBox(
                  height: 3,
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
        pressedScale: AcademyTheme.of(context).interaction.pressedScale,
        onTap: onPressed,
        child: ExcludeSemantics(child: tile),
      ),
    );
  }
}
