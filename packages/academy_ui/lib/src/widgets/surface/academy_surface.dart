import 'package:flutter/cupertino.dart';

import '../../theme/academy_theme.dart';
import '../modal/modal_sheet_corner_mask.dart';

class AcademySurface extends StatelessWidget {
  const AcademySurface({super.key, required this.child});
  final Widget child;
  @override
  Widget build(BuildContext context) {
    final content = Padding(
      padding: AcademyTheme.of(context).paddings.surface,
      child: child,
    );
    if (ModalSheetSurfaceScope.isInModalSheet(context)) {
      return ModalSheetMaskedFill(
        color: AcademyTheme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(
          AcademyTheme.of(context).radii.table,
        ),
        child: content,
      );
    }
    return DecoratedBox(
      decoration: ShapeDecoration(
        color: AcademyTheme.of(context).colorScheme.surface,
        shape: RoundedSuperellipseBorder(
          borderRadius: BorderRadius.circular(
            AcademyTheme.of(context).radii.table,
          ),
        ),
      ),
      child: content,
    );
  }
}
