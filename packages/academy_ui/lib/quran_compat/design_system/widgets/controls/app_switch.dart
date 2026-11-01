import 'package:academy_ui/academy_ui.dart' show AcademySwitch;
import 'package:cupertino_ui/cupertino_ui.dart';

import '../../../theme/app_colors.dart';

/// Cupertino switch used by GroupedTable accessory rows: [AcademySwitch] with
/// the palette's switch track color (the accent when the palette has none).
class AppSwitch extends StatelessWidget {
  const AppSwitch({super.key, required this.value, required this.onChanged});

  final bool value;
  final ValueChanged<bool>? onChanged;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return AcademySwitch(
      value: value,
      onChanged: onChanged,
      activeTrackColor: colors.switchActive ?? colors.accent,
    );
  }
}
