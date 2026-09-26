import 'dart:async';

import 'package:flutter/widgets.dart';

import 'route_snapshot_mode.dart';

/// Keeps a sheet background frozen during the configured animation/scroll phases.
class SheetSnapshotState {
  SheetSnapshotState({required this.onScrollChanged});

  final VoidCallback onScrollChanged;
  final SnapshotController controller = SnapshotController();

  // LOCAL PATCH (quran_flutter): freeze the background snapshot while the inner
  // content scrolls. Combined into [_updateSnapshotState] alongside the mode's
  // animation/drag logic, so the background is frozen during scroll AND during
  // animation/drag, and reverts to live only when everything is idle. Driven
  // entirely inside this package: [buildPage] wraps the content in a
  // ScrollNotification listener (when snapshotting is enabled) and [_settleDelay]
  // debounces the revert (ScrollEnd is unreliable when scroll→sheet-drag hands
  // off or content is nested). See
  // docs/tasks/2026-06-22-modal-sheet-scroll-jank/task.md and grep "LOCAL PATCH".
  bool contentScrolling = false;
  Timer? _contentScrollSettleTimer;
  static const Duration _contentScrollSettleDelay = Duration(milliseconds: 120);

  /// LOCAL PATCH (quran_flutter): freeze on any scroll activity; revert after the
  /// scroll settles. Returns false so the notification keeps bubbling.
  bool handleContentScroll(ScrollNotification notification) {
    if (notification is ScrollStartNotification ||
        notification is ScrollUpdateNotification ||
        notification is OverscrollNotification) {
      if (!contentScrolling) {
        contentScrolling = true;
        onScrollChanged();
      }
      _contentScrollSettleTimer?.cancel();
      _contentScrollSettleTimer =
          Timer(_contentScrollSettleDelay, _settleContentScroll);
    }
    return false;
  }

  void _settleContentScroll() {
    contentScrolling = false;
    // Recompute through the mode logic: if the sheet is now being dragged or
    // animated, [_updateSnapshotState] keeps the snapshot; otherwise it reverts.
    onScrollChanged();
  }

  void update({
    required RouteSnapshotMode mode,
    required AnimationController? animation,
    required bool isUserDragging,
    required double maxExtent,
    required double? animationTargetValue,
    required bool isCovered,
  }) {
    if (mode == RouteSnapshotMode.never) {
      controller.allowSnapshotting = false;
      return;
    }
    if (mode == RouteSnapshotMode.always) {
      controller.allowSnapshotting = true;
      return;
    }

    final isAnimating = animation?.isAnimating ?? false;
    final value = animation?.value ?? 0.0;
    final isVisible = value > 0.001;
    final isSettled = !isAnimating && !isUserDragging && isVisible;
    final isFullyOpen = (value - maxExtent).abs() < 0.001;

    final isTargetingMax = animationTargetValue != null &&
        (animationTargetValue - maxExtent).abs() < 0.001;

    final isMovingForward = isTargetingMax &&
        ((animation?.status.isAnimating ?? false) ||
            (animationTargetValue > value));

    controller.allowSnapshotting = switch (mode) {
      RouteSnapshotMode.animating => isAnimating || isUserDragging,
      RouteSnapshotMode.settled => isSettled,
      RouteSnapshotMode.openAndForward => (isSettled && isFullyOpen) ||
          (isAnimating && isMovingForward && !isUserDragging),
      // LOCAL PATCH (quran_flutter): animating + inner-content scroll +
      // covered by a child sheet. Last term keeps the (often heavy) background
      // frozen while a stacked child sheet is open over this one — otherwise
      // this route settles, drops its snapshot, and the background repaints
      // live behind the child sheet (e.g. tafsir reader under the settings
      // sheet). isCovered exactly when a child
      // StupidSimpleSheetTransitionMixin route is on top (see didChangeNext).
      RouteSnapshotMode.animatingAndScrolling =>
        isAnimating || isUserDragging || contentScrolling || isCovered,
      _ => false, // never/always handled above
    };
  }

  void dispose() {
    _contentScrollSettleTimer?.cancel();
    controller.dispose();
  }
}
