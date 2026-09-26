import 'dart:math' as math;

import 'package:flutter/widgets.dart';

// Ported from Quran's app_chrome_bar_metrics.dart and floating_chrome_insets.dart.
const academyChromeBarHeight = 44.0;
const academyChromeContentGap = 8.0;
double academyEdgeInset(double safe) => math.max(safe, 8);
double academyChromeTopOf(BuildContext context) =>
    academyEdgeInset(MediaQuery.paddingOf(context).top);
double academyChromeHeightOf(BuildContext context, {bool subtitle = false}) =>
    math.max(
      academyChromeBarHeight,
      (MediaQuery.textScalerOf(context).scale(17) * 1.4).ceilToDouble() +
          (subtitle
              ? (MediaQuery.textScalerOf(context).scale(13) * 1.4)
                    .ceilToDouble()
              : 0),
    );
double academyChromeContentTopOf(BuildContext context) =>
    academyChromeTopOf(context) +
    academyChromeHeightOf(context) +
    academyChromeContentGap;
double academyChromeBottomOf(BuildContext context) {
  final media = MediaQuery.of(context);
  return academyEdgeInset(
    math.max(media.padding.bottom, media.viewPadding.bottom),
  );
}
