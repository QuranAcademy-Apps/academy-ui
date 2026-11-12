import 'package:cupertino_ui/cupertino_ui.dart';

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
      // The line of text sets the height, so the target can only grow along it:
      // toward the free space after the symbol.
      child: CupertinoButton(
        padding: const EdgeInsets.all(2),
        minimumSize: const Size(AcademyTokens.target, 0),
        alignment: AlignmentDirectional.centerStart,
        onPressed: onPressed,
        child: AcademySfIcon(
          AcademyTheme.of(context).icons.info,
          fontSize: iconSize,
          color:
              color ??
              AcademyTheme.of(context).inlineInfoColor ??
              AcademyTheme.of(context).colorScheme.accentForeground,
          scaleWithText: true,
        ),
      ),
    );
  }

  Widget _round(BuildContext context) => AcademyIconButton(
    label: AcademyLocalizations.of(context).information,
    icon: AcademyTheme.of(context).icons.info,
    onPressed: onPressed,
  );
}
