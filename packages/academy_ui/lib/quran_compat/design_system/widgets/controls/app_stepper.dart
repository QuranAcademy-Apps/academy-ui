import 'package:academy_ui/academy_ui.dart' show AcademyActionStepper;
import 'package:cupertino_ui/cupertino_ui.dart';

import '../../../theme/app_colors.dart';

/// Minus/plus stepper for settings rows, tinted with the primary text color.
class AppStepper extends StatelessWidget {
  const AppStepper({
    super.key,
    required this.onDecrease,
    required this.onIncrease,
    this.centered = false,
  });

  final VoidCallback? onDecrease;
  final VoidCallback? onIncrease;
  final bool centered;

  @override
  Widget build(BuildContext context) => AcademyActionStepper(
    onDecrease: onDecrease,
    onIncrease: onIncrease,
    centered: centered,
    color: context.appColors.textPrimary,
  );
}
