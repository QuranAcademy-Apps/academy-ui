part of '../grouped_table.dart';

/// Vertical space a leading section header occupies: the caption line (≈14pt at
/// [AppTypography.section]'s 12pt size and system line height) plus its 8pt
/// bottom gap before the first card. When the first section has no header,
/// [GroupedTable] reserves this much extra top padding so the first card lands
/// at the same offset as on a header-led screen — keeping the nav-bar→first-card
/// distance uniform across grouped screens regardless of whether they lead with
/// a header. Header-led screens are unaffected (the real header already fills
/// this band).
const double kGroupedTableLeadingHeaderReserve = 22;

class GroupedTable extends StatelessWidget {
  const GroupedTable({
    super.key,
    required this.sections,
    this.padding = const EdgeInsets.fromLTRB(16, 16, 16, 32),
    this.sectionSpacing = 24,
    this.controller,
    this.physics,
    this.shrinkWrap = false,
    this.lazyRows = false,
    this.animated = false,
    this.alignFirstCard = true,
  });

  final List<GroupedTableSection> sections;
  final EdgeInsetsGeometry padding;
  final double sectionSpacing;

  /// Scroll controller / physics for the outer scrollable. When [shrinkWrap]
  /// is true the table renders as a non-scrolling inline column, so both are
  /// ignored — wrap the table in your own scrollable instead.
  final ScrollController? controller;
  final ScrollPhysics? physics;
  final bool shrinkWrap;

  /// When true (default), a headerless first section reserves
  /// [kGroupedTableLeadingHeaderReserve] of extra top padding so its first card
  /// aligns with header-led screens. Set false for layouts that intentionally
  /// hug the top inset (e.g. when the gap is owned by a surrounding header).
  final bool alignFirstCard;

  /// When true, each row becomes an independent [ListView] item so rows
  /// outside the viewport are never built. Use for long single-section lists
  /// (e.g. reciters). Has no effect when [shrinkWrap] is true.
  final bool lazyRows;

  /// When true, sections smoothly resize when rows are added/removed and rows
  /// fade in as they appear. Use for lists where items migrate between sections
  /// (e.g. a download moving from "available" to "downloaded"). Rows should set
  /// a stable [GroupedTableRow.rowKey] so existing rows keep their state across
  /// rebuilds. Ignored when [lazyRows] is true.
  final bool animated;

  @override
  Widget build(BuildContext context) {
    final visibleSections = sections
        .where((section) => section.rows.isNotEmpty)
        .toList(growable: false);

    // В модалке секции скругляют фон маской (ModalSheetMaskedFill), которая
    // пересчитывается на скролле — поэтому per-item RB отключаем, иначе маска
    // замёрзнет. Тяжёлый контент строк держим в своих RB (см. _rowView/_FlatRow).
    final inModal = ModalSheetSurfaceScope.isInModalSheet(context);

    if (lazyRows) {
      return _buildLazyList(visibleSections, inModal: inModal);
    }

    if (shrinkWrap) {
      return _buildInlineSections(visibleSections);
    }

    return ListView.separated(
      controller: controller,
      physics: physics,
      shrinkWrap: shrinkWrap,
      addRepaintBoundaries: !inModal,
      padding: _effectivePadding(visibleSections),
      itemCount: visibleSections.length,
      separatorBuilder: (_, _) => SizedBox(height: sectionSpacing),
      itemBuilder: (context, index) {
        return _GroupedTableSectionView(
          section: visibleSections[index],
          animated: animated,
        );
      },
    );
  }

  Widget _buildInlineSections(List<GroupedTableSection> visibleSections) {
    final children = <Widget>[];

    for (var i = 0; i < visibleSections.length; i++) {
      if (i > 0) {
        children.add(SizedBox(height: sectionSpacing));
      }
      children.add(
        _GroupedTableSectionView(
          section: visibleSections[i],
          animated: animated,
        ),
      );
    }

    return Padding(
      padding: _effectivePadding(visibleSections),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: children,
      ),
    );
  }

  Widget _buildLazyList(
    List<GroupedTableSection> visibleSections, {
    required bool inModal,
  }) {
    // Flatten sections+rows into individual list items so ListView can
    // build only the rows that are actually visible.
    final items = <_FlatItem>[];

    for (var si = 0; si < visibleSections.length; si++) {
      final section = visibleSections[si];

      if (si > 0) {
        items.add(_FlatSpacer(sectionSpacing));
      }

      if (section.header != null) {
        items.add(_FlatHeader(section.header!, section.headerStyle));
      }

      final rowCount = section.rows.length;
      for (var ri = 0; ri < rowCount; ri++) {
        items.add(
          _FlatRow(
            row: section.rows[ri],
            isFirst: ri == 0,
            isLast: ri == rowCount - 1,
            cornerRadius: section.cornerRadius,
          ),
        );
      }

      if (section.footer != null) {
        items.add(_FlatFooter(section.footer!, section.footerStyle));
      }
    }

    return ListView.builder(
      controller: controller,
      physics: physics,
      shrinkWrap: shrinkWrap,
      addRepaintBoundaries: !inModal,
      padding: _effectivePadding(visibleSections),
      itemCount: items.length,
      itemBuilder: (context, index) => items[index].build(context),
    );
  }

  /// Adds [kGroupedTableLeadingHeaderReserve] to the top padding when the first
  /// visible section has no header, so the first card sits at the same offset
  /// as on header-led screens. No-op for header-led screens (the header itself
  /// already fills that band) and when [alignFirstCard] is false.
  EdgeInsetsGeometry _effectivePadding(
    List<GroupedTableSection> visibleSections,
  ) {
    final firstHeaderless =
        visibleSections.isEmpty || visibleSections.first.header == null;
    if (!alignFirstCard || !firstHeaderless) {
      return padding;
    }
    return padding.add(
      const EdgeInsets.only(top: kGroupedTableLeadingHeaderReserve),
    );
  }
}

// ---------------------------------------------------------------------------
// Flat item types for lazy-row rendering
// ---------------------------------------------------------------------------

sealed class _FlatItem {
  Widget build(BuildContext context);
}

final class _FlatSpacer extends _FlatItem {
  _FlatSpacer(this.height);
  final double height;

  @override
  Widget build(BuildContext context) => SizedBox(height: height);
}

final class _FlatHeader extends _FlatItem {
  _FlatHeader(this.text, this.style);
  final String text;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Padding(
      padding: const EdgeInsets.only(left: 16, bottom: 8),
      child: Text(
        text.toUpperCase(),
        style: style ?? AppTypography.section(colors.textPrimary),
      ),
    );
  }
}

final class _FlatFooter extends _FlatItem {
  _FlatFooter(this.text, this.style);
  final String text;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Padding(
      padding: const EdgeInsets.only(left: 12, top: 8, right: 12),
      child: Text(
        text,
        style: style ?? AppTypography.listFootnote(colors.textSecondary),
      ),
    );
  }
}

/// A single row rendered with per-edge corner radius so it can live as its
/// own [ListView] item and be built lazily.
final class _FlatRow extends _FlatItem {
  _FlatRow({
    required this.row,
    required this.isFirst,
    required this.isLast,
    required this.cornerRadius,
  });

  final GroupedTableRow row;
  final bool isFirst;
  final bool isLast;
  final double cornerRadius;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final r = Radius.circular(cornerRadius);
    final borderRadius = BorderRadius.only(
      topLeft: isFirst ? r : Radius.zero,
      topRight: isFirst ? r : Radius.zero,
      bottomLeft: isLast ? r : Radius.zero,
      bottomRight: isLast ? r : Radius.zero,
    );

    final content = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _GroupedTableRowView(row: row),
        if (!isLast) _GroupedTableDivider(row: row),
      ],
    );

    // В модалке — БЕЗ ClipRRect (он бы ре-растеризовался без RB-кэша → лаги):
    // ModalSheetMaskedFill скругляет card-углы заливкой И маскирует по форме шита
    // у верха. Контент держим в своём RB (фон-маска перерисовывается на скролле).
    if (ModalSheetSurfaceScope.isInModalSheet(context)) {
      return ModalSheetMaskedFill(
        color: colors.backgroundSecondary,
        borderRadius: borderRadius,
        child: RepaintBoundary(child: content),
      );
    }

    return ClipRRect(
      borderRadius: borderRadius,
      child: ColoredBox(color: colors.backgroundSecondary, child: content),
    );
  }
}

class GroupedTableSection {
  const GroupedTableSection({
    this.header,
    this.footer,
    required this.rows,
    this.headerStyle,
    this.footerStyle,
    this.cornerRadius = 14,
  });

  final String? header;
  final String? footer;
  final List<GroupedTableRow> rows;
  final TextStyle? headerStyle;
  final TextStyle? footerStyle;
  final double cornerRadius;
}

class GroupedTableRow {
  const GroupedTableRow({
    required this.title,
    this.rowKey,
    this.titleWidget,
    this.titleTrailing,
    this.subtitle,
    this.subtitleWidget,
    this.trailingTitle,
    this.leading,
    this.leadingGap = 16,
    this.accessory = const GroupedTableAccessory.none(),
    this.onTap,
    this.onLongPress,
    this.wrapper,
    this.enabled = true,
    this.minHeight = 44,
    this.horizontalPadding = 16,
    this.verticalPadding = 11,
    this.separatorLeadingInset,
    this.titleStyle,
    this.subtitleStyle,
    this.trailingTitleStyle,
    this.semanticLabel,
    this.semanticHint,
    this.excludeFromSemantics = false,
    this.paintsOwnBackground = false,
  });

  final String title;

  /// Stable identity for this row across rebuilds. Used by
  /// [GroupedTable.animated] to preserve per-row animation state and to detect
  /// rows that newly appear in a section.
  final Key? rowKey;
  final Widget? titleWidget;
  final Widget? titleTrailing;
  final String? subtitle;
  final Widget? subtitleWidget;
  final String? trailingTitle;
  final Widget? leading;

  /// Зазор между [leading] и заголовком.
  final double leadingGap;
  final GroupedTableAccessory accessory;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final Widget Function(BuildContext context, Widget child)? wrapper;
  final bool enabled;
  final double minHeight;
  final double horizontalPadding;
  final double verticalPadding;
  final double? separatorLeadingInset;
  final TextStyle? titleStyle;
  final TextStyle? subtitleStyle;
  final TextStyle? trailingTitleStyle;
  final String? semanticLabel;
  final String? semanticHint;
  final bool excludeFromSemantics;

  /// Строка САМА красит свой непрозрачный фон (напр. под Dismissible). В модалке
  /// такие строки не оборачиваются во внешний кэширующий RB: их фон —
  /// [ModalSheetMaskedFill], которому нужно перекрашиваться на скролле (а тяжёлый
  /// контент строка прячет в свой ручной RB сама).
  final bool paintsOwnBackground;
}
