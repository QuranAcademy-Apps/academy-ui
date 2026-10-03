import 'package:cupertino_ui/cupertino_ui.dart' hide CupertinoButton;
import 'package:flutter/cupertino.dart' show CupertinoButton;

import '../../foundation/interaction/academy_interaction.dart';
import '../../foundation/motion/academy_press_effect.dart';

import '../icon/academy_sf_image.dart';
import '../../theme/academy_theme.dart';
import '../modal/modal_sheet_corner_mask.dart';

/// Quran ReaderQuickSettingsSquareButton: 68px utility control with rounded corners.
class AcademySettingsSquareButton extends StatelessWidget {
  const AcademySettingsSquareButton({
    super.key,
    required this.icon,
    required this.label,
    required this.onPressed,
    this.onLongPress,
    this.cornerRadius,
    this.foreground,
  });
  final IconData icon;
  final String label;
  final VoidCallback? onPressed, onLongPress;
  final double? cornerRadius;
  final Color? foreground;
  @override
  Widget build(BuildContext context) => AcademyActionSemantics(
    label: label,
    enabled: onPressed != null,
    child: AcademyPressEffect(
      enabled: onPressed != null,
      child: CupertinoButton(
        onLongPress: onPressed == null ? null : onLongPress,
        padding: EdgeInsets.zero,
        onPressed: onPressed,
        child: ModalSheetMaskedFill(
          color: AcademyTheme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(
            cornerRadius ?? AcademyTheme.of(context).radii.settingsButton,
          ),
          child: SizedBox.square(
            dimension: 68,
            child: Center(
              child: AcademySfIcon(
                icon,
                size: 29,
                color: onPressed == null
                    ? AcademyTheme.of(context).colorScheme.onSurfaceVariant
                    : foreground ??
                          AcademyTheme.of(context).colorScheme.primary,
              ),
            ),
          ),
        ),
      ),
    ),
  );
}
