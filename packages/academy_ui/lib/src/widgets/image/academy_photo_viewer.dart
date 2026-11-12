import '../../theme/academy_theme.dart';

import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:flutter/gestures.dart';

import '../../foundation/localizations/academy_localizations.dart';
import '../../foundation/scroll/academy_scroll_behavior.dart';
import '../icon/academy_sf_image.dart';

/// Full-screen photo pager with pinch zoom and swipe-down dismissal, ported
/// from Yalla. Opens media supplied by the caller, without owning its data.
/// Image builders may consume [AcademyPhotoDecodeScope] to decode for the viewport
/// first and request more detail after a zoom gesture ends.
Future<void> showAcademyPhotoViewer(
  BuildContext context, {
  required int itemCount,
  required IndexedWidgetBuilder itemBuilder,
  int initialIndex = 0,
}) => Navigator.of(context).push<void>(
  _PhotoViewerRoute(
    builder: (_) => AcademyPhotoViewer(
      itemCount: itemCount,
      itemBuilder: itemBuilder,
      initialIndex: initialIndex,
    ),
  ),
);

/// Stable per-page physical-pixel budget. It grows after pinch completion, never
/// on each transform tick, and keeps the largest requested tier until disposal.
class AcademyPhotoDecodeScope extends InheritedWidget {
  const AcademyPhotoDecodeScope({
    super.key,
    required this.width,
    required super.child,
  });

  final int width;

  static int? maybeWidthOf(BuildContext context) => context
      .dependOnInheritedWidgetOfExactType<AcademyPhotoDecodeScope>()
      ?.width;

  @override
  bool updateShouldNotify(AcademyPhotoDecodeScope oldWidget) =>
      width != oldWidget.width;
}

/// Coarse tiers share ImageCache entries and avoid original-size decoding on
/// initial open. 5x zoom still requests up to 8K on high-density phones.
int academyPhotoDecodeWidth(double logicalWidth, double dpr, double zoom) {
  final pixels = (logicalWidth * dpr * zoom).ceil();
  const tiers = [512, 1024, 1536, 2048, 3072, 4096, 6144, 8192];
  return tiers.firstWhere((tier) => tier >= pixels, orElse: () => tiers.last);
}

class AcademyPhotoViewer extends StatefulWidget {
  const AcademyPhotoViewer({
    super.key,
    required this.itemCount,
    required this.itemBuilder,
    this.initialIndex = 0,
  }) : assert(itemCount > 0),
       assert(initialIndex >= 0 && initialIndex < itemCount);

  final int itemCount;
  final IndexedWidgetBuilder itemBuilder;
  final int initialIndex;

  @override
  State<AcademyPhotoViewer> createState() => _AcademyPhotoViewerState();
}

/// A transparent route keeps the previous screen visible during dismissal.
class _PhotoViewerRoute extends PageRoute<void> {
  _PhotoViewerRoute({required this.builder}) : super(fullscreenDialog: true);
  final WidgetBuilder builder;
  bool dragCompleted = false;

  @override
  bool get opaque => false;
  @override
  Color? get barrierColor => null;
  @override
  String? get barrierLabel => null;
  @override
  bool get maintainState => true;
  @override
  Duration get transitionDuration => const Duration(milliseconds: 200);
  @override
  Duration get reverseTransitionDuration =>
      dragCompleted ? Duration.zero : const Duration(milliseconds: 180);
  @override
  Widget buildPage(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
  ) => Semantics(
    scopesRoute: true,
    explicitChildNodes: true,
    child: builder(context),
  );
  @override
  Widget buildTransitions(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) => MediaQuery.disableAnimationsOf(context)
      ? child
      : FadeTransition(opacity: animation, child: child);
}

class _AcademyPhotoViewerState extends State<AcademyPhotoViewer>
    with SingleTickerProviderStateMixin {
  late final _pages = PageController(initialPage: widget.initialIndex);
  late final _drag = AnimationController.unbounded(vsync: this);
  late int _index = widget.initialIndex;
  final _pointers = <int>{};
  VelocityTracker? _velocity;
  Offset _origin = Offset.zero;
  bool _zoomed = false, _blocked = false, _closing = false;
  Axis? _axis;

  @override
  void dispose() {
    _pages.dispose();
    _drag.dispose();
    super.dispose();
  }

  void _close() {
    if (_closing) return;
    _closing = true;
    Navigator.of(context).pop();
  }

  void _reset() {
    if (_closing) return;
    _drag.animateTo(
      0,
      duration: MediaQuery.disableAnimationsOf(context)
          ? Duration.zero
          : const Duration(milliseconds: 220),
      curve: Curves.easeOutCubic,
    );
  }

  void _down(PointerDownEvent event) {
    _pointers.add(event.pointer);
    if (_closing) return;
    if (_pointers.length > 1) {
      _blocked = true;
      _reset();
      return;
    }
    _drag.stop();
    _origin = event.position - Offset(0, _drag.value);
    _axis = null;
    _blocked = _zoomed;
    _velocity = VelocityTracker.withKind(event.kind)
      ..addPosition(event.timeStamp, event.position);
  }

  void _move(PointerMoveEvent event) {
    if (_closing || _blocked || _zoomed || _pointers.length != 1) return;
    _velocity?.addPosition(event.timeStamp, event.position);
    final delta = event.position - _origin;
    if (_axis == null && delta.distance > 12) {
      _axis = delta.dy.abs() > delta.dx.abs() ? Axis.vertical : Axis.horizontal;
    }
    if (_axis == Axis.vertical) {
      _drag.value = delta.dy.clamp(0.0, double.infinity);
    }
  }

  void _up(PointerUpEvent event) {
    _pointers.remove(event.pointer);
    if (_closing) return;
    final speed = _velocity?.getVelocity().pixelsPerSecond.dy ?? 0;
    final close =
        !_blocked &&
        !_zoomed &&
        (_drag.value > 120 || (_drag.value > 40 && speed > 900));
    if (close) {
      _finishDismiss();
    } else {
      _reset();
    }
  }

  void _cancel(PointerCancelEvent event) {
    _pointers.remove(event.pointer);
    _blocked = true;
    _reset();
  }

  Future<void> _finishDismiss() async {
    _closing = true;
    final route = ModalRoute.of(context);
    try {
      await _drag
          .animateTo(
            MediaQuery.sizeOf(context).height,
            duration: MediaQuery.disableAnimationsOf(context)
                ? Duration.zero
                : const Duration(milliseconds: 200),
            curve: Curves.easeOutCubic,
          )
          .orCancel;
    } on TickerCanceled {
      return;
    }
    if (!mounted || route?.isCurrent != true) return;
    if (route is _PhotoViewerRoute) route.dragCompleted = true;
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) => SizedBox.expand(
    key: const ValueKey('academy-photo-viewer'),
    child: AnimatedBuilder(
      animation: _drag,
      child: Listener(
        behavior: HitTestBehavior.opaque,
        onPointerDown: _down,
        onPointerMove: _move,
        onPointerUp: _up,
        onPointerCancel: _cancel,
        child: ScrollConfiguration(
          behavior: const AcademyScrollBehavior(),
          child: PageView.builder(
            controller: _pages,
            physics: _zoomed ? const NeverScrollableScrollPhysics() : null,
            itemCount: widget.itemCount,
            onPageChanged: (index) => setState(() {
              _index = index;
              _zoomed = false;
            }),
            itemBuilder: (context, index) => _PhotoPage(
              onZoom: (value) {
                if (index == _index && _zoomed != value) {
                  _blocked = true;
                  _reset();
                  setState(() => _zoomed = value);
                }
              },
              child: widget.itemBuilder(context, index),
            ),
          ),
        ),
      ),
      builder: (context, child) {
        // Like extended_image: fade over half a viewport, shrink to 80%.
        final progress = (_drag.value / (MediaQuery.sizeOf(context).height / 2))
            .clamp(0.0, 1.0);
        return Stack(
          children: [
            Positioned.fill(
              child: ColoredBox(
                key: const ValueKey('photo-viewer-backdrop'),
                color: AcademyTheme.of(context).colorScheme.photoViewerBackdrop
                    .withValues(alpha: 1 - progress),
              ),
            ),
            Positioned.fill(
              child: Transform.translate(
                key: const ValueKey('photo-viewer-drag'),
                offset: Offset(0, _drag.value),
                child: Transform.scale(
                  key: const ValueKey('photo-viewer-scale'),
                  scale: 1 - .2 * progress,
                  child: child,
                ),
              ),
            ),
            PositionedDirectional(
              end:
                  (Directionality.of(context) == TextDirection.rtl
                      ? MediaQuery.paddingOf(context).left
                      : MediaQuery.paddingOf(context).right) +
                  16,
              top: MediaQuery.paddingOf(context).top + 8,
              child: Opacity(
                key: const ValueKey('photo-viewer-chrome'),
                opacity: 1 - progress,
                child: _closeButton(),
              ),
            ),
          ],
        );
      },
    ),
  );

  Widget _closeButton() => Semantics(
    label: AcademyLocalizations.of(context).closePhotoViewer,
    hint: AcademyLocalizations.of(context).closePhotoViewerHint,
    button: true,
    excludeSemantics: true,
    onTap: _close,
    child: DecoratedBox(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: AcademyTheme.of(context).colorScheme.photoViewerControlShadow,
        ),
        boxShadow: [
          BoxShadow(
            color: AcademyTheme.of(context)
                .colorScheme
                .photoViewerControlShadow,
            blurRadius: 12,
          ),
        ],
      ),
      child: CupertinoButton(
        key: const ValueKey('photo-viewer-close'),
        padding: EdgeInsets.zero,
        minimumSize: const Size(48, 48),
        onPressed: _close,
        child: AcademySfImage(
          AcademyTheme.of(context).icons.close,
          frameSize: 48,
          symbolSize: 20,
          foreground: AcademyTheme.of(context).colorScheme.onPhotoViewerControl,
          background: AcademyTheme.of(context).colorScheme.photoViewerControl,
        ),
      ),
    ),
  );
}

/// Zoom pattern adapted from Quran's MushafZoomablePage.
class _PhotoPage extends StatefulWidget {
  const _PhotoPage({required this.child, required this.onZoom});
  final Widget child;
  final ValueChanged<bool> onZoom;

  @override
  State<_PhotoPage> createState() => _PhotoPageState();
}

class _PhotoPageState extends State<_PhotoPage> {
  final _transform = TransformationController();
  bool _zoomed = false;
  double _decodeZoom = 1;

  void _zoomEnded(ScaleEndDetails details) {
    final zoom = _transform.value.getMaxScaleOnAxis().clamp(1.0, 5.0);
    if (zoom > _decodeZoom) setState(() => _decodeZoom = zoom);
  }

  @override
  void initState() {
    super.initState();
    _transform.addListener(_transformChanged);
  }

  void _transformChanged() {
    final zoomed = _transform.value.getMaxScaleOnAxis() > 1.001;
    if (_zoomed == zoomed) return;
    setState(() => _zoomed = zoomed);
    widget.onZoom(zoomed);
  }

  @override
  void dispose() {
    _transform.removeListener(_transformChanged);
    _transform.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => InteractiveViewer(
    transformationController: _transform,
    minScale: 1,
    maxScale: 5,
    panEnabled: _zoomed,
    onInteractionEnd: _zoomEnded,
    child: AcademyPhotoDecodeScope(
      width: academyPhotoDecodeWidth(
        MediaQuery.sizeOf(context).width,
        MediaQuery.devicePixelRatioOf(context),
        _decodeZoom,
      ),
      child: SizedBox.expand(child: Center(child: widget.child)),
    ),
  );
}
