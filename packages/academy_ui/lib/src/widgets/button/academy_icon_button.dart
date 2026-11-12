import '../icon/academy_sf_image.dart';

import 'package:cupertino_ui/cupertino_ui.dart';

import '../../foundation/interaction/academy_interaction.dart';

import '../../theme/academy_theme.dart';
import '../../foundation/motion/academy_press_effect.dart';
import '../../foundation/motion/press_scale.dart';

/// Adapted from quran_flutter's SFButton: independent hit area and round fill.
class AcademyIconButton extends StatelessWidget {
  const AcademyIconButton({
    super.key,
    required this.label,
    required this.icon,
    required this.onPressed,
  }) : frameSize = null,
       symbolSize = null,
       foreground = null;

  /// A bare symbol that scales when pressed, with no fill of its own.
  const AcademyIconButton.plain({
    super.key,
    required this.label,
    required this.icon,
    required this.onPressed,
    double this.frameSize = 44,
    double this.symbolSize = 16,
    this.foreground,
  });
  final String label;
  final IconData icon;
  final VoidCallback? onPressed;
  final double? frameSize;
  final double? symbolSize;

  /// Symbol color; default: the theme's text color.
  final Color? foreground;

  Widget _plain(BuildContext context) => Semantics(
    button: true,
    enabled: onPressed != null,
    label: label,
    child: PressScale(
      enabled: onPressed != null,
      onTap: onPressed,
      child: SizedBox.square(
        dimension: frameSize,
        child: Center(
          child: ExcludeSemantics(
            child: AcademySfImage.plain(
              icon,
              frameSize: frameSize!,
              symbolSize: symbolSize!,
              foreground:
                  foreground ?? AcademyTheme.of(context).colorScheme.onSurface,
            ),
          ),
        ),
      ),
    ),
  );

  @override
  Widget build(BuildContext context) => frameSize != null
      ? _plain(context)
      : AcademyActionSemantics(
          label: label,
          enabled: onPressed != null,
          child: AcademyPressEffect(
            enabled: onPressed != null,
            child: CupertinoButton(
              padding: EdgeInsets.zero,
              minimumSize: const Size(
                AcademyTokens.largeTarget,
                AcademyTokens.largeTarget,
              ),
              onPressed: onPressed,
              child: AcademySfImage(
                icon,
                foreground: AcademyTheme.of(context).colorScheme.onSurface,
                background: AcademyTheme.of(context)
                    .colorScheme
                    .surfaceContainerHighest,
              ),
            ),
          ),
        );
}
