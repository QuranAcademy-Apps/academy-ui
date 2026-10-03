import '../icon/academy_sf_image.dart';

import 'package:flutter/cupertino.dart';

import '../../foundation/interaction/academy_interaction.dart';

import '../../theme/academy_theme.dart';
import '../../foundation/motion/academy_press_effect.dart';

/// Adapted from quran_flutter's SFButton: independent hit area and round fill.
class AcademyIconButton extends StatelessWidget {
  const AcademyIconButton({
    super.key,
    required this.label,
    required this.icon,
    required this.onPressed,
  });
  final String label;
  final IconData icon;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) => AcademyActionSemantics(
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
