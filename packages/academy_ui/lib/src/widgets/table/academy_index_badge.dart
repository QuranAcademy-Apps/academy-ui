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
        constraints: const BoxConstraints(
          minWidth: AcademyTokens.tableIconExtent,
          minHeight: AcademyTokens.tableIconExtent,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 4),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(theme.radii.rowIcon),
        ),
        child: Text(
          '$index',
          style: theme.textTheme.bodyStrong.copyWith(
            fontSize: index > 99 ? 13 : 15,
            fontFeatures: const [FontFeature.tabularFigures()],
          ),
        ),
      ),
    );
  }
}
