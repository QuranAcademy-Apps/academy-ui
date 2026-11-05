import 'dart:math' as math;

import 'package:flutter/widgets.dart';

/// App-wide memory of the status-bar inset, per orientation, so an immersive
/// screen reserves the right space on its first frame instead of learning it
/// and jumping once.
///
/// Call [observe] from a place that sees the root [MediaQuery], for example
/// `CupertinoApp.builder`. The stored value is the latest settled reading, so a
/// transiently inflated inset heals by itself.
class AcademyTopInsetMemory {
  AcademyTopInsetMemory._();

  static final instance = AcademyTopInsetMemory._();

  double _portrait = 0, _landscape = 0;
  Orientation? _last;

  /// Records the inset of [media]. Skips the frame an orientation flips on,
  /// which can pair the new size with the old padding, and a collapsed inset,
  /// which only means the status bar is hidden.
  void observe(MediaQueryData media) {
    final orientation = media.orientation;
    final settled = _last == null || _last == orientation;
    _last = orientation;
    final top = media.padding.top;
    if (!settled || !top.isFinite || top <= 0) return;
    if (orientation == Orientation.portrait) {
      _portrait = top;
    } else {
      _landscape = top;
    }
  }

  /// The inset for [orientation]; 0 when none was seen.
  double reservedFor(Orientation orientation) =>
      orientation == Orientation.portrait ? _portrait : _landscape;

  @visibleForTesting
  void reset() {
    _portrait = _landscape = 0;
    _last = null;
  }
}

/// Freezes the top safe-area inset for [child], so hiding the status bar does
/// not shift content. On an iPad or an iPhone without a notch, hiding it
/// collapses `MediaQuery.padding.top` to 0.
///
/// Keeps the largest inset seen in the current orientation, seeded from
/// [AcademyTopInsetMemory]. Ported from Quran's StableTopInset.
class AcademyStableTopInset extends StatefulWidget {
  const AcademyStableTopInset({super.key, required this.child});
  final Widget child;
  @override
  State<AcademyStableTopInset> createState() => _AcademyStableTopInsetState();
}

class _AcademyStableTopInsetState extends State<AcademyStableTopInset> {
  double _frozenTop = 0;
  Orientation? _orientation;

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final orientation = media.orientation;
    final current = math.max(
      media.padding.top,
      AcademyTopInsetMemory.instance.reservedFor(orientation),
    );
    // Rebuilds come from the MediaQuery itself, so no setState is needed.
    _frozenTop = _orientation == orientation
        ? math.max(current, _frozenTop)
        : current;
    _orientation = orientation;
    return MediaQuery(
      data: media.copyWith(padding: media.padding.copyWith(top: _frozenTop)),
      child: widget.child,
    );
  }
}
