import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:motor/motor.dart';

import 'clamped_animation.dart';
import 'dismissal_mode.dart';
import 'relative_sheet_gesture_detector.dart';
import 'route_snapshot_mode.dart';
import 'sheet_dismissal_transition.dart';
import 'sheet_snapshot_state.dart';
import 'snapping_point.dart';

/// A mixin that provides sheet transition behavior for a [PopupRoute].
///
/// This mixin handles the slide-up animation, drag gesture detection,
/// and dismissal logic for sheet-style popups.
///
/// The sheet slides in from the bottom and can be dismissed by dragging down
/// or by tapping the barrier. The animation supports spring physics for
/// natural motion.
///
/// See also:
///
///  * [StupidSimpleSheetRoute], which is a [PopupRoute] that leverages this
/// mixin.
mixin StupidSimpleSheetTransitionMixin<T> on PopupRoute<T> {
  /// Builds the primary contents of the sheet.
  @protected
  Widget buildContent(BuildContext context);

  /// The motion configuration for the sheet animation.
  Motion get motion;

  /// How much resistance the sheet should give when the user tries to drag
  /// it past it's fully opened state.
  double get overshootResistance => 100;

  /// {@template clearBarrierImmediately}
  /// Whether this route should clear the modal barrier immediately when
  /// dismissed.
  ///
  /// This can make your app feel more responsive by letting the user interact
  /// with the underlying content, while this sheet is still animating out.
  ///
  /// Defaults to true.
  /// {@endtemplate}
  bool get clearBarrierImmediately => true;

  /// {@template onlyDragWhenScrollWasAtTop}
  /// Whether the sheet should only start being draggable when its scrollable
  /// content was at the top whenever the user initiates a drag.
  ///
  /// If this is true, and the user starts scrolling up from somewhere other
  /// than the top, the scroll view will perform a normal overscroll.
  ///
  /// This matches iOS sheet behavior and defaults to true.
  /// {@endtemplate}
  bool get onlyDragWhenScrollWasAtTop => true;

  /// Whether the sheet can be dragged.
  ///
  /// When false, the sheet cannot be moved by dragging and applies
  /// resistance in both directions, similar to the resistance applied when
  /// dragging past 1.0.
  ///
  /// Defaults to true.
  bool get draggable => true;

  /// Whether the navigator's user gesture methods should be called when
  /// dragging starts and ends.
  ///
  /// Defaults to false.
  bool get callNavigatorUserGestureMethods => false;

  /// Whether the sheet's origin should be moved up by the bottom view inset of
  /// the current [MediaQuery].
  ///
  /// If this is true, and the keyboard is opened, the sheet will originate from
  /// above the keyboard.
  bool get originateAboveBottomViewInset => false;

  /// The mode used to animate the sheet's dismissal.
  ///
  /// [DismissalMode.slide] translates the sheet downward (the default).
  /// [DismissalMode.shrink] shrinks the sheet vertically, clipping overflow
  /// once the child's minimum intrinsic height is reached.
  ///
  /// Defaults to [DismissalMode.slide].
  DismissalMode get dismissalMode => DismissalMode.slide;

  /// Controls when the route behind this sheet is rasterized to a GPU texture.
  ///
  /// When enabled, the previous route's widget tree is replaced with a frozen
  /// image during the configured phases, eliminating rebuild/paint costs.
  ///
  /// Defaults to [RouteSnapshotMode.never].
  ///
  /// To use this, subclasses must also provide a [delegatedTransition] that
  /// wraps the previous route's child in a [SnapshotWidget] using
  /// [backgroundSnapshotController]. See [StupidSimpleSheetRoute] for an
  /// example.
  RouteSnapshotMode get backgroundSnapshotMode => RouteSnapshotMode.never;

  /// The [SnapshotController] that toggles snapshotting of the background
  /// route.
  ///
  /// Subclasses should pass this to a [SnapshotWidget] wrapping the previous
  /// route's child inside their [delegatedTransition].
  @protected
  SnapshotController get backgroundSnapshotController => _snapshot.controller;

  late final SheetSnapshotState _snapshot =
      SheetSnapshotState(onScrollChanged: _updateSnapshotState);

  /// The [SnapshotController] from the sheet route stacked on top of this one.
  ///
  /// Set automatically when another [StupidSimpleSheetTransitionMixin] route
  /// pushes on top. Used by [maybeSnapshotChild] to wrap this route's content.
  SnapshotController? _coveredBySnapshotController;

  bool _isUserDragging = false;

  @override
  bool get allowSnapshotting =>
      backgroundSnapshotMode != RouteSnapshotMode.never;

  @protected
  SheetSnappingConfig? snappingConfigOverride;

  /// The base snapping configuration for the sheet, as provided by the
  /// implementing class.
  ///
  /// This is used as the fallback when no override is set via
  /// [StupidSimpleSheetController.overrideSnappingConfig].
  ///
  /// Defaults to only containing a relative point at 1.0 (fully open).
  ///
  /// A fully closed point of 0.0 is always added implicitly.
  @protected
  SheetSnappingConfig get snappingConfig;

  /// The currently active snapping configuration for the sheet.
  ///
  /// This will return the override if one has been set via
  /// [StupidSimpleSheetController.overrideSnappingConfig], otherwise it returns
  /// [snappingConfig].
  SheetSnappingConfig get effectiveSnappingConfig =>
      snappingConfigOverride ?? snappingConfig;

  double? _dragEndVelocity;

  @protected
  double? animationTargetValue;

  /// Where the sheet should stick if [draggable] is false, or when
  /// overshooting.
  @protected
  double? stickingPoint;

  void _updateSnapshotState() {
    _snapshot.update(
      mode: backgroundSnapshotMode,
      animation: controller,
      isUserDragging: _isUserDragging,
      maxExtent: effectiveSnappingConfig.maxExtent,
      animationTargetValue: animationTargetValue,
      isCovered: _coveredBySnapshotController != null,
    );
  }

  @override
  Duration get transitionDuration => switch (motion) {
        CurvedMotion(:final duration) => duration,
        CupertinoMotion(:final duration) => duration,
        _ => const Duration(milliseconds: 500),
      };

  @override
  Animation<double>? get animation => super.animation?.clamped;

  @override
  Animation<double>? get secondaryAnimation =>
      super.secondaryAnimation?.clamped;

  @override
  Simulation? createSimulation({required bool forward}) {
    final v = _dragEndVelocity;
    _dragEndVelocity = null;

    // Get the appropriate end value
    double endValue;
    if (forward) {
      // Opening: use initial snap point or default
      endValue = effectiveSnappingConfig.initialSnap;
    } else {
      // Closing
      endValue = 0.0;
    }
    animationTargetValue = endValue;
    stickingPoint = endValue;
    _updateSnapshotState();
    return motion.createSimulation(
      end: endValue,
      start: animation?.value ?? 0,
      velocity: -(v ?? 0),
    );
  }

  @override
  Widget buildPage(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
  ) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) => MediaQuery.removeViewInsets(
        context: context,
        removeBottom: originateAboveBottomViewInset,
        // ^ The sheet is already moved up by the bottom view inset, so we make
        // sure the content inside the sheet doesn't add extra padding
        child: RelativeSheetGestureDetector(
          dismissalMode: dismissalMode,
          onlyDragWhenScrollWasAtTop: onlyDragWhenScrollWasAtTop,
          scrollableCanMoveBack: (animationTargetValue ?? animation.value) <
              effectiveSnappingConfig.maxExtent,
          onRelativeDragStart: () => _handleDragStart(context),
          onRelativeDragUpdate: (relativeDelta, referenceHeight, wouldScroll) =>
              _handleDragUpdate(
            context,
            relativeDelta,
            referenceHeight,
            wouldScroll,
          ),
          onRelativeDragEnd: (relativeVelocity, referenceHeight, willScroll) =>
              _handleDragEnd(
            context,
            relativeVelocity,
            referenceHeight,
            willScroll,
          ),
          child: child!,
        ),
      ),
      // LOCAL PATCH (quran_flutter): observe inner scrolls only for the
      // animatingAndScrolling mode (the only one that freezes on content scroll).
      child: backgroundSnapshotMode == RouteSnapshotMode.animatingAndScrolling
          ? NotificationListener<ScrollNotification>(
              onNotification: _snapshot.handleContentScroll,
              child: buildContent(context),
            )
          : buildContent(context),
    );
  }

  @override
  AnimationController createAnimationController() {
    assert(
      !debugTransitionCompleted(),
      'Cannot reuse a $runtimeType after disposing it.',
    );
    final duration = transitionDuration;
    final reverseDuration = reverseTransitionDuration;
    final animationController = AnimationController.unbounded(
      duration: duration,
      reverseDuration: reverseDuration,
      debugLabel: debugLabel,
      vsync: navigator!,
    )..addStatusListener((_) => _updateSnapshotState());
    return animationController;
  }

  @override
  Widget buildTransitions(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Flexible(
          child: SheetDismissalTransition(
            animation: controller!,
            dismissalMode: dismissalMode,
            child: child,
          ),
        ),
        if (originateAboveBottomViewInset)
          SizedBox(
            height: MediaQuery.viewInsetsOf(context).bottom,
          ),
      ],
    );
  }

  final _poppedNotifier = ValueNotifier(false);

  @override
  Widget buildModalBarrier() {
    return ValueListenableBuilder(
      valueListenable: _poppedNotifier,
      builder: (context, value, child) {
        return IgnorePointer(
          ignoring: value && clearBarrierImmediately,
          child: super.buildModalBarrier(),
        );
      },
    );
  }

  @override
  @mustCallSuper
  bool didPop(T? result) {
    _poppedNotifier.value = true;
    _updateSnapshotState();
    return super.didPop(result);
  }

  void _handleDragStart(
    BuildContext context,
  ) {
    _isUserDragging = true;
    _updateSnapshotState();
    if (callNavigatorUserGestureMethods) {
      navigator?.didStartUserGesture();
    }
  }

  void _handleDragUpdate(
    BuildContext context,
    double delta,
    double referenceHeight,
    bool wouldScroll,
  ) {
    if (_poppedNotifier.value) return;
    final currentValue = controller?.value ?? 0;
    var adjustedDelta = delta;

    final maxExtent = effectiveSnappingConfig.maxExtent;

    final minSnap = effectiveSnappingConfig.minExtent;
    final cannotPop = popDisposition != RoutePopDisposition.pop;
    final belowMinAndCannotPop =
        cannotPop && currentValue < minSnap && delta > 0;

    final applyResistance =
        !draggable || currentValue > maxExtent || belowMinAndCannotPop;

    if (wouldScroll && (currentValue - delta) > maxExtent) {
      // If the scrollable would scroll, and the sheet will be dragged past its
      // max, we don't allow that.
      adjustedDelta = currentValue - maxExtent;
    } else if (applyResistance && delta != 0) {
      final stickingPoint = this.stickingPoint ?? 1.0;
      // Reduce the delta with diminishing returns (resistance)

      final overshoot = (stickingPoint - currentValue).abs();

      final resistance = 1.0 /
          (1.0 + overshoot * overshootResistance); // Exponential resistance

      adjustedDelta = delta * resistance;
    }

    final newValue = currentValue - adjustedDelta;

    controller?.value = newValue;
    animationTargetValue = newValue;
  }

  void _handleDragEnd(
    BuildContext context,
    double velocity,
    double referenceHeight,
    bool willScroll,
  ) {
    _isUserDragging = false;
    final currentValue = controller!.value;
    if (callNavigatorUserGestureMethods) {
      navigator?.didStopUserGesture();
    }

    // If the route has been popped, don't interfere with the closing animation
    if (_poppedNotifier.value) return;

    _dragEndVelocity = velocity;

    final maxExtent = effectiveSnappingConfig.maxExtent;

    final minSnap = effectiveSnappingConfig.minExtent;
    final cannotPop = popDisposition != RoutePopDisposition.pop;
    final belowMinAndCannotPop = cannotPop && currentValue < minSnap;

    // If dragged past fully open, or below min snap when route can't pop,
    // snap back to the appropriate point
    if (currentValue > maxExtent || !draggable || belowMinAndCannotPop) {
      final stickingPoint = this.stickingPoint ?? maxExtent;
      final snapTarget = currentValue > maxExtent ? maxExtent : stickingPoint;
      // Scale the velocity by the same resistance factor that was applied
      // during dragging
      final overshoot = (currentValue - stickingPoint).abs();
      final resistance = 1.0 / (maxExtent + overshoot * overshootResistance);
      final adjustedVelocity = velocity * resistance;

      final backSim = motion.createSimulation(
        start: currentValue,
        end: snapTarget,
        velocity: -adjustedVelocity,
      );
      controller!.animateWith(backSim);
      _dragEndVelocity = null;
    } else {
      // Find the target snap point based on position and velocity
      final targetValue =
          animationTargetValue = effectiveSnappingConfig.findTargetSnapPoint(
        position: currentValue,
        relativeVelocity: -velocity,
        absoluteVelocity: -velocity * referenceHeight,
        includeClosed: popDisposition == RoutePopDisposition.pop,
      );

      stickingPoint = targetValue;

      // If target is 0 (closed), dismiss the sheet
      if (targetValue <= 0.001) {
        navigator?.pop();
      } else {
        // Animate to the target snap point
        final snapSim = motion.createSimulation(
          start: currentValue,
          end: targetValue,
          velocity: -_dragEndVelocity!,
        );
        controller!.animateWith(snapSim);
        _dragEndVelocity = null;
      }
    }
    _updateSnapshotState();
  }

  /// Wraps [child] in a [SnapshotWidget] if another sheet route with
  /// snapshotting is stacked on top of this one.
  ///
  /// Call this in [buildTransitions] around the content that should be
  /// snapshotted when covered by another sheet. Returns [child] unchanged
  /// when no snapshotting is active.
  @protected
  Widget maybeSnapshotChild(Widget child) {
    final controller = _coveredBySnapshotController;
    if (controller == null) return child;
    return SnapshotWidget(
      controller: controller,
      mode: SnapshotMode.permissive,
      autoresize: true,
      child: child,
    );
  }

  @override
  @mustCallSuper
  void didChangeNext(Route<dynamic>? nextRoute) {
    super.didChangeNext(nextRoute);
    if (nextRoute is StupidSimpleSheetTransitionMixin) {
      _coveredBySnapshotController = nextRoute._snapshot.controller;
    } else {
      _coveredBySnapshotController = null;
    }
    // LOCAL PATCH (quran_flutter): recompute snapshotting now that the covered
    // state changed (animatingAndScrolling freezes while covered by a sheet).
    _updateSnapshotState();
  }

  @override
  @mustCallSuper
  void didPopNext(Route<dynamic> nextRoute) {
    super.didPopNext(nextRoute);
    _coveredBySnapshotController = null;
    // LOCAL PATCH (quran_flutter): child sheet dismissed → recompute (may
    // unfreeze the background if nothing else requires snapshotting).
    _updateSnapshotState();
  }

  @override
  @mustCallSuper
  void dispose() {
    _snapshot.dispose();
    _poppedNotifier.dispose();
    super.dispose();
  }
}
