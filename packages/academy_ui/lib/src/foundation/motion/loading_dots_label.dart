// Adapted from quran_flutter/lib/core/widgets/loading_dots_label.dart.
import 'dart:async';

import 'package:flutter/widgets.dart';

/// Renders [text] followed by animated trailing dots that cycle ".", "..", "..."
/// about twice a second.
///
/// The dots live in a fixed-width slot so a centered or min-width parent layout
/// does not shift as the dot count changes.
class LoadingDotsLabel extends StatefulWidget {
  const LoadingDotsLabel({
    super.key,
    required this.text,
    this.style,
    this.maxDots = 3,
    this.dotsWidth = 16,
  });

  final String text;
  final TextStyle? style;
  final int maxDots;
  final double dotsWidth;

  @override
  State<LoadingDotsLabel> createState() => _LoadingDotsLabelState();
}

class _LoadingDotsLabelState extends State<LoadingDotsLabel> {
  static const _interval = Duration(milliseconds: 450);
  Timer? _timer;
  int _dotCount = 1;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _timer?.cancel();
    if (MediaQuery.disableAnimationsOf(context)) {
      _dotCount = widget.maxDots;
      return;
    }
    _timer = Timer.periodic(_interval, (_) {
      if (!mounted) return;
      setState(() => _dotCount = _dotCount % widget.maxDots + 1);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Flexible(
          child: Text(
            widget.text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: widget.style,
          ),
        ),
        SizedBox(
          width: widget.dotsWidth,
          child: Text('.' * _dotCount, maxLines: 1, style: widget.style),
        ),
      ],
    );
  }
}
