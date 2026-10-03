import '../../theme/academy_theme.dart';

import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

/// Отдаёт потомкам [GlobalKey] скруглённой поверхности модального шита, чтобы
/// непрозрачный контент мог замаскировать СВОЮ заливку по форме шита у верхних
/// углов (вместо клипа над скроллящимся контентом — тот = offscreen-пас на каждый
/// кадр). Ставит [ModalSheetRoundedSurface]; вне шита scope отсутствует.
class ModalSheetSurfaceScope extends InheritedWidget {
  const ModalSheetSurfaceScope({
    super.key,
    required this.surfaceKey,
    this.radius = AcademyRadii.defaultModal,
    required super.child,
  });

  final GlobalKey surfaceKey;
  final double radius;
  static double radiusOf(BuildContext context) =>
      context
          .dependOnInheritedWidgetOfExactType<ModalSheetSurfaceScope>()
          ?.radius ??
      AcademyTheme.of(context).radii.modal;

  static GlobalKey? maybeSurfaceKeyOf(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<ModalSheetSurfaceScope>()
        ?.surfaceKey;
  }

  /// True, если контекст внутри модального шита (есть скруглённая поверхность).
  static bool isInModalSheet(BuildContext context) =>
      maybeSurfaceKeyOf(context) != null;

  @override
  bool updateShouldNotify(ModalSheetSurfaceScope oldWidget) =>
      surfaceKey != oldWidget.surfaceKey || radius != oldWidget.radius;
}

/// Непрозрачная скруглённая подложка шита: rounded [DecoratedBox]
/// ([academyModalSheetSurfaceShape]) + [ModalSheetSurfaceScope] с ключом на ней.
/// Верхние углы скругляет статичная заливка, без клипа над скроллом.
class ModalSheetRoundedSurface extends StatefulWidget {
  const ModalSheetRoundedSurface({
    super.key,
    required this.color,
    required this.child,
  });

  final Color color;
  final Widget child;

  @override
  State<ModalSheetRoundedSurface> createState() =>
      _ModalSheetRoundedSurfaceState();
}

class _ModalSheetRoundedSurfaceState extends State<ModalSheetRoundedSurface> {
  final GlobalKey _surfaceKey = GlobalKey(
    debugLabel: 'ModalSheetRoundedSurface',
  );

  @override
  Widget build(BuildContext context) {
    return ModalSheetSurfaceScope(
      surfaceKey: _surfaceKey,
      radius: AcademyTheme.of(context).radii.modal,
      child: DecoratedBox(
        key: _surfaceKey,
        decoration: ShapeDecoration(
          color: widget.color,
          shape: RoundedSuperellipseBorder(
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(AcademyTheme.of(context).radii.modal),
            ),
          ),
        ),
        child: widget.child,
      ),
    );
  }
}

/// Красит [color] как непрозрачную заливку формы [borderRadius] (углы
/// карточки/строки), ДОПОЛНИТЕЛЬНО обрезанную по форме шита у его верхних углов
/// (чтобы заливка не заезжала в вырез скруглённого угла), затем рисует child.
/// Вдали от верхних углов — просто rrect [borderRadius] (заменяет ClipRRect без
/// offscreen-паса). Поверхность шита берётся из [ModalSheetSurfaceScope]; если его
/// нет (full-page) — всегда rrect. Маска пересчитывается в paint(), поэтому
/// элемент НЕ должен быть в кэширующем RepaintBoundary (иначе маска замёрзнет).
class ModalSheetMaskedFill extends SingleChildRenderObjectWidget {
  const ModalSheetMaskedFill({
    super.key,
    required this.color,
    this.borderRadius = BorderRadius.zero,
    super.child,
  });

  final Color color;
  final BorderRadius borderRadius;

  @override
  RenderModalSheetMaskedFill createRenderObject(BuildContext context) {
    return RenderModalSheetMaskedFill(
      color: color,
      borderRadius: borderRadius,
      surfaceKey: ModalSheetSurfaceScope.maybeSurfaceKeyOf(context),
      modalRadius: ModalSheetSurfaceScope.radiusOf(context),
    );
  }

  @override
  void updateRenderObject(
    BuildContext context,
    RenderModalSheetMaskedFill renderObject,
  ) {
    renderObject
      ..color = color
      ..borderRadius = borderRadius
      ..surfaceKey = ModalSheetSurfaceScope.maybeSurfaceKeyOf(context)
      ..modalRadius = ModalSheetSurfaceScope.radiusOf(context);
  }
}

class RenderModalSheetMaskedFill extends RenderProxyBox {
  RenderModalSheetMaskedFill({
    required Color color,
    required BorderRadius borderRadius,
    required GlobalKey? surfaceKey,
    double modalRadius = AcademyRadii.defaultModal,
  }) : // Public constructor names differ from private mutable storage.
       // ignore: prefer_initializing_formals
       _color = color,
       // ignore: prefer_initializing_formals
       _borderRadius = borderRadius,
       // ignore: prefer_initializing_formals
       _surfaceKey = surfaceKey,
       // ignore: prefer_initializing_formals
       _modalRadius = modalRadius;

  double _modalRadius;
  set modalRadius(double value) {
    if (_modalRadius == value) return;
    _modalRadius = value;
    markNeedsPaint();
  }

  ShapeBorder get _shape => RoundedSuperellipseBorder(
    borderRadius: BorderRadius.vertical(top: Radius.circular(_modalRadius)),
  );

  Color _color;
  BorderRadius _borderRadius;
  GlobalKey? _surfaceKey;

  set color(Color value) {
    if (_color == value) return;
    _color = value;
    markNeedsPaint();
  }

  set borderRadius(BorderRadius value) {
    if (_borderRadius == value) return;
    _borderRadius = value;
    markNeedsPaint();
  }

  set surfaceKey(GlobalKey? value) {
    if (identical(_surfaceKey, value)) return;
    _surfaceKey = value;
    markNeedsPaint();
  }

  RenderBox? get _surfaceBox {
    final renderObject = _surfaceKey?.currentContext?.findRenderObject();
    if (renderObject is RenderBox && renderObject.hasSize) {
      return renderObject;
    }
    return null;
  }

  // Переиспользуем между кадрами — в paint() переназначаем только цвет.
  final Paint _fillPaint = Paint();

  @override
  void paint(PaintingContext context, Offset offset) {
    if (size.isEmpty) {
      super.paint(context, offset);
      return;
    }

    final canvas = context.canvas;
    final paint = _fillPaint..color = _color;
    final rect = Offset.zero & size;

    canvas.save();
    canvas.translate(offset.dx, offset.dy);
    _paintFill(canvas, paint, rect);
    canvas.restore();

    super.paint(context, offset);
  }

  void _paintFill(Canvas canvas, Paint paint, Rect rect) {
    final elementRRect = _borderRadius.toRRect(rect);
    final surfaceBox = _surfaceBox;
    if (surfaceBox == null) {
      canvas.drawRRect(elementRRect, paint);
      return;
    }

    final localToSurface = getTransformTo(surfaceBox);
    final rectInSurface = MatrixUtils.transformRect(localToSurface, rect);
    final surfaceToLocal = Matrix4.tryInvert(localToSurface);
    final radius = _modalRadius;
    final intersectsTopCorners =
        rectInSurface.top < radius &&
        rectInSurface.bottom > 0 &&
        rectInSurface.left < surfaceBox.size.width &&
        rectInSurface.right > 0;
    // Вырожденный трансформ (scale→0 в переходе) → tryInvert == null: дешёвый
    // фоллбэк на собственный rrect вместо краша в paint().
    if (!intersectsTopCorners || surfaceToLocal == null) {
      canvas.drawRRect(elementRRect, paint);
      return;
    }

    final surfacePath = _shape
        .getOuterPath(Offset.zero & surfaceBox.size)
        .transform(surfaceToLocal.storage);
    final elementPath = Path()..addRRect(elementRRect);
    final visiblePath = Path.combine(
      PathOperation.intersect,
      elementPath,
      surfacePath,
    );
    canvas.drawPath(visiblePath, paint);
  }
}
