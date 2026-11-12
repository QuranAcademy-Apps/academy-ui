import '../../foundation/interaction/academy_interaction.dart';
import '../../foundation/motion/academy_press_effect.dart';
import '../icon/academy_sf_image.dart';

import 'package:cupertino_ui/cupertino_ui.dart';

import 'academy_grouped_table.dart';
import 'academy_table_row_slot.dart';
import '../../theme/academy_theme.dart';
import '../../foundation/surface/academy_surface_mask.dart';

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
    this.uppercase = false,
    this.prominent = false,
    this.style,
    this.padding,
    this.subtitle,
    this.subtitleStyle,
  });
  const AcademyTableHeader.action({
    super.key,
    required this.title,
    required String action,
    required VoidCallback? onPressed,
    IconData? icon,
    this.uppercase = false,
    this.prominent = false,
    this.style,
    this.padding,
    this.subtitle,
    this.subtitleStyle,
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

  /// Stronger inset-grouped heading, corresponding to UIKit's prominent header.
  /// The default is the standard grouped heading (17pt semibold).
  final bool prominent;
  final TextStyle? style;
  final EdgeInsetsGeometry? padding;

  /// Explanation under the heading, inside the same [padding].
  final String? subtitle;
  final TextStyle? subtitleStyle;
  @override
  Widget build(BuildContext context) {
    final theme = AcademyTheme.of(context);
    final heading = Semantics(
      container: true,
      header: true,
      child: Text(
        uppercase || theme.table.headerUppercase ? title.toUpperCase() : title,
        style:
            style ??
            theme.table.headerStyle ??
            (prominent
                    ? theme.textTheme.sectionHeading
                    : theme.textTheme.bodyStrong)
                .copyWith(
                  color: prominent
                      ? theme.colorScheme.onSurface
                      : theme.colorScheme.onSurfaceVariant,
                ),
      ),
    );
    Widget action() {
      final color = onAction == null
          ? theme.colorScheme.onSurfaceVariant
          : theme.colorScheme.accentForeground;
      return AcademyActionSemantics(
        label: actionLabel!,
        enabled: onAction != null,
        child: AcademyPressEffect(
          enabled: onAction != null,
          child: CupertinoButton(
            onPressed: onAction,
            padding: EdgeInsets.zero,
            minimumSize: const Size(AcademyTokens.target, AcademyTokens.target),
            child: ExcludeSemantics(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (actionIcon != null) ...[
                    AcademySfIcon(
                      actionIcon!,
                      size: AcademyTheme.of(context).sizes.menuIcon,
                      color: color,
                    ),
                    const SizedBox(width: AcademyTokens.labelGap),
                  ],
                  Flexible(
                    child: Text(
                      actionLabel!,
                      textAlign: TextAlign.end,
                      style: theme.textTheme.bodyRow.copyWith(color: color),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    final header = LayoutBuilder(
      builder: (context, constraints) {
        // A trailing control that cannot sit beside the heading (narrow
        // width or large text) moves under it instead of squeezing it.
        if (trailing != null &&
            actionLabel == null &&
            (constraints.maxWidth < 280 ||
                MediaQuery.textScalerOf(context).scale(15) > 24)) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              heading,
              Semantics(container: true, child: trailing!),
            ],
          );
        }
        return Row(
          children: [
            Expanded(child: heading),
            if (actionLabel != null) ...[
              const SizedBox(width: AcademyTokens.inlineGap),
              ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: constraints.maxWidth * .6,
                ),
                child: action(),
              ),
            ],
            if (trailing != null) ...[
              const SizedBox(width: AcademyTokens.inlineGap),
              Semantics(container: true, child: trailing!),
            ],
          ],
        );
      },
    );
    return Padding(
      padding: padding ?? theme.paddings.tableHeader,
      child: subtitle == null
          ? header
          : Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                header,
                Padding(
                  padding: const EdgeInsets.only(bottom: AcademyTokens.space),
                  child: Text(
                    subtitle!,
                    style:
                        subtitleStyle ??
                        theme.textTheme.bodySmall.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                  ),
                ),
              ],
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
          AcademyTheme.of(context).table.footerStyle ??
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
      end:
          end ??
          AcademyTheme.of(context).table.separatorEnd ??
          AcademyTheme.of(context).paddings.tableRow.right,
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
    this.separatorStart,
    this.separatorEnd,
    this.insetCustomRows = false,
    this.clip = false,
    this.animated = false,
  });
  final List<Widget> rows;
  final double? cornerRadius;

  /// Resizes smoothly as rows come and go; a row with a new key fades in.
  final bool animated;
  final bool showSeparators;

  /// Fixed separator start, overriding each row's [AcademyTableRowGeometry].
  final double? separatorStart;

  /// Separator end inset; default: the row's trailing padding.
  final double? separatorEnd;

  /// Pads rows that are not [AcademyTableRowGeometry] by the row insets,
  /// keeps their own width (centered)
  /// instead of giving them the row scope.
  final bool insetCustomRows;

  /// Clips row content (such as a pressed highlight) to the rounded surface.
  final bool clip;
  final Widget Function(BuildContext context, int precedingIndex)?
  separatorBuilder;
  final EdgeInsetsGeometry? padding;
  @override
  Widget build(BuildContext context) {
    final inModal = ModalSheetSurfaceScope.isInModalSheet(context);
    Widget rowOf(Widget row) {
      final faded = animated ? _FadeInRow(child: row) : row;
      // A modal fill repaints while scrolling: cache the glyphs apart from it,
      // unless the row paints a fill of its own.
      return inModal && academyTableRowCachesGlyphs(row)
          ? RepaintBoundary(child: faded)
          : faded;
    }

    // One column cannot hold two children with the same key.
    final seenKeys = <Key>{};
    final repeatedKeys = <Key>{
      for (final row in rows)
        if (row.key case final key? when !seenKeys.add(key)) key,
    };
    final column = Padding(
      padding: padding ?? AcademyTheme.of(context).paddings.tableBody,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (var i = 0; i < rows.length; i++) ...[
            if (i > 0 && showSeparators)
              separatorBuilder?.call(context, i - 1) ??
                  AcademyTableSeparator(
                    start:
                        separatorStart ??
                        academyTableRowStart(context, rows[i - 1]),
                    end: separatorEnd,
                  ),
            academyTableRowSlot(
              context,
              rows[i],
              insetCustomRows: insetCustomRows,
              content: rowOf(rows[i]),
              keyed: !repeatedKeys.contains(rows[i].key),
            ),
          ],
        ],
      ),
    );
    final content = animated
        ? AnimatedSize(
            duration: MediaQuery.disableAnimationsOf(context)
                ? Duration.zero
                : AcademyTokens.layoutMotion,
            curve: Curves.easeInOut,
            alignment: Alignment.topCenter,
            child: column,
          )
        : column;
    if (inModal) {
      return ModalSheetMaskedFill(
        color: AcademyTheme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(
          cornerRadius ?? AcademyTheme.of(context).radii.table,
        ),
        child: content,
      );
    }
    final radius = BorderRadius.circular(
      cornerRadius ?? AcademyTheme.of(context).radii.table,
    );
    if (AcademyTheme.of(context).table.clipSurface) {
      return ClipRRect(
        borderRadius: radius,
        child: ColoredBox(
          color: AcademyTheme.of(context).colorScheme.surface,
          child: content,
        ),
      );
    }
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AcademyTheme.of(context).colorScheme.surface,
        borderRadius: radius,
      ),
      child: clip ? ClipRRect(borderRadius: radius, child: content) : content,
    );
  }
}

/// Fades a row in once, when first mounted.
class _FadeInRow extends StatefulWidget {
  const _FadeInRow({required this.child});
  final Widget child;
  @override
  State<_FadeInRow> createState() => _FadeInRowState();
}

class _FadeInRowState extends State<_FadeInRow>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 260),
    value: MediaQuery.disableAnimationsOf(context) ? 1 : 0,
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
  Widget build(BuildContext context) =>
      FadeTransition(opacity: _opacity, child: widget.child);
}

class AcademyTableSectionView extends StatelessWidget {
  const AcademyTableSectionView({
    super.key,
    required this.section,
    this.animated = false,
  });
  final AcademyTableSection section;
  final bool animated;
  @override
  Widget build(BuildContext context) => Column(
    mainAxisSize: MainAxisSize.min,
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      if (section.spacingBefore != null)
        SizedBox(height: section.spacingBefore),
      if (section.header != null || section.title != null)
        section.header ??
            AcademyTableHeader(
              title: section.title!,
              subtitle: section.subtitle,
              trailing: section.headerTrailing,
              style: section.headerStyle,
              padding: section.headerPadding,
            ),
      AcademyTableBody(
        rows: section.rows,
        cornerRadius: section.cornerRadius,
        showSeparators: section.showSeparators,
        separatorBuilder: section.separatorBuilder,
        padding: section.bodyPadding,
        separatorStart: section.separatorStart,
        separatorEnd: section.separatorEnd,
        insetCustomRows: section.insetCustomRows,
        clip: section.clip,
        animated: animated,
      ),
      if (section.footerWidget != null || section.footer != null)
        section.footerWidget ??
            AcademyTableFooter(
              text: section.footer!,
              style: section.footerStyle,
              padding: section.footerPadding,
            ),
    ],
  );
}
