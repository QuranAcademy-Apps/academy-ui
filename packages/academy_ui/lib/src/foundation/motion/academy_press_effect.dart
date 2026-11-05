import 'dart:math' as math;

import 'package:flutter/gestures.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

import '../../theme/academy_theme.dart';

/// Paint-only feedback for native buttons. Cupertino keeps ownership of taps,
/// keyboard activation and semantics; the hit target never shrinks.
class AcademyPressEffect extends StatefulWidget {
  const AcademyPressEffect({
    super.key,
    required this.child,
    required this.enabled,
  });
  final Widget child;
  final bool enabled;
  @override
  State<AcademyPressEffect> createState() => _AcademyPressEffectState();
}

class _AcademyPressEffectState extends State<AcademyPressEffect>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  late final AnimationController _controller;
  late final CurvedAnimation _curve;
  late Animation<double> _scale;
  int? _pointer;
  Offset? _origin;
  bool _reducedMotion = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _controller = AnimationController(
      vsync: this,
      duration: AcademyTokens.buttonPressMotion,
      reverseDuration: AcademyTokens.buttonReleaseMotion,
    );
    _curve = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutQuart,
      reverseCurve: Curves.easeOutCubic,
    );
  }

  void _reset() {
    _pointer = null;
    _origin = null;
    _controller.value = 0;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _scale = Tween<double>(
      begin: 1,
      end: AcademyTheme.of(context).interaction.pressedScale,
    ).animate(_curve);
    _reducedMotion = MediaQuery.disableAnimationsOf(context);
    if (_reducedMotion) _reset();
  }

  @override
  void didUpdateWidget(AcademyPressEffect oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!widget.enabled) _reset();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state != AppLifecycleState.resumed) _reset();
  }

  void _down(PointerDownEvent event) {
    if (!widget.enabled ||
        _reducedMotion ||
        _pointer != null ||
        event.buttons != kPrimaryButton) {
      return;
    }
    _pointer = event.pointer;
    _origin = event.position;
    _controller.forward();
  }

  void _end(int pointer) {
    if (pointer != _pointer) return;
    _pointer = null;
    _origin = null;
    _controller.reverse();
  }

  void _move(PointerMoveEvent event) {
    if (event.pointer != _pointer) return;
    final render = context.findRenderObject();
    final slop = MediaQuery.gestureSettingsOf(context).touchSlop ?? kTouchSlop;
    if ((event.position - _origin!).distance > slop ||
        render is RenderBox && !render.size.contains(event.localPosition)) {
      _end(event.pointer);
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _curve.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Listener(
    behavior: HitTestBehavior.deferToChild,
    onPointerDown: _down,
    onPointerMove: _move,
    onPointerUp: (event) => _end(event.pointer),
    onPointerCancel: (event) => _end(event.pointer),
    child: _PressPaint(scale: _scale, child: widget.child),
  );
}

class _PressPaint extends SingleChildRenderObjectWidget {
  const _PressPaint({required this.scale, required super.child});
  final Animation<double> scale;
  @override
  RenderObject createRenderObject(BuildContext context) =>
      _RenderPressPaint(scale);
  @override
  void updateRenderObject(
    BuildContext context,
    _RenderPressPaint renderObject,
  ) => renderObject.scale = scale;
}

class _RenderPressPaint extends RenderProxyBox {
  _RenderPressPaint(this._scale);
  Animation<double> _scale;
  set scale(Animation<double> value) {
    if (value == _scale) return;
    if (attached) _scale.removeListener(markNeedsPaint);
    _scale = value;
    if (attached) _scale.addListener(markNeedsPaint);
    markNeedsPaint();
  }

  @override
  void attach(PipelineOwner owner) {
    super.attach(owner);
    _scale.addListener(markNeedsPaint);
  }

  @override
  void detach() {
    _scale.removeListener(markNeedsPaint);
    super.detach();
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    if (size.longestSide <= 0 || _scale.value == 1) {
      super.paint(context, offset);
      return;
    }
    final scale = math.max(
      _scale.value,
      1 - AcademyTokens.buttonMaximumShrink / size.longestSide,
    );
    final center = size.center(Offset.zero);
    final transform = Matrix4.identity()
      ..translateByDouble(center.dx, center.dy, 0, 1)
      ..scaleByDouble(scale, scale, 1, 1)
      ..translateByDouble(-center.dx, -center.dy, 0, 1);
    context.pushTransform(needsCompositing, offset, transform, super.paint);
  }
}
