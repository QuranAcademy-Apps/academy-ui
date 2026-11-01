part of '../modal_sheet_detents.dart';

final class ModalSheetDetent {
  const ModalSheetDetent._factor(this._heightFactor);
  const ModalSheetDetent._auto() : _heightFactor = null;

  static const auto = ModalSheetDetent._auto();
  static const medium = ModalSheetDetent._factor(0.5);
  static const large = ModalSheetDetent._factor(0.9);
  static const full = ModalSheetDetent._factor(1.0);

  factory ModalSheetDetent.custom(double heightFactor) {
    if (heightFactor < 0.1 || heightFactor > 1.0) {
      throw ArgumentError.value(
        heightFactor,
        'heightFactor',
        'Must be between 0.1 and 1.0.',
      );
    }
    return ModalSheetDetent._factor(heightFactor);
  }

  final double? _heightFactor;

  bool get isAuto => _heightFactor == null;

  double get heightFactor {
    final heightFactor = _heightFactor;
    if (heightFactor == null) {
      throw StateError('Auto detent does not have a fixed height factor.');
    }
    return heightFactor;
  }

  double heightOf(
    BuildContext context, {
    double? autoHeight,
    ModalSheetDetent autoFallbackDetent = ModalSheetDetent.medium,
  }) {
    final screenMetrics = _modalSheetScreenMetrics(context);
    final rawHeight = isAuto
        ? autoHeight ?? autoFallbackDetent.heightOf(context)
        : screenMetrics.height * heightFactor;
    final fullHeight = isLandscapeModalPresentation(context)
        ? screenMetrics.height
        : screenMetrics.height - screenMetrics.paddingTop - _modalFullTopGap;
    return rawHeight.clamp(0.0, fullHeight).toDouble();
  }

  @override
  bool operator ==(Object other) {
    return other is ModalSheetDetent && other._heightFactor == _heightFactor;
  }

  @override
  int get hashCode => _heightFactor.hashCode;
}

/// The off-screen bottom slice a modal sheet pushes below its resting detent.
///
/// Content is laid out at full route height and translated to its detent.
/// Use the completed animation's position after a drag or runtime override;
/// while animating, fall back to the initial detent without per-frame work.
/// Add the device top safe area (subtracted by [ModalSheetDetent.heightOf])
/// and bottom safe area so the last rows remain reachable. Read these from
/// [View] because `MediaQuery.padding` is zeroed inside the sheet.
///
/// This is the single computation behind [ModalSheetScrollInsets]; widgets read
/// the value via [ModalSheetScrollInsets.of], never by calling this directly.
double _modalSheetOffscreenBottomInset(
  BuildContext context,
  StupidSimpleSheetController<dynamic> controller,
) {
  final animation = controller.animation;
  final fraction =
      animation != null && animation.status == AnimationStatus.completed
      ? animation.value
      : controller.effectiveSnappingConfig.initialSnap;
  return modalSheetInsetForFraction(
    context,
    fullHeight: ModalSheetDetent.full.heightOf(context),
    fraction: fraction,
  );
}

const _modalFullTopGap = 0.0;
const _landscapeModalMinimumDetent = ModalSheetDetent.full;

/// The single detent every partial-screen sheet collapses to in landscape: the
/// `.full` height with the small top gap rendered by [LandscapeModalSheetFrame].
const _landscapeFullSnappingConfig = SheetSnappingConfig([1], initialSnap: 1);

/// Remembers the portrait snapping configuration for a sheet controller so it
/// can be restored when the device rotates back from landscape, instead of
/// leaving the sheet stuck at the landscape full detent. Seeded at push time by
/// [showAppCupertinoModalBottomSheet] from the caller's (un-collapsed) detents
/// and updated at runtime by [setModalSheetDetentHeight]. Keyed weakly by the
/// controller, so it is released together with the sheet route.
/// See [LandscapeModalSheetFrame].
final Expando<SheetSnappingConfig> _portraitSnappingConfig = Expando();

/// Set by [modalSheetSnappingConfig] and consumed by the next
/// [showAppCupertinoModalBottomSheet] push, carrying the portrait
/// (un-collapsed) snapping config so the route can be tagged for orientation
/// restore. Safe as a transient hand-off: the config is built synchronously in
/// the push call's argument list, immediately before the route is created.
SheetSnappingConfig? _pendingPortraitSnappingConfig;

/// Captures (and clears) the pending portrait snapping config queued by the
/// most recent [modalSheetSnappingConfig] call, associating it with [route].
void attachPortraitSnappingConfig(Object route) {
  final pending = _pendingPortraitSnappingConfig;
  _pendingPortraitSnappingConfig = null;
  if (pending != null) _portraitSnappingConfig[route] = pending;
}

SheetSnappingConfig modalSheetSnappingConfig({
  required BuildContext context,
  required List<ModalSheetDetent> detents,
  required ModalSheetDetent initialDetent,
  double? autoHeight,
  ModalSheetDetent autoFallbackDetent = ModalSheetDetent.medium,
}) {
  final routeHeight = _modalSheetRouteHeight(context);
  if (routeHeight <= 0) {
    final fallback = const SheetSnappingConfig([1], initialSnap: 1);
    _pendingPortraitSnappingConfig = fallback;
    return fallback;
  }

  double snapFor(ModalSheetDetent detent) {
    return (detent.heightOf(
              context,
              autoHeight: autoHeight,
              autoFallbackDetent: autoFallbackDetent,
            ) /
            routeHeight)
        .clamp(0.0, 1.0)
        .toDouble();
  }

  // Portrait configuration: every requested detent, without collapsing to
  // `.full`. Stashed so the sheet can be restored to these detents when the
  // device rotates back to portrait, even if it was opened in landscape.
  final portraitSnaps = <double>{
    for (final detent in {...detents, initialDetent}) snapFor(detent),
  }.toList()..sort();
  final portraitConfig = SheetSnappingConfig(
    portraitSnaps,
    initialSnap: snapFor(initialDetent),
  );
  _pendingPortraitSnappingConfig = portraitConfig;

  // Landscape presents a single full detent for a clean initial open;
  // [LandscapeModalSheetFrame] keeps it locked while rotated.
  if (isLandscapeModalPresentation(context)) {
    return _landscapeFullSnappingConfig;
  }
  return portraitConfig;
}

ModalSheetDetent effectiveLandscapeModalDetent(
  BuildContext context,
  ModalSheetDetent detent,
) {
  if (!isLandscapeModalPresentation(context)) return detent;
  if (detent.isAuto ||
      detent.heightFactor < _landscapeModalMinimumDetent.heightFactor) {
    return _landscapeModalMinimumDetent;
  }
  return detent;
}

void setModalSheetDetentHeight({
  required BuildContext context,
  required double height,
  List<ModalSheetDetent> detents = const [],
  bool animate = true,
}) {
  if (!height.isFinite || height <= 0) return;

  final controller = _ModalSheetControllerScope.maybeOf(context);
  if (controller == null) return;

  final routeHeight = _modalSheetRouteHeight(context);
  if (routeHeight <= 0) return;

  final snap = (height / routeHeight).clamp(0.0, 1.0).toDouble();
  if (snap <= 0) return;

  final fixedSnaps = detents
      .where((detent) => !detent.isAuto)
      .map(
        (detent) =>
            (detent.heightOf(context) / routeHeight).clamp(0.0, 1.0).toDouble(),
      );
  final snaps = <double>{snap, ...fixedSnaps}.toList()..sort();
  final portraitConfig = SheetSnappingConfig(snaps, initialSnap: snap);

  // Remember the portrait configuration so [LandscapeModalSheetFrame] can
  // restore the nested screen's detent when the device rotates back to portrait
  // (rather than reverting to the sheet route's initial config).
  _portraitSnappingConfig[controller] = portraitConfig;

  // In landscape every partial-screen sheet collapses to a single full detent,
  // regardless of the height a nested screen requests, so nested navigation
  // never reintroduces intermediate detents.
  if (isLandscapeModalPresentation(context)) {
    controller.overrideSnappingConfig(_landscapeFullSnappingConfig);
    if (animate) controller.animateToRelative(1);
    return;
  }

  controller.overrideSnappingConfig(portraitConfig);
  if (animate) controller.animateToRelative(snap);
}

double _modalSheetRouteHeight(BuildContext context) {
  return _modalSheetScreenMetrics(context).height;
}

({double height, double paddingTop}) _modalSheetScreenMetrics(
  BuildContext context,
) {
  final view = View.of(context);
  final devicePixelRatio = view.devicePixelRatio;
  if (devicePixelRatio <= 0) {
    final mediaQuery = MediaQuery.of(context);
    return (height: mediaQuery.size.height, paddingTop: mediaQuery.padding.top);
  }
  return (
    height: view.physicalSize.height / devicePixelRatio,
    paddingTop: view.padding.top / devicePixelRatio,
  );
}
