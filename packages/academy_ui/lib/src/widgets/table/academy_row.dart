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
    this.minHeight = AcademyTokens.tableRowHeight,
    this.horizontalPadding,
    this.verticalPadding,
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
       minHeight = AcademyTokens.tableRowHeight,
       horizontalPadding = null,
       verticalPadding = null;

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
  final double minHeight;
  final double? verticalPadding;
  final double? horizontalPadding;
  final Widget? trailing;

  /// Navigation accessory; does not reserve space when hidden.
  final bool showChevron;
  final VoidCallback? onPressed;
  @override
  double separatorStart(BuildContext context) =>
      (horizontalPadding ?? AcademyTheme.of(context).paddings.tableRow.left) +
      (icon != null || leading != null
          ? AcademyTokens.tableIconExtent + AcademyTokens.inlineGap
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
    final titleStyle = theme.textTheme.bodyRow.copyWith(
      color:
          toneColor ??
          (actionLabel != null ? theme.colorScheme.onSurfaceVariant : null),
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
        children: [
          if (leading != null) ...[
            SizedBox(width: AcademyTokens.tableIconExtent, child: leading),
            const SizedBox(width: AcademyTokens.inlineGap),
          ] else if (icon != null) ...[
            if (tileColor != null)
              Container(
                width: AcademyTokens.tableIconExtent,
                height: AcademyTokens.tableIconExtent,
                decoration: BoxDecoration(
                  color: tileColor,
                  borderRadius: BorderRadius.circular(
                    AcademyTheme.of(context).radii.rowIcon,
                  ),
                ),
                alignment: Alignment.center,
                child: AcademySfIcon(
                  icon!,
                  size: 17,
                  color: tone == null || tone == AcademyTone.error
                      ? theme.colorScheme.iconOnColoredSurface
                      : AcademyContrast.foreground(
                          theme.colorScheme.iconOnColoredSurface,
                          tileColor,
                        ),
                ),
              )
            else
              AcademySfIcon(
                icon!,
                size: 22,
                boxSize: AcademyTokens.tableIconExtent,
                paintExtent: AcademyTokens.tableIconExtent,
                color: CupertinoTheme.of(context).primaryColor,
              ),
            const SizedBox(width: AcademyTokens.inlineGap),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
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
                      style: AcademyTheme.of(context).textTheme.bodyMedium
                          .copyWith(
                            color: AcademyTheme.of(context)
                                .colorScheme
                                .onSurfaceVariant,
                          ),
                    ),
                  ),
              ],
            ),
          ),
          if (trailing != null) ...[
            const SizedBox(width: AcademyTokens.inlineGap),
            trailing!,
          ] else if (onPressed != null && actionLabel == null && showChevron)
            AcademySfIcon(AcademySymbols.forward, size: 16, color: toneColor),
        ],
      ),
    );
    final interaction = GestureDetector(
      onLongPress: enabled ? onLongPress : null,
      child: Opacity(opacity: enabled ? 1 : .45, child: content),
    );
    final accessible = trailing is CupertinoSwitch
        ? MergeSemantics(child: interaction)
        : interaction;
    final row = onPressed == null
        ? ConstrainedBox(
            constraints: BoxConstraints(minHeight: minHeight),
            child: accessible,
          )
        : CupertinoButton(
            padding: EdgeInsets.zero,
            onPressed: enabled ? onPressed : null,
            minimumSize: Size(AcademyTokens.target, minHeight),
            child: accessible,
          );
    return AcademyInteractionBlocker(
      enabled: enabled,
      label: title,
      value: subtitle,
      button: onPressed != null,
      checked: trailing is CupertinoSwitch
          ? (trailing as CupertinoSwitch).value
          : null,
      child: row,
    );
  }
}
