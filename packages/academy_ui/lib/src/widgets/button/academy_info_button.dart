import 'package:flutter/cupertino.dart';

import '../../foundation/localizations/academy_localizations.dart';
import '../../theme/academy_theme.dart';
import '../icon/academy_sf_image.dart';
import 'academy_icon_button.dart';

/// Information action using the shared round icon button.
class AcademyInfoButton extends StatelessWidget {
  const AcademyInfoButton({super.key, required this.onPressed})
    : iconSize = null,
      color = null;

  /// A bare symbol without the round fill, for inline use next to a title.
  const AcademyInfoButton.inline({
    super.key,
    required this.onPressed,
    this.iconSize = 18,
    this.color,
  });

  final VoidCallback onPressed;
  final double? iconSize;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final iconSize = this.iconSize;
    if (iconSize == null) return _round(context);
    return Semantics(
      label: AcademyLocalizations.of(context).information,
      button: true,
      excludeSemantics: true,
      onTap: onPressed,
      child: CupertinoButton(
        padding: const EdgeInsets.all(2),
        minimumSize: Size.zero,
        onPressed: onPressed,
        child: AcademySfIcon(
          AcademySymbols.info,
          fontSize: iconSize,
          color: color ?? AcademyTheme.of(context).colorScheme.accentForeground,
          scaleWithText: true,
        ),
      ),
    );
  }

  Widget _round(BuildContext context) => AcademyIconButton(
    label: AcademyLocalizations.of(context).information,
    icon: AcademySymbols.info,
    onPressed: onPressed,
  );
}
