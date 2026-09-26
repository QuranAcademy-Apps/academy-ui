// Adapted from quran_flutter/lib/shared/widgets/soft_fade_switcher.dart.
import 'package:flutter/widgets.dart';

class SoftFadeSwitcher extends StatelessWidget {
  const SoftFadeSwitcher({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 260),
    this.reverseDuration,
    this.switchInCurve = Curves.easeOutCubic,
    this.switchOutCurve = Curves.easeInCubic,
    this.initialOffset = const Offset(0, 0.015),
    this.initialScale = 0.985,
    this.alignment = Alignment.center,
    this.layoutBuilder = AnimatedSwitcher.defaultLayoutBuilder,
  });

  final Widget child;
  final Duration duration;
  final Duration? reverseDuration;
  final Curve switchInCurve;
  final Curve switchOutCurve;
  final Offset initialOffset;
  final double initialScale;
  final Alignment alignment;
  final AnimatedSwitcherLayoutBuilder layoutBuilder;

  @override
  Widget build(BuildContext context) {
    if (MediaQuery.disableAnimationsOf(context)) return child;
    return AnimatedSwitcher(
      duration: duration,
      reverseDuration: reverseDuration,
      switchInCurve: switchInCurve,
      switchOutCurve: switchOutCurve,
      layoutBuilder: layoutBuilder,
      transitionBuilder: (child, animation) {
        return SoftFadeTransition(
          animation: animation,
          initialOffset: initialOffset,
          initialScale: initialScale,
          alignment: alignment,
          child: child,
        );
      },
      child: child,
    );
  }
}

class SoftFadeTransition extends StatelessWidget {
  const SoftFadeTransition({
    super.key,
    required this.animation,
    required this.child,
    this.initialOffset = const Offset(0, 0.015),
    this.initialScale = 0.985,
    this.alignment = Alignment.center,
  });

  final Animation<double> animation;
  final Widget child;
  final Offset initialOffset;
  final double initialScale;
  final Alignment alignment;

  @override
  Widget build(BuildContext context) {
    final fade = FadeTransition(opacity: animation, child: child);
    final slide = initialOffset == Offset.zero
        ? fade
        : SlideTransition(
            position: Tween<Offset>(
              begin: initialOffset,
              end: Offset.zero,
            ).animate(animation),
            child: fade,
          );

    if (initialScale == 1) return slide;

    return ScaleTransition(
      scale: Tween<double>(begin: initialScale, end: 1).animate(animation),
      alignment: alignment,
      child: slide,
    );
  }
}
