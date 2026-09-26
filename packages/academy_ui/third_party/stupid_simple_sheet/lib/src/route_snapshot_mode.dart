import 'package:cupertino_ui/cupertino_ui.dart';

/// Controls when the route behind the sheet is rasterized to a GPU texture
/// instead of being painted live.
///
/// Snapshotting replaces the background route's widget tree with a frozen
/// image, eliminating the cost of rebuilding and painting complex widgets
/// during sheet transitions and while the sheet is open.
///
/// See also:
///
///  * [SnapshotWidget], the Flutter widget that performs the rasterization.
enum RouteSnapshotMode {
  /// Never snapshot. The background route is always painted live.
  ///
  /// Use this when the content behind the sheet contains animations, video, or
  /// other dynamic content that must remain live at all times.
  never,

  /// Snapshot only while the sheet animation is playing (opening, closing,
  /// or being dragged). Reverts to the live widget tree when the animation
  /// settles.
  ///
  /// Good for cases where transition performance matters but background content
  /// must stay live when the sheet is idle.
  animating,

  /// Snapshot while the sheet is open and settled. Reverts to live during
  /// all animations (opening, closing, and drag gestures).
  ///
  /// Useful when the transition involves visual effects that don't rasterize
  /// well, but idle performance matters.
  settled,

  /// Snapshot while the sheet animates toward its fully-open (max extent)
  /// position, and while it is settled there. Reverts to the live widget tree
  /// during dismiss gestures, closing animations, and animations toward
  /// intermediate snap points.
  ///
  /// "Forward" only counts when the animation target is the maximum snapping
  /// point. Animations to intermediate snap points are not snapshotted.
  ///
  /// Best default for most sheets: maximum performance during the opening
  /// transition and while idle, with real content visible as the user drags to
  /// dismiss.
  openAndForward,

  /// Always snapshot while the sheet is present.
  ///
  /// Maximum performance. The background is completely frozen for the lifetime
  /// of the sheet. Best for static background content.
  always,

  /// LOCAL PATCH (quran_flutter): snapshot while the sheet animates or is
  /// dragged (exactly like [animating]) AND while the sheet's inner content is
  /// being scrolled. Reverts to the live background only when everything is idle
  /// — no animation, no sheet drag, no content scroll.
  ///
  /// This is the app's default for modal sheets: it keeps the (often heavy)
  /// background frozen during the exact moments it would otherwise repaint live
  /// every frame — sheet motion and inner scroll — while staying live and
  /// interactive once the sheet settles and the user stops scrolling.
  ///
  /// Inner-scroll detection is driven inside the package (see
  /// [StupidSimpleSheetTransitionMixin]); no app-side wiring is required.
  animatingAndScrolling,
}
