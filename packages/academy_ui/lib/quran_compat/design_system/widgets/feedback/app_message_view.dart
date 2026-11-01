import 'package:academy_ui/academy_ui.dart' show AcademyMessageView;
import 'package:cupertino_ui/cupertino_ui.dart';

import '../../../theme/app_colors.dart';

/// Centered secondary-text state for empty or failed content without an action.
class AppMessageView extends StatelessWidget {
  const AppMessageView({
    super.key,
    required this.message,
    this.padding = const EdgeInsets.symmetric(horizontal: 32),
  });

  final String message;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) => AcademyMessageView(
    message: message,
    messageColor: context.appColors.textSecondary,
    padding: padding,
  );
}
