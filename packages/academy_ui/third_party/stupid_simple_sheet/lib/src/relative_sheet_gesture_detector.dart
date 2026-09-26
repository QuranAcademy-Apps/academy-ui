import 'package:flutter/widgets.dart';
import 'package:scroll_drag_detector/scroll_drag_detector.dart';

import 'dismissal_mode.dart';
import 'sheet_dismissal_transition.dart';

class RelativeSheetGestureDetector extends StatefulWidget {
  const RelativeSheetGestureDetector({
    super.key,
    required this.scrollableCanMoveBack,
    required this.onlyDragWhenScrollWasAtTop,
    required this.onRelativeDragStart,
    required this.onRelativeDragUpdate,
    required this.onRelativeDragEnd,
    required this.dismissalMode,
    required this.child,
  });

  final bool scrollableCanMoveBack;
  final bool onlyDragWhenScrollWasAtTop;
  final VoidCallback onRelativeDragStart;
  // ignore: avoid_positional_boolean_parameters
  final void Function(double delta, double referenceHeight, bool wouldScroll)
      onRelativeDragUpdate;
  // ignore: avoid_positional_boolean_parameters
  final void Function(double velocity, double referenceHeight, bool wouldScroll)
      onRelativeDragEnd;
  final DismissalMode dismissalMode;

  final Widget child;

  @override
  State<RelativeSheetGestureDetector> createState() =>
      _RelativeSheetGestureDetectorState();
}

class _RelativeSheetGestureDetectorState
    extends State<RelativeSheetGestureDetector> {
  double? _referenceHeight;

  @override
  Widget build(BuildContext context) {
    return ScrollDragDetector(
      onlyDragWhenScrollWasAtTop: widget.onlyDragWhenScrollWasAtTop,
      scrollableCanMoveBack: widget.scrollableCanMoveBack,
      onVerticalDragStart: (details, _) {
        _referenceHeight = SheetDismissalTransition.referenceHeightOf(
          context,
          widget.dismissalMode,
        );
        widget.onRelativeDragStart();
      },
      onVerticalDragEnd: (details, willScroll) {
        if (_referenceHeight case final height?) {
          widget.onRelativeDragEnd(
            details.velocity.pixelsPerSecond.dy / height,
            height,
            willScroll,
          );
        }
        _referenceHeight = null;
      },
      onVerticalDragUpdate: (details, wouldScroll) {
        if (_referenceHeight case final height?) {
          widget.onRelativeDragUpdate(
            details.primaryDelta! / height,
            height,
            wouldScroll,
          );
        }
      },
      child: widget.child,
    );
  }
}
