import 'package:flutter/cupertino.dart';

import '../../foundation/localizations/academy_localizations.dart';
import '../icon/academy_sf_image.dart';
import 'academy_icon_button.dart';

/// Information action using the shared round icon button.
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
