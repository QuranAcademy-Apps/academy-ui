import 'package:flutter/widgets.dart';

import '../../widgets/modal/modal_sheet_detents.dart';

/// Whether [route] is part of a running navigation transition: its own
/// entry/exit animation or the secondary animation driven by the route above
/// it. Covers an in-progress back swipe too: while the finger drags, the
/// secondary animation sits mid-value with an animating status.
bool academyIsRouteTransitionActive(ModalRoute<Object?>? route) {
  if (route == null) return false;
  return (route.animation?.status.isAnimating ?? false) ||
      (route.secondaryAnimation?.status.isAnimating ?? false);
}

/// Runs a screen's heavy initialization after its entry transition, so the
/// first frames of a push stay cheap. Fires once, after the final transition
/// frame, or right away for a route that is already settled.
///
/// Read what a first frame needs synchronously in `initState` instead, for
/// example the value of a switch: it would visibly flip after the push.
///
/// Ported from Quran's DeferredRouteInit. Inside a sheet it also waits for the
/// sheet itself: the first route of a nested navigator reads as settled while
/// the sheet is still rising.
mixin AcademyDeferredRouteInit<T extends StatefulWidget> on State<T> {
  Animation<double>? _route;
  Animation<double>? _sheet;
  bool _didFire = false;

  /// Called once, after the entry transition completes.
  void onRouteTransitionComplete();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final route = ModalRoute.of(context)?.animation;
    final sheet = modalSheetTranslateAnimation(context);
    if (identical(route, _route) && identical(sheet, _sheet)) return;
    _stopListening();
    _route = route;
    _sheet = sheet;
    if (_didFire) return;
    if (route == null && sheet == null) {
      _fire();
      return;
    }
    route?.addStatusListener(_statusChanged);
    sheet?.addStatusListener(_statusChanged);
    // The status cannot be trusted here: a CupertinoPageRoute's animation reads
    // `completed` between route install and the first transition frame. Check
    // once that frame has set the real status.
    WidgetsBinding.instance.addPostFrameCallback((_) => _fireIfSettled());
  }

  void _statusChanged(AnimationStatus status) {
    if (status == AnimationStatus.completed) _fireIfSettled();
  }

  void _fireIfSettled() {
    if (!mounted || _didFire) return;
    bool settled(Animation<double>? animation) =>
        animation == null || animation.status == AnimationStatus.completed;
    if (settled(_route) && settled(_sheet)) _fire();
  }

  void _fire() {
    if (_didFire || !mounted) return;
    _didFire = true;
    _stopListening();
    // After the final transition frame is painted, so the work never lands on
    // that frame itself.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) onRouteTransitionComplete();
    });
  }

  void _stopListening() {
    _route?.removeStatusListener(_statusChanged);
    _sheet?.removeStatusListener(_statusChanged);
  }

  @override
  void dispose() {
    _stopListening();
    super.dispose();
  }
}
