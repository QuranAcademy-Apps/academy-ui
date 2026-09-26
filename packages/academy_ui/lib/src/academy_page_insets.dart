import 'package:flutter/widgets.dart';

/// The page owns header obstruction; scroll content consumes it as padding.
class AcademyPageInsets extends InheritedWidget {
  const AcademyPageInsets({super.key, required this.top, required super.child});
  final double top;
  static double topOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<AcademyPageInsets>()?.top ??
      20;
  @override
  bool updateShouldNotify(AcademyPageInsets oldWidget) => top != oldWidget.top;
}
