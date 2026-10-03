import 'package:cupertino_ui/cupertino_ui.dart' hide CupertinoButton;

import '../icon/academy_sf_image.dart';
import '../../theme/academy_theme.dart';

/// Menu row adapted from Quran's pull-down rows and AppMenuCheckmark.
/// Leading/trailing icons and selection are independent; null onPressed disables.
enum AcademyMenuSelectionPosition { leading, trailing, none }

class AcademyMenuItem extends StatelessWidget implements CupertinoMenuEntry {
  const AcademyMenuItem({
    super.key,
    required this.title,
    this.subtitle,
    this.leadingIcon,
    this.trailingIcon,
    this.checked = false,
    this.onPressed,
    this.destructive = false,
    this.selectionPosition = AcademyMenuSelectionPosition.trailing,
    this.leading,
    this.trailing,
    this.titleWidget,
    this.subtitleWidget,
    this.padding,
    this.minimumHeight = 44,
    this.closeOnSelect = true,
    this.leadingWidth,
    this.trailingWidth,
  });
  final String title;
  final String? subtitle;
  final IconData? leadingIcon, trailingIcon;
  final bool checked, destructive;
  final AcademyMenuSelectionPosition selectionPosition;
  final Widget? leading, trailing, titleWidget, subtitleWidget;
  final EdgeInsetsGeometry? padding;
  final double minimumHeight;
  final bool closeOnSelect;
  final double? leadingWidth, trailingWidth;
  @override
  bool get isDivider => false;
  @override
  bool hasLeading(BuildContext context) =>
      leading != null ||
      leadingIcon != null ||
      checked && selectionPosition == AcademyMenuSelectionPosition.leading;
  final VoidCallback? onPressed;
  @override
  Widget build(BuildContext context) {
    final theme = AcademyTheme.of(context);
    final iconColor = destructive
        ? theme.colorScheme.error
        : theme.colorScheme.onSurfaceVariant;
    final showTrailingCheck =
        checked && selectionPosition == AcademyMenuSelectionPosition.trailing;
    final showLeadingCheck =
        checked && selectionPosition == AcademyMenuSelectionPosition.leading;
    final accessoryWidth = trailingIcon != null && showTrailingCheck
        ? 52.0
        : 22.0;
    final resolvedTrailingWidth =
        trailing != null || trailingIcon != null || showTrailingCheck
        ? accessoryWidth +
              28 // 12px text gap + 16px outer inset.
        : 16.0;
    return Semantics(
      selected: checked,
      child: CupertinoMenuItem(
        onPressed: onPressed,
        isDestructiveAction: destructive,
        padding: padding,
        constraints: BoxConstraints(minHeight: minimumHeight),
        requestCloseOnActivate: closeOnSelect,
        // Width includes the 16px outer inset and the 12px text gap.
        leadingWidth:
            leadingWidth ??
            (leadingIcon != null && showLeadingCheck
                ? 80
                : leading != null || leadingIcon != null || showLeadingCheck
                ? 50
                : 16),
        leadingMidpointAlignment: AlignmentDirectional(
          leadingIcon != null && showLeadingCheck ? .05 : .08,
          0,
        ),
        trailingWidth: trailingWidth ?? resolvedTrailingWidth,
        trailingMidpointAlignment: AlignmentDirectional(
          1 - (32 + accessoryWidth) / resolvedTrailingWidth,
          0,
        ),
        decoration: WidgetStateProperty.resolveWith((states) {
          final highlighted =
              states.contains(WidgetState.pressed) ||
              states.contains(WidgetState.hovered) ||
              states.contains(WidgetState.focused);
          return BoxDecoration(
            color: highlighted
                ? theme.colorScheme.menuHighlight
                : theme.colorScheme.surface,
          );
        }),
        leading:
            leading ??
            (showLeadingCheck && leadingIcon != null
                ? Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      AcademySfIcon(
                        AcademySymbols.checkmark,
                        size: 17,
                        boxSize: 22,
                        color: theme.colorScheme.onSurface,
                      ),
                      const SizedBox(width: 8),
                      AcademySfIcon(
                        leadingIcon!,
                        size: 17,
                        boxSize: 22,
                        color: iconColor,
                      ),
                    ],
                  )
                : showLeadingCheck
                ? AcademySfIcon(
                    AcademySymbols.checkmark,
                    size: 17,
                    boxSize: 22,
                    color: theme.colorScheme.onSurface,
                  )
                : leadingIcon == null
                ? null
                : AcademySfIcon(
                    leadingIcon!,
                    size: 17,
                    boxSize: 22,
                    color: iconColor,
                  )),
        trailing:
            trailing ??
            (trailingIcon == null && !showTrailingCheck
                ? null
                : Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (trailingIcon != null)
                        AcademySfIcon(
                          trailingIcon!,
                          size: 17,
                          boxSize: 22,
                          color: iconColor,
                        ),
                      if (trailingIcon != null && showTrailingCheck)
                        const SizedBox(width: 8),
                      if (showTrailingCheck)
                        AcademySfIcon(
                          AcademySymbols.checkmark,
                          size: 17,
                          boxSize: 22,
                          color: theme.colorScheme.onSurface,
                        ),
                    ],
                  )),
        subtitle:
            subtitleWidget ??
            (subtitle == null
                ? null
                : Text(
                    subtitle!,
                    style: theme.textTheme.bodySmall.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  )),
        child:
            titleWidget ??
            Text(
              title,
              style: theme.textTheme.bodyLarge.copyWith(
                color: onPressed == null
                    ? theme.colorScheme.onSurfaceVariant
                    : destructive
                    ? theme.colorScheme.error
                    : theme.colorScheme.onSurface,
              ),
            ),
      ),
    );
  }
}
