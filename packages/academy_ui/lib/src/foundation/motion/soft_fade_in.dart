import 'package:flutter/widgets.dart';

// Ported from Yalla's motion/soft_fade_in.dart (2026-11-02).
/// Shared timing for content that becomes available after loading.
abstract final class AcademyContentMotion {
  static const duration = Duration(milliseconds: 300);
  static const curve = Cubic(.23, 1, .32, 1);
}

/// Reveals new content once, without replaying on data or form rebuilds.
/// Does not retain an outgoing copy (in particular, private account data).
class SoftFadeIn extends StatefulWidget {
  const SoftFadeIn({super.key, required this.child, this.revealKey});

  final Widget child;

  /// Optional readiness identity when the loaded child keeps the same type/key.
  final Object? revealKey;

  @override
  State<SoftFadeIn> createState() => _SoftFadeInState();
}

/// Uses the same reveal lifetime for content in the primary sliver viewport.
/// A distinct widget type prevents box/sliver state reuse across render protocols.
class SliverSoftFadeIn extends SoftFadeIn {
  const SliverSoftFadeIn({super.key, required super.child, super.revealKey});
}

class _SoftFadeInState extends State<SoftFadeIn>
    with SingleTickerProviderStateMixin {
  late final _controller = AnimationController(
    vsync: this,
    duration: AcademyContentMotion.duration,
  );
  late final _opacity = CurvedAnimation(
    parent: _controller,
    curve: AcademyContentMotion.curve,
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.disableAnimationsOf(context)) {
      _controller.value = 1;
    } else if (_controller.status == AnimationStatus.dismissed) {
      _controller.forward();
    }
  }

  @override
  void didUpdateWidget(SoftFadeIn oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.revealKey != widget.revealKey ||
        !Widget.canUpdate(oldWidget.child, widget.child)) {
      if (MediaQuery.disableAnimationsOf(context)) {
        _controller.value = 1;
      } else {
        _controller.forward(from: 0);
      }
    }
  }

  @override
  void dispose() {
    _opacity.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget is SliverSoftFadeIn
      ? SliverFadeTransition(opacity: _opacity, sliver: widget.child)
      : FadeTransition(opacity: _opacity, child: widget.child);
}

/// Keeps keyed content identity across loading, insertion and list updates.
List<Widget> softFadeChildren(List<Widget> children) => [
  for (final (index, child) in children.indexed)
    SoftFadeIn(
      key: ValueKey(child.key ?? (child.runtimeType, index)),
      child: child,
    ),
];
