import 'dart:math' as math;

import 'package:flutter/widgets.dart';

// Ported from Yalla's yalla_text_fit.dart (large text at 320pt/×2, 2026-11-02).

/// Width of [text] laid out on one line at [scaler] (system scale by default).
double academyTextWidth(
  BuildContext context,
  String text,
  TextStyle style, {
  TextScaler? scaler,
}) {
  final painter = TextPainter(
    text: TextSpan(text: text, style: style),
    textDirection: Directionality.of(context),
    textScaler: scaler ?? MediaQuery.textScalerOf(context),
  )..layout();
  final width = painter.width;
  painter.dispose();
  return width;
}

/// Width of the widest unbreakable word in [text] at the system text scale.
double academyLongestWordWidth(
  BuildContext context,
  String text,
  TextStyle style,
) => text
    .split(RegExp(r'\s+'))
    .where((word) => word.isNotEmpty)
    .fold(
      0.0,
      (widest, word) =>
          math.max(widest, academyTextWidth(context, word, style)),
    );

/// Largest scaler not above the system one, and not below 1×, at which the
/// text fits [maxWidth] without breaking inside a word (or, with [wholeText],
/// on a single line). Text keeps growing with system settings; it only stops
/// growing where the box cannot hold it. Below 1× is never used, so a fitted
/// label is never smaller than at the default text size.
TextScaler academyFitTextScaler(
  BuildContext context,
  String text,
  TextStyle style,
  double maxWidth, {
  bool wholeText = false,
}) {
  final system = MediaQuery.textScalerOf(context);
  final base = style.fontSize ?? 14;
  final factor = system.scale(base) / base;
  if (factor <= 1 || !maxWidth.isFinite) return system;
  final needed = wholeText
      ? academyTextWidth(context, text, style)
      : academyLongestWordWidth(context, text, style);
  // Half a point of slack: glyph rounding must not tip the last letter over.
  final limit = maxWidth - .5;
  if (needed <= limit) return system;
  return TextScaler.linear(math.max(1.0, factor * limit / needed));
}
