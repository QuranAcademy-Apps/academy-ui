import 'dart:ui';

import 'package:cupertino_ui/cupertino_ui.dart';

import '../../theme/app_chrome_style.dart';
import '../../theme/app_colors.dart';

/// Gradient-filled control chrome used by reader bars and floating toasts.
class GradientControlChrome extends StatelessWidget {
  const GradientControlChrome({
    super.key,
    required this.child,
    required this.radius,
    this.borderWidth = 1,
    this.boxShadow = const [],
    this.enableBackdropBlur = false,
    this.enableShadow = true,
  });

  final Widget child;
  final double radius;
  final double borderWidth;
  final List<BoxShadow> boxShadow;
  final bool enableBackdropBlur;

  /// When false, the chrome renders with no drop shadow so content scrolling
  /// behind/around it stays crisp (used by the floating tab bar, which sits
  /// directly over list content).
  final bool enableShadow;

  static const capsuleRadius = 30.0;

  @override
  Widget build(BuildContext context) {
    final isDark = CupertinoTheme.brightnessOf(context) == Brightness.dark;
    final borderRadius = BorderRadius.circular(radius);

    // Reduce Transparency.
    if (AppChromeStyle.reduceTransparencyOf(context)) {
      // A control that was frosting over live media (video player) drops its
      // surface entirely so the video shows through — only the icon/label
      // remains. Everywhere else: a flat opaque control (solid fill + coloured
      // outline), no gradient, shadow, or backdrop blur.
      if (enableBackdropBlur) return child;
      final colors = context.appColors;
      return DecoratedBox(
        decoration: BoxDecoration(
          color: colors.backgroundControl,
          borderRadius: borderRadius,
          // Neutral grey outline (the favourites-heart tint) rather than the
          // accent, so the flat controls read as quiet chrome.
          border: Border.all(
            color: CupertinoColors.secondaryLabel.resolveFrom(context),
            width: borderWidth <= 0 ? 1 : borderWidth,
          ),
        ),
        child: child,
      );
    }
    // The fill `DecoratedBox` carries the [borderRadius] so its gradient is
    // self-clipped to the rounded rect. In the common (non-blur) path this lets
    // us drop the antialiased `ClipRRect` entirely — one fewer clip layer per
    // chrome control (these render several per bar). The clip is only needed to
    // bound the backdrop blur, so it stays on that path alone.
    final paintedChild = CustomPaint(
      foregroundPainter: _GradientControlChromePainter(
        radius: radius,
        borderWidth: borderWidth,
        isDark: isDark,
      ),
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: borderRadius,
          gradient: _GradientControlChromePainter.fillGradient(isDark),
        ),
        child: child,
      ),
    );
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: borderRadius,
        boxShadow: !enableShadow
            ? const []
            : (boxShadow.isEmpty
                  ? _GradientControlChromeShadowDefaults.boxShadows(isDark)
                  : boxShadow),
      ),
      child: enableBackdropBlur
          ? ClipRRect(
              borderRadius: borderRadius,
              child: BackdropFilter.grouped(
                filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
                child: paintedChild,
              ),
            )
          : paintedChild,
    );
  }
}

class GradientControlChromeCapsule extends StatelessWidget {
  const GradientControlChromeCapsule({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return GradientControlChrome(
      radius: GradientControlChrome.capsuleRadius,
      child: child,
    );
  }
}

class _GradientControlChromeShadowDefaults {
  const _GradientControlChromeShadowDefaults._();

  static final List<BoxShadow> _dark = [
    BoxShadow(
      color: CupertinoColors.black.withValues(alpha: 0.2),
      blurRadius: 14,
      spreadRadius: 0.4,
      offset: Offset.zero,
    ),
  ];

  static final List<BoxShadow> _light = [
    BoxShadow(
      color: CupertinoColors.black.withValues(alpha: 0.1),
      blurRadius: 14,
      spreadRadius: 0.4,
      offset: Offset.zero,
    ),
  ];

  static List<BoxShadow> boxShadows(bool isDark) {
    return isDark ? _dark : _light;
  }
}

class _GradientControlChromePainter extends CustomPainter {
  const _GradientControlChromePainter({
    required this.radius,
    required this.borderWidth,
    required this.isDark,
  });

  static const LinearGradient _darkFillGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF1C1C1E), Color(0xFF2F2F32)],
  );

  static const LinearGradient _lightFillGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFFF2F2F2), Color(0xFFFFFFFF)],
  );

  static const LinearGradient _darkStrokeGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0x66FFFFFF), Color(0x26FFFFFF)],
  );

  static const LinearGradient _lightStrokeGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFFFFFFFF), Color(0xFFE5E5E5)],
  );

  static LinearGradient fillGradient(bool isDark) {
    return isDark ? _darkFillGradient : _lightFillGradient;
  }

  static LinearGradient strokeGradient(bool isDark) {
    return isDark ? _darkStrokeGradient : _lightStrokeGradient;
  }

  final double radius;
  final double borderWidth;
  final bool isDark;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    if (borderWidth <= 0) return;

    final strokeInset = borderWidth / 2;
    final strokeRadius = radius > strokeInset ? radius - strokeInset : 0.0;
    final strokePaint = Paint()
      ..shader = strokeGradient(isDark).createShader(rect)
      ..style = PaintingStyle.stroke
      ..strokeWidth = borderWidth;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        rect.deflate(strokeInset),
        Radius.circular(strokeRadius),
      ),
      strokePaint,
    );
  }

  @override
  bool shouldRepaint(covariant _GradientControlChromePainter oldDelegate) {
    return oldDelegate.radius != radius ||
        oldDelegate.borderWidth != borderWidth ||
        oldDelegate.isDark != isDark;
  }
}
