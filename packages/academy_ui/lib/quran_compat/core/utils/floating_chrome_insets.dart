import 'dart:math' as math;

import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:flutter/foundation.dart';

import './display_chrome_android_bridge.dart';

/// Minimum breathing room kept at the top/bottom screen edge so content and
/// floating chrome never sit flush against the physical edge on devices WITHOUT
/// a notch / home-indicator inset. On devices WITH an inset the real (larger)
/// inset wins, so notched layouts are unchanged.
const double kEdgeBreathingInset = 8;

/// Floors a raw vertical safe-area inset to [kEdgeBreathingInset]. Use at the
/// edge-inset boundaries (chrome bar/tab insets, floating bottom chrome) so the
/// 8px floor is applied uniformly without per-screen padding.
double withEdgeBreathing(double rawInset) =>
    math.max(rawInset, kEdgeBreathingInset);

/// Raw bottom inset from the platform (padding / viewPadding max).
///
/// Prefer [floatingChromeBottomInsetOf] for floating bars, docks, tab bar
/// chrome, and bottom-positioned overlays under edge-to-edge Android.
double mediaQueryBottomSafeInsetOf(BuildContext context) {
  return mediaQueryBottomSafeInsetFor(MediaQuery.of(context));
}

double mediaQueryBottomSafeInsetFor(MediaQueryData mediaQuery) {
  return math.max(mediaQuery.padding.bottom, mediaQuery.viewPadding.bottom);
}

/// Bottom inset for floating chrome (reader bars, player dock, tab bar area,
/// bottom toasts) positioned at the screen's bottom system boundary.
///
/// On Android, when [warmDisplayChromeAndroidFromPlatform] has populated
/// [androidBottomRoundedCornerInsetLogicalPx], the rounded-corner radius is
/// capped by the platform gesture/navigation inset. Some devices report a
/// radius that is visually too high for floating bottom chrome.
/// Non-Android platforms always use [mediaQueryBottomSafeInsetOf].
double floatingChromeBottomInsetOf(BuildContext context) {
  return floatingChromeBottomInsetForMediaQuery(MediaQuery.of(context));
}

double floatingChromeBottomInsetForMediaQuery(MediaQueryData mediaQuery) {
  // Floor to the edge-breathing minimum so floating bottom chrome (tab pill,
  // bottom fade, pushed-screen bottom, reader dock) lifts 8px off a flush edge
  // on devices without a home-indicator inset.
  final base = withEdgeBreathing(mediaQueryBottomSafeInsetFor(mediaQuery));
  if (defaultTargetPlatform != TargetPlatform.android) {
    return base;
  }

  final platformBoundary = math.max(
    base,
    mediaQuery.systemGestureInsets.bottom,
  );
  // The rounded-corner curve reduction only makes sense under gesture
  // navigation, where the area below the gesture pill is just the screen
  // corner. With an opaque 3-button / 2-button bar the buttons must be cleared
  // in full, so fall back to the real system inset.
  if (!androidUsesGestureNavigation) {
    return platformBoundary;
  }
  final curve = androidBottomRoundedCornerInsetLogicalPx;
  if (curve != null && curve > 0) {
    if (platformBoundary > 0) {
      return math.min(math.max(base, curve), platformBoundary);
    }
    return curve;
  }

  return platformBoundary;
}

/// Bottom inset for [CupertinoTabBar] on Android.
///
/// Uses the same policy as [floatingChromeBottomInsetOf] / reader floating
/// chrome, but ignores existing MediaQuery bottom padding and viewPadding so a
/// stale system inset on cold start does not block the warmed rounded-corner
/// inset before metrics refresh (for example after opening search).
double androidTabBarBottomChromeInsetOf(BuildContext context) {
  if (defaultTargetPlatform != TargetPlatform.android) {
    return mediaQueryBottomSafeInsetOf(context);
  }

  final mediaQuery = MediaQuery.of(context);
  return floatingChromeBottomInsetForMediaQuery(
    mediaQuery.copyWith(
      padding: mediaQuery.padding.copyWith(bottom: 0),
      viewPadding: mediaQuery.viewPadding.copyWith(bottom: 0),
    ),
  );
}

MediaQueryData normalizedAndroidLandscapeSafeArea(MediaQueryData mediaQuery) {
  if (defaultTargetPlatform != TargetPlatform.android) {
    return mediaQuery;
  }

  final size = mediaQuery.size;
  if (size.width <= size.height) {
    return mediaQuery;
  }

  final sideInset = _androidLandscapeSideInset(mediaQuery);
  if (sideInset <= 0) {
    return mediaQuery;
  }

  final padding = mediaQuery.padding;
  final viewPadding = mediaQuery.viewPadding;
  return mediaQuery.copyWith(
    padding: padding.copyWith(
      left: math.max(padding.left, sideInset),
      right: math.max(padding.right, sideInset),
    ),
    viewPadding: viewPadding.copyWith(
      left: math.max(viewPadding.left, sideInset),
      right: math.max(viewPadding.right, sideInset),
    ),
  );
}

double _androidLandscapeSideInset(MediaQueryData mediaQuery) {
  final base = math.max(
    mediaQuery.padding.bottom,
    mediaQuery.viewPadding.bottom,
  );
  return math.max(base, mediaQuery.systemGestureInsets.bottom);
}
