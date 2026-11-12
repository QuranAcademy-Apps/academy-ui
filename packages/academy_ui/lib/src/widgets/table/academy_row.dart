import '../switch/academy_switch.dart';
import '../../foundation/motion/press_scale.dart';
import 'academy_row_accessory.dart';
import '../../theme/academy_row_icons.dart';
import '../../foundation/interaction/academy_interaction.dart';
import '../icon/academy_chevron.dart';
import '../icon/academy_sf_image.dart';

import 'package:cupertino_ui/cupertino_ui.dart';

import '../../theme/academy_theme.dart';

import '../../foundation/table/academy_table_row_scope.dart';

/// Adapted from Quran GroupedTableRow: leading, flexible text and accessory.
class AcademyRow extends StatelessWidget implements AcademyTableRowGeometry {
  const AcademyRow({
    super.key,
    required this.title,
    this.subtitle,
    this.icon,
    this.iconBackgroundColor,
    this.iconColorRole,
    this.tone,
    this.actionLabel,
    this.trailing,
    this.showChevron,
    this.onPressed,
    this.leading,
    this.titleWidget,
    this.subtitleWidget,
    this.titleTrailing,
    this.onLongPress,
    this.enabled = true,
    this.minHeight,
    this.horizontalPadding,
    this.verticalPadding,
    this.eyebrow,
    this.detail,
    this.titleStyle,
    this.subtitleStyle,
    this.subtitleMaxLines,
    this.subtitleTextAlign = TextAlign.start,
    this.crossAxisAlignment,
    this.leadingExtent,
    this.iconForeground,
    this.selected,
    this.trailingSpacing,
    this.chevron,
    this.pressedColor,
    this.trailingText,
    this.trailingTextStyle,
    this.leadingGap,
    this.semanticLabel,
    this.semanticHint,
    this.excludeFromSemantics = false,
    this.wrapper,
    this.separatorInset,
    this.paintsOwnBackground = false,
  });

  /// One action for the entire row; the accent label is not a nested button.
  const AcademyRow.action({
    super.key,
    required this.title,
    required String action,
    required this.onPressed,
    this.subtitle,
    this.icon,
    this.iconColorRole,
    this.enabled = true,
    this.tone,
  }) : actionLabel = action,
       iconBackgroundColor = null,
       trailing = null,
       showChevron = false,
       leading = null,
       titleWidget = null,
       subtitleWidget = null,
       titleTrailing = null,
       onLongPress = null,
       minHeight = null,
       horizontalPadding = null,
       verticalPadding = null,
       eyebrow = null,
       detail = null,
       titleStyle = null,
       subtitleStyle = null,
       subtitleMaxLines = null,
       subtitleTextAlign = TextAlign.start,
       crossAxisAlignment = null,
       leadingExtent = null,
       iconForeground = null,
       selected = null,
       trailingSpacing = null,
       chevron = null,
       pressedColor = null,
       trailingText = null,
       trailingTextStyle = null,
       leadingGap = null,
       semanticLabel = null,
       semanticHint = null,
       excludeFromSemantics = false,
       wrapper = null,
       separatorInset = null,
       paintsOwnBackground = false;

  final AcademyTone? tone;
  final AcademyRowIcons? iconColorRole;
  final String? actionLabel;
  final String title;
  final String? subtitle;
  final IconData? icon;
  final Color? iconBackgroundColor;
  final Widget? leading, titleWidget, subtitleWidget, titleTrailing;
  final VoidCallback? onLongPress;
  final bool enabled;

  /// Default: the theme's row height.
  final double? minHeight;
  final double? verticalPadding;
  final double? horizontalPadding;
  final Widget? trailing;

  /// Navigation accessory; does not reserve space when hidden.
  final bool? showChevron;
  final VoidCallback? onPressed;

  /// Small caption above the title, for example a city above a hotel.
  final String? eyebrow;

  /// Extra content under the subtitle, such as a status badge.
  final Widget? detail;
  final TextStyle? titleStyle, subtitleStyle;
  final int? subtitleMaxLines;
  final TextAlign subtitleTextAlign;

  /// Default: centered, or top-aligned with an [eyebrow].
  final CrossAxisAlignment? crossAxisAlignment;

  /// Width of the leading column shared by every row of a table. When set,
  /// symbols and tiles are centered in it at their natural height and a
  /// [leading] widget is square; default: a [AcademyTokens.tableIconExtent]
  /// box.
  final double? leadingExtent;

  /// Symbol color on a colored tile; default: a contrast-checked white.
  final Color? iconForeground;

  /// Exposes the selected state to accessibility.
  final bool? selected;

  /// Gap before [trailing]; default: the table theme's.
  final double? trailingSpacing;

  /// One line of text beside [trailing], at most 170pt wide.
  final String? trailingText;
  final TextStyle? trailingTextStyle;

  /// Gap after the leading content; default: the table theme's.
  final double? leadingGap;

  /// Replaces what accessibility reads from the row's content.
  final String? semanticLabel;
  final String? semanticHint;
  final bool excludeFromSemantics;

  /// Wraps the finished row, for example in a Dismissible.
  final Widget Function(BuildContext context, Widget child)? wrapper;

  /// Fixed separator start under this row.
  final double? separatorInset;

  /// The row paints its own opaque background, so a modal table must not cache
  /// it in a repaint boundary: the fill follows the sheet while scrolling.
  final bool paintsOwnBackground;

  /// Replaces the navigation chevron.
  final Widget? chevron;

  /// Highlights the whole row while pressed (grouped-list style) instead of
  /// fading the content.
  final Color? pressedColor;
  @override
  double separatorStart(BuildContext context) =>
      separatorInset ??
      academyRowSeparatorStart(
        context,
        hasLeading: icon != null || leading != null,
        start: horizontalPadding,
        leadingExtent: leadingExtent,
        leadingGap: leadingGap,
      );

  @override
  Widget build(BuildContext context) {
    final theme = AcademyTheme.of(context);
    final toneColor = tone == AcademyTone.error
        ? AcademyRowIcons.alert.colorOf(context)
        : tone == null
        ? null
        : theme.colorScheme.toneForeground(tone!);
    final tileColor = tone != null
        ? toneColor
        : iconBackgroundColor ?? iconColorRole?.colorOf(context);
    final table = theme.table;
    final leadingExtent = this.leadingExtent ?? table.leadingExtent;
    final pressedColor = this.pressedColor ?? table.pressedColor;
    final gap = leadingGap ?? table.leadingGap;
    final textVertical = verticalPadding ?? theme.paddings.tableRow.top;
    final stretchTrailing =
        trailing is AcademyRowAccessory &&
        (trailing as AcademyRowAccessory).stretches;
    // A theme's title style sets the look; the tone still colors it, so a
    // destructive row stays red.
    final titleColor =
        toneColor ??
        (actionLabel != null ? theme.colorScheme.onSurfaceVariant : null);
    final baseTitleStyle = table.rowTitleStyle ?? theme.textTheme.bodyRow;
    final titleStyle =
        this.titleStyle ??
        (titleColor == null
            ? baseTitleStyle
            : baseTitleStyle.copyWith(color: titleColor));
    // At large text a value cannot share a line with the title without breaking
    // its words, so it moves under the title, as in a native value cell.
    final largeText =
        MediaQuery.textScalerOf(context).scale(1) >=
        AcademyTokens.adaptiveTextScale;
    final trailingTextMoves = largeText && trailingText != null;
    final trailingMoves =
        largeText &&
        switch (trailing) {
          final AcademyRowTrailingText text => !text.disclosure,
          final AcademyRowAccessory accessory => accessory.movesUnderTitle,
          _ => false,
        };
    final tallTrailing =
        !trailingMoves &&
        switch (trailing) {
          final AcademyRowAccessoryButton button => button.onPressed != null,
          final AcademyRowAccessory accessory => accessory.hasTallTarget,
          _ => false,
        };
    // A tall touch target fits beside the text instead of growing the row.
    final paddingAroundText = table.paddingAroundText || tallTrailing;
    Widget tile(Color fill) => Container(
      width: AcademyTheme.of(context).sizes.rowIconExtent,
      height: AcademyTheme.of(context).sizes.rowIconExtent,
      decoration: BoxDecoration(
        color: fill,
        borderRadius: BorderRadius.circular(
          AcademyTheme.of(context).radii.rowIcon,
        ),
      ),
      alignment: Alignment.center,
      child: AcademySfIcon(
        icon!,
        size: AcademyTheme.of(context).sizes.rowTileIcon,
        color:
            iconForeground ??
            (tone == null || tone == AcademyTone.error
                ? theme.colorScheme.iconOnColoredSurface
                : AcademyContrast.foreground(
                    theme.colorScheme.iconOnColoredSurface,
                    fill,
                  )),
      ),
    );
    Widget aroundText(Widget child) => paddingAroundText
        ? Padding(
            padding: EdgeInsets.symmetric(vertical: textVertical),
            child: child,
          )
        : child;
    final body = Row(
      crossAxisAlignment: stretchTrailing
          ? CrossAxisAlignment.stretch
          : crossAxisAlignment ??
                (eyebrow == null
                    ? CrossAxisAlignment.center
                    : CrossAxisAlignment.start),
      children: [
        if (leading != null) ...[
          if (leadingExtent != null)
            SizedBox.square(dimension: leadingExtent, child: leading)
          else if (table.fixedLeadingColumn)
            SizedBox(
              width: AcademyTheme.of(context).sizes.rowIconExtent,
              child: leading,
            )
          else
            leading!,
          SizedBox(width: gap),
        ] else if (icon != null) ...[
          if (leadingExtent != null)
            SizedBox(
              width: leadingExtent,
              child: Center(
                heightFactor: 1,
                child: tileColor != null
                    ? tile(tileColor)
                    : AcademySfIcon(
                        icon!,
                        size: AcademyTheme.of(context).sizes.rowIcon,
                        color: CupertinoTheme.of(context).primaryColor,
                      ),
              ),
            )
          else if (tileColor != null)
            tile(tileColor)
          else
            AcademySfIcon(
              icon!,
              size: AcademyTheme.of(context).sizes.rowIcon,
              boxSize: AcademyTheme.of(context).sizes.rowIconExtent,
              paintExtent: AcademyTheme.of(context).sizes.rowIconExtent,
              color: CupertinoTheme.of(context).primaryColor,
            ),
          SizedBox(width: gap),
        ],
        Expanded(
          child: aroundText(
            Column(
              crossAxisAlignment: subtitleTextAlign == TextAlign.start
                  ? CrossAxisAlignment.start
                  : CrossAxisAlignment.stretch,
              children: [
                if (eyebrow != null)
                  Text(
                    eyebrow!,
                    style: theme.textTheme.bodySmall.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                titleWidget ??
                    (actionLabel != null
                        ? LayoutBuilder(
                            builder: (context, constraints) {
                              final titleText = Text(title, style: titleStyle);
                              final actionText = Text(
                                actionLabel!,
                                textAlign: TextAlign.end,
                                style: theme.textTheme.bodyRow.copyWith(
                                  color: theme.colorScheme.accentForeground,
                                ),
                              );
                              if (MediaQuery.textScalerOf(context).scale(1) >=
                                  AcademyTokens.adaptiveTextScale) {
                                return Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    titleText,
                                    const SizedBox(
                                      height: AcademyTokens.labelGap,
                                    ),
                                    actionText,
                                  ],
                                );
                              }
                              return Row(
                                children: [
                                  Expanded(child: titleText),
                                  const SizedBox(
                                    width: AcademyTokens.inlineGap,
                                  ),
                                  ConstrainedBox(
                                    constraints: BoxConstraints(
                                      maxWidth: constraints.maxWidth * .6,
                                    ),
                                    child: actionText,
                                  ),
                                ],
                              );
                            },
                          )
                        : Row(
                            children: [
                              Flexible(child: Text(title, style: titleStyle)),
                              if (titleTrailing != null) ...[
                                const SizedBox(width: AcademyTokens.labelGap),
                                titleTrailing!,
                              ],
                            ],
                          )),
                if (subtitleWidget != null)
                  Padding(
                    padding: AcademyTheme.of(context).paddings.rowSubtitle,
                    child: subtitleWidget!,
                  )
                else if (subtitle != null)
                  Padding(
                    padding: AcademyTheme.of(context).paddings.rowSubtitle,
                    child: Text(
                      subtitle!,
                      textAlign: subtitleTextAlign,
                      maxLines: subtitleMaxLines,
                      overflow: subtitleMaxLines == null
                          ? null
                          : TextOverflow.ellipsis,
                      style:
                          subtitleStyle ??
                          table.rowSubtitleStyle ??
                          AcademyTheme.of(context).textTheme.bodyMedium
                              .copyWith(
                                color: AcademyTheme.of(context)
                                    .colorScheme
                                    .onSurfaceVariant,
                              ),
                    ),
                  ),
                if (detail != null)
                  Padding(
                    padding: const EdgeInsets.only(top: AcademyTokens.labelGap),
                    child: Align(
                      alignment: AlignmentDirectional.centerStart,
                      child: detail,
                    ),
                  ),
                if (trailingTextMoves)
                  Padding(
                    padding: const EdgeInsets.only(top: AcademyTokens.labelGap),
                    child: Text(
                      trailingText!,
                      style: AcademyRowTrailingText.styleOf(
                        context,
                        trailingTextStyle,
                      ),
                    ),
                  ),
                if (trailingMoves)
                  Padding(
                    padding: const EdgeInsets.only(top: AcademyTokens.labelGap),
                    child: Align(
                      alignment: AlignmentDirectional.centerStart,
                      child: switch (trailing) {
                        final AcademyRowTrailingText text => Text(
                          text.text,
                          style: AcademyRowTrailingText.styleOf(
                            context,
                            text.style,
                          ),
                        ),
                        _ => AcademyRowEnabledScope(
                          enabled: enabled,
                          child: trailing!,
                        ),
                      },
                    ),
                  ),
              ],
            ),
          ),
        ),
        if (trailingText != null && !trailingTextMoves) ...[
          const SizedBox(width: AcademyTokens.inlineGap),
          aroundText(
            AcademyRowTrailingText(trailingText!, style: trailingTextStyle),
          ),
        ],
        if (trailing != null) ...[
          if (!trailingMoves) ...[
            SizedBox(width: trailingSpacing ?? table.trailingSpacing),
            AcademyRowEnabledScope(enabled: enabled, child: trailing!),
          ],
        ] else if (onPressed != null &&
            actionLabel == null &&
            (showChevron ?? table.showChevron))
          chevron ??
              table.navigationChevron ??
              table.chevronBuilder?.call(context, 0) ??
              Padding(
                padding: const EdgeInsetsDirectional.only(
                  start: AcademyTokens.labelGap,
                ),
                child: AcademyChevron(
                  size: theme.sizes.rowChevron,
                  color: toneColor,
                ),
              ),
      ],
    );
    final endInset =
        horizontalPadding ??
        (!AcademyTableRowScope.contains(context)
            ? 0.0
            : theme.paddings.tableRow.right);
    final content = Padding(
      padding: EdgeInsetsDirectional.fromSTEB(
        horizontalPadding ?? AcademyTableRowScope.of(context),
        paddingAroundText ? 0 : textVertical,
        stretchTrailing ? 0 : endInset,
        paddingAroundText
            ? 0
            : verticalPadding ?? theme.paddings.tableRow.bottom,
      ),
      child: stretchTrailing ? IntrinsicHeight(child: body) : body,
    );
    final interaction = GestureDetector(
      onLongPress: enabled ? onLongPress : null,
      child: Opacity(opacity: enabled ? 1 : .45, child: content),
    );
    final merges = switch (trailing) {
      CupertinoSwitch() || AcademySwitch() => true,
      final AcademyRowAccessory accessory => accessory.mergesIntoRow,
      _ => false,
    };
    // Every way of drawing the row announces the same state.
    Widget announced(Widget child) {
      final merged = merges ? MergeSemantics(child: child) : child;
      return selected == null
          ? merged
          : Semantics(selected: selected, child: merged);
    }

    final accessible = announced(interaction);
    final tappable = enabled && (onPressed != null || onLongPress != null);
    final row = table.press != null && tappable
        ? ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: minHeight ?? theme.sizes.rowHeight,
            ),
            child: PressScale(
              onTap: onPressed,
              onLongPress: onLongPress,
              pressedScale: table.press!.scale,
              pressDuration: table.press!.duration,
              releaseDuration: table.press!.duration,
              pressDelay: table.press!.delay,
              child: announced(content),
            ),
          )
        : onPressed == null
        ? ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: minHeight ?? AcademyTheme.of(context).sizes.rowHeight,
            ),
            child: accessible,
          )
        : pressedColor != null
        ? Semantics(
            button: true,
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight:
                    minHeight ?? AcademyTheme.of(context).sizes.rowHeight,
              ),
              child: CupertinoListTile(
                padding: EdgeInsets.zero,
                leadingSize: 0,
                backgroundColorActivated: pressedColor,
                onTap: enabled ? onPressed : null,
                title: DefaultTextStyle(
                  style: theme.textTheme.bodyRow,
                  // The native tile title is one line; rows keep Dynamic Type.
                  child: accessible,
                ),
              ),
            ),
          )
        : CupertinoButton(
            padding: EdgeInsets.zero,
            onPressed: enabled ? onPressed : null,
            minimumSize: Size(
              AcademyTokens.target,
              minHeight ?? AcademyTheme.of(context).sizes.rowHeight,
            ),
            child: accessible,
          );
    final Widget semantics = excludeFromSemantics
        ? ExcludeSemantics(child: row)
        : semanticLabel != null ||
              semanticHint != null ||
              table.mergeRowSemantics
        ? Semantics(
            container: true,
            button: tappable,
            enabled: enabled,
            label: semanticLabel,
            hint: semanticHint,
            excludeSemantics: semanticLabel != null,
            child: table.mergeRowSemantics ? MergeSemantics(child: row) : row,
          )
        : AcademyInteractionBlocker(
            enabled: enabled,
            label: title,
            value: subtitle,
            button: onPressed != null,
            checked: switch (trailing) {
              final CupertinoSwitch toggle => toggle.value,
              final AcademySwitch toggle => toggle.value,
              final AcademyRowAccessory accessory => accessory.toggleValue,
              _ => null,
            },
            child: row,
          );
    return wrapper?.call(context, semantics) ?? semantics;
  }
}
