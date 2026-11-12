import 'package:cupertino_ui/cupertino_ui.dart';

import '../../theme/academy_theme.dart';
import '../icon/academy_sf_image.dart';

class AcademyStatus extends StatelessWidget {
  const AcademyStatus({
    super.key,
    required this.label,
    this.tone = AcademyTone.neutral,
    this.icon,
    this.foreground,
    this.background,
    this.compact = false,
    this.fitLabel = false,
    this.radius,
  });
  final String label;
  final AcademyTone tone;

  /// Small leading symbol in the label color.
  final IconData? icon;

  /// Explicit colors instead of the [tone] pair (for example over a photo).
  final Color? foreground, background;

  /// One line with an ellipsis.
  final bool compact;

  /// One line scaled down to fit instead of truncating.
  final bool fitLabel;

  /// Default: [AcademyRadii.status].
  final double? radius;
  @override
  Widget build(BuildContext context) {
    final theme = AcademyTheme.of(context);
    final palette = theme.colorScheme;
    final color = foreground ?? palette.toneForeground(tone);
    final text = Text(
      label,
      textAlign: TextAlign.center,
      maxLines: compact || fitLabel ? 1 : null,
      overflow: fitLabel
          ? TextOverflow.visible
          : compact
          ? TextOverflow.ellipsis
          : null,
      style: theme.textTheme.status.copyWith(color: color),
    );
    final labelWidget = fitLabel
        ? FittedBox(fit: BoxFit.scaleDown, child: text)
        : text;
    return Container(
      padding: theme.paddings.status,
      decoration: BoxDecoration(
        color: background ?? palette.toneContainer(tone),
        borderRadius: BorderRadius.circular(radius ?? theme.radii.status),
      ),
      child: icon == null
          ? labelWidget
          : Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                AcademySfIcon(
                  icon!,
                  size: AcademyTheme.of(context).sizes.statusIcon,
                  color: color,
                ),
                const SizedBox(width: 4),
                Flexible(child: labelWidget),
              ],
            ),
    );
  }
}
