part of '../modal_sheet_detents.dart';

class ModalDetentFocus extends StatefulWidget {
  const ModalDetentFocus({
    super.key,
    required this.child,
    this.restingDetent = ModalSheetDetent.medium,
    this.focusedDetent = ModalSheetDetent.full,
  });

  final Widget child;
  final ModalSheetDetent restingDetent;
  final ModalSheetDetent focusedDetent;

  @override
  State<ModalDetentFocus> createState() => _ModalDetentFocusState();
}

class _ModalDetentFocusState extends State<ModalDetentFocus> {
  StupidSimpleSheetController<dynamic>? _routeController;
  bool _hasFocusInSubtree = false;

  @override
  void initState() {
    super.initState();
    FocusManager.instance.addListener(_handlePrimaryFocusChanged);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _routeController = _ModalSheetControllerScope.maybeOf(context);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _handlePrimaryFocusChanged();
    });
  }

  @override
  void dispose() {
    FocusManager.instance.removeListener(_handlePrimaryFocusChanged);
    super.dispose();
  }

  void _handlePrimaryFocusChanged() {
    if (!mounted) return;

    final focusedContext = FocusManager.instance.primaryFocus?.context;
    var hasFocusInSubtree = focusedContext == context;
    focusedContext?.visitAncestorElements((ancestor) {
      if (ancestor == context) {
        hasFocusInSubtree = true;
        return false;
      }
      return true;
    });

    if (_hasFocusInSubtree == hasFocusInSubtree) return;
    _hasFocusInSubtree = hasFocusInSubtree;
    _setRouteDetent(
      hasFocusInSubtree ? widget.focusedDetent : widget.restingDetent,
    );
  }

  void _setRouteDetent(ModalSheetDetent detent) {
    final controller = _routeController;
    if (controller == null) return;
    final routeHeight = _modalSheetRouteHeight(context);
    if (routeHeight <= 0) return;
    final snap =
        (effectiveLandscapeModalDetent(context, detent).heightOf(context) /
                routeHeight)
            .clamp(0.0, 1.0)
            .toDouble();
    if (snap <= 0) return;
    controller.animateToRelative(snap);
  }

  @override
  Widget build(BuildContext context) {
    return ClipRect(child: widget.child);
  }
}
