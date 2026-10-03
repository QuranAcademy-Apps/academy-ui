import '../../foundation/interaction/academy_interaction.dart';
import '../icon/academy_sf_image.dart';

import 'package:flutter/cupertino.dart';

import '../../theme/academy_theme.dart';

import 'academy_divider.dart';

/// Adapted from Quran GroupedTableRow: leading, flexible text and accessory.
class AcademyRow extends StatelessWidget {
  const AcademyRow({
    super.key,
    required this.title,
    this.subtitle,
    this.icon,
    this.iconBackgroundColor,
    this.trailing,
    this.onPressed,
    this.leading,
    this.titleWidget,
    this.subtitleWidget,
    this.titleTrailing,
    this.onLongPress,
    this.enabled = true,
    this.minHeight = 48,
    this.horizontalPadding,
    this.verticalPadding,
  });
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
  final VoidCallback? onPressed;
  @override
  Widget build(BuildContext context) {
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
            if (iconBackgroundColor != null)
              Container(
                width: AcademyTokens.tableIconExtent,
                height: AcademyTokens.tableIconExtent,
                decoration: BoxDecoration(
                  color: iconBackgroundColor,
                  borderRadius: BorderRadius.circular(
                    AcademyTheme.of(context).radii.rowIcon,
                  ),
                ),
                alignment: Alignment.center,
                child: AcademySfIcon(
                  icon!,
                  size: 17,
                  color: AcademyTheme.of(context)
                      .colorScheme
                      .iconOnColoredSurface,
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
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            title,
                            style: AcademyTheme.of(context).textTheme.bodyLarge,
                          ),
                        ),
                        if (titleTrailing != null) ...[
                          const SizedBox(width: AcademyTokens.labelGap),
                          titleTrailing!,
                        ],
                      ],
                    ),
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
          ] else if (onPressed != null)
            const AcademySfIcon(AcademySymbols.forward, size: 16),
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
