import 'dart:math' as math;

import 'package:flutter/widgets.dart';

/// The page owns what obstructs its content; scroll content consumes it as
/// padding instead of working it out on each screen.
class AcademyPageInsets extends InheritedWidget {
  const AcademyPageInsets({
    super.key,
    required this.top,
    this.bottom,
    required super.child,
  });
  final double top;

  /// Null when the page leaves it to [bottomOf]'s default.
  final double? bottom;
  static double topOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<AcademyPageInsets>()?.top ??
      20;

  /// Space to leave under the last row; default: the safe area, at least 8,
  /// plus 16.
  static double bottomOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<AcademyPageInsets>()?.bottom ??
      math.max(
            8.0,
            math.max(
              MediaQuery.paddingOf(context).bottom,
              MediaQuery.viewPaddingOf(context).bottom,
            ),
          ) +
          16;
  @override
  bool updateShouldNotify(AcademyPageInsets oldWidget) =>
      top != oldWidget.top || bottom != oldWidget.bottom;
}
