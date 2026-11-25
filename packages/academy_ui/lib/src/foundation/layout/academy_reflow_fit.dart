import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

/// Fits wrapping text into the box it is given, by re-wrapping it.
///
/// `FittedBox` lays the child out at the full width and then shrinks the
/// finished block: the lines stay as they were wrapped, so a block taller than
/// the room comes out narrower than the box. This one finds the largest scale
/// `s <= 1` for which the child, laid out at `width / s` and drawn at `s`,
/// fits the height: wider virtual width means fewer lines, and drawing at `s`
/// fills the real width. A child that already fits is left at scale 1.
///
/// Needs a bounded width and height from the parent; the child must support
/// dry layout (text, `Column`, `Padding`, `SizedBox`).
///
/// Ported from Zikro's counter screen (the dhikr text fills the room left by
/// the ring), 2026-11-25.
class AcademyReflowFit extends SingleChildRenderObjectWidget {
  const AcademyReflowFit({super.key, super.child});

  @override
  RenderObject createRenderObject(BuildContext context) => _RenderReflowFit();
}

class _RenderReflowFit extends RenderBox
    with RenderObjectWithChildMixin<RenderBox> {
  static const _minScale = .1;
  static const _steps = 14;

  Matrix4 _transform = Matrix4.identity();

  @override
  void setupParentData(RenderObject child) {
    if (child.parentData is! BoxParentData) child.parentData = BoxParentData();
  }

  double _scaleFor(RenderBox child, double width, double height) {
    double heightAt(double scale) =>
        scale *
        child.getDryLayout(BoxConstraints(maxWidth: width / scale)).height;
    if (heightAt(1) <= height) return 1;
    var low = _minScale, high = 1.0;
    for (var i = 0; i < _steps; i++) {
      final mid = (low + high) / 2;
      if (heightAt(mid) <= height) {
        low = mid;
      } else {
        high = mid;
      }
    }
    return low;
  }

  /// Scale and the child's size at that scale (the child is laid out at
  /// `width / scale`).
  (double, Size) _fit(RenderBox child, BoxConstraints constraints) {
    final width = constraints.maxWidth;
    final scale = constraints.hasBoundedHeight && constraints.hasBoundedWidth
        ? _scaleFor(child, width, constraints.maxHeight)
        : 1.0;
    final size = child.getDryLayout(BoxConstraints(maxWidth: width / scale));
    return (scale, size);
  }

  Size _sizeFor(BoxConstraints constraints, double scale, Size child) =>
      constraints.constrain(
        Size(
          constraints.hasBoundedWidth ? constraints.maxWidth : child.width,
          constraints.hasBoundedHeight
              ? constraints.maxHeight
              : child.height * scale,
        ),
      );

  @override
  Size computeDryLayout(BoxConstraints constraints) {
    final child = this.child;
    if (child == null) return constraints.smallest;
    final (scale, size) = _fit(child, constraints);
    return _sizeFor(constraints, scale, size);
  }

  @override
  void performLayout() {
    final child = this.child;
    if (child == null) {
      size = constraints.smallest;
      return;
    }
    final (scale, _) = _fit(child, constraints);
    child.layout(
      BoxConstraints(maxWidth: constraints.maxWidth / scale),
      parentUsesSize: true,
    );
    size = _sizeFor(constraints, scale, child.size);
    // Centered both ways in the room, drawn at [scale].
    _transform = Matrix4.translationValues(
      (size.width - child.size.width * scale) / 2,
      (size.height - child.size.height * scale) / 2,
      0,
    )..scaleByDouble(scale, scale, 1, 1);
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    final child = this.child;
    if (child == null) return;
    layer = context.pushTransform(
      needsCompositing,
      offset,
      _transform,
      (context, offset) => context.paintChild(child, offset),
      oldLayer: layer is TransformLayer ? layer as TransformLayer? : null,
    );
  }

  @override
  void applyPaintTransform(RenderBox child, Matrix4 transform) =>
      transform.multiply(_transform);

  @override
  bool hitTestChildren(BoxHitTestResult result, {required Offset position}) {
    final child = this.child;
    if (child == null) return false;
    return result.addWithPaintTransform(
      transform: _transform,
      position: position,
      hitTest: (result, position) => child.hitTest(result, position: position),
    );
  }
}
