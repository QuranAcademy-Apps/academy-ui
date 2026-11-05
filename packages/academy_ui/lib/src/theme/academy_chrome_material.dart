import 'package:flutter/widgets.dart';

/// Surface of [AcademyChrome] for a whole app. A null role keeps the palette
/// default noted on it.
@immutable
class AcademyChromeMaterial {
  const AcademyChromeMaterial({
    this.fill,
    this.borderGradient,
    this.borderWidth = 1,
    this.shadows = const [],
    this.reducedFill,
    this.reducedBorder,
    this.backdropBlurSigma = 18,
  });

  /// Fill of the gradient style; default: chromeGradientStart to chromeGradientEnd.
  final Gradient? fill;

  /// Stroke of the gradient style; default: a solid chromeBorder line.
  final Gradient? borderGradient;

  /// Width of [borderGradient].
  final double borderWidth;

  /// Elevation of the gradient style; default: [AcademyChromeColors.shadow].
  final List<BoxShadow> shadows;

  /// Fill under reduced transparency; default: opaque chromeSurface.
  final Color? reducedFill;

  /// Outline under reduced transparency; default: chromeBorder.
  final Color? reducedBorder;

  /// Blur of a chrome that frosts over live content.
  final double backdropBlurSigma;
}
