import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';

/// Input density is explicit: a wide window can still be a touch device.
enum AcademyDensity { touch, desktop }

@immutable
class AcademyInteractionTheme {
  const AcademyInteractionTheme({
    this.density = AcademyDensity.touch,
    this.hapticsEnabled = true,
    this.selectionFeedback,
  });
  final AcademyDensity density;
  final bool hapticsEnabled;
  final VoidCallback? selectionFeedback;
  double get minimumTarget => density == AcademyDensity.touch ? 44 : 32;
  void selectionClick() {
    if (!hapticsEnabled) return;
    if (selectionFeedback case final callback?) {
      callback();
    } else {
      HapticFeedback.selectionClick();
    }
  }
}
