import 'dart:math' as math;

import 'package:flutter/cupertino.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';

import '../../theme/academy_theme.dart';
import '../localizations/academy_localizations.dart';

class AcademyPopoverController extends ValueNotifier<bool> {
  AcademyPopoverController() : super(false);
  bool get isOpen => value;
  void show() => value = true;
  void hide() => value = false;
  void toggle() => value = !value;
}

/// Preferred side; falls back when the content would leave the visible area.
/// Start and end follow the current text direction.
enum AcademyPopoverPlacement { auto, above, below, start, end }

/// Anchored, opaque content that follows layout/scroll and inherits live themes.
/// The caller owns an external controller. Use rootOverlay inside modal sheets.
class AcademyPopover extends StatefulWidget {
  const AcademyPopover({
    super.key,
    required this.builder,
    required this.contentBuilder,
    this.controller,
    this.width = 320,
    this.matchAnchorWidth = false,
    this.anchorKey,
    this.maxHeight = 360,
    this.gap = 8,
    this.placement = AcademyPopoverPlacement.auto,
    this.rootOverlay = true,
    this.dismissOnTapOutside = true,
    this.requestFocus = true,
    this.onOpenChanged,
  }) : assert(width > 0),
       assert(maxHeight > 0),
       assert(gap >= 0);
  final Widget Function(BuildContext, AcademyPopoverController) builder;
  final Widget Function(BuildContext, VoidCallback close) contentBuilder;
  final AcademyPopoverController? controller;
  final double width, maxHeight, gap;
  final AcademyPopoverPlacement placement;

  /// Use the laid-out trigger's width, clamped only to the visible screen.
  final bool matchAnchorWidth;

  /// Optional precise anchor inside a labelled/validated control.
  final GlobalKey? anchorKey;
  final bool rootOverlay, dismissOnTapOutside, requestFocus;
  final ValueChanged<bool>? onOpenChanged;
  @override
  State<AcademyPopover> createState() => _AcademyPopoverState();
}

class _AcademyPopoverState extends State<AcademyPopover> {
  final _portal = OverlayPortalController();
  AcademyPopoverController? _owned;
  AcademyPopoverController get _controller =>
      widget.controller ?? (_owned ??= AcademyPopoverController());
  FocusNode? _previousFocus;
  bool _shown = false;
  @override
  void initState() {
    super.initState();
    _controller.addListener(_changed);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _changed();
    });
  }

  @override
  void didUpdateWidget(AcademyPopover oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      (oldWidget.controller ?? _owned!).removeListener(_changed);
      _controller.addListener(_changed);
      _changed();
    }
  }

  void _changed() {
    if (SchedulerBinding.instance.schedulerPhase ==
        SchedulerPhase.persistentCallbacks) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _changed();
      });
      return;
    }
    if (_shown == _controller.isOpen) return;
    _shown = _controller.isOpen;
    if (_shown) {
      _previousFocus = FocusManager.instance.primaryFocus;
      _portal.show();
    } else {
      _portal.hide();
      if (widget.requestFocus && _previousFocus?.context != null) {
        _previousFocus?.requestFocus();
      }
    }
    widget.onOpenChanged?.call(_shown);
  }

  @override
  void dispose() {
    _controller.removeListener(_changed);
    _owned?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => CallbackShortcuts(
    bindings: {
      const SingleActivator(LogicalKeyboardKey.escape): _controller.hide,
    },
    child: OverlayPortal.overlayChildLayoutBuilder(
      controller: _portal,
      overlayLocation: widget.rootOverlay
          ? OverlayChildLocation.rootOverlay
          : OverlayChildLocation.nearestOverlay,
      overlayChildBuilder: (context, info) {
        final theme = AcademyTheme.of(context);
        final media = MediaQuery.of(context);
        var anchor = MatrixUtils.transformRect(
          info.childPaintTransform,
          Offset.zero & info.childSize,
        );
        final target = widget.anchorKey?.currentContext?.findRenderObject();
        if (target is RenderBox && target.hasSize) {
          final overlay = Overlay.of(
            context,
            rootOverlay: widget.rootOverlay,
          ).context.findRenderObject();
          if (overlay is RenderBox) {
            anchor = MatrixUtils.transformRect(
              target.getTransformTo(overlay),
              Offset.zero & target.size,
            );
          }
        }
        // Use view metrics, including when a sheet consumed MediaQuery insets.
        final view = View.of(context);
        final insets = EdgeInsets.fromViewPadding(
          view.viewInsets,
          view.devicePixelRatio,
        );
        final safe = EdgeInsets.fromViewPadding(
          view.padding,
          view.devicePixelRatio,
        );
        final bounds = Rect.fromLTRB(
          safe.left + 8,
          safe.top + 8,
          math.max(safe.left + 8, info.overlaySize.width - safe.right - 8),
          math.max(
            safe.top + 8,
            info.overlaySize.height -
                math.max(insets.bottom, media.viewInsets.bottom) -
                safe.bottom -
                8,
          ),
        );
        Widget content = DecoratedBox(
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(theme.radii.table),
            border: Border.all(
              color: theme.colorScheme.outlineVariant,
              width: 1 / view.devicePixelRatio,
            ),
            boxShadow: [
              BoxShadow(
                color: theme.colorScheme.segmentShadow,
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
              BoxShadow(
                color: theme.colorScheme.segmentShadow,
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(theme.radii.table),
            child: Padding(
              padding: const EdgeInsets.all(1),
              child: DefaultTextStyle(
                style: theme.textTheme.bodyLarge,
                child: widget.contentBuilder(context, _controller.hide),
              ),
            ),
          ),
        );
        if (widget.requestFocus) {
          content = FocusScope(
            autofocus: true,
            child: FocusTraversalGroup(child: content),
          );
        }
        return Stack(
          children: [
            if (widget.dismissOnTapOutside)
              Positioned.fill(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: _controller.hide,
                  child: Semantics(
                    label: AcademyLocalizations.of(context).close,
                    button: true,
                    child: const SizedBox.expand(),
                  ),
                ),
              ),
            Positioned.fill(
              child: CustomSingleChildLayout(
                delegate: _PopoverLayout(
                  anchor,
                  bounds,
                  widget.matchAnchorWidth ? anchor.width : widget.width,
                  widget.maxHeight,
                  widget.gap,
                  Directionality.of(context),
                  widget.placement,
                ),
                child: content,
              ),
            ),
          ],
        );
      },
      child: widget.builder(context, _controller),
    ),
  );
}

class _PopoverLayout extends SingleChildLayoutDelegate {
  _PopoverLayout(
    this.anchor,
    this.bounds,
    this.width,
    this.maxHeight,
    this.gap,
    this.direction,
    this.placement,
  );
  final Rect anchor, bounds;
  final double width, maxHeight, gap;
  final TextDirection direction;
  final AcademyPopoverPlacement placement;
  double get below => math.max(0, bounds.bottom - anchor.bottom - gap);
  double get above => math.max(0, anchor.top - gap - bounds.top);
  double get contentWidth => math.min(width, bounds.width);

  // A side tooltip must fit at its readable width. Otherwise use vertical
  // placement, rather than squeezing it into a narrow strip beside the anchor.
  bool? get onRight {
    if (placement != AcademyPopoverPlacement.start &&
        placement != AcademyPopoverPlacement.end) {
      return null;
    }
    final preferRight =
        (placement == AcademyPopoverPlacement.end) ==
        (direction == TextDirection.ltr);
    final right = bounds.right - anchor.right - gap;
    final left = anchor.left - gap - bounds.left;
    if ((preferRight ? right : left) >= contentWidth) return preferRight;
    if ((preferRight ? left : right) >= contentWidth) return !preferRight;
    return null;
  }

  @override
  BoxConstraints getConstraintsForChild(BoxConstraints constraints) =>
      BoxConstraints(
        minWidth: contentWidth,
        maxWidth: contentWidth,
        maxHeight: math
            .min(
              maxHeight,
              onRight == null ? math.max(below, above) : bounds.height,
            )
            .clamp(0, bounds.height),
      );
  @override
  Offset getPositionForChild(Size size, Size childSize) {
    final side = onRight;
    final x = side == null
        ? direction == TextDirection.ltr
              ? anchor.left
              : anchor.right - childSize.width
        : side
        ? anchor.right + gap
        : anchor.left - gap - childSize.width;
    final useBelow = switch (placement) {
      AcademyPopoverPlacement.above =>
        above < childSize.height && below > above,
      AcademyPopoverPlacement.below =>
        below >= childSize.height || below >= above,
      _ => below >= childSize.height || below >= above,
    };
    final y = side != null
        ? anchor.center.dy - childSize.height / 2
        : useBelow
        ? anchor.bottom + gap
        : anchor.top - gap - childSize.height;
    return Offset(
      x.clamp(
        bounds.left,
        math.max(bounds.left, bounds.right - childSize.width),
      ),
      y.clamp(
        bounds.top,
        math.max(bounds.top, bounds.bottom - childSize.height),
      ),
    );
  }

  @override
  bool shouldRelayout(covariant _PopoverLayout old) =>
      anchor != old.anchor ||
      bounds != old.bounds ||
      width != old.width ||
      maxHeight != old.maxHeight ||
      gap != old.gap ||
      direction != old.direction ||
      placement != old.placement;
}
