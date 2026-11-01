import 'package:flutter/cupertino.dart';

import '../../theme/academy_theme.dart';
import '../icon/academy_sf_image.dart';
import 'academy_grouped_table.dart';
import 'academy_row.dart';

/// One grouped table that folds: the header row (title, caption and a chevron
/// that turns down) shows or hides [rows] beneath it in the same card. The
/// header has no icon, so it reads as the group's title and not as another
/// row. The table grows with the same motion as other layout changes.
class AcademyDisclosureTable extends StatelessWidget {
  const AcademyDisclosureTable({
    super.key,
    required this.title,
    required this.expanded,
    required this.onToggle,
    required this.rows,
    this.subtitle,
  });

  final String title;
  final String? subtitle;
  final bool expanded;
  final VoidCallback onToggle;

  /// Shown below the header while [expanded].
  final List<Widget> rows;

  @override
  Widget build(BuildContext context) {
    final theme = AcademyTheme.of(context);
    final duration = MediaQuery.disableAnimationsOf(context)
        ? Duration.zero
        : AcademyTokens.layoutMotion;
    final table = AcademyGroupedTable(
      sections: [
        AcademyTableSection(
          rows: [
            Semantics(
              expanded: expanded,
              child: AcademyRow(
                title: title,
                subtitle: subtitle,
                showChevron: false,
                trailing: AnimatedRotation(
                  turns: expanded ? .25 : 0,
                  duration: duration,
                  curve: Curves.easeInOut,
                  child: AcademySfIcon(
                    AcademySymbols.forward,
                    size: 16,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                onPressed: onToggle,
              ),
            ),
            if (expanded) ...rows,
          ],
        ),
      ],
    );
    // A zero-duration AnimatedSize asserts, so reduced motion skips it.
    return duration == Duration.zero
        ? table
        : AnimatedSize(
            duration: duration,
            curve: Curves.easeInOut,
            alignment: Alignment.topCenter,
            child: table,
          );
  }
}
