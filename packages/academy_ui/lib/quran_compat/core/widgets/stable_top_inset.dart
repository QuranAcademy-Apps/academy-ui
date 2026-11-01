import 'dart:math' as math;

import 'package:flutter/widgets.dart';

import '../utils/reader_top_inset_memory.dart';

/// Resolves the top safe-area inset that an immersive screen should keep using
/// while the status bar is toggled on/off.
///
/// Hiding the iOS status bar collapses `MediaQuery.padding.top` to 0 on devices
/// where the status bar is not a persistent notch inset (iPad, non-notched
/// iPhones). Keeping the largest inset seen for the current orientation freezes
/// the layout so content does not jump when the bar appears/disappears. The
/// value is re-seeded on orientation flips, where the real inset legitimately
/// differs.
@visibleForTesting
double resolveStableTopInset({
  required double currentTop,
  required double frozenTop,
  required bool orientationChanged,
}) {
  if (orientationChanged) return currentTop;
  return math.max(currentTop, frozenTop);
}

/// Freezes the top safe-area inset for [child] so toggling the system status bar
/// does not shift content. See [resolveStableTopInset].
///
/// Used by any full-screen surface that hides the status bar for an immersive
/// mode (the Quran reader, the video player). The frozen inset is seeded from
/// [ReaderTopInsetMemory] so the reserved space is correct on the very first
/// frame instead of being learned reactively (which would jump once).
class StableTopInset extends StatefulWidget {
  const StableTopInset({super.key, required this.child});

  final Widget child;

  @override
  State<StableTopInset> createState() => _StableTopInsetState();
}

class _StableTopInsetState extends State<StableTopInset> {
  double _frozenTop = 0;
  Orientation? _orientation;

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final orientation = mediaQuery.orientation;
    // Seed from the app-wide status-bar inset remembered for this orientation
    // (recorded on screens where the bar is visible). This keeps the reserved
    // space correct on the very first frame and right after an orientation flip,
    // even when the bar is already hidden and the live inset reads 0 — so there
    // is no one-time jump.
    final reserved = ReaderTopInsetMemory.instance.reservedFor(orientation);
    final currentTop = math.max(mediaQuery.padding.top, reserved);
    // Persisted on the State instance; rebuilds are driven by the ambient
    // MediaQuery change, so no setState is needed to keep the frozen value.
    _frozenTop = resolveStableTopInset(
      currentTop: currentTop,
      frozenTop: _frozenTop,
      orientationChanged: _orientation != orientation,
    );
    _orientation = orientation;

    return MediaQuery(
      data: mediaQuery.copyWith(
        padding: mediaQuery.padding.copyWith(top: _frozenTop),
      ),
      child: widget.child,
    );
  }
}
