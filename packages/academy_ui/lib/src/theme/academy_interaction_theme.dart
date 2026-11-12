import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:flutter/services.dart';

/// Input density is explicit: a wide window can still be a touch device.
enum AcademyDensity { touch, desktop }

@immutable
class AcademyInteractionTheme {
  const AcademyInteractionTheme({
    this.density = AcademyDensity.touch,
    this.hapticsEnabled = true,
    this.selectionFeedback,
    this.pressedScale = 0.97,
    this.chromePressedScale = 0.9,
  });
  final AcademyDensity density;
  final bool hapticsEnabled;
  final VoidCallback? selectionFeedback;

  /// Scale of a pressed button, card or tile.
  final double pressedScale;

  /// Scale of a pressed round navigation button.
  final double chromePressedScale;
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
