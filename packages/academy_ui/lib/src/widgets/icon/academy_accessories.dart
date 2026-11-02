import 'package:flutter/cupertino.dart';

import '../../theme/academy_theme.dart';
import 'academy_sf_image.dart';
export '../button/academy_info_button.dart';

class AcademyCheckmark extends StatelessWidget {
  const AcademyCheckmark({super.key, this.selected = true, this.color});
  final bool selected;

  /// Default: the text color; a brand may mark selection with its accent.
  final Color? color;
  @override
  Widget build(BuildContext context) => MediaQuery.withNoTextScaling(
    child: selected
        ? AcademySfIcon(
            AcademySymbols.checkmark,
            size: 18,
            boxSize: 18,
            color: color ?? AcademyTheme.of(context).colorScheme.onSurface,
          )
        : const SizedBox(width: 18),
  );
}

class AcademyChevron extends StatelessWidget {
  const AcademyChevron({super.key, this.turns = 0});
  final double turns;
  @override
  Widget build(BuildContext context) => AnimatedRotation(
    turns: turns,
    duration: MediaQuery.disableAnimationsOf(context)
        ? Duration.zero
        : AcademyTokens.motion,
    child: AcademySfIcon(AcademySymbols.forward, size: 16),
  );
}
