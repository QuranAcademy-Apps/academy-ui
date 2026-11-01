import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Bumped when [androidBottomRoundedCornerInsetLogicalPx] changes after warm.
final ValueNotifier<int> displayChromeAndroidListenable = ValueNotifier<int>(0);

@visibleForTesting
void notifyDisplayChromeAndroidChangedForTest() {
  displayChromeAndroidListenable.value++;
}

const String _displayChromeChannelName = 'quran_academy/display_chrome';

/// Cached contribution from physical bottom rounded corners (Android RoundedCorner),
/// in Flutter logical pixels (same convention as dp on Android).
double? _androidBottomRoundedCornerInsetLogicalPx;

double? get androidBottomRoundedCornerInsetLogicalPx =>
    _androidBottomRoundedCornerInsetLogicalPx;

/// Cached Android system navigation mode (0 = 3-button, 1 = 2-button,
/// 2 = gesture). Null until [warmDisplayChromeAndroidFromPlatform] reads it.
int? _androidNavigationMode;

/// True only when the device is confirmed to use gesture navigation.
///
/// Returns `false` while the mode is unknown so opaque button bars (3-button /
/// 2-button) are cleared with the full system inset by default; the rounded
/// corner curve reduction is reserved for gesture navigation.
bool get androidUsesGestureNavigation => _androidNavigationMode == 2;

const MethodChannel _displayChromeChannel = MethodChannel(
  _displayChromeChannelName,
);

const List<Duration> _warmRetryDelays = <Duration>[
  Duration(milliseconds: 0),
  Duration(milliseconds: 80),
  Duration(milliseconds: 250),
  Duration(milliseconds: 700),
];

/// Reads bottom-left / bottom-right [RoundedCorner] radii via platform channel.
///
/// Safe to call before first frame. On Android, retries a few times because
/// `View.rootWindowInsets` may be null or report `radius == 0` until the window
/// is fully attached.
///
/// Returns `true` if a positive value was captured, otherwise `false`.
Future<bool> warmDisplayChromeAndroidFromPlatform() async {
  if (kIsWeb || defaultTargetPlatform != TargetPlatform.android) {
    _androidBottomRoundedCornerInsetLogicalPx = null;
    return false;
  }

  // Navigation mode is a Settings.Secure read that is reliable on the first
  // attempt, so capture it up front before the rounded-corner retry loop.
  _androidNavigationMode = await _fetchNavigationMode() ?? _androidNavigationMode;

  final previous = _androidBottomRoundedCornerInsetLogicalPx;
  for (final delay in _warmRetryDelays) {
    if (delay > Duration.zero) {
      await Future<void>.delayed(delay);
    }
    final value = await _fetchBottomRoundedCornerDp();
    if (value != null && value > 0) {
      _androidBottomRoundedCornerInsetLogicalPx = value;
      if (previous != value) {
        displayChromeAndroidListenable.value++;
      }
      return true;
    }
  }

  // Keep the previous known value if the platform temporarily returned 0
  // (orientation change while still attached, etc.).
  return _androidBottomRoundedCornerInsetLogicalPx != null;
}

/// Force-clear cache for tests or when the platform explicitly reports zero.
@visibleForTesting
void resetDisplayChromeAndroidCache() {
  _androidBottomRoundedCornerInsetLogicalPx = null;
  _androidNavigationMode = null;
}

Future<int?> _fetchNavigationMode() async {
  try {
    final int? value = await _displayChromeChannel.invokeMethod<int>(
      'getNavigationMode',
    );
    return value;
  } catch (_) {
    return null;
  }
}

Future<double?> _fetchBottomRoundedCornerDp() async {
  try {
    final num? value = await _displayChromeChannel.invokeMethod<num>(
      'getBottomRoundedCornerInsetDp',
    );
    final d = value?.toDouble();
    if (d == null || d.isNaN || d.isInfinite || d <= 0) {
      return null;
    }
    return d;
  } catch (_) {
    return null;
  }
}
