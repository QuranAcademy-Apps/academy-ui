import 'package:flutter/cupertino.dart';

import '../../theme/academy_theme.dart';
import 'academy_sf_image.dart';
export '../button/academy_info_button.dart';

class AcademyCheckmark extends StatelessWidget {
  const AcademyCheckmark({super.key, this.selected = true, this.color});
  final bool selected;

  /// Default: the theme's [AcademyThemeData.checkmarkColor].
  final Color? color;
  @override
  Widget build(BuildContext context) => MediaQuery.withNoTextScaling(
    child: selected
        ? AcademySfIcon(
            AcademyTheme.of(context).icons.checkmark,
            size: AcademyTheme.of(context).sizes.checkmark,
            boxSize: 18,
            color:
                color ??
                AcademyTheme.of(context).checkmarkColor ??
                AcademyTheme.of(context).colorScheme.onSurface,
          )
        : const SizedBox(width: 18),
  );
}

/// Check of the selected row in a system pull-down menu.
class AcademyMenuCheckmark extends StatelessWidget {
  const AcademyMenuCheckmark({super.key, this.fontWeight = FontWeight.w600});
  final FontWeight fontWeight;
  @override
  Widget build(BuildContext context) {
    final theme = AcademyTheme.of(context);
    return AcademySfIcon(
      theme.icons.checkmark,
      fontSize: theme.sizes.menuIcon,
      fontWeight: fontWeight,
      scaleWithText: true,
      mirrorInRtl: false,
    );
  }
}
