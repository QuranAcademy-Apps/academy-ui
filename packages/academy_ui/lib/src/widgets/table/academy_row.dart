import '../switch/academy_switch.dart';
import '../../theme/academy_row_icons.dart';
import '../../foundation/interaction/academy_interaction.dart';
import '../icon/academy_sf_image.dart';

import 'package:flutter/cupertino.dart';

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
    this.showChevron = true,
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
    this.trailingSpacing = AcademyTokens.inlineGap,
    this.chevron,
    this.pressedColor,
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
       trailingSpacing = AcademyTokens.inlineGap,
       chevron = null,
       pressedColor = null;

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
  final bool showChevron;
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

  /// Gap before [trailing].
  final double trailingSpacing;

  /// Replaces the navigation chevron.
  final Widget? chevron;

  /// Highlights the whole row while pressed (grouped-list style) instead of
  /// fading the content.
  final Color? pressedColor;
  @override
  double separatorStart(BuildContext context) =>
      (horizontalPadding ?? AcademyTheme.of(context).paddings.tableRow.left) +
      (icon != null || leading != null
          ? (leadingExtent ?? AcademyTheme.of(context).sizes.rowIconExtent) +
                AcademyTokens.inlineGap
          : 0);

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
    final titleStyle =
        this.titleStyle ??
        theme.textTheme.bodyRow.copyWith(
          color:
              toneColor ??
              (actionLabel != null ? theme.colorScheme.onSurfaceVariant : null),
        );
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
    final content = Padding(
      padding: EdgeInsetsDirectional.fromSTEB(
        horizontalPadding ?? AcademyTableRowScope.of(context),
        verticalPadding ?? AcademyTheme.of(context).paddings.tableRow.top,
        horizontalPadding ??
            (!AcademyTableRowScope.contains(context)
                ? 0
                : AcademyTheme.of(context).paddings.tableRow.right),
        verticalPadding ?? AcademyTheme.of(context).paddings.tableRow.bottom,
      ),
      child: Row(
        crossAxisAlignment:
            crossAxisAlignment ??
            (eyebrow == null
                ? CrossAxisAlignment.center
                : CrossAxisAlignment.start),
        children: [
          if (leading != null) ...[
            if (leadingExtent != null)
              SizedBox.square(dimension: leadingExtent, child: leading)
            else
              SizedBox(
                width: AcademyTheme.of(context).sizes.rowIconExtent,
                child: leading,
              ),
            const SizedBox(width: AcademyTokens.inlineGap),
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
            const SizedBox(width: AcademyTokens.inlineGap),
          ],
          Expanded(
            child: Column(
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
              ],
            ),
          ),
          if (trailing != null) ...[
            SizedBox(width: trailingSpacing),
            trailing!,
          ] else if (onPressed != null && actionLabel == null && showChevron)
            chevron ??
                AcademySfIcon(
                  AcademyTheme.of(context).icons.forward,
                  size: AcademyTheme.of(context).sizes.rowChevron,
                  color: toneColor,
                ),
        ],
      ),
    );
    final interaction = GestureDetector(
      onLongPress: enabled ? onLongPress : null,
      child: Opacity(opacity: enabled ? 1 : .45, child: content),
    );
    final merged = trailing is CupertinoSwitch || trailing is AcademySwitch
        ? MergeSemantics(child: interaction)
        : interaction;
    final accessible = selected == null
        ? merged
        : Semantics(selected: selected, child: merged);
    final row = onPressed == null
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
    return AcademyInteractionBlocker(
      enabled: enabled,
      label: title,
      value: subtitle,
      button: onPressed != null,
      checked: switch (trailing) {
        final CupertinoSwitch toggle => toggle.value,
        final AcademySwitch toggle => toggle.value,
        _ => null,
      },
      child: row,
    );
  }
}
