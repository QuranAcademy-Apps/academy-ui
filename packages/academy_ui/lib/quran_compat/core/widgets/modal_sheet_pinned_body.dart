import 'package:cupertino_ui/cupertino_ui.dart';
import 'modal_sheet_detents.dart';
import 'modal_sheet_inset_geometry.dart';

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
