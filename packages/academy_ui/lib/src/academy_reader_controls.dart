import 'dart:math' as math;

import 'package:cupertino_ui/cupertino_ui.dart';

import 'academy_menu_anchor.dart';
import 'academy_sf_image.dart';
import 'academy_theme.dart';
import 'chrome/academy_chrome.dart';
import 'modal/modal_sheet_corner_mask.dart';

/// Quran TajweedDisclosureCard, with app-owned expansion and opaque fill.
class AcademyDisclosureCard extends StatelessWidget {
  const AcademyDisclosureCard({
    super.key,
    required this.title,
    required this.expanded,
    required this.onToggle,
    required this.child,
  });
  final String title;
  final bool expanded;
  final VoidCallback onToggle;
  final Widget child;
  @override
  Widget build(BuildContext context) {
    final theme = AcademyTheme.of(context);
    final content = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Semantics(
          button: true,
          expanded: expanded,
          child: CupertinoButton(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            minimumSize: const Size(44, 56),
            onPressed: onToggle,
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: theme.textTheme.bodyLarge.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                AcademySfIcon(
                  expanded ? AcademySymbols.up : AcademySymbols.down,
                  size: 18,
                  boxSize: 22,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ],
            ),
          ),
        ),
        AnimatedCrossFade(
          firstChild: const SizedBox(width: double.infinity),
          secondChild: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: SizedBox(width: double.infinity, child: child),
          ),
          crossFadeState: expanded
              ? CrossFadeState.showSecond
              : CrossFadeState.showFirst,
          duration: MediaQuery.disableAnimationsOf(context)
              ? Duration.zero
              : const Duration(milliseconds: 180),
          sizeCurve: Curves.easeInOut,
        ),
      ],
    );
    return ModalSheetMaskedFill(
      color: theme.colorScheme.surface,
      borderRadius: BorderRadius.circular(14),
      child: content,
    );
  }
}

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

/// Quran menu indicator, including the two-line theme/font selector.
class AcademyMenuButton extends StatelessWidget {
  const AcademyMenuButton({
    super.key,
    required this.title,
    required this.items,
    this.subtitle,
    this.chevronOnLeading = false,
    this.enabled = true,
    this.style = AcademyChromeStyle.none,
    this.minimumHeight = 44,
    this.radius = 30,
    this.expand = false,
  });
  final String title;
  final String? subtitle;
  final List<Widget> items;
  final bool chevronOnLeading, enabled;
  final AcademyChromeStyle style;
  final double minimumHeight, radius;
  final bool expand;
  @override
  Widget build(BuildContext context) => AcademyMenuAnchor(
    consumeOutsideTaps: true,
    menuChildren: items,
    builder: (context, controller, _) {
      final theme = AcademyTheme.of(context);
      final chevron = AcademySfIcon(
        AcademySymbols.upDown,
        size: 15,
        color: theme.colorScheme.onSurfaceVariant,
      );
      return AcademyChrome(
        style: style,
        radius: radius,
        child: CupertinoButton(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          minimumSize: Size(44, minimumHeight),
          onPressed: enabled
              ? () => controller.isOpen ? controller.close() : controller.open()
              : null,
          child: Row(
            mainAxisSize: expand ? MainAxisSize.max : MainAxisSize.min,
            children: [
              if (chevronOnLeading) ...[chevron, const SizedBox(width: 12)],
              Flexible(
                fit: expand ? FlexFit.tight : FlexFit.loose,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: theme.textTheme.bodyLarge),
                    if (subtitle != null)
                      Text(
                        subtitle!,
                        style: theme.textTheme.bodySmall.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                  ],
                ),
              ),
              if (!chevronOnLeading) ...[const SizedBox(width: 12), chevron],
            ],
          ),
        ),
      );
    },
  );
}

enum AcademySegmentStyle { pill, compact }

/// Quran ReaderQuickSettingsSquareButton: 68px utility control with rounded corners.
class AcademySettingsSquareButton extends StatelessWidget {
  const AcademySettingsSquareButton({
    super.key,
    required this.icon,
    required this.label,
    required this.onPressed,
    this.onLongPress,
    this.cornerRadius = 34,
    this.foreground,
  });
  final IconData icon;
  final String label;
  final VoidCallback? onPressed, onLongPress;
  final double cornerRadius;
  final Color? foreground;
  @override
  Widget build(BuildContext context) => Semantics(
    label: label,
    button: true,
    child: GestureDetector(
      onLongPress: onLongPress,
      child: CupertinoButton(
        padding: EdgeInsets.zero,
        onPressed: onPressed,
        child: ModalSheetMaskedFill(
          color: AcademyTheme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(cornerRadius),
          child: SizedBox.square(
            dimension: 68,
            child: Center(
              child: AcademySfIcon(
                icon,
                size: 29,
                color: onPressed == null
                    ? AcademyTheme.of(context).colorScheme.onSurfaceVariant
                    : foreground ??
                          AcademyTheme.of(context).colorScheme.primary,
              ),
            ),
          ),
        ),
      ),
    ),
  );
}

/// Quran's 32px quick-settings pill and 31px compact segmented control.
/// The visual control stays small; each segment has a 44px interaction height.
class AcademyCompactSegment<T extends Object> extends StatelessWidget {
  const AcademyCompactSegment({
    super.key,
    required this.items,
    required this.value,
    required this.labelFor,
    required this.onChanged,
    this.iconFor,
    this.style = AcademySegmentStyle.pill,
  }) : assert(items.length > 0);
  final List<T> items;
  final T value;
  final String Function(T) labelFor;
  final IconData Function(T)? iconFor;
  final ValueChanged<T>? onChanged;
  final AcademySegmentStyle style;
  @override
  Widget build(BuildContext context) {
    final theme = AcademyTheme.of(context);
    final selected = items.indexOf(value).clamp(0, items.length - 1);
    final pill = style == AcademySegmentStyle.pill;
    final height = math.max(
      pill ? 32.0 : 31.0,
      iconFor == null ? MediaQuery.textScalerOf(context).scale(13) + 12 : 32.0,
    );
    return SizedBox(
      height: math.max(44, height),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth / items.length;
          return Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                height: height,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: theme.colorScheme.segmentBackground,
                    borderRadius: BorderRadius.circular(pill ? 16 : 8),
                  ),
                  child: const SizedBox.expand(),
                ),
              ),
              if (!pill)
                for (var i = 1; i < items.length; i++)
                  PositionedDirectional(
                    start: width * i,
                    top: (math.max(44, height) - 16) / 2,
                    child: Container(
                      width: .5,
                      height: 16,
                      color: theme.colorScheme.outlineVariant,
                    ),
                  ),
              AnimatedPositionedDirectional(
                duration: MediaQuery.disableAnimationsOf(context)
                    ? Duration.zero
                    : const Duration(milliseconds: 240),
                curve: Curves.easeInOutCubic,
                start: width * selected + 2,
                width: math.max(0, width - 4),
                top: (math.max(44, height) - height) / 2 + 2,
                height: height - 4,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: theme.colorScheme.segmentSelected,
                    borderRadius: BorderRadius.circular(pill ? 14 : 7),
                    boxShadow: [
                      BoxShadow(
                        color: theme.colorScheme.segmentShadow,
                        blurRadius: 2,
                        offset: Offset(0, 1),
                      ),
                    ],
                  ),
                ),
              ),
              Row(
                children: [
                  for (final item in items)
                    Expanded(
                      child: Semantics(
                        button: true,
                        selected: item == value,
                        enabled: onChanged != null,
                        onTap: onChanged == null
                            ? null
                            : () {
                                if (item != value) onChanged!(item);
                              },
                        label: labelFor(item),
                        excludeSemantics: true,
                        child: CupertinoButton(
                          padding: EdgeInsets.zero,
                          minimumSize: const Size(44, 44),
                          onPressed: onChanged == null
                              ? null
                              : () {
                                  if (item != value) onChanged!(item);
                                },
                          child: iconFor == null
                              ? Text(
                                  labelFor(item),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: theme.textTheme.bodySmall.copyWith(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                  ),
                                )
                              : AcademySfIcon(
                                  iconFor!(item),
                                  size: 18,
                                  color: item == value
                                      ? theme.colorScheme.onSurface
                                      : theme.colorScheme.onSurfaceVariant,
                                ),
                        ),
                      ),
                    ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}

/// Quran's small close/utility button. Surface 28px, hit area at least 44px.
class AcademyCompactIconButton extends StatelessWidget {
  const AcademyCompactIconButton({
    super.key,
    this.icon = AcademySymbols.close,
    this.label = 'Закрыть',
    required this.onPressed,
  });
  final IconData icon;
  final String label;
  final VoidCallback? onPressed;
  @override
  Widget build(BuildContext context) => Semantics(
    label: label,
    button: true,
    child: CupertinoButton(
      padding: EdgeInsets.zero,
      minimumSize: const Size(44, 44),
      onPressed: onPressed,
      child: Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AcademyTheme.of(context).colorScheme.segmentBackground,
        ),
        child: Center(
          child: AcademySfIcon(
            icon,
            size: 17,
            color: AcademyTheme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      ),
    ),
  );
}
