import 'package:flutter/cupertino.dart';

import '../../theme/academy_theme.dart';

/// Standard 51 x 31 Cupertino switch for rows and forms.
///
/// [activeTrackColor] defaults to the accent fill of the active theme.
class AcademySwitch extends StatelessWidget {
  const AcademySwitch({
    super.key,
    required this.value,
    required this.onChanged,
    this.activeTrackColor,
  });

  final bool value;
  final ValueChanged<bool>? onChanged;
  final Color? activeTrackColor;

  @override
  Widget build(BuildContext context) => SizedBox(
    width: 51,
    height: 31,
    child: Center(
      child: CupertinoSwitch(
        value: value,
        onChanged: onChanged,
        activeTrackColor:
            activeTrackColor ?? AcademyTheme.of(context).colorScheme.accentFill,
      ),
    ),
  );
}
