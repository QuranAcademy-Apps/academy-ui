part of '../modal_sheet_detents.dart';

/// Captures the enclosing sheet controller at this point in the tree and
/// re-exposes it to descendants.
///
/// [StupidSimpleSheetController.maybeOf] resolves the controller through
/// `ModalRoute.of`, so a context inside a nested [Navigator] (e.g. a modal
/// stack pushed within the sheet) resolves the *inner* route instead of the
/// sheet route and the detent helpers no-op. Wrap the nested navigator with
/// this widget — placed above it, where `ModalRoute.of` still resolves the
/// sheet route — so descendants keep reaching the sheet controller.
class CaptureModalSheetController extends StatelessWidget {
  const CaptureModalSheetController({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return _ModalSheetControllerScope(
      controller: StupidSimpleSheetController.maybeOf<dynamic>(context),
      child: child,
    );
  }
}

class _ModalSheetControllerScope extends InheritedWidget {
  const _ModalSheetControllerScope({
    required this.controller,
    required super.child,
  });

  final StupidSimpleSheetController<dynamic>? controller;

  /// Prefers a captured controller from an ancestor scope, falling back to the
  /// route lookup for contexts that are not behind a nested navigator.
  static StupidSimpleSheetController<dynamic>? maybeOf(BuildContext context) {
    final scope = context
        .dependOnInheritedWidgetOfExactType<_ModalSheetControllerScope>();
    return scope?.controller ??
        StupidSimpleSheetController.maybeOf<dynamic>(context);
  }

  @override
  bool updateShouldNotify(_ModalSheetControllerScope oldWidget) {
    return controller != oldWidget.controller;
  }
}

/// The enclosing modal sheet's own translate animation (open/close/snap), or
/// null outside a sheet. The sheet lays content out once and only translates,
/// so this — not [ModalRoute.animation] in general — is the "sheet is
/// mid-translate" signal; heavy per-frame list work (e.g. extent
/// precalculation) must pause while it animates.
Animation<double>? modalSheetTranslateAnimation(BuildContext context) {
  return _ModalSheetControllerScope.maybeOf(context)?.animation;
}

/// Exposes the live modal off-screen bottom inset to descendants, recomputed
/// whenever the sheet's resting detent changes (drag-snap,
/// [setModalSheetDetentHeight], rotation). Installed once by
/// [showAcademyModalRoute] so any scrollable inside the sheet — read
/// directly via [ModalSheetScrollInsets.of], or indirectly via a scaffold that
/// folds it into its content insets — clears the off-screen slice without
/// per-screen detent knowledge. Returns 0 outside a sheet.
///
/// This is the systemic seam: every modal goes through
/// [showAcademyModalRoute], so no sheet can silently miss the inset.
class ModalSheetScrollInsets extends InheritedWidget {
  const ModalSheetScrollInsets({
    super.key,
    required this.bottom,
    required super.child,
  });

  /// The off-screen bottom slice + device safe area, or 0 outside a sheet.
  final double bottom;

  static double of(BuildContext context) {
    final scope = context
        .dependOnInheritedWidgetOfExactType<ModalSheetScrollInsets>();
    return scope?.bottom ?? 0;
  }

  /// The inset for a footer pinned to a full-height sheet child. Unlike a
  /// scrollable, the footer already occupies the full detent's top-safe-area
  /// subtraction, so it must not be lifted by that top inset a second time.
  static double pinnedBottomOf(BuildContext context) {
    final scrollInset = of(context);
    final view = View.of(context);
    final ratio = view.devicePixelRatio;
    final topInset = ratio > 0
        ? view.padding.top / ratio
        : MediaQuery.paddingOf(context).top;
    return (scrollInset - topInset).clamp(0.0, double.infinity).toDouble();
  }

  /// Whether [context] belongs to an app modal sheet route.
  static bool isInModalSheet(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<ModalSheetScrollInsets>() !=
      null;

  @override
  bool updateShouldNotify(ModalSheetScrollInsets oldWidget) =>
      bottom != oldWidget.bottom;
}

class _ModalSheetScrollInsetScope extends StatefulWidget {
  const _ModalSheetScrollInsetScope({required this.child});

  final Widget child;

  @override
  State<_ModalSheetScrollInsetScope> createState() =>
      _ModalSheetScrollInsetScopeState();
}

class _ModalSheetScrollInsetScopeState
    extends State<_ModalSheetScrollInsetScope>
    with WidgetsBindingObserver {
  StupidSimpleSheetController<dynamic>? _controller;
  Animation<double>? _animation;
  double _bottom = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeMetrics() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _recompute();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Re-resolve the controller; also re-runs on MediaQuery changes (rotation),
    // which feed into the inset math.
    final controller = StupidSimpleSheetController.maybeOf<dynamic>(context);
    if (!identical(controller, _controller)) {
      _animation?.removeStatusListener(_handleStatus);
      _controller = controller;
      // The inset depends only on the resting fraction, which moves when the
      // config is overridden — always paired with an animation, i.e. a status
      // change. Listening to *status* (not every value tick) skips per-frame
      // work during drags/animations; [_recompute] still dedupes.
      _animation = controller?.animation;
      _animation?.addStatusListener(_handleStatus);
    }
    _recompute();
  }

  void _handleStatus(AnimationStatus _) => _recompute();

  void _recompute() {
    if (!mounted) return;
    final controller = _controller;
    final next = controller == null
        ? 0.0
        : _modalSheetOffscreenBottomInset(context, controller);
    if ((next - _bottom).abs() > 0.5) {
      setState(() => _bottom = next);
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _animation?.removeStatusListener(_handleStatus);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ModalSheetScrollInsets(bottom: _bottom, child: widget.child);
  }
}

const academyModalSheetTopRadius = Radius.circular(32);

/// Форма скруглённого верха модалки (iOS-сквиркл, радиус 32). Единый источник
/// для: shape опак-подложки SheetBackground И rounded-заливки модалок, которые
/// рисуют СВОЙ опак-фон (вместо клипа над скроллом — тот = offscreen-пас каждый
/// кадр). Скругление держит статичная заливка, скролл не клипается.
const academyModalSheetSurfaceShape = RoundedSuperellipseBorder(
  borderRadius: BorderRadius.vertical(top: academyModalSheetTopRadius),
);

Future<T?> showAcademyModalRoute<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  Color? backgroundColor,
  Color? barrierColor,
  bool useRootNavigator = false,
  bool? isDismissible,
  bool enableDrag = true,
  bool onlyDragWhenScrollWasAtTop = true,
  bool clearBarrierImmediately = true,
  Duration? duration,
  SheetSnappingConfig snappingConfig = SheetSnappingConfig.full,
  double overshootResistance = 100,
  // Режим снапшота фона для всех модалок: animatingAndScrolling (LOCAL PATCH в
  // third_party/stupid_simple_sheet) = морозит фон при анимации/драге шита И во
  // время скролла внутреннего контента; в покое фон живой. Детект скролла —
  // целиком внутри пакета. Для шитов над ЖИВЫМ контентом (видео/аудио) явно
  // передавать `never`.
  RouteSnapshotMode backgroundSnapshotMode =
      RouteSnapshotMode.animatingAndScrolling,
  ShapeBorder shape = academyModalSheetSurfaceShape,
  // Rounded corners belong to opaque fills. Scrolling content has no rounded
  // clip; custom opaque content uses ModalSheetMaskedFill near sheet corners.
  Clip clipBehavior = Clip.none,
}) {
  final dismissible = isDismissible ?? true;
  final navigator = Navigator.of(context, rootNavigator: useRootNavigator);
  final route = _AcademySheetRoute<T>(
    barrierColor:
        barrierColor ?? AcademyTheme.of(context).colorScheme.modalBarrier,
    barrierDismissible: dismissible,
    barrierLabel: 'Dismiss modal',
    clearBarrierImmediately: clearBarrierImmediately,
    draggable: enableDrag && dismissible,
    motion: CupertinoMotion.smooth(
      duration: MediaQuery.disableAnimationsOf(context)
          ? Duration.zero
          : duration ?? const Duration(milliseconds: 350),
      snapToEnd: true,
    ),
    onlyDragWhenScrollWasAtTop: onlyDragWhenScrollWasAtTop,
    overshootResistance: overshootResistance,
    backgroundSnapshotMode: backgroundSnapshotMode,
    snappingConfig: snappingConfig,
    child: InheritedTheme.captureAll(
      context,
      SheetBackground(
        backgroundColor: backgroundColor ?? CupertinoColors.transparent,
        shape: shape,
        clipBehavior: clipBehavior,
        child: _ModalSheetScrollInsetScope(
          child: RepaintBoundary(child: Builder(builder: builder)),
        ),
      ),
      to: navigator.context,
    ),
  );
  // Tag the route with the portrait detents queued by the matching
  // [modalSheetSnappingConfig] call, so it can be restored on rotation back to
  // portrait regardless of the orientation the sheet was opened in.
  attachPortraitSnappingConfig(route);
  return navigator.push<T>(route);
}

class _AcademySheetRoute<T> extends StupidSimpleSheetRoute<T> {
  _AcademySheetRoute({
    required super.child,
    super.settings,
    required this.overshootResistance,
    required super.motion,
    required super.barrierColor,
    required super.barrierDismissible,
    required super.barrierLabel,
    required super.clearBarrierImmediately,
    required super.onlyDragWhenScrollWasAtTop,
    required super.snappingConfig,
    required super.draggable,
    required super.backgroundSnapshotMode,
  }) : super(originateAboveBottomViewInset: true);

  @override
  final double overshootResistance;

  // Заморозка фона во время скролла контента реализована ВНУТРИ вендоренного
  // пакета (LOCAL PATCH в third_party/stupid_simple_sheet): пакет сам слушает
  // ScrollNotification своего контента и комбинирует это с anim/drag-логикой в
  // _updateSnapshotState. Здесь ничего настраивать не нужно — режим работает для
  // любого backgroundSnapshotMode != never.
}
