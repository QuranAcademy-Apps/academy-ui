import 'package:cupertino_ui/cupertino_ui.dart';

import '../../theme/academy_theme.dart';

/// The outline of every field-shaped control: text inputs, floating fields and
/// select triggers. Keeping the policy here makes Increase Contrast, focus and
/// client palettes behave the same across them.
Color academyFieldBorderColor(
  BuildContext context, {
  bool enabled = true,
  bool focused = false,
  bool invalid = false,
  bool bordered = true,
}) {
  final colors = AcademyTheme.of(context).colorScheme;
  final highContrast = MediaQuery.highContrastOf(context);
  if (invalid) return colors.textFieldErrorForeground;
  if (!enabled) {
    return highContrast
        ? AcademyContrast.foreground(
            colors.textFieldDisabledBorder,
            colors.textFieldDisabledBackground,
            minimum: 3,
          )
        : colors.textFieldDisabledBorder;
  }
  if (focused) return colors.textFieldFocusBorder;
  if (highContrast) return colors.textFieldControlBorder;
  return bordered ? colors.textFieldBorder : const Color(0x00000000);
}

/// The fill of every field-shaped control.
Color academyFieldFillColor(BuildContext context, {bool enabled = true}) {
  final colors = AcademyTheme.of(context).colorScheme;
  return enabled
      ? colors.textFieldBackground
      : colors.textFieldDisabledBackground;
}
