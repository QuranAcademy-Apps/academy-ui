import 'package:flutter/widgets.dart';

/// Whether [top] is a usable status-bar inset worth remembering.
///
/// Rejects non-finite values and the collapsed `0` the platform reports while
/// the status bar is hidden (which must not overwrite a real remembered inset).
@visibleForTesting
bool isRecordableTopInset(double top) => top.isFinite && top > 0;

/// Whether a status-bar inset observed for [current] should be recorded, given
/// the [last] orientation recorded.
///
/// Returns false only on the orientation-flip frame: during a rotation the
/// platform can briefly report the new orientation's size together with the
/// previous orientation's padding, which would record one orientation's inset
/// into the other bucket. Skipping that single frame lets the settled value win.
bool shouldRecordOrientation(Orientation? last, Orientation current) =>
    last == null || last == current;

/// App-wide memory of the status-bar top inset, kept per orientation.
///
/// The status bar is only ever hidden inside the reader; on every other screen
/// it is visible, so the root `MediaQuery.padding.top` there is the authoritative
/// status-bar height. Recording it app-wide lets the reader reserve the correct
/// space on its very first frame instead of learning it reactively and jumping
/// once. Notched devices report the same constant inset everywhere, so this is a
/// no-op for them.
///
/// The stored value is the latest settled reading (not a running max), so a
/// transiently-inflated inset self-heals once a normal reading is seen again; the
/// consuming `StableTopInset` freeze provides the within-session stability that
/// keeps the layout from jumping when the bar toggles.
class ReaderTopInsetMemory {
  ReaderTopInsetMemory._();

  static final ReaderTopInsetMemory instance = ReaderTopInsetMemory._();

  double _portrait = 0;
  double _landscape = 0;

  /// Records [top] as the status-bar inset for [orientation]. Ignores collapsed
  /// (`<= 0`) or non-finite values so a hidden-bar frame cannot erase a real one.
  void record(Orientation orientation, double top) {
    if (!isRecordableTopInset(top)) return;
    if (orientation == Orientation.portrait) {
      _portrait = top;
    } else {
      _landscape = top;
    }
  }

  /// The reserved status-bar inset for [orientation] (0 when never observed).
  double reservedFor(Orientation orientation) =>
      orientation == Orientation.portrait ? _portrait : _landscape;

  @visibleForTesting
  void reset() {
    _portrait = 0;
    _landscape = 0;
  }
}
