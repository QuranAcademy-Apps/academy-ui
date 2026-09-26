import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:motor/motor.dart';

import 'src/dismissal_mode.dart';
import 'src/route_snapshot_mode.dart';
import 'src/snapping_point.dart';
import 'src/stupid_simple_sheet_controller.dart';
import 'src/stupid_simple_sheet_transition.dart';

export 'package:motor/src/motion.dart';

export 'src/dismissal_mode.dart';
export 'src/route_snapshot_mode.dart';
export 'src/sheet_background.dart';
export 'src/sheet_dismissal_transition.dart';
export 'src/shrink_transition.dart';
export 'src/snapping_point.dart';
export 'src/stupid_simple_cupertino_sheet.dart';
export 'src/stupid_simple_glass_sheet.dart';

export 'src/stupid_simple_sheet_controller.dart';
export 'src/stupid_simple_sheet_transition.dart';

/// A modal route that displays a sheet that slides up from the bottom.
///
/// The sheet can be dismissed by dragging down or by tapping the barrier.
/// The animation supports spring physics for natural motion using the
///
///
/// By default, when a modal route is replaced by another, the previous route
/// remains in memory. To free all the resources when this is not necessary, set
/// [maintainState] to false.
///
/// The type `T` specifies the return type of the route which can be supplied as
/// the route is popped from the stack via [Navigator.pop] when an optional
/// `result` can be provided.
///
/// See also:
///
///  * [StupidSimpleSheetTransitionMixin], for a mixin that provides sheet
/// transition
///    behavior for this modal route.
///  * [CupertinoModalPopupRoute], for a similar iOS-style modal popup.
class StupidSimpleSheetRoute<T> extends PopupRoute<T>
    with StupidSimpleSheetTransitionMixin<T>, StupidSimpleSheetController<T> {
  /// Creates a sheet route for displaying modal content.
  ///
  /// The [motion] and [child] arguments must not be null.
  StupidSimpleSheetRoute({
    required this.child,
    super.settings,
    this.motion = const CupertinoMotion.smooth(snapToEnd: true),
    this.barrierColor = const Color.fromRGBO(0, 0, 0, 0.2),
    this.barrierDismissible = true,
    this.barrierLabel,
    this.clearBarrierImmediately = true,
    this.onlyDragWhenScrollWasAtTop = true,
    this.callNavigatorUserGestureMethods = false,
    this.snappingConfig = SheetSnappingConfig.full,
    this.draggable = true,
    this.originateAboveBottomViewInset = false,
    this.dismissalMode = DismissalMode.slide,
    this.backgroundSnapshotMode = RouteSnapshotMode.never,
  });

  @override
  final Motion motion;

  /// The widget to display in the sheet.
  final Widget child;

  @override
  final Color? barrierColor;

  @override
  final bool barrierDismissible;

  @override
  final String? barrierLabel;

  @override
  final bool clearBarrierImmediately;

  @override
  final bool onlyDragWhenScrollWasAtTop;

  @override
  final bool callNavigatorUserGestureMethods;

  /// The base snapping configuration for the sheet.
  @override
  final SheetSnappingConfig snappingConfig;

  @override
  final bool draggable;

  @override
  final bool originateAboveBottomViewInset;

  @override
  final DismissalMode dismissalMode;

  @override
  final RouteSnapshotMode backgroundSnapshotMode;

  @override
  DelegatedTransitionBuilder? get delegatedTransition =>
      backgroundSnapshotMode == RouteSnapshotMode.never
          ? null
          : (context, animation, secondaryAnimation, canSnapshot, child) {
              return SnapshotWidget(
                controller: backgroundSnapshotController,
                mode: SnapshotMode.permissive,
                autoresize: true,
                child: child,
              );
            };

  @override
  Widget buildContent(BuildContext context) {
    return child;
  }
}
