import 'package:flutter/cupertino.dart';

import '../../theme/academy_theme.dart';

/// Adapted from Quran DotStripScroller: one dot per page; the current page is
/// a pill, completed pages use the accent. Long strips scroll and keep the
/// current dot centered; the edges fade instead of clipping.
class AcademyPageDots extends StatefulWidget {
  const AcademyPageDots({
    super.key,
    required this.count,
    required this.index,
    this.isCompleted,
    this.onSelected,
    this.semanticsLabel,
  }) : assert(count >= 0),
       assert(count == 0 || (index >= 0 && index < count));
  final int count, index;
  final bool Function(int index)? isCompleted;
  final ValueChanged<int>? onSelected;

  /// For example «Зикр 3 из 17».
  final String? semanticsLabel;

  static const slot = 12.0;
  static const height = 20.0;

  @override
  State<AcademyPageDots> createState() => _AcademyPageDotsState();
}

class _AcademyPageDotsState extends State<AcademyPageDots> {
  final _controller = ScrollController();
  double _viewport = 0;

  @override
  void didUpdateWidget(AcademyPageDots oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.index != widget.index || oldWidget.count != widget.count) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _center(true));
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  double get _extent => widget.count * AcademyPageDots.slot + 8;

  void _center(bool animate) {
    if (!mounted || !_controller.hasClients) return;
    final position = _controller.position;
    final target =
        (4 +
                widget.index * AcademyPageDots.slot +
                AcademyPageDots.slot / 2 -
                _viewport / 2)
            .clamp(0.0, position.maxScrollExtent);
    if (!animate || MediaQuery.disableAnimationsOf(context)) {
      _controller.jumpTo(target);
    } else {
      _controller.animateTo(
        target,
        duration: AcademyTokens.selectionMotion,
        curve: Curves.easeOutCubic,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = AcademyTheme.of(context);
    final accent = CupertinoTheme.of(context).primaryColor;
    final strip = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(width: 4),
        for (var i = 0; i < widget.count; i++)
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: widget.onSelected == null
                ? null
                : () => widget.onSelected!(i),
            child: SizedBox(
              width: AcademyPageDots.slot,
              height: AcademyPageDots.height,
              child: Center(
                child: _Dot(
                  current: i == widget.index,
                  color: i == widget.index
                      ? theme.colorScheme.onSurface
                      : widget.isCompleted?.call(i) ?? false
                      ? accent
                      : theme.colorScheme.onSurfaceVariant.withValues(
                          alpha: .35,
                        ),
                ),
              ),
            ),
          ),
        const SizedBox(width: 4),
      ],
    );
    return Semantics(
      label: widget.semanticsLabel,
      excludeSemantics: true,
      child: SizedBox(
        height: AcademyPageDots.height,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final overflow = _extent > constraints.maxWidth;
            if (_viewport != constraints.maxWidth) {
              _viewport = constraints.maxWidth;
              WidgetsBinding.instance.addPostFrameCallback(
                (_) => _center(false),
              );
            }
            final scroller = SingleChildScrollView(
              controller: _controller,
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              child: strip,
            );
            if (!overflow) return Center(child: strip);
            return ShaderMask(
              blendMode: BlendMode.dstIn,
              shaderCallback: (rect) => const LinearGradient(
                colors: [
                  Color(0x00000000),
                  Color(0xFF000000),
                  Color(0xFF000000),
                  Color(0x00000000),
                ],
                stops: [0, .1, .9, 1],
              ).createShader(rect),
              child: scroller,
            );
          },
        ),
      ),
    );
  }
}

class _Dot extends StatelessWidget {
  const _Dot({required this.current, required this.color});
  final bool current;
  final Color color;
  @override
  Widget build(BuildContext context) => AnimatedContainer(
    duration: MediaQuery.disableAnimationsOf(context)
        ? Duration.zero
        : AcademyTokens.motion,
    curve: Curves.easeOut,
    width: current ? 8 : 6,
    height: current ? 8 : 6,
    decoration: BoxDecoration(color: color, shape: BoxShape.circle),
  );
}
