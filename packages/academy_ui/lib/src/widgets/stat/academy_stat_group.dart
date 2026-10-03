import 'package:flutter/cupertino.dart';

import '../../theme/academy_theme.dart';

@immutable
class AcademyStat {
  const AcademyStat({required this.label, required this.value, this.alignment});
  final String label, value;
  final AcademyStatAlignment? alignment;
}

enum AcademyStatAlignment { start, center, end }

/// Two or three metadata columns; narrow widths and large text use a list.
class AcademyStatGroup extends StatelessWidget {
  AcademyStatGroup({
    super.key,
    required List<AcademyStat> stats,
    this.alignment = AcademyStatAlignment.start,
  }) : assert(stats.length >= 2 && stats.length <= 3),
       stats = List.unmodifiable(stats);
  final List<AcademyStat> stats;
  final AcademyStatAlignment alignment;
  @override
  Widget build(BuildContext context) {
    final theme = AcademyTheme.of(context);
    TextAlign textAlign(AcademyStat stat) =>
        switch (stat.alignment ?? alignment) {
          AcademyStatAlignment.start => TextAlign.start,
          AcademyStatAlignment.center => TextAlign.center,
          AcademyStatAlignment.end => TextAlign.end,
        };
    Widget cell(AcademyStat stat, {bool vertical = false}) => Semantics(
      container: true,
      excludeSemantics: true,
      label: stat.label,
      value: stat.value,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            stat.label,
            textAlign: vertical ? TextAlign.start : textAlign(stat),
            style: theme.textTheme.bodyMedium.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: AcademyTokens.labelGap),
          Text(
            stat.value,
            textAlign: vertical ? TextAlign.start : textAlign(stat),
            style: theme.textTheme.labelLarge,
          ),
        ],
      ),
    );
    return LayoutBuilder(
      builder: (context, constraints) {
        final vertical =
            MediaQuery.textScalerOf(context).scale(1) >=
                AcademyTokens.adaptiveTextScale ||
            constraints.maxWidth < AcademyTokens.metadataHorizontalWidth;
        if (vertical) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (var i = 0; i < stats.length; i++) ...[
                if (i > 0) const SizedBox(height: AcademyTokens.inlineGap),
                cell(stats[i], vertical: true),
              ],
            ],
          );
        }
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (var i = 0; i < stats.length; i++) ...[
              if (i > 0) const SizedBox(width: AcademyTokens.inlineGap),
              Expanded(child: cell(stats[i])),
            ],
          ],
        );
      },
    );
  }
}
