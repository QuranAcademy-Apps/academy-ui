import 'package:cupertino_ui/cupertino_ui.dart';

import '../../foundation/interaction/academy_interaction.dart';
import '../../foundation/motion/academy_press_effect.dart';
import '../../foundation/localizations/academy_localizations.dart';

import '../icon/academy_sf_image.dart';
import '../../theme/academy_theme.dart';

/// Quran's small close/utility button. Surface 28px, hit area at least 44px.
class AcademyCompactIconButton extends StatelessWidget {
  const AcademyCompactIconButton({
    super.key,
    this.icon,
    this.label,
    required this.onPressed,
  });

  /// Default: the theme's [AcademyIcons.close].
  final IconData? icon;
  final String? label;
  final VoidCallback? onPressed;
  @override
  Widget build(BuildContext context) {
    final theme = AcademyTheme.of(context);
    final look = theme.chromeButton;
    final button = CupertinoButton(
      padding: EdgeInsets.zero,
      minimumSize: Size(look.compactTarget, look.compactTarget),
      onPressed: onPressed,
      child: Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: theme.colorScheme.segmentBackground,
        ),
        child: Center(
          child: AcademySfIcon(
            icon ?? theme.icons.close,
            size: theme.sizes.compactIcon,
            fontWeight: look.compactWeight,
            scaleWithText: look.symbolScalesWithText,
            mirrorInRtl: look.symbolMirrorsInRtl,
            color: look.compactForeground ?? theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ),
    );
    return AcademyActionSemantics(
      label: label ?? AcademyLocalizations.of(context).close,
      enabled: onPressed != null,
      child: look.compactPressEffect
          ? AcademyPressEffect(enabled: onPressed != null, child: button)
          : button,
    );
  }
}
