import 'dart:async';

import 'package:flutter/cupertino.dart';

import '../../foundation/overlay/academy_popover.dart';
import '../../theme/academy_theme.dart';

/// Hover, keyboard-focus and long-press hint. Does not add another tap action.
class AcademyTooltip extends StatefulWidget {
  const AcademyTooltip({
    super.key,
    required this.message,
    required this.child,
    this.waitDuration = const Duration(milliseconds: 500),
    this.placement = AcademyPopoverPlacement.auto,
    this.width = 240,
  });
  final String message;
  final Widget child;
  final Duration waitDuration;
  final AcademyPopoverPlacement placement;
  final double width;
  @override
  State<AcademyTooltip> createState() => _AcademyTooltipState();
}

class _AcademyTooltipState extends State<AcademyTooltip> {
  final _controller = AcademyPopoverController();
  Timer? _timer;
  void _show() {
    _timer?.cancel();
    _timer = Timer(widget.waitDuration, _controller.show);
  }

  void _hide() {
    _timer?.cancel();
    _controller.hide();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AcademyPopover(
    controller: _controller,
    width: widget.width,
    placement: widget.placement,
    maxHeight: 160,
    dismissOnTapOutside: false,
    requestFocus: false,
    contentBuilder: (context, _) => IgnorePointer(
      child: Padding(
        padding: AcademyTheme.of(context).paddings.field,
        child: Text(
          widget.message,
          style: AcademyTheme.of(context).textTheme.bodySmall,
        ),
      ),
    ),
    builder: (context, _) => Semantics(
      tooltip: widget.message,
      child: Focus(
        canRequestFocus: false,
        onFocusChange: (focused) => focused ? _show() : _hide(),
        child: MouseRegion(
          onEnter: (_) => _show(),
          onExit: (_) => _hide(),
          child: GestureDetector(
            excludeFromSemantics: true,
            onLongPress: () {
              _timer?.cancel();
              _controller.show();
              _timer = Timer(const Duration(seconds: 3), _controller.hide);
            },
            child: widget.child,
          ),
        ),
      ),
    ),
  );
}
