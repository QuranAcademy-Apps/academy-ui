import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/physics.dart';

/// Touch uses native bounce; wheel input gets a viewport-only edge spring.
class AcademyScrollBehavior extends CupertinoScrollBehavior {
  const AcademyScrollBehavior({this.mouseDrag = true});

  /// Mouse dragging only where the platform has native Apple pointers. A mouse
  /// drag elsewhere would scroll instead of selecting text.
  factory AcademyScrollBehavior.forEnvironment({
    required TargetPlatform platform,
    required bool isWeb,
  }) => AcademyScrollBehavior(
    mouseDrag:
        !isWeb &&
        (platform == TargetPlatform.macOS || platform == TargetPlatform.iOS),
  );

  final bool mouseDrag;
  @override
  Set<PointerDeviceKind> get dragDevices => {
    ...super.dragDevices,
    if (mouseDrag) PointerDeviceKind.mouse,
  };
  @override
  ScrollPhysics getScrollPhysics(BuildContext context) =>
      const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics());
  @override
  Widget buildOverscrollIndicator(
    BuildContext context,
    Widget child,
    ScrollableDetails details,
  ) => _WheelEdgeSpring(details: details, child: child);
}

/// Lets a mouse select text inside [child], keeping every other inherited
/// scroll setting. Wrap scrollables that contain selectable or editable text.
class AcademySelectionSafeScrollBoundary extends StatelessWidget {
  const AcademySelectionSafeScrollBoundary({super.key, required this.child});
  final Widget child;
  @override
  Widget build(BuildContext context) {
    final behavior = ScrollConfiguration.of(context);
    if (!behavior.dragDevices.contains(PointerDeviceKind.mouse)) return child;
    return ScrollConfiguration(
      behavior: behavior.copyWith(
        dragDevices: behavior.dragDevices.difference({PointerDeviceKind.mouse}),
      ),
      child: child,
    );
  }
}

class _WheelEdgeSpring extends StatefulWidget {
  const _WheelEdgeSpring({required this.details, required this.child});
  final ScrollableDetails details;
  final Widget child;
  @override
  State<_WheelEdgeSpring> createState() => _WheelEdgeSpringState();
}

class _WheelEdgeSpringState extends State<_WheelEdgeSpring>
    with SingleTickerProviderStateMixin {
  late final _spring = AnimationController.unbounded(vsync: this);
  Timer? _release;
  bool get _horizontal =>
      axisDirectionToAxis(widget.details.direction) == Axis.horizontal;

  void _signal(PointerSignalEvent event) {
    final controller = widget.details.controller;
    if (event is! PointerScrollEvent ||
        controller == null ||
        controller.positions.length != 1 ||
        MediaQuery.disableAnimationsOf(context)) {
      return;
    }
    final position = controller.position;
    if (!position.hasContentDimensions) return;
    final raw = _horizontal ? event.scrollDelta.dx : event.scrollDelta.dy;
    final reverse =
        widget.details.direction == AxisDirection.up ||
        widget.details.direction == AxisDirection.left;
    final delta = reverse ? -raw : raw;
    final outward =
        (position.pixels <= position.minScrollExtent && delta < 0) ||
        (position.pixels >= position.maxScrollExtent && delta > 0);
    if (!outward) return;
    // First/deepest eligible viewport wins; regular scrolling remains with Flutter.
    GestureBinding.instance.pointerSignalResolver.register(event, (resolved) {
      (resolved as PointerScrollEvent).respond(allowPlatformDefault: false);
      _release?.cancel();
      _spring.stop();
      _spring.value = (_spring.value - raw * .28).clamp(-64.0, 64.0);
      _release = Timer(const Duration(milliseconds: 90), () {
        if (!mounted) return;
        _spring.animateWith(
          SpringSimulation(
            const SpringDescription(mass: 1, stiffness: 220, damping: 24),
            _spring.value,
            0,
            0,
          ),
        );
      });
    });
  }

  @override
  void dispose() {
    _release?.cancel();
    _spring.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Listener(
    onPointerSignal: _signal,
    child: ClipRect(
      child: AnimatedBuilder(
        animation: _spring,
        child: widget.child,
        builder: (context, child) => Transform.translate(
          key: const ValueKey('wheel-edge-transform'),
          offset: _horizontal
              ? Offset(_spring.value, 0)
              : Offset(0, _spring.value),
          child: child,
        ),
      ),
    ),
  );
}
