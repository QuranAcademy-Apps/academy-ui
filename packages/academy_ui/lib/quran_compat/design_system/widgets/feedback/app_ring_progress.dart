import 'package:academy_ui/academy_ui.dart' show AcademyRingProgress;
import 'package:cupertino_ui/cupertino_ui.dart';

import '../../../theme/app_colors.dart';

/// Ring that fills its parent, drawn in the palette's stroke color.
class AppRingProgress extends StatelessWidget {
  const AppRingProgress({super.key, required this.progress});

  final double progress;

  @override
  Widget build(BuildContext context) => AcademyRingProgress.fill(
    value: progress,
    color: context.appColors.strokePrimary,
  );
}
