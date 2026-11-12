import 'package:cupertino_ui/cupertino_ui.dart';

import '../../theme/academy_theme.dart';
import 'academy_sf_image.dart';
export '../button/academy_info_button.dart';

class AcademyCheckmark extends StatelessWidget {
  const AcademyCheckmark({
    super.key,
    this.selected = true,
    this.color,
    this.scaleWithText = false,
  });
  final bool selected;

  /// Grows the symbol with the system text size.
  final bool scaleWithText;

  /// Default: the theme's [AcademyThemeData.checkmarkColor].
  final Color? color;
  @override
  Widget build(BuildContext context) {
    final theme = AcademyTheme.of(context);
    if (!selected) return SizedBox(width: theme.sizes.checkmark);
    final symbol = AcademySfIcon(
      theme.icons.checkmark,
      size: theme.sizes.checkmark,
      boxSize: scaleWithText ? null : theme.sizes.checkmark,
      scaleWithText: scaleWithText,
      color: color ?? theme.checkmarkColor ?? theme.colorScheme.onSurface,
    );
    return scaleWithText ? symbol : MediaQuery.withNoTextScaling(child: symbol);
  }
}
