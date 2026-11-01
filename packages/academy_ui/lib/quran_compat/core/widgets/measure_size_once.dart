import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

/// Сообщает высоту своего child ровно один раз — после первого лэйаута.
///
/// Используется, чтобы узнать высоту однотипной строки списка и отдать её
/// `SuperListView` как точный extent, после чего precalc можно выключить
/// (строки фиксированной высоты). Без хардкода высоты.
class MeasureSizeOnce extends SingleChildRenderObjectWidget {
  const MeasureSizeOnce({
    super.key,
    required this.onMeasured,
    required Widget super.child,
  });

  final ValueChanged<Size> onMeasured;

  @override
  RenderObject createRenderObject(BuildContext context) =>
      _RenderMeasureSizeOnce(onMeasured);

  @override
  void updateRenderObject(BuildContext context, RenderObject renderObject) =>
      (renderObject as _RenderMeasureSizeOnce).onMeasured = onMeasured;
}

class _RenderMeasureSizeOnce extends RenderProxyBox {
  _RenderMeasureSizeOnce(this.onMeasured);

  ValueChanged<Size> onMeasured;
  bool _reported = false;

  @override
  void performLayout() {
    super.performLayout();
    if (_reported || size.height <= 0) return;
    _reported = true;
    // Вызов из performLayout запрещает setState синхронно — откладываем на кадр.
    WidgetsBinding.instance.addPostFrameCallback((_) => onMeasured(size));
  }
}
