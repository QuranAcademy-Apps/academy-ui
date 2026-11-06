import 'package:flutter/widgets.dart';

/// Look of [AcademySegmentedControl.fitted] for a whole app.
@immutable
class AcademySegmentedTheme {
  const AcademySegmentedTheme({
    this.height = 36,
    this.minSegmentWidth = 41,
    this.cornerRadius = 18,
    this.selectionCornerRadius = 16.2,
    this.textColor,
    this.selectionBorderColor,
    this.selectionShadowColor,
  });

  final double height;
  final double minSegmentWidth;
  final double cornerRadius;
  final double selectionCornerRadius;
  final Color? textColor;
  final Color? selectionBorderColor;
  final Color? selectionShadowColor;
}
