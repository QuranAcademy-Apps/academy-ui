import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

/// Bottom inset for floating chrome under edge-to-edge Android, for
/// [AcademyThemeData.chromeBottomInsetOf]. Elsewhere: the safe area, at least 8.
///
/// The app reads the native values itself, since the library has no platform
/// channel. [roundedCornerInset] is the part of the bottom corner radius that
/// chrome should clear. Some devices report a radius that is too high, so it is
/// capped by the gesture inset. It applies only under [gestureNavigation]: with
/// a 2- or 3-button bar, the buttons must be cleared in full.
///
/// Ported from Quran's floatingChromeBottomInsetForMediaQuery.
double academyAndroidChromeBottomInset(
  MediaQueryData media, {
  double? roundedCornerInset,
  bool gestureNavigation = true,
}) {
  final base = math.max(
    8.0,
    math.max(media.padding.bottom, media.viewPadding.bottom),
  );
  if (defaultTargetPlatform != TargetPlatform.android) return base;
  final boundary = math.max(base, media.systemGestureInsets.bottom);
  if (!gestureNavigation) return boundary;
  final corner = roundedCornerInset;
  if (corner == null || corner <= 0) return boundary;
  return math.min(math.max(base, corner), boundary);
}

/// Makes both side insets of landscape Android at least as large as the bottom
/// inset, since some devices report them as asymmetric or zero. Apply to the
/// root [MediaQuery]. A heuristic ported from Quran: check it on your devices.
MediaQueryData academyNormalizedAndroidLandscape(MediaQueryData media) {
  if (defaultTargetPlatform != TargetPlatform.android ||
      media.size.width <= media.size.height) {
    return media;
  }
  final side = math.max(
    math.max(media.padding.bottom, media.viewPadding.bottom),
    media.systemGestureInsets.bottom,
  );
  if (side <= 0) return media;
  EdgeInsets widened(EdgeInsets insets) => insets.copyWith(
    left: math.max(insets.left, side),
    right: math.max(insets.right, side),
  );
  return media.copyWith(
    padding: widened(media.padding),
    viewPadding: widened(media.viewPadding),
  );
}
