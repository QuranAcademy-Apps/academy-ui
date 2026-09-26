import 'package:flutter/cupertino.dart';

import 'academy_controls.dart';
import 'academy_menu.dart';
import 'academy_navigation.dart';
import 'academy_theme.dart';
import 'modal/modal_sheet_corner_mask.dart';

/// Compact metadata badge matching Quran's downloaded-content table.
class AcademyTableBadge extends StatelessWidget {
  const AcademyTableBadge({super.key, required this.label});
  final String label;
  @override
  Widget build(BuildContext context) {
    final theme = AcademyTheme.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: theme.colorScheme.scaffoldBackground,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 3),
        child: Text(
          label,
          style: theme.textTheme.sectionLabel.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

class AcademyTableHeader extends StatelessWidget {
  const AcademyTableHeader({
    super.key,
    required this.title,
    this.trailing,
    this.uppercase = true,
    this.style,
    this.padding = const EdgeInsets.fromLTRB(16, 0, 16, 8),
  });
  final String title;
  final Widget? trailing;
  final bool uppercase;
  final TextStyle? style;
  final EdgeInsetsGeometry padding;
  @override
  Widget build(BuildContext context) => Padding(
    padding: padding,
    child: Row(
      children: [
        Expanded(
          child: Semantics(
            container: true,
            header: true,
            child: Text(
              uppercase ? title.toUpperCase() : title,
              style:
                  style ??
                  AcademyTheme.of(context).textTheme.sectionLabel.copyWith(
                    color: AcademyTheme.of(context)
                        .colorScheme
                        .onSurfaceVariant,
                  ),
            ),
          ),
        ),
        if (trailing != null) ...[
          const SizedBox(width: 12),
          Semantics(container: true, child: trailing!),
        ],
      ],
    ),
  );
}

class AcademyTableFooter extends StatelessWidget {
  const AcademyTableFooter({
    super.key,
    required this.text,
    this.style,
    this.padding = const EdgeInsets.fromLTRB(12, 8, 12, 0),
  });
  final String text;
  final TextStyle? style;
  final EdgeInsetsGeometry padding;
  @override
  Widget build(BuildContext context) => Padding(
    padding: padding,
    child: Text(
      text,
      style:
          style ??
          AcademyTheme.of(context).textTheme.bodySmall.copyWith(
            color: AcademyTheme.of(context).colorScheme.onSurfaceVariant,
          ),
    ),
  );
}

class AcademyTableSeparator extends StatelessWidget {
  const AcademyTableSeparator({super.key, this.start = 16, this.end = 16});
  final double start, end;
  @override
  Widget build(BuildContext context) => Padding(
    padding: EdgeInsetsDirectional.only(start: start, end: end),
    child: Container(
      height: .5,
      color: AcademyTheme.of(context).colorScheme.outlineVariant,
    ),
  );
}

/// Opaque card body, independently usable with arbitrary row content.
class AcademyTableBody extends StatelessWidget {
  const AcademyTableBody({
    super.key,
    required this.rows,
    this.cornerRadius = 14,
    this.showSeparators = true,
    this.separatorBuilder,
    this.padding = const EdgeInsets.symmetric(vertical: 4),
  });
  final List<Widget> rows;
  final double cornerRadius;
  final bool showSeparators;
  final Widget Function(BuildContext context, int precedingIndex)?
  separatorBuilder;
  final EdgeInsetsGeometry padding;
  @override
  Widget build(BuildContext context) {
    final content = Padding(
      padding: padding,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (var i = 0; i < rows.length; i++) ...[
            if (i > 0 && showSeparators)
              separatorBuilder?.call(context, i - 1) ??
                  AcademyTableSeparator(start: _separatorStart(rows[i - 1])),
            AcademyTableRowScope(child: rows[i]),
          ],
        ],
      ),
    );
    if (ModalSheetSurfaceScope.isInModalSheet(context)) {
      return ModalSheetMaskedFill(
        color: AcademyTheme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(cornerRadius),
        child: content,
      );
    }
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AcademyTheme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(cornerRadius),
      ),
      child: content,
    );
  }

  double _separatorStart(Widget row) {
    final hasLeading =
        row is AcademyRow && (row.icon != null || row.leading != null) ||
        row is AcademyOptionMenu && row.icon != null ||
        row is AcademyMenuRow && row.icon != null;
    return 16 + (hasLeading ? AcademyTokens.tableIconExtent + 12 : 0);
  }
}

class AcademyTableSectionView extends StatelessWidget {
  const AcademyTableSectionView({super.key, required this.section});
  final AcademyTableSection section;
  @override
  Widget build(BuildContext context) => Column(
    mainAxisSize: MainAxisSize.min,
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      if (section.header != null || section.title != null)
        section.header ??
            AcademyTableHeader(
              title: section.title!,
              trailing: section.headerTrailing,
              style: section.headerStyle,
            ),
      AcademyTableBody(
        rows: section.rows,
        cornerRadius: section.cornerRadius,
        showSeparators: section.showSeparators,
        separatorBuilder: section.separatorBuilder,
      ),
      if (section.footerWidget != null || section.footer != null)
        section.footerWidget ??
            AcademyTableFooter(
              text: section.footer!,
              style: section.footerStyle,
            ),
    ],
  );
}
