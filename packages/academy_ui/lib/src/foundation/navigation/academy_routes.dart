import 'package:cupertino_ui/cupertino_ui.dart';

import '../motion/soft_fade_switcher.dart';

/// [CupertinoPageRoute] without its barrier, which darkens the page below and
/// fills the whole navigator, so inside a sheet it shows in the rounded corners.
class AcademyPageRoute<T> extends CupertinoPageRoute<T> {
  AcademyPageRoute({
    required super.builder,
    super.title,
    super.settings,
    super.maintainState,
    super.fullscreenDialog,
    this.instantPush = false,
  });

  /// Appears at once but still animates when dismissed, for example when a cold
  /// launch jumps straight to the last open screen.
  final bool instantPush;

  @override
  Duration get transitionDuration =>
      instantPush ? Duration.zero : super.transitionDuration;

  @override
  Duration get reverseTransitionDuration => instantPush
      ? CupertinoRouteTransitionMixin.kTransitionDuration
      : super.reverseTransitionDuration;

  @override
  Color? get barrierColor => null;
}

/// A soft, see-through appearance for a screen that overlays the current one
/// rather than going deeper, such as search. Under Reduce Motion, a plain fade.
class AcademyFadeRoute<T> extends PageRouteBuilder<T> {
  AcademyFadeRoute({
    required WidgetBuilder builder,
    super.settings,
    super.transitionDuration = const Duration(milliseconds: 300),
    super.reverseTransitionDuration = const Duration(milliseconds: 300),
  }) : super(
         opaque: false,
         pageBuilder: (context, _, _) => Builder(builder: builder),
         transitionsBuilder: (context, animation, _, child) {
           final still = MediaQuery.disableAnimationsOf(context);
           return SoftFadeTransition(
             animation: CurvedAnimation(
               parent: animation,
               curve: Curves.easeInOutCubic,
             ),
             initialOffset: still ? Offset.zero : const Offset(0, 0.01),
             initialScale: still ? 1 : 0.99,
             child: child,
           );
         },
       );
}
