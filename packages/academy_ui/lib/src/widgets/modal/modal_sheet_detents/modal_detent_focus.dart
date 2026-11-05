part of '../modal_sheet_detents.dart';

class ModalDetentFocus extends StatefulWidget {
  const ModalDetentFocus({
    super.key,
    required this.child,
    this.restingDetent = ModalSheetDetent.medium,
    this.focusedDetent = ModalSheetDetent.full,
    this.keepExpanded = false,
    this.autoHeight,
  });

  final Widget child;
  final ModalSheetDetent restingDetent;
  final ModalSheetDetent focusedDetent;
  final bool keepExpanded;
  final double? autoHeight;

  @override
  State<ModalDetentFocus> createState() => _ModalDetentFocusState();
}

class _ModalDetentFocusState extends State<ModalDetentFocus>
    with WidgetsBindingObserver {
  StupidSimpleSheetController<dynamic>? _routeController;
  bool _hasFocusInSubtree = false;
  double? _lastSnap;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
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
    WidgetsBinding.instance.removeObserver(this);
    FocusManager.instance.removeListener(_handlePrimaryFocusChanged);
    super.dispose();
  }

  @override
  void didChangeMetrics() {
    // Fires on every keyboard frame. Restarting the spring each time would also
    // pull back a sheet the user has dragged, so only a new height moves it.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _applyDetent(onlyIfMoved: true);
    });
  }

  @override
  void didUpdateWidget(ModalDetentFocus oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.keepExpanded != oldWidget.keepExpanded ||
        widget.restingDetent != oldWidget.restingDetent ||
        widget.autoHeight != oldWidget.autoHeight) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _applyDetent();
      });
    }
  }

  void _applyDetent({bool onlyIfMoved = false}) => _setRouteDetent(
    _hasFocusInSubtree || widget.keepExpanded
        ? widget.focusedDetent
        : widget.restingDetent,
    onlyIfMoved: onlyIfMoved,
  );

  void _handlePrimaryFocusChanged() {
    if (!mounted) return;

    // Only text input expands the sheet. A nested navigator focuses its
    // route's scope on every push, and buttons take keyboard focus; neither
    // brings up the keyboard.
    final node = FocusManager.instance.primaryFocus;
    final candidate = node is FocusScopeNode ? null : node?.context;
    final focusedContext =
        candidate != null &&
            (candidate.widget is EditableText ||
                candidate.findAncestorWidgetOfExactType<EditableText>() != null)
        ? candidate
        : null;
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
    _applyDetent();
  }

  void _setRouteDetent(ModalSheetDetent detent, {required bool onlyIfMoved}) {
    final controller = _routeController;
    if (controller == null) return;
    final routeHeight = _modalSheetRouteHeight(context);
    if (routeHeight <= 0) return;
    final snap =
        (effectiveLandscapeModalDetent(
                  context,
                  detent,
                ).heightOf(context, autoHeight: widget.autoHeight) /
                routeHeight)
            .clamp(0.0, 1.0)
            .toDouble();
    if (snap <= 0) return;
    final last = _lastSnap ?? controller.effectiveSnappingConfig.initialSnap;
    if (onlyIfMoved && (snap - last).abs() < 0.001) return;
    _lastSnap = snap;
    controller.animateToRelative(snap);
  }

  @override
  Widget build(BuildContext context) {
    return ClipRect(child: widget.child);
  }
}
