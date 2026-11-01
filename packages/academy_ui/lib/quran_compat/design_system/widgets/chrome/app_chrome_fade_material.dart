import 'dart:ui' show ImageFilter;

import 'package:cupertino_ui/cupertino_ui.dart';

import '../../../theme/app_chrome_style.dart';

/// Direction of an [AppChromeFadeMaterial] gradient — which edge is most
/// opaque (where the bar sits) fading toward the content.
enum AppChromeFadeDirection { top, bottom }

/// Gradient fade that lets page content stay visible while softly dissolving as
/// it scrolls under a floating bar. The single source of truth for the app's
/// chrome edge fade — used by the floating top bar, the floating bottom tab
/// bar, and the Quran reader (via `ReaderChromeFadeMaterial`, which delegates
/// here).
///
/// With [enableBackdropBlur] the fade also blurs the content behind it (a
/// frosted material that dissolves), otherwise it is a pure colour gradient.
class AppChromeFadeMaterial extends StatelessWidget {
  const AppChromeFadeMaterial({
    super.key,
    this.direction = AppChromeFadeDirection.top,
    this.enableBackdropBlur = false,
    this.blurSigma = 18,
  });

  final AppChromeFadeDirection direction;
  final bool enableBackdropBlur;
  final double blurSigma;

  /// Length of the fade tail beyond the bar row, i.e. the gradient extends
  /// `bar height + extension` past the safe-area inset. Kept short so the fade
  /// is a tight edge rather than a tall wash.
  static const extension = 8.0;
  static const _stops = [0.0, 0.4, 0.7, 1.0];
  static const _alphas = [0.85, 0.6, 0.2, 0.0];

  @override
  Widget build(BuildContext context) {
    final isTop = direction == AppChromeFadeDirection.top;
    final isDark = CupertinoTheme.brightnessOf(context) == Brightness.dark;
    final materialColor = isDark
        ? CupertinoColors.black
        : CupertinoColors.white;
    // On a short (landscape phone) viewport the fade band occupies a large
    // fraction of the screen, so the standard density reads as a heavy,
    // hard-edged plate. Soften it there so it stays a light wash that dissolves
    // gracefully instead of looking clipped. Tablets / portrait keep full
    // density.
    final shortViewport = MediaQuery.sizeOf(context).height < 500;
    final baseAlpha = isDark ? 0.58 : 0.62;
    final materialAlpha = shortViewport ? baseAlpha * 0.6 : baseAlpha;

    Alignment begin() => isTop ? Alignment.topCenter : Alignment.bottomCenter;
    Alignment end() => isTop ? Alignment.bottomCenter : Alignment.topCenter;

    // Reduce Transparency: no bar plate at all. Removing the blur, gradient and
    // shadow already eliminated the per-frame cost; painting an opaque colour on
    // top would NOT cull the content underneath (Flutter still paints it), so it
    // only adds a draw rather than saving one. The opaque control chips
    // (GradientControlChrome) keep the floating controls legible without a band.
    if (AppChromeStyle.reduceTransparencyOf(context)) {
      return const IgnorePointer(child: SizedBox.expand());
    }

    if (!enableBackdropBlur) {
      return IgnorePointer(
        child: DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: begin(),
              end: end(),
              stops: _stops,
              colors: [
                for (final alpha in _alphas)
                  materialColor.withValues(alpha: materialAlpha * alpha),
              ],
            ),
          ),
          child: const SizedBox.expand(),
        ),
      );
    }

    // Frosted variant: a soft material whose opacity follows the same gradient,
    // applied as a dstIn mask over a backdrop blur so the bar's content stays
    // sharp while the page behind dissolves.
    final fade = LinearGradient(
      begin: begin(),
      end: end(),
      stops: _stops,
      colors: [
        for (final alpha in _alphas)
          const Color(0xFF000000).withValues(alpha: alpha),
      ],
    );

    return IgnorePointer(
      child: ClipRect(
        child: ShaderMask(
          blendMode: BlendMode.dstIn,
          shaderCallback: (bounds) => fade.createShader(bounds),
          child: BackdropFilter.grouped(
            filter: ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
            child: ColoredBox(
              color: materialColor.withValues(alpha: materialAlpha),
              child: BackdropFilter.grouped(
                blendMode: BlendMode.srcOver,
                filter: ImageFilter.blur(
                  sigmaX: blurSigma * 0.45,
                  sigmaY: blurSigma * 0.45,
                ),
                child: const SizedBox.expand(),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
