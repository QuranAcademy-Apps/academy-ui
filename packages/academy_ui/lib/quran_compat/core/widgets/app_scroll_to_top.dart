import 'dart:async';

import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:flutter/rendering.dart';

/// Handles the iOS status-bar tap for a full-screen vertical scroll surface.
///
/// The hosting screen owns [controller] and any feature-specific work that
/// needs cancelling before the return animation begins.
class AppScrollToTop extends StatefulWidget {
  const AppScrollToTop({
    super.key,
    required this.controller,
    required this.child,
    this.onBeforeScroll,
    this.onTap,
    this.enabled = true,
  });

  final ScrollController controller;
  final Widget child;
  final VoidCallback? onBeforeScroll;
  final VoidCallback? onTap;
  final bool enabled;

  @override
  State<AppScrollToTop> createState() => _AppScrollToTopState();
}

class _AppScrollToTopState extends State<AppScrollToTop>
    with WidgetsBindingObserver {
  final _surfaceKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void activate() {
    super.activate();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void deactivate() {
    WidgetsBinding.instance.removeObserver(this);
    super.deactivate();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void handleStatusBarTap() {
    if (!widget.enabled ||
        widget.controller.positions.length != 1 ||
        ModalRoute.isCurrentOf(context) == false) {
      return;
    }

    final surface = _surfaceKey.currentContext?.findRenderObject();
    if (surface is! RenderBox || !surface.attached || !surface.hasSize) {
      return;
    }
    final view = View.of(context);
    final hit = HitTestResult();
    // Reader lists can sit below SafeArea, so the status-bar origin is outside
    // their bounds. The view centre selects the visible page and excludes
    // offstage tabs, adjacent pager pages and surfaces behind modal barriers.
    WidgetsBinding.instance.hitTestInView(
      hit,
      (view.physicalSize / view.devicePixelRatio).center(Offset.zero),
      view.viewId,
    );
    if (!hit.path.any((entry) => identical(entry.target, surface))) {
      return;
    }

    widget.onBeforeScroll?.call();
    unawaited(
      widget.controller.animateTo(
        widget.controller.position.minScrollExtent,
        duration: const Duration(milliseconds: 500),
        curve: Curves.linearToEaseOut,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MetaData(
      key: _surfaceKey,
      behavior: HitTestBehavior.translucent,
      child: widget.onTap == null
          ? widget.child
          : GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: widget.onTap,
              child: widget.child,
            ),
    );
  }
}
