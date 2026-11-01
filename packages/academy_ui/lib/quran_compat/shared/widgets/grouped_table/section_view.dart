part of '../grouped_table.dart';

class _GroupedTableSectionView extends StatelessWidget {
  const _GroupedTableSectionView({
    required this.section,
    this.animated = false,
  });

  final GroupedTableSection section;
  final bool animated;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final inModal = ModalSheetSurfaceScope.isInModalSheet(context);

    final rowsColumn = Column(
      children: [
        for (final entry in section.rows.asMap().entries) ...[
          _rowView(entry.value, inModal),
          if (entry.key != section.rows.length - 1)
            _GroupedTableDivider(row: entry.value),
        ],
      ],
    );

    final sized = animated
        ? AnimatedSize(
            duration: const Duration(milliseconds: 280),
            curve: Curves.easeInOut,
            alignment: Alignment.topCenter,
            child: rowsColumn,
          )
        : rowsColumn;

    // В модалке — БЕЗ ClipRRect (он бы ре-растеризовался без RB-кэша → лаги):
    // ModalSheetMaskedFill скругляет card-углы заливкой И маскирует по форме шита
    // у верхних углов. Вне модалки — прежний ClipRRect + ColoredBox.
    final Widget card = inModal
        ? ModalSheetMaskedFill(
            color: colors.backgroundSecondary,
            borderRadius: BorderRadius.circular(section.cornerRadius),
            child: sized,
          )
        : ClipRRect(
            borderRadius: BorderRadius.circular(section.cornerRadius),
            child: ColoredBox(color: colors.backgroundSecondary, child: sized),
          );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (section.header != null) ...[
          Padding(
            padding: const EdgeInsets.only(left: 16, bottom: 8),
            child: Text(
              section.header!.toUpperCase(),
              style:
                  section.headerStyle ??
                  AppTypography.section(colors.sectionHeader),
            ),
          ),
        ],
        card,
        if (section.footer != null) ...[
          Padding(
            padding: const EdgeInsets.only(left: 12, top: 8, right: 12),
            child: Text(
              section.footer!,
              style:
                  section.footerStyle ??
                  AppTypography.listFootnote(colors.textSecondary),
            ),
          ),
        ],
      ],
    );
  }

  Widget _rowView(GroupedTableRow row, bool inModal) {
    final Widget view = _GroupedTableRowView(row: row);
    final wrapped = animated
        // Keyed so existing rows keep their fade state across rebuilds; a row
        // that newly appears in this section mounts fresh and fades in.
        ? _AnimatedGroupedRow(key: row.rowKey, child: view)
        : view;
    // В модалке секция перекрашивает фон-маску на скролле (per-item RB выключен).
    // Кэшируем глифы строки в ручном RB — каждый кадр перерисовывается только
    // дешёвая заливка, не текст. Строки со своим маск-фоном (Dismissible) НЕ
    // оборачиваем: их фон-маске нужно перекрашиваться (она прячет контент в свой
    // RB сама).
    if (inModal && !row.paintsOwnBackground) {
      return RepaintBoundary(child: wrapped);
    }
    return wrapped;
  }
}

/// Fades its child in once, when first mounted. Combined with the section's
/// [AnimatedSize], a row migrating between sections fades into its new home
/// while both sections smoothly resize.
class _AnimatedGroupedRow extends StatefulWidget {
  const _AnimatedGroupedRow({super.key, required this.child});

  final Widget child;

  @override
  State<_AnimatedGroupedRow> createState() => _AnimatedGroupedRowState();
}

class _AnimatedGroupedRowState extends State<_AnimatedGroupedRow>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 260),
  )..forward();

  late final Animation<double> _opacity = CurvedAnimation(
    parent: _controller,
    curve: Curves.easeOut,
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(opacity: _opacity, child: widget.child);
  }
}

class _GroupedTableDivider extends StatelessWidget {
  const _GroupedTableDivider({required this.row});

  final GroupedTableRow row;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Container(
      height: 0.5,
      margin: EdgeInsets.only(
        left: row.separatorLeadingInset ?? row.horizontalPadding,
      ),
      color: colors.separator,
    );
  }
}
