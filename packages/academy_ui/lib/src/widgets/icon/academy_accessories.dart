import '../../foundation/localizations/academy_localizations.dart';

import 'package:flutter/cupertino.dart';

import '../../theme/academy_theme.dart';
import 'academy_sf_image.dart';
import '../button/academy_icon_button.dart';

class AcademyCheckmark extends StatelessWidget {
  const AcademyCheckmark({super.key, this.selected = true});
  final bool selected;
  @override
  Widget build(BuildContext context) => MediaQuery.withNoTextScaling(
    child: selected
        ? AcademySfIcon(
            AcademySymbols.checkmark,
            size: 18,
            boxSize: 18,
            color: AcademyTheme.of(context).colorScheme.onSurface,
          )
        : const SizedBox(width: 18),
  );
}

class AcademyInfoButton extends StatelessWidget {
  const AcademyInfoButton({super.key, required this.onPressed});
  final VoidCallback onPressed;
  @override
  Widget build(BuildContext context) => AcademyIconButton(
    label: AcademyLocalizations.of(context).information,
    icon: AcademySymbols.info,
    onPressed: onPressed,
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
    child: AcademySfIcon(
      Directionality.of(context) == TextDirection.rtl
          ? AcademySymbols.back
          : AcademySymbols.forward,
      size: 16,
    ),
  );
}
