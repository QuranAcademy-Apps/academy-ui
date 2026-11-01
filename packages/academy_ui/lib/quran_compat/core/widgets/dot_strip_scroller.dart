import 'package:academy_ui/academy_ui.dart' show AcademyDotStripScroller;
import 'package:cupertino_ui/cupertino_ui.dart';

import '../../theme/app_colors.dart';

/// Narrow dot strip with quantized vertical-drag scrolling; the dots follow the
/// palette's primary icon color. See [AcademyDotStripScroller].
class DotStripScroller extends StatelessWidget {
  const DotStripScroller({
    super.key,
    required this.steps,
    required this.onProgress,
    this.gestureWidth = stripWidth,
    this.fillAvailableHeight = false,
    this.dotsTipBuilder,
  });

  final int steps;
  final ValueChanged<double> onProgress;
  final double gestureWidth;
  final bool fillAvailableHeight;
  final Widget Function(BuildContext context, Widget dots)? dotsTipBuilder;

  static const double stripWidth = AcademyDotStripScroller.stripWidth;

  @override
  Widget build(BuildContext context) => AcademyDotStripScroller(
    steps: steps,
    onProgress: onProgress,
    gestureWidth: gestureWidth,
    fillAvailableHeight: fillAvailableHeight,
    dotsTipBuilder: dotsTipBuilder,
    dotColor:
        AppColorsProvider.maybeOf(context)?.iconPrimary ??
        CupertinoColors.label,
  );
}
