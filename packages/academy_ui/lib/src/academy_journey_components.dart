import 'package:flutter/cupertino.dart';

import 'academy_components.dart';
import 'academy_controls.dart';
import 'academy_navigation.dart';
import 'academy_sf_image.dart';
import 'academy_theme.dart';

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
         trailing: _CompletionMark(completed: item.completed),
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

class _CompletionMark extends StatelessWidget {
  const _CompletionMark({required this.completed});
  final bool completed;
  @override
  Widget build(BuildContext context) {
    final p = AcademyTheme.of(context).colorScheme;
    return Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: completed ? p.primary : null,
        border: Border.all(
          color: completed ? p.primary : p.outline,
          width: 1.5,
        ),
      ),
      child: completed
          ? Center(
              child: AcademySfIcon(
                AcademySymbols.checkmark,
                size: 13,
                color: p.onPrimary,
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
  }) : assert(completed >= 0),
       assert(total >= 0),
       assert(completed <= total);
  final String title;
  final int completed, total;
  @override
  Widget build(BuildContext context) {
    final theme = AcademyTheme.of(context);
    return Semantics(
      label: title,
      value: '$completed из $total',
      excludeSemantics: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(title, style: theme.textTheme.titleLarge),
          const SizedBox(height: 6),
          Text(
            total == 0 ? 'Нет пунктов' : 'Выполнено $completed из $total',
            style: theme.textTheme.bodySmall.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(3),
            child: SizedBox(
              height: 6,
              child: ColoredBox(
                color: theme.colorScheme.surfaceContainerHighest,
                child: Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: FractionallySizedBox(
                    widthFactor: total == 0 ? 0 : completed / total,
                    child: ColoredBox(
                      color: theme.colorScheme.primary,
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
    this.completionLabel = 'Завершено',
  }) : assert(step >= 1),
       assert(step <= total);
  final String title, description;
  final String completionLabel;
  final int step, total;
  final bool completed;
  final List<Widget> content;
  final bool framed;
  final String? nextLabel;
  final Widget? descriptionContent;
  final VoidCallback? onNext, onPrevious;
  @override
  Widget build(BuildContext context) {
    final theme = AcademyTheme.of(context);
    final body = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          completed ? completionLabel : 'Шаг $step из $total',
          style: theme.textTheme.bodySmall.copyWith(
            color: theme.colorScheme.primary,
          ),
        ),
        const SizedBox(height: 8),
        Semantics(
          header: true,
          child: Text(title, style: theme.textTheme.titleLarge),
        ),
        const SizedBox(height: 12),
        descriptionContent ??
            Text(description, style: theme.textTheme.bodyLarge),
        ...content,
        const SizedBox(height: 24),
        AcademyButton(
          label:
              nextLabel ??
              (completed
                  ? 'Готово'
                  : step == total
                  ? 'Завершить'
                  : 'Следующий шаг'),
          onPressed: completed ? null : onNext,
        ),
        if (onPrevious != null) ...[
          const SizedBox(height: 8),
          AcademyTextButton(label: 'Предыдущий шаг', onPressed: onPrevious),
        ],
      ],
    );
    return framed ? AcademySurface(child: body) : body;
  }
}
