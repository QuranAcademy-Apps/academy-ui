import 'package:academy_ui/academy_ui.dart' show AcademySymbols;
import 'package:cupertino_ui/cupertino_ui.dart';

import '../../../core/widgets/app_sf_icon.dart';
import '../../../l10n/quran_compat_strings.dart';
import '../../../theme/app_colors.dart';

/// Compact close control shared by dense modal headers.
class AppCompactCloseButton extends StatelessWidget {
  const AppCompactCloseButton({super.key, required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: QuranCompatStrings.of(context).close,
      child: CupertinoButton(
        padding: EdgeInsets.zero,
        minimumSize: const Size(28, 28),
        onPressed: onPressed,
        child: Container(
          width: 28,
          height: 28,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: context.appColors.fillPrimary,
            shape: BoxShape.circle,
          ),
          child: AppSfIcon(
            AcademySymbols.close,
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: context.appColors.iconPrimary,
          ),
        ),
      ),
    );
  }
}
