import '../button/academy_pill_button.dart';

import 'package:flutter/cupertino.dart';

import 'academy_grouped_table.dart';
import '../menu/academy_menu.dart';
import '../menu/academy_option_menu.dart';
import 'academy_row.dart';
import 'academy_divider.dart';
import '../../theme/academy_theme.dart';
import '../modal/modal_sheet_corner_mask.dart';

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
        borderRadius: BorderRadius.circular(
          AcademyTheme.of(context).radii.tableBadge,
        ),
      ),
      child: Padding(
        padding: AcademyTheme.of(context).paddings.tableBadge,
        child: Text(
          label,
          style: theme.textTheme.tableBadge.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
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
    this.actionLabel,
    this.onAction,
    this.actionIcon,
    this.uppercase = true,
    this.style,
    this.padding,
  });
  const AcademyTableHeader.action({
    super.key,
    required this.title,
    required String action,
    required VoidCallback? onPressed,
    IconData? icon,
    this.uppercase = false,
    this.style,
    this.padding,
  }) : actionLabel = action,
       onAction = onPressed,
       actionIcon = icon,
       trailing = null;
  final String? actionLabel;
  final VoidCallback? onAction;
  final IconData? actionIcon;
  final String title;
  final Widget? trailing;
  final bool uppercase;
  final TextStyle? style;
  final EdgeInsetsGeometry? padding;
  @override
  Widget build(BuildContext context) {
    final theme = AcademyTheme.of(context);
    final heading = Semantics(
      container: true,
      header: true,
      child: Text(
        uppercase ? title.toUpperCase() : title,
        style:
            style ??
            theme.textTheme.sectionLabel.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
      ),
    );
    Widget action() => AcademyPillButton(
      label: actionLabel!,
      icon: actionIcon,
      onPressed: onAction,
      tinted: false,
    );
    return Padding(
      padding: padding ?? theme.paddings.tableHeader,
      child: LayoutBuilder(
        builder: (context, constraints) {
          if (actionLabel != null &&
              (MediaQuery.textScalerOf(context).scale(1) >=
                      AcademyTokens.adaptiveTextScale ||
                  constraints.maxWidth <
                      AcademyTokens.metadataHorizontalWidth)) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                heading,
                Align(
                  alignment: AlignmentDirectional.centerEnd,
                  child: action(),
                ),
              ],
            );
          }
          return Row(
            children: [
              Expanded(child: heading),
              if (actionLabel != null) ...[
                const SizedBox(width: AcademyTokens.inlineGap),
                Flexible(child: action()),
              ],
              if (trailing != null) ...[
                const SizedBox(width: AcademyTokens.inlineGap),
                Semantics(container: true, child: trailing!),
              ],
            ],
          );
        },
      ),
    );
  }
}

class AcademyTableFooter extends StatelessWidget {
  const AcademyTableFooter({
    super.key,
    required this.text,
    this.style,
    this.padding,
  });
  final String text;
  final TextStyle? style;
  final EdgeInsetsGeometry? padding;
  @override
  Widget build(BuildContext context) => Padding(
    padding: padding ?? AcademyTheme.of(context).paddings.tableFooter,
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
  const AcademyTableSeparator({super.key, this.start, this.end});
  final double? start, end;
  @override
  Widget build(BuildContext context) => Padding(
    padding: EdgeInsetsDirectional.only(
      start: start ?? AcademyTheme.of(context).paddings.tableRow.left,
      end: end ?? AcademyTheme.of(context).paddings.tableRow.right,
    ),
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
    this.cornerRadius,
    this.showSeparators = true,
    this.separatorBuilder,
    this.padding,
  });
  final List<Widget> rows;
  final double? cornerRadius;
  final bool showSeparators;
  final Widget Function(BuildContext context, int precedingIndex)?
  separatorBuilder;
  final EdgeInsetsGeometry? padding;
  @override
  Widget build(BuildContext context) {
    final content = Padding(
      padding: padding ?? AcademyTheme.of(context).paddings.tableBody,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (var i = 0; i < rows.length; i++) ...[
            if (i > 0 && showSeparators)
              separatorBuilder?.call(context, i - 1) ??
                  AcademyTableSeparator(
                    start: _separatorStart(context, rows[i - 1]),
                  ),
            AcademyTableRowScope(child: rows[i]),
          ],
        ],
      ),
    );
    if (ModalSheetSurfaceScope.isInModalSheet(context)) {
      return ModalSheetMaskedFill(
        color: AcademyTheme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(
          cornerRadius ?? AcademyTheme.of(context).radii.table,
        ),
        child: content,
      );
    }
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AcademyTheme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(
          cornerRadius ?? AcademyTheme.of(context).radii.table,
        ),
      ),
      child: content,
    );
  }

  double _separatorStart(BuildContext context, Widget row) {
    final hasLeading =
        row is AcademyRow && (row.icon != null || row.leading != null) ||
        row is AcademyOptionMenu && row.icon != null ||
        row is AcademyMenuRow && row.icon != null;
    return AcademyTheme.of(context).paddings.tableRow.left +
        (hasLeading
            ? AcademyTokens.tableIconExtent + AcademyTokens.inlineGap
            : 0);
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
