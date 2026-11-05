import 'package:flutter/cupertino.dart';

import 'modal_sheet_detents.dart';

/// Hidden slice of a translated sheet, plus the device's bottom safe area.
double modalSheetInsetForFraction(
  BuildContext context, {
  required double fullHeight,
  required double fraction,
}) {
  final view = View.of(context);
  final ratio = view.devicePixelRatio;
  final mediaQuery = MediaQuery.of(context);
  final height = ratio > 0
      ? view.physicalSize.height / ratio
      : mediaQuery.size.height;
  if (height <= 0) return mediaQuery.padding.bottom;
  final top = ratio > 0 ? view.padding.top / ratio : mediaQuery.padding.top;
  final bottom = ratio > 0
      ? view.padding.bottom / ratio
      : mediaQuery.padding.bottom;
  final hidden = fullHeight - (fraction * height).clamp(0.0, height) + top;
  return (hidden > 0 ? hidden : 0) + bottom;
}

/// Resizes a bounded sheet body while keeping its footer at the visible bottom.
/// Only padding rebuilds each tick; the content keeps its widget identity.
class ModalSheetPinnedBody extends StatelessWidget {
  const ModalSheetPinnedBody({
    super.key,
    required this.child,
    this.enabled = true,
  });

  final Widget child;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    if (!enabled) return child;
    final animation = modalSheetTranslateAnimation(context);
    if (animation == null) return child;
    final minimum = modalSheetMinimumExtent(context);
    final fullHeight = ModalSheetDetent.full.heightOf(context);
    return AnimatedBuilder(
      animation: animation,
      child: child,
      builder: (context, child) => Padding(
        padding: EdgeInsets.only(
          bottom: modalSheetInsetForFraction(
            context,
            fullHeight: fullHeight,
            // Below the lowest open detent, let the whole sheet slide out.
            fraction: animation.value.clamp(minimum, 1.0),
          ),
        ),
        child: child,
      ),
    );
  }
}
