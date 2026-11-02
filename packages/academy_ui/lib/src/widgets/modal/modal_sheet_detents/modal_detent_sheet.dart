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
/// The sheet lays its content out at the full route height and only
/// *translates* down to its resting detent, so the slice below the detent is
/// off-screen and a scrollable's last rows are otherwise unreachable. Derived
/// from the sheet's LIVE resting fraction (`effectiveSnappingConfig.initialSnap`)
/// so it always matches the actual detent and tracks runtime changes
/// ([setModalSheetDetentHeight]); collapses to ~the bottom safe area at the full
/// detent. Adds the device **top** safe area (which the full-height content
/// occupies but [ModalSheetDetent.heightOf] subtracts from `full`) plus the
/// device **bottom** safe area (home indicator). Safe areas are read from the
/// physical [View] because `MediaQuery.padding` is zeroed inside the sheet.
///
/// This is the single computation behind [ModalSheetScrollInsets]; widgets read
/// the value via [ModalSheetScrollInsets.of], never by calling this directly.
double _modalSheetOffscreenBottomInset(
  BuildContext context,
  StupidSimpleSheetController<dynamic> controller,
) {
  final routeHeight = _modalSheetRouteHeight(context);
  if (routeHeight <= 0) return MediaQuery.paddingOf(context).bottom;
  final restingHeight =
      ((controller.animation?.value ??
                  controller.effectiveSnappingConfig.initialSnap) *
              routeHeight)
          .clamp(0.0, routeHeight)
          .toDouble();
  final view = View.of(context);
  final ratio = view.devicePixelRatio;
  final topInset = ratio > 0
      ? view.padding.top / ratio
      : MediaQuery.paddingOf(context).top;
  // The keyboard covers the home indicator: only the part of the safe area
  // above it counts, as in MediaQueryData.fromView.
  final bottomInset = ratio > 0
      ? (view.padding.bottom - view.viewInsets.bottom).clamp(
              0.0,
              double.infinity,
            ) /
            ratio
      : MediaQuery.paddingOf(context).bottom;
  final offscreenGap =
      ModalSheetDetent.full.heightOf(context) - restingHeight + topInset;
  return (offscreenGap > 0 ? offscreenGap : 0) + bottomInset;
}

const _modalFullTopGap = 0.0;
const _landscapeModalMinimumDetent = ModalSheetDetent.full;

/// The single detent every partial-screen sheet collapses to in landscape: the
/// `.full` height with the small top gap rendered by [LandscapeModalSheetFrame].
const _landscapeFullSnappingConfig = SheetSnappingConfig([1], initialSnap: 1);

/// Remembers the portrait snapping configuration for a sheet controller so it
/// can be restored when the device rotates back from landscape, instead of
/// leaving the sheet stuck at the landscape full detent. Seeded at push time by
/// [showAcademyModalRoute] from the caller's (un-collapsed) detents
/// and updated at runtime by [setModalSheetDetentHeight]. Keyed weakly by the
/// controller, so it is released together with the sheet route.
/// See [LandscapeModalSheetFrame].
final Expando<SheetSnappingConfig> _portraitSnappingConfig = Expando();

/// Set by [modalSheetSnappingConfig] and consumed by the next
/// [showAcademyModalRoute] push, carrying the portrait
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

/// Height every detent and [ModalSheetScrollInsets] are measured against: the
/// screen above the keyboard. A sheet's content box must have this height in
/// portrait, otherwise each detent shows only part of its height whenever the
/// top safe area is non-zero.
double modalSheetRouteHeight(BuildContext context) =>
    _modalSheetRouteHeight(context);

({double height, double paddingTop}) _modalSheetScreenMetrics(
  BuildContext context,
) {
  final view = View.of(context);
  final devicePixelRatio = view.devicePixelRatio;
  // A sheet anchored over the keyboard measures against the whole screen.
  final keyboard = _ModalKeyboardScope.movesAboveKeyboard(context);
  if (devicePixelRatio <= 0) {
    final mediaQuery = MediaQuery.of(context);
    return (
      height:
          (mediaQuery.size.height -
                  (keyboard ? mediaQuery.viewInsets.bottom : 0))
              .clamp(0.0, double.infinity),
      paddingTop: mediaQuery.padding.top,
    );
  }
  return (
    height:
        (view.physicalSize.height - (keyboard ? view.viewInsets.bottom : 0)) /
        devicePixelRatio,
    paddingTop: view.padding.top / devicePixelRatio,
  );
}
