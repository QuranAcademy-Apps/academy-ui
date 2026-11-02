import 'package:flutter/cupertino.dart';

import '../../foundation/interaction/academy_interaction.dart';
import '../../foundation/motion/academy_press_effect.dart';
import '../../foundation/localizations/academy_localizations.dart';

import '../icon/academy_sf_image.dart';
import '../../theme/academy_theme.dart';

/// Quran's small close/utility button. Surface 28px, hit area at least 44px.
class AcademyCompactIconButton extends StatelessWidget {
  const AcademyCompactIconButton({
    super.key,
    this.icon = AcademySymbols.close,
    this.label,
    required this.onPressed,
  });
  final IconData icon;
  final String? label;
  final VoidCallback? onPressed;
  @override
  Widget build(BuildContext context) => AcademyActionSemantics(
    label: label ?? AcademyLocalizations.of(context).close,
    enabled: onPressed != null,
    child: AcademyPressEffect(
      enabled: onPressed != null,
      child: CupertinoButton(
        padding: EdgeInsets.zero,
        minimumSize: const Size(AcademyTokens.target, AcademyTokens.target),
        onPressed: onPressed,
        child: Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AcademyTheme.of(context).colorScheme.segmentBackground,
          ),
          child: Center(
            child: AcademySfIcon(
              icon,
              size: 17,
              color: AcademyTheme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      ),
    ),
  );
}
