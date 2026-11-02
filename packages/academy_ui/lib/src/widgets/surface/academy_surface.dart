import 'package:flutter/cupertino.dart';

import '../../theme/academy_theme.dart';
import '../../foundation/surface/academy_surface_mask.dart';

class AcademySurface extends StatelessWidget {
  const AcademySurface({
    super.key,
    required this.child,
    this.padding,
    this.radius,
    this.continuousCorners = true,
  });
  final Widget child;

  /// Default: [AcademyPaddings.surface].
  final EdgeInsetsGeometry? padding;

  /// Default: [AcademyRadii.surface].
  final double? radius;

  /// Superellipse corners; false draws circular ones (for example to match
  /// grouped tables).
  final bool continuousCorners;
  @override
  Widget build(BuildContext context) {
    final content = Padding(
      padding: padding ?? AcademyTheme.of(context).paddings.surface,
      child: child,
    );
    final corner = radius ?? AcademyTheme.of(context).radii.surface;
    if (ModalSheetSurfaceScope.isInModalSheet(context)) {
      return ModalSheetMaskedFill(
        color: AcademyTheme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(corner),
        child: content,
      );
    }
    final color = AcademyTheme.of(context).colorScheme.surface;
    return DecoratedBox(
      decoration: continuousCorners
          ? ShapeDecoration(
              color: color,
              shape: RoundedSuperellipseBorder(
                borderRadius: BorderRadius.circular(corner),
              ),
            )
          : BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(corner),
            ),
      child: content,
    );
  }
}
