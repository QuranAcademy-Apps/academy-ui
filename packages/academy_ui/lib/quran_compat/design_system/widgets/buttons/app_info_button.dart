import 'package:academy_ui/academy_ui.dart' show AcademyInfoButton;
import 'package:cupertino_ui/cupertino_ui.dart';

import '../../../theme/app_colors.dart';

class AppInfoButton extends StatelessWidget {
  const AppInfoButton({
    required this.onPressed,
    this.iconSize = 18,
    this.color,
    super.key,
  });

  final VoidCallback onPressed;
  final double iconSize;
  final Color? color;

  @override
  Widget build(BuildContext context) => AcademyInfoButton.inline(
    onPressed: onPressed,
    iconSize: iconSize,
    color:
        color ??
        context.appColors.actionAccent ??
        context.appColors.iconPrimary,
  );
}
