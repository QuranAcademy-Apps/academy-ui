import 'package:flutter/cupertino.dart';

import '../../theme/academy_theme.dart';
import '../icon/academy_sf_image.dart';

/// Small row chevron in the tertiary label color (Yalla's grouped rows),
/// for [AcademyRow.chevron].
class AcademyRowChevron extends StatelessWidget {
  const AcademyRowChevron({super.key});
  @override
  Widget build(BuildContext context) => SizedBox(
    width: 8,
    height: 14,
    child: FittedBox(
      fit: BoxFit.contain,
      child: AcademySfIcon(
        AcademySymbols.forward,
        size: 14,
        color: AcademyTheme.of(context).colorScheme.labelTertiary,
      ),
    ),
  );
}
