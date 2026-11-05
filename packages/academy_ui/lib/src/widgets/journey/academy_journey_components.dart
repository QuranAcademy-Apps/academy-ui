import '../../foundation/localizations/academy_localizations.dart';

import 'package:flutter/cupertino.dart';

import '../button/academy_button.dart';
import '../surface/academy_surface.dart';
import '../table/academy_grouped_table.dart';
import '../table/academy_row.dart';
import '../icon/academy_sf_image.dart';
import '../../theme/academy_theme.dart';

class AcademyChecklistEntry {
  const AcademyChecklistEntry({
    required this.id,
    required this.title,
    this.subtitle,
    this.completed = false,
  });
  final String id, title;
  final String? subtitle;
  final bool completed;
}

/// Controlled checklist: the feature owns persistence and completion rules.
class AcademyChecklist extends StatelessWidget {
  const AcademyChecklist({
    super.key,
    required this.title,
    required this.items,
    required this.onChanged,
    this.showProgress = true,
  });
  final String title;
  final List<AcademyChecklistEntry> items;
  final void Function(String id, bool completed) onChanged;
  final bool showProgress;
  @override
  Widget build(BuildContext context) {
    final completed = items.where((item) => item.completed).length;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (showProgress)
          AcademyJourneyProgress(
            title: title,
            completed: completed,
            total: items.length,
          ),
        if (showProgress) const SizedBox(height: 16),
        AcademyGroupedTable(
          sections: [
            AcademyTableSection(
              rows: [
                for (final item in items)
                  _ChecklistRow(
                    item: item,
                    onToggle: () => onChanged(item.id, !item.completed),
                  ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}

class _ChecklistRow extends AcademyRow {
  _ChecklistRow({
    required AcademyChecklistEntry item,
    required VoidCallback onToggle,
  }) : _item = item,
       _onToggle = onToggle,
       super(
         title: item.title,
         subtitle: item.subtitle,
         onPressed: onToggle,
         trailing: AcademyCompletionMark(completed: item.completed),
       );
  final AcademyChecklistEntry _item;
  final VoidCallback _onToggle;
  @override
  Widget build(BuildContext context) => Semantics(
    checked: _item.completed,
    label: _item.title,
    hint: _item.subtitle,
    onTap: _onToggle,
    excludeSemantics: true,
    child: super.build(context),
  );
}

/// Round completion indicator of checklist rows.
class AcademyCompletionMark extends StatelessWidget {
  const AcademyCompletionMark({super.key, required this.completed});
  final bool completed;
  @override
  Widget build(BuildContext context) {
    final p = AcademyTheme.of(context).colorScheme;
    return Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: completed ? p.accentFill : null,
        border: Border.all(
          color: completed ? p.accentFill : p.outline,
          width: 1.5,
        ),
      ),
      child: completed
          ? Center(
              child: AcademySfIcon(
                AcademyTheme.of(context).icons.checkmark,
                size: 13,
                color: p.onAccentFill,
              ),
            )
          : null,
    );
  }
}

class AcademyJourneyProgress extends StatelessWidget {
  const AcademyJourneyProgress({
    super.key,
    required this.title,
    required this.completed,
    required this.total,
    this.showTitle = true,
    this.labelStyle,
    this.barHeight = 6,
    this.barSpacing = AcademyTokens.inlineGap,
    this.trackColor,
    this.fillColor,
  }) : assert(completed >= 0),
       assert(total >= 0),
       assert(completed <= total);
  final String title;
  final int completed, total;

  /// False keeps [title] for accessibility only (a section header shows it).
  final bool showTitle;

  /// Default: secondary [AcademyTypography.bodySmall].
  final TextStyle? labelStyle;
  final double barHeight, barSpacing;

  /// Defaults: [AcademyColors.surfaceContainerHighest] and
  /// [AcademyColors.primary].
  final Color? trackColor, fillColor;
  @override
  Widget build(BuildContext context) {
    final theme = AcademyTheme.of(context);
    return Semantics(
      label: title,
      value: AcademyLocalizations.of(context).count(completed, total),
      excludeSemantics: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (showTitle) ...[
            Text(title, style: theme.textTheme.titleLarge),
            const SizedBox(height: 6),
          ],
          Text(
            total == 0
                ? AcademyLocalizations.of(context).emptyProgress
                : AcademyLocalizations.of(context)
                      .completedCount(completed, total),
            style:
                labelStyle ??
                theme.textTheme.bodySmall.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
          ),
          SizedBox(height: barSpacing),
          ClipRRect(
            borderRadius: BorderRadius.circular(
              AcademyTheme.of(context).radii.progress,
            ),
            child: SizedBox(
              height: barHeight,
              child: ColoredBox(
                color: trackColor ?? theme.colorScheme.surfaceContainerHighest,
                child: Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: FractionallySizedBox(
                    widthFactor: total == 0 ? 0 : completed / total,
                    child: ColoredBox(
                      color: fillColor ?? theme.colorScheme.primary,
                      child: const SizedBox.expand(),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Content and ritual wording must be supplied by the approved guide feature.
class AcademyGuideStep extends StatelessWidget {
  const AcademyGuideStep({
    super.key,
    required this.title,
    required this.description,
    required this.step,
    required this.total,
    required this.onNext,
    this.onPrevious,
    this.completed = false,
    this.content = const [],
    this.framed = true,
    this.nextLabel,
    this.descriptionContent,
    this.completionLabel,
    this.onDone,
    this.readOnly = false,
  }) : assert(step >= 1),
       assert(step <= total);
  final String title, description;
  final String? completionLabel;
  final int step, total;
  final bool completed, readOnly;
  final List<Widget> content;
  final bool framed;
  final String? nextLabel;
  final Widget? descriptionContent;
  final VoidCallback? onNext, onPrevious, onDone;
  @override
  Widget build(BuildContext context) {
    final theme = AcademyTheme.of(context);
    final body = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          completed
              ? (completionLabel ?? AcademyLocalizations.of(context).completed)
              : AcademyLocalizations.of(context).step(step, total),
          style: theme.textTheme.bodySmall.copyWith(
            color: theme.colorScheme.primary,
          ),
        ),
        const SizedBox(height: 8),
        Semantics(
          header: true,
          child: Text(title, style: theme.textTheme.titleLarge),
        ),
        const SizedBox(height: AcademyTokens.inlineGap),
        descriptionContent ??
            Text(description, style: theme.textTheme.bodyLarge),
        ...content,
        const SizedBox(height: 24),
        if (!readOnly && (!completed || onDone != null || onNext != null))
          AcademyButton(
            label:
                nextLabel ??
                (completed
                    ? AcademyLocalizations.of(context).done
                    : step == total
                    ? AcademyLocalizations.of(context).finish
                    : AcademyLocalizations.of(context).nextStep),
            onPressed: completed ? (onDone ?? onNext) : onNext,
          ),
        if (!readOnly && onPrevious != null) ...[
          const SizedBox(height: 8),
          AcademyTextButton(
            label: AcademyLocalizations.of(context).previousStep,
            onPressed: onPrevious,
          ),
        ],
      ],
    );
    return framed ? AcademySurface(child: body) : body;
  }
}
