import 'dart:async';

import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

/// Handles the iOS status-bar tap for a full-screen list with its own
/// [controller]. Flutter handles it only for the [PrimaryScrollController], so
/// do not wrap a primary list in this as well.
///
/// Ported from Quran's AppScrollToTop.
class AcademyScrollToTop extends StatefulWidget {
  const AcademyScrollToTop({
    super.key,
    required this.controller,
    required this.child,
    this.onBeforeScroll,
    this.onTap,
    this.enabled = true,
  });

  final ScrollController controller;
  final Widget child;

  /// Cancels work that the return animation would fight with.
  final VoidCallback? onBeforeScroll;

  /// An ordinary tap on the content, which does not scroll.
  final VoidCallback? onTap;
  final bool enabled;

  @override
  State<AcademyScrollToTop> createState() => _AcademyScrollToTopState();
}

class _AcademyScrollToTopState extends State<AcademyScrollToTop>
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
    if (surface is! RenderBox || !surface.attached || !surface.hasSize) return;
    final view = View.of(context);
    final hit = HitTestResult();
    // A list can sit below the safe area, so the status bar is outside its
    // bounds. The view centre selects the visible page and excludes offstage
    // tabs, adjacent pager pages and surfaces behind modal barriers.
    WidgetsBinding.instance.hitTestInView(
      hit,
      (view.physicalSize / view.devicePixelRatio).center(Offset.zero),
      view.viewId,
    );
    if (!hit.path.any((entry) => identical(entry.target, surface))) return;

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
  Widget build(BuildContext context) => MetaData(
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
