import 'academy_menu.dart';
import 'academy_reader_controls.dart';
import 'academy_sf_image.dart';
import 'chrome/academy_chrome.dart';
import 'chrome/academy_chrome_metrics.dart';
import 'academy_page_insets.dart';

import 'package:flutter/cupertino.dart';

import 'academy_theme.dart';

/// Adapted from Quran AppPageScaffold: opaque navigation + explicit safe area.
class AcademyPage extends StatelessWidget {
  const AcademyPage({
    super.key,
    required this.title,
    required this.child,
    this.trailing,
    this.titleWidget,
  });
  final String title;
  final Widget child;
  final Widget? trailing;
  final Widget? titleWidget;
  @override
  Widget build(BuildContext context) {
    final top = academyChromeTopOf(context);
    final barHeight = academyChromeHeightOf(context);
    return CupertinoPageScaffold(
      child: Stack(
        children: [
          Positioned.fill(
            child: Center(
              child: SizedBox(
                width: 430,
                child: AcademyPageInsets(
                  top: academyChromeContentTopOf(context),
                  child: child,
                ),
              ),
            ),
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: IgnorePointer(
              child: Container(
                height: top + barHeight + 16,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      AcademyTheme.of(context).scaffoldBackgroundColor,
                      AcademyTheme.of(context).scaffoldBackgroundColor
                          .withValues(alpha: 0),
                    ],
                    stops: const [.65, 1],
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            top: top,
            left: 0,
            right: 0,
            child: AcademyChromeBar(
              title: titleWidget == null ? title : null,
              middle: titleWidget,
              leading: Navigator.of(context).canPop()
                  ? AcademyChromeButton(
                      icon: AcademySymbols.back,
                      label: 'Назад',
                      onPressed: () => Navigator.maybePop(context),
                    )
                  : null,
            ),
          ),
          if (trailing != null)
            Positioned(top: top, right: 16, child: trailing!),
        ],
      ),
    );
  }
}

/// Quran AppMenuAnchor + AppMenuCheckmark pattern. A short selection stays
/// anchored to its trigger and never opens a modal route.
class AcademyOptionMenu extends StatelessWidget {
  const AcademyOptionMenu({
    super.key,
    required this.label,
    required this.value,
    required this.options,
    required this.onSelected,
    this.icon,
    this.activation = AcademyMenuActivation.row,
    this.menuWidth,
    this.menuMaxHeight,
    this.useRootOverlay,
  });
  final String label, value;
  final List<String> options;
  final ValueChanged<String> onSelected;
  final IconData? icon;
  final AcademyMenuActivation activation;
  final double? menuWidth, menuMaxHeight;
  final bool? useRootOverlay;
  @override
  Widget build(BuildContext context) => AcademyMenuRow(
    label: label,
    value: value,
    icon: icon,
    activation: activation,
    menuWidth: menuWidth,
    menuMaxHeight: menuMaxHeight,
    useRootOverlay: useRootOverlay,
    items: [
      for (final option in options)
        AcademyMenuItem(
          title: option,
          checked: option == value,
          onPressed: () => onSelected(option),
        ),
    ],
  );
}

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
    this.verticalPadding = 10,
  });
  final String title;
  final String? subtitle;
  final IconData? icon;
  final Color? iconBackgroundColor;
  final Widget? leading, titleWidget, subtitleWidget, titleTrailing;
  final VoidCallback? onLongPress;
  final bool enabled;
  final double minHeight, verticalPadding;
  final double? horizontalPadding;
  final Widget? trailing;
  final VoidCallback? onPressed;
  @override
  Widget build(BuildContext context) {
    final content = Padding(
      padding: EdgeInsets.symmetric(
        vertical: verticalPadding,
        horizontal: horizontalPadding ?? AcademyTableRowScope.of(context),
      ),
      child: Row(
        children: [
          if (leading != null) ...[
            SizedBox(width: AcademyTokens.tableIconExtent, child: leading),
            const SizedBox(width: 12),
          ] else if (icon != null) ...[
            if (iconBackgroundColor != null)
              Container(
                width: AcademyTokens.tableIconExtent,
                height: AcademyTokens.tableIconExtent,
                decoration: BoxDecoration(
                  color: iconBackgroundColor,
                  borderRadius: BorderRadius.circular(7),
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
            const SizedBox(width: 12),
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
                          const SizedBox(width: 6),
                          titleTrailing!,
                        ],
                      ],
                    ),
                if (subtitleWidget != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: subtitleWidget!,
                  )
                else if (subtitle != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
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
            const SizedBox(width: 12),
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
    return onPressed == null
        ? ConstrainedBox(
            constraints: BoxConstraints(minHeight: minHeight),
            child: accessible,
          )
        : CupertinoButton(
            padding: EdgeInsets.zero,
            onPressed: enabled ? onPressed : null,
            minimumSize: Size(44, minHeight),
            child: accessible,
          );
  }
}

class AcademyDivider extends StatelessWidget {
  const AcademyDivider({super.key});
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 8),
    child: Container(
      height: .5,
      color: AcademyTheme.of(context).colorScheme.outlineVariant,
    ),
  );
}

class AcademyTableRowScope extends InheritedWidget {
  const AcademyTableRowScope({super.key, required super.child});
  static double of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<AcademyTableRowScope>() == null
      ? 0
      : 16;
  @override
  bool updateShouldNotify(AcademyTableRowScope oldWidget) => false;
}
