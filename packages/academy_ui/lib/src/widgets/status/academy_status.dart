import 'package:flutter/cupertino.dart';

import '../../theme/academy_theme.dart';

class AcademyStatus extends StatelessWidget {
  const AcademyStatus({
    super.key,
    required this.label,
    this.tone = AcademyTone.neutral,
  });
  final String label;
  final AcademyTone tone;
  @override
  Widget build(BuildContext context) {
    final palette = AcademyTheme.of(context).colorScheme;
    return Container(
      padding: AcademyTheme.of(context).paddings.status,
      decoration: BoxDecoration(
        color: palette.toneContainer(tone),
        borderRadius: BorderRadius.circular(
          AcademyTheme.of(context).radii.status,
        ),
      ),
      child: Text(
        label,
        style: AcademyTheme.of(context).textTheme.status
            .copyWith(color: palette.toneForeground(tone)),
      ),
    );
  }
}
