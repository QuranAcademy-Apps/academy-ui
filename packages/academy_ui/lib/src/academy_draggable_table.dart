import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';

import 'academy_table.dart';
import 'academy_sf_image.dart';
import 'academy_theme.dart';

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
    this.label = 'Перетащить',
    this.height = 44,
  });
  final bool enabled;
  final String label;
  final double height;
  @override
  Widget build(BuildContext context) => Semantics(
    label: label,
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
              AcademySymbols.dragHandle,
              size: 18,
              boxSize: 44,
              color: AcademyTheme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    ),
  );
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
    this.emptyLabel = 'Перетащите сюда',
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
  final String emptyLabel;
  final bool Function(AcademyTableDragData<T> source)? accepts;
  final ValueChanged<T>? onRemove;
  final double? feedbackWidth;

  Widget _target(BuildContext context, int slot, Widget child) =>
      DragTarget<AcademyTableDragData<T>>(
        onWillAcceptWithDetails: (details) =>
            enabled &&
            !editing &&
            (accepts?.call(details.data) ?? true) &&
            !(details.data.sectionId == sectionId &&
                (slot == details.data.index || slot == details.data.index + 1)),
        onAcceptWithDetails: (details) {
          final source = details.data;
          final destination =
              source.sectionId == sectionId && slot > source.index
              ? slot - 1
              : slot;
          onMove(source, sectionId, destination);
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
                      emptyLabel,
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
                  data: AcademyTableDragData(
                    item: items[i],
                    itemId: itemId(items[i]),
                    sectionId: sectionId,
                    index: i,
                  ),
                  enabled: enabled,
                  editing: editing,
                  onRemove: onRemove,
                  rowBuilder: rowBuilder,
                  feedbackWidth: feedbackWidth,
                ),
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
    required this.enabled,
    required this.editing,
    required this.rowBuilder,
    this.onRemove,
    this.feedbackWidth,
  });
  final AcademyTableDragData<T> data;
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
        label: 'Перетащить ${widget.data.item}',
      );
      final width = widget.feedbackWidth ?? constraints.maxWidth;
      final theme = AcademyTheme.of(context);
      final direction = Directionality.of(context);
      final accessory = widget.editing
          ? CupertinoButton(
              padding: EdgeInsets.zero,
              minimumSize: const Size(44, 44),
              onPressed: widget.onRemove == null
                  ? null
                  : () => widget.onRemove!(widget.data.item),
              child: Semantics(
                label: 'Удалить ${widget.data.item}',
                button: true,
                child: AcademySfIcon(
                  AcademySymbols.trash,
                  color: theme.colorScheme.error,
                  size: 20,
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
                HapticFeedback.selectionClick();
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
                        widget.rowBuilder(
                          context,
                          widget.data.item,
                          const AcademyDragHandle(),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              childWhenDragging: Opacity(opacity: .3, child: handle),
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {},
                child: handle,
              ),
            );
      return Opacity(
        opacity: _dragging ? .4 : 1,
        child: widget.rowBuilder(context, widget.data.item, accessory),
      );
    },
  );
}
