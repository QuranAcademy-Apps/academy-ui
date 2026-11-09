import 'package:flutter/cupertino.dart';

import 'package:academy_ui/academy_ui.dart';

@immutable
class AcademyPrayerTime {
  const AcademyPrayerTime({required this.name, required this.time});

  /// «Фаджр».
  final String name;

  /// Already formatted, «05:12».
  final String time;
}

/// The day's prayer times side by side on one card. The [highlighted] column
/// (usually the next prayer) gets an accent tint; [caption] («Аср через
/// 1 ч 20 мин») sits above the card on the page background. With
/// [onPressed] the whole strip is a button, and a caption row shows a chevron.
class AcademyPrayerStrip extends StatelessWidget {
  AcademyPrayerStrip({
    super.key,
    required List<AcademyPrayerTime> times,
    this.highlighted,
    this.caption,
    this.onPressed,
  }) : assert(times.length >= 2),
       assert(highlighted == null || highlighted < times.length),
       times = List.unmodifiable(times);

  final List<AcademyPrayerTime> times;
  final int? highlighted;
  final String? caption;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final theme = AcademyTheme.of(context);
    final accent = CupertinoTheme.of(context).primaryColor;
    final muted = theme.colorScheme.onSurfaceVariant;
    const figures = [FontFeature.tabularFigures()];
    Widget column(int index) {
      final item = times[index];
      final active = index == highlighted;
      return Expanded(
        child: DecoratedBox(
          decoration: ShapeDecoration(
            color: active ? accent.withValues(alpha: .14) : null,
            shape: RoundedSuperellipseBorder(
              borderRadius: BorderRadius.circular(theme.radii.button),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 2),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    item.name,
                    maxLines: 1,
                    style: theme.textTheme.caption.copyWith(
                      color: active ? accent : muted,
                    ),
                  ),
                ),
                const SizedBox(height: AcademyTokens.labelGap),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    item.time,
                    maxLines: 1,
                    style: theme.textTheme.bodyStrong.copyWith(
                      color: active ? accent : null,
                      fontFeatures: figures,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final columns = Padding(
      padding: const EdgeInsets.all(6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [for (var i = 0; i < times.length; i++) column(i)],
      ),
    );
    final card = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (caption != null)
          Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(16, 0, 12, 8),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    caption!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.caption.copyWith(color: muted),
                  ),
                ),
                if (onPressed != null)
                  AcademySfIcon(
                    AcademyTheme.of(context).icons.forward,
                    size: AcademyTheme.of(context).sizes.smallIcon,
                    color: muted,
                  ),
              ],
            ),
          ),
        DecoratedBox(
          decoration: ShapeDecoration(
            color: theme.colorScheme.surface,
            shape: RoundedSuperellipseBorder(
              borderRadius: BorderRadius.circular(theme.radii.surface),
            ),
          ),
          child: columns,
        ),
      ],
    );
    return AcademyActionSemantics(
      label: caption ?? times.map((t) => t.name).join(', '),
      value: times.map((t) => '${t.name} ${t.time}').join(', '),
      enabled: onPressed != null,
      child: PressScale(
        enabled: onPressed != null,
        pressedScale: AcademyTheme.of(context).interaction.pressedScale,
        onTap: onPressed,
        child: ExcludeSemantics(child: card),
      ),
    );
  }
}
