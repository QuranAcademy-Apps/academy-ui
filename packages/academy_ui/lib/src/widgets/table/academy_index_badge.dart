import 'package:flutter/cupertino.dart';

import '../../theme/academy_theme.dart';

/// Rounded-square ordinal of a list row (Quran surah number style). Put it in
/// `AcademyRow.leading`.
class AcademyIndexBadge extends StatelessWidget {
  const AcademyIndexBadge(this.index, {super.key});
  final int index;

  @override
  Widget build(BuildContext context) {
    final theme = AcademyTheme.of(context);
    return MediaQuery.withClampedTextScaling(
      maxScaleFactor: 1.3,
      child: Container(
        constraints: BoxConstraints(
          minWidth: AcademyTheme.of(context).sizes.rowIconExtent,
          minHeight: AcademyTheme.of(context).sizes.rowIconExtent,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 4),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(theme.radii.rowIcon),
        ),
        // A row's leading column is narrower than three digits: the number
        // shrinks to fit rather than breaking onto a second line.
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            '$index',
            maxLines: 1,
            softWrap: false,
            style: theme.textTheme.bodyStrong.copyWith(
              fontSize: index > 99 ? 13 : 15,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
        ),
      ),
    );
  }
}
