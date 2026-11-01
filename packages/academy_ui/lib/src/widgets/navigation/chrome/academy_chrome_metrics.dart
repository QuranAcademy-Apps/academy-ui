import 'dart:math' as math;

import 'package:flutter/widgets.dart';

import '../../../theme/academy_theme.dart';
import '../../../foundation/layout/academy_text_metrics.dart';

// Ported from Quran's app_chrome_bar_metrics.dart and floating_chrome_insets.dart.
const academyChromeBarHeight = AcademyTokens.target;
const academyChromeContentGap = AcademyTokens.space;
double academyEdgeInset(double safe) => math.max(safe, 8);
double academyChromeTopOf(BuildContext context) =>
    academyEdgeInset(MediaQuery.paddingOf(context).top);
double academyChromeHeightOf(BuildContext context, {bool subtitle = false}) =>
    math.max(
      academyChromeBarHeight,
      _chromeLineHeight(
            context,
            AcademyTheme.of(context).textTheme.titleMedium,
          ) +
          (subtitle
              ? _chromeLineHeight(
                  context,
                  AcademyTheme.of(context).textTheme.bodySmall,
                )
              : 0),
    );
double _chromeLineHeight(BuildContext context, TextStyle style) => math.max(
  (MediaQuery.textScalerOf(context).scale(style.fontSize!) * 1.4)
      .ceilToDouble(),
  academyTextLineHeight(context, style).ceilToDouble(),
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
