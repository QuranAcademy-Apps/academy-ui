import '../../../theme/academy_theme.dart';

import 'package:flutter/cupertino.dart';

/// Translucent edge plate under a floating bar: content dissolves softly as it
/// scrolls under the chrome. Ported from Quran's `AppChromeFadeMaterial`
/// (colour gradient only, no backdrop blur). Fills its parent; size it to the
/// bar zone plus [extension].
class AcademyChromeFadeMaterial extends StatelessWidget {
  const AcademyChromeFadeMaterial({super.key, this.bottom = false});

  /// Which edge is most opaque: the bottom one when true, otherwise the top.
  final bool bottom;

  /// Fade tail beyond the bar row, kept short so it reads as an edge.
  static const extension = 8.0;
  static const _stops = [0.0, 0.4, 0.7, 1.0];
  static const _alphas = [0.85, 0.6, 0.2, 0.0];

  @override
  Widget build(BuildContext context) {
    final dark = CupertinoTheme.brightnessOf(context) == Brightness.dark;
    final material = AcademyTheme.of(context).colorScheme.chromeFade;
    final base = dark ? 0.58 : 0.62;
    // A short (landscape phone) viewport would turn the plate into a heavy band.
    final density = MediaQuery.sizeOf(context).height < 500 ? base * 0.6 : base;
    return IgnorePointer(
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: bottom ? Alignment.bottomCenter : Alignment.topCenter,
            end: bottom ? Alignment.topCenter : Alignment.bottomCenter,
            stops: _stops,
            colors: [
              for (final alpha in _alphas)
                material.withValues(alpha: density * alpha),
            ],
          ),
        ),
        child: const SizedBox.expand(),
      ),
    );
  }
}
