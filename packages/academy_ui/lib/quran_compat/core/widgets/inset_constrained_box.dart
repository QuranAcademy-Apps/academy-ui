import 'dart:math' as math;

import 'package:cupertino_ui/cupertino_ui.dart';

class InsetConstrainedBox extends StatelessWidget {
  const InsetConstrainedBox({
    super.key,
    required this.child,
    this.insets = const EdgeInsetsDirectional.symmetric(horizontal: 24),
    this.maxWidth = double.infinity,
    this.alignment = AlignmentDirectional.topCenter,
  });

  final Widget child;
  final EdgeInsetsGeometry insets;
  final double maxWidth;
  final AlignmentGeometry alignment;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final resolvedInsets = insets.resolve(Directionality.of(context));
        final mediaWidth = MediaQuery.sizeOf(context).width;
        final parentWidth = constraints.maxWidth.isFinite
            ? math.min(constraints.maxWidth, mediaWidth)
            : mediaWidth;
        final availableWidth = math.max(
          0.0,
          parentWidth - resolvedInsets.horizontal,
        );
        final effectiveWidth = math.min(availableWidth, maxWidth);

        return Padding(
          padding: insets,
          child: Align(
            alignment: alignment,
            child: SizedBox(width: effectiveWidth, child: child),
          ),
        );
      },
    );
  }
}
