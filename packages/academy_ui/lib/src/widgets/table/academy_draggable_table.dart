import 'package:flutter/semantics.dart';
import 'package:flutter/cupertino.dart';

import 'academy_table.dart';
import '../../foundation/interaction/academy_interaction.dart';
import '../../foundation/localizations/academy_localizations.dart';
import '../menu/academy_menu_anchor.dart';
import '../menu/academy_menu_item.dart';
import '../icon/academy_sf_image.dart';
import '../../theme/academy_theme.dart';

/// Stable item identity and source location; no domain services are referenced.
class AcademyTableDragData<T extends Object> {
  const AcademyTableDragData({
    required this.item,
    required this.itemId,
    required this.sectionId,
    required this.index,
  });
  final T item;
  final Object itemId, sectionId;
  final int index;
}

class AcademyDragHandle extends StatelessWidget {
  const AcademyDragHandle({
    super.key,
    this.enabled = true,
    this.label,
    this.height = 44,
  });
  final bool enabled;
  final String? label;
  final double height;
  @override
  Widget build(BuildContext context) => Semantics(
    label: label ?? AcademyLocalizations.of(context).drag,
    enabled: enabled,
    child: SizedBox(
      width: 49,
      height: height,
      child: Row(
        children: [
          Container(
            width: 1,
            height: 32,
            color: AcademyTheme.of(context).colorScheme.outlineVariant,
          ),
          const SizedBox(width: 4),
          Transform.translate(
            offset: Offset(
              Directionality.of(context) == TextDirection.ltr ? 9 : -9,
              0,
            ),
            child: AcademySfIcon(
              AcademyTheme.of(context).icons.dragHandle,
              size: AcademyTheme.of(context).sizes.controlIcon,
              boxSize: 44,
              color: AcademyTheme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    ),
  );
}

/// A destination exposed by the host alongside pointer drop targets.
/// [itemCount] is the insertion index for appending to another section.
class AcademyTableMoveTarget<T extends Object> {
  const AcademyTableMoveTarget({
    required this.sectionId,
    required this.label,
    required this.itemCount,
    this.enabled = true,
    this.accepts,
  }) : assert(itemCount >= 0);
  final Object sectionId;
  final String label;
  final int itemCount;
  final bool enabled;
  final bool Function(AcademyTableDragData<T>)? accepts;
}

/// Controlled reorder / cross-section move. Only the handle starts dragging.
/// onMove receives an index AFTER removal from the source section.
class AcademyDraggableTableSection<T extends Object> extends StatelessWidget {
  const AcademyDraggableTableSection({
    super.key,
    required this.sectionId,
    required this.items,
    required this.itemId,
    required this.rowBuilder,
    required this.onMove,
    this.header,
    this.footer,
    this.enabled = true,
    this.emptyLabel,
    this.labelForItem,
    this.moveTargets = const [],
    this.accepts,
    this.onRemove,
    this.editing = false,
    this.feedbackWidth,
  });
  final Object sectionId;
  final List<T> items;
  final Object Function(T item) itemId;
  final Widget Function(BuildContext context, T item, Widget accessory)
  rowBuilder;
  final void Function(
    AcademyTableDragData<T> source,
    Object destinationSection,
    int destinationIndex,
  )
  onMove;
  final Widget? header, footer;
  final bool enabled, editing;
  final String? emptyLabel;
  final String Function(T)? labelForItem;
  final List<AcademyTableMoveTarget<T>> moveTargets;
  final bool Function(AcademyTableDragData<T> source)? accepts;
  final ValueChanged<T>? onRemove;
  final double? feedbackWidth;

  AcademyTableDragData<T> _source(int index) => AcademyTableDragData(
    item: items[index],
    itemId: itemId(items[index]),
    sectionId: sectionId,
    index: index,
  );

  Map<String, VoidCallback> _moves(
    BuildContext context,
    AcademyTableDragData<T> source,
  ) {
    if (!enabled || editing) return const {};
    final strings = AcademyLocalizations.of(context);
    final acceptsLocal = accepts?.call(source) ?? true;
    return {
      if (acceptsLocal && source.index > 0)
        strings.moveUp: () => onMove(source, sectionId, source.index - 1),
      if (acceptsLocal && source.index < items.length - 1)
        strings.moveDown: () => onMove(source, sectionId, source.index + 1),
      for (final target in moveTargets)
        if (target.sectionId != sectionId &&
            target.enabled &&
            (target.accepts?.call(source) ?? true))
          strings.moveTo(target.label): () =>
              onMove(source, target.sectionId, target.itemCount),
    };
  }

  /// [slot] is the place before this target. Dropped on a row of its own section,
  /// a row takes that row's place, whatever their heights. From another section
  /// it goes before or after the row, by the side the preview is on.
  Widget _target(
    BuildContext context,
    int slot,
    Widget child, {
    bool isRow = false,
  }) => Builder(
    builder: (targetContext) => DragTarget<AcademyTableDragData<T>>(
      onWillAcceptWithDetails: (details) =>
          enabled &&
          !editing &&
          (accepts?.call(details.data) ?? true) &&
          !(details.data.sectionId == sectionId &&
              (slot == details.data.index ||
                  (!isRow && slot == details.data.index + 1))),
      onAcceptWithDetails: (details) {
        if (!enabled || editing || !(accepts?.call(details.data) ?? true)) {
          return;
        }
        final source = details.data;
        if (source.sectionId == sectionId) {
          onMove(
            source,
            sectionId,
            !isRow && slot > source.index ? slot - 1 : slot,
          );
          return;
        }
        final box = targetContext.findRenderObject()! as RenderBox;
        final after =
            isRow && details.offset.dy > box.localToGlobal(Offset.zero).dy;
        onMove(source, sectionId, after ? slot + 1 : slot);
      },
      builder: (context, candidates, _) => Stack(
        children: [
          child,
          if (candidates.isNotEmpty)
            Positioned.fill(
              child: IgnorePointer(
                child: ColoredBox(
                  color: AcademyTheme.of(context).colorScheme.menuHighlight,
                ),
              ),
            ),
        ],
      ),
    ),
  );

  @override
  Widget build(BuildContext context) {
    assert(
      items.map(itemId).toSet().length == items.length,
      'Items require unique stable IDs',
    );
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AcademyTableBody(
          padding: EdgeInsets.zero,
          showSeparators: false,
          rows: [
            if (header != null) ...[
              header!,
              const AcademyTableSeparator(start: 0, end: 0),
            ],
            if (items.isEmpty)
              _target(
                context,
                0,
                SizedBox(
                  height: 68,
                  child: Center(
                    child: Text(
                      emptyLabel ?? AcademyLocalizations.of(context).dropHere,
                      style: AcademyTheme.of(context).textTheme.bodySmall,
                    ),
                  ),
                ),
              ),
            for (var i = 0; i < items.length; i++) ...[
              if (i > 0) const AcademyTableSeparator(start: 20, end: 0),
              _target(
                context,
                i,
                _DraggableRow<T>(
                  key: ValueKey(itemId(items[i])),
                  data: _source(i),
                  label:
                      labelForItem?.call(items[i]) ??
                      (items[i] is String
                          ? items[i] as String
                          : AcademyLocalizations.of(context).itemNumber(i + 1)),
                  moves: _moves(context, _source(i)),
                  enabled: enabled,
                  editing: editing,
                  onRemove: onRemove,
                  rowBuilder: rowBuilder,
                  feedbackWidth: feedbackWidth,
                ),
                isRow: true,
              ),
            ],
            if (items.isNotEmpty)
              _target(
                context,
                items.length,
                const SizedBox(height: 8, width: double.infinity),
              ),
          ],
        ),
        ?footer,
      ],
    );
  }
}

class _DraggableRow<T extends Object> extends StatefulWidget {
  const _DraggableRow({
    super.key,
    required this.data,
    required this.label,
    required this.moves,
    required this.enabled,
    required this.editing,
    required this.rowBuilder,
    this.onRemove,
    this.feedbackWidth,
  });
  final AcademyTableDragData<T> data;
  final String label;
  final Map<String, VoidCallback> moves;
  final bool enabled, editing;
  final Widget Function(BuildContext, T, Widget) rowBuilder;
  final ValueChanged<T>? onRemove;
  final double? feedbackWidth;
  @override
  State<_DraggableRow<T>> createState() => _DraggableRowState<T>();
}

class _DraggableRowState<T extends Object> extends State<_DraggableRow<T>> {
  bool _dragging = false;
  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final handle = AcademyDragHandle(
        enabled: widget.enabled,
        label: AcademyLocalizations.of(context).moveItem(widget.label),
      );
      final width = widget.feedbackWidth ?? constraints.maxWidth;
      final theme = AcademyTheme.of(context);
      final direction = Directionality.of(context);
      final accessory = widget.editing
          ? AcademyActionSemantics(
              label: AcademyLocalizations.of(context).removeItem(widget.label),
              enabled: widget.enabled && widget.onRemove != null,
              child: CupertinoButton(
                padding: EdgeInsets.zero,
                minimumSize: const Size(
                  AcademyTokens.target,
                  AcademyTokens.target,
                ),
                onPressed: !widget.enabled || widget.onRemove == null
                    ? null
                    : () => widget.onRemove!(widget.data.item),
                child: AcademySfIcon(
                  AcademyTheme.of(context).icons.trash,
                  color: theme.colorScheme.error,
                  size: AcademyTheme.of(context).sizes.deleteIcon,
                ),
              ),
            )
          : Draggable<AcademyTableDragData<T>>(
              data: widget.data,
              maxSimultaneousDrags: widget.enabled ? 1 : 0,
              dragAnchorStrategy: (draggable, handleContext, position) {
                // Anchor the full-row preview to the row, not the small handle.
                final rowBox = context.findRenderObject()! as RenderBox;
                return rowBox.globalToLocal(position);
              },
              onDragStarted: () {
                AcademyTheme.of(context).interaction.selectionClick();
                setState(() => _dragging = true);
              },
              onDragEnd: (_) {
                if (mounted) setState(() => _dragging = false);
              },
              feedback: InheritedTheme.captureAll(
                context,
                Directionality(
                  textDirection: direction,
                  child: SizedBox(
                    width: width,
                    child: AcademyTableBody(
                      showSeparators: false,
                      rows: [
                        // Built only while dragging, not for every row at rest.
                        Builder(
                          builder: (_) => widget.rowBuilder(
                            context,
                            widget.data.item,
                            const AcademyDragHandle(),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              childWhenDragging: Opacity(opacity: .3, child: handle),
              child: AcademyMenuAnchor(
                consumeOutsideTaps: true,
                menuChildren: [
                  for (final move in widget.moves.entries)
                    AcademyMenuItem(title: move.key, onPressed: move.value),
                ],
                builder: (context, controller, child) => AcademyActionSemantics(
                  label: AcademyLocalizations.of(context)
                      .moveItem(widget.label),
                  enabled: widget.enabled && widget.moves.isNotEmpty,
                  customActions: {
                    for (final move in widget.moves.entries)
                      CustomSemanticsAction(label: move.key): move.value,
                  },
                  child: CupertinoButton(
                    padding: EdgeInsets.zero,
                    minimumSize: const Size(
                      AcademyTokens.target,
                      AcademyTokens.target,
                    ),
                    onPressed: widget.enabled && widget.moves.isNotEmpty
                        ? () => controller.isOpen
                              ? controller.close()
                              : controller.open()
                        : null,
                    child: ExcludeSemantics(child: handle),
                  ),
                ),
              ),
            );
      return AcademyInteractionBlocker(
        enabled: widget.enabled,
        label: widget.label,
        child: Opacity(
          opacity: _dragging
              ? .4
              : widget.enabled
              ? 1
              : .45,
          child: widget.rowBuilder(context, widget.data.item, accessory),
        ),
      );
    },
  );
}
