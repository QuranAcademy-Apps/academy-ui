// Tinted glass imitation of iOS 26 navigation chrome, ported from Yalla
// (YallaGlassMaterial, ADR-0006, accepted 2026-10-12). No refraction.
import 'academy_chrome.dart';

import 'dart:math' as math;
import 'dart:ui' show ImageFilter;

import 'package:flutter/cupertino.dart';

import '../../../theme/academy_theme.dart';

RSuperellipse _materialShape(Rect rect, double radius, {required bool dark}) {
  final r = radius.clamp(0.0, rect.shortestSide / 2);
  return RSuperellipse.fromRectXY(
    rect,
    rect.width > rect.height * 1.5
        ? r * (dark ? 1.04 : .98)
        : r * (dark ? 1.02 : .98),
    r,
  );
}

class _MaterialClipper extends CustomClipper<RSuperellipse> {
  const _MaterialClipper(this.radius, this.dark);
  final double radius;
  final bool dark;
  @override
  RSuperellipse getClip(Size size) =>
      _materialShape(Offset.zero & size, radius, dark: dark);
  @override
  bool shouldReclip(_MaterialClipper old) =>
      radius != old.radius || dark != old.dark;
}

/// Near-opaque tinted glass: soft backdrop blur, top/bottom edge light and an
/// outside shadow. Used by [AcademyChromeStyle.glass] navigation surfaces only.
class AcademyGlassMaterial extends StatelessWidget {
  const AcademyGlassMaterial({
    super.key,
    required this.child,
    this.radius = 28,
    this.density = .94,
    this.blurSigma = 20,
  });
  final Widget child;
  final double radius;
  final double density;
  final double blurSigma;
  @override
  Widget build(BuildContext context) {
    final dark = AcademyTheme.of(context).brightness == Brightness.dark;
    final colors = AcademyChromeTheme.colorsOf(context);
    final customFill = colors.glassFill;
    final opacity = density.clamp(0.0, 1.0);
    final fill = customFill != null
        ? [customFill, customFill, customFill]
        : dark
        ? const [Color(0xFF313233), Color(0xFF313233), Color(0xFF313233)]
        : const [Color(0xFFF6F6F6), Color(0xFFF6F6F6), Color(0xFFFFFFFF)];
    return _OutsideShadow(
      radius: radius,
      dark: dark,
      shadow: BoxShadow(
        color: (colors.glassShadow ?? CupertinoColors.black).withValues(
          alpha: dark ? .02 : .035,
        ),
        blurRadius: 2.5,
        offset: const Offset(0, 1.5),
      ),
      child: Stack(
        fit: StackFit.passthrough,
        children: [
          Positioned.fill(
            child: ClipRSuperellipse(
              clipper: _MaterialClipper(radius, dark),
              child: BackdropFilter(
                // A fully opaque fill hides every backdrop pixel. Preserve the
                // accepted near-opaque material; only skip an invisible filter.
                enabled: opacity < 1 && blurSigma > 0,
                filter: ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
                child: LayoutBuilder(
                  builder: (context, bounds) {
                    final circular = bounds.maxWidth <= bounds.maxHeight * 1.1;
                    final localFill = customFill == null && !dark && circular
                        ? const [
                            Color(0xFFF8F8F8),
                            Color(0xFFF8F8F8),
                            Color(0xFFFFFFFF),
                          ]
                        : fill;
                    return DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: localFill
                              .map((c) => c.withValues(alpha: opacity))
                              .toList(),
                          stops: !dark && circular
                              ? const [0, .4, 1]
                              : const [0, .18, .86],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
          Positioned.fill(
            child: IgnorePointer(
              child: RepaintBoundary(
                child: CustomPaint(
                  painter: _GlassStrokePainter(
                    radius: radius,
                    dark: dark,
                    rim: colors.glassRim,
                    edge: colors.glassEdge,
                  ),
                ),
              ),
            ),
          ),
          child,
        ],
      ),
    );
  }
}

/// Reference captures are 144 DPI (2 image pixels per logical point).
/// Keep edge-light dimensions in logical points, including on live 44pt controls.
/// Vertical weighting fades the highlights before they reach the side walls.
class _GlassStrokePainter extends CustomPainter {
  _GlassStrokePainter({
    required this.radius,
    required this.dark,
    this.rim,
    this.edge,
  });
  final double radius;
  final bool dark;
  final Color? rim, edge;

  // These profiles depend only on the theme, never on a frame or widget size.
  static final _darkGradients = _gradients(true, CupertinoColors.white);
  static final _lightGradients = _gradients(false, CupertinoColors.white);
  Size? _size;
  late RSuperellipse _shape;
  late Path _contactPath;
  late Paint _contactPaint;
  final _rims = <({Path path, Paint paint})>[];

  static List<LinearGradient> _gradients(bool dark, Color rim) {
    const lightProfile = [
      0.0,
      .65,
      .70,
      .88,
      .88,
      .70,
      .65,
      .55,
      .45,
      .40,
      .25,
      .18,
      .13,
      .10,
      .06,
      .02,
    ];
    return List.generate(dark ? 24 : 16, (depth) {
      final alpha = dark
          ? (depth == 0
                ? .345
                : depth == 1
                ? .20
                : .071 * math.exp(-(depth - 2) / 6.1))
          : lightProfile[depth];
      return LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: List.generate(33, (i) {
          final t = i / 32;
          final weight = math.pow((2 * t - 1).abs(), 3).toDouble();
          return rim.withValues(
            alpha:
                alpha * weight * (dark && t > .5 ? (depth > 1 ? .60 : .91) : 1),
          );
        }, growable: false),
      );
    }, growable: false);
  }

  void _prepare(Size size) {
    if (_size == size) return;
    _size = size;
    final rect = Offset.zero & size;
    final contact = edge ?? CupertinoColors.black;
    _shape = _materialShape(rect, radius, dark: dark);
    _contactPath = Path()..addRSuperellipse(_shape.deflate(.25));
    _contactPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = .5
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          contact.withValues(alpha: dark ? 0 : .058),
          contact.withValues(alpha: dark ? .74 : .23),
          contact.withValues(alpha: dark ? .74 : .23),
          contact.withValues(alpha: dark ? 0 : .085),
        ],
        stops: const [0, .42, .58, 1],
      ).createShader(rect);
    _rims.clear();
    final customRim = rim;
    final gradients = customRim != null
        ? _gradients(dark, customRim)
        : dark
        ? _darkGradients
        : _lightGradients;
    for (var depth = 0; depth < gradients.length; depth++) {
      final inset = depth * .5 + .25;
      if (inset >= size.shortestSide / 2) break;
      _rims.add((
        path: Path()..addRSuperellipse(_shape.deflate(inset)),
        paint: Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = .5
          ..shader = gradients[depth].createShader(
            Rect.fromLTWH(0, depth * .5, size.width, size.height - depth),
          ),
      ));
    }
  }

  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty) return;
    _prepare(size);
    canvas.save();
    // Keep positioned paths: CanvasKit drawRSuperellipse shifts the shader.
    canvas.drawPath(_contactPath, _contactPaint);
    canvas.clipRSuperellipse(_shape);
    for (final rim in _rims) {
      canvas.drawPath(rim.path, rim.paint);
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(_GlassStrokePainter old) =>
      radius != old.radius ||
      dark != old.dark ||
      rim != old.rim ||
      edge != old.edge;
}

class _OutsideShadow extends StatelessWidget {
  const _OutsideShadow({
    required this.radius,
    required this.shadow,
    required this.dark,
    required this.child,
  });
  final double radius;
  final BoxShadow shadow;
  final bool dark;
  final Widget child;
  @override
  Widget build(BuildContext context) =>
      CustomPaint(painter: _ShadowPainter(radius, shadow, dark), child: child);
}

class _ShadowPainter extends CustomPainter {
  const _ShadowPainter(this.radius, this.shadow, this.dark);
  final double radius;
  final BoxShadow shadow;
  final bool dark;
  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final shape = _materialShape(rect, radius, dark: dark);
    final outside = Path()
      ..fillType = PathFillType.evenOdd
      ..addRect(rect.inflate(shadow.blurRadius * 4 + 8))
      ..addRSuperellipse(shape);
    canvas.save();
    canvas.clipPath(outside);
    canvas.drawPath(
      Path()..addRSuperellipse(
        shape.shift(shadow.offset).inflate(shadow.spreadRadius),
      ),
      shadow.toPaint(),
    );
    canvas.restore();
  }

  @override
  bool shouldRepaint(_ShadowPainter old) =>
      radius != old.radius || shadow != old.shadow || dark != old.dark;
}
