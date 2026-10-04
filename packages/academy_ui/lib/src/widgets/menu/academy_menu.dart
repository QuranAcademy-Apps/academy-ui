import 'package:cupertino_ui/cupertino_ui.dart' as menu;
import 'package:flutter/cupertino.dart';

import 'academy_menu_anchor.dart';
import '../table/academy_row.dart';
import '../../foundation/table/academy_table_row_scope.dart';
import '../icon/academy_sf_image.dart';
import '../../theme/academy_theme.dart';

enum AcademyMenuActivation { row, accessory }

/// A menu independent of table rows or navigation buttons.
class AcademyMenu extends StatelessWidget {
  const AcademyMenu({
    super.key,
    required this.items,
    required this.builder,
    this.width,
    this.maxHeight,
    this.useRootOverlay,
    this.onOpen,
    this.onClose,
    this.overlayPadding,
    this.enableLongPress = false,
    this.enableSwipe = true,
    this.controller,
    this.position,
  });
  final List<Widget> items;
  final Widget Function(BuildContext context, VoidCallback toggle) builder;
  final double? width, maxHeight;
  final bool? useRootOverlay;
  final VoidCallback? onOpen, onClose;
  final EdgeInsetsGeometry? overlayPadding;
  final bool enableLongPress, enableSwipe;
  final MenuController? controller;

  /// Optional opening point relative to the anchor's top-left corner.
  final Offset? position;
  @override
  Widget build(BuildContext context) => AcademyMenuAnchor(
    menuChildren: items,
    controller: controller,
    enableSwipe: enableSwipe,
    constraints: width == null && maxHeight == null
        ? null
        : BoxConstraints(
            minWidth: width ?? 0,
            maxWidth: width ?? double.infinity,
            maxHeight: maxHeight ?? double.infinity,
          ),
    useRootOverlay: useRootOverlay,
    consumeOutsideTaps: true,
    overlayPadding: overlayPadding,
    enableLongPressToOpen: enableLongPress,
    onOpen: onOpen,
    onClose: onClose,
    builder: (context, controller, _) => builder(
      context,
      () => controller.isOpen
          ? controller.close()
          : controller.open(position: position),
    ),
  );
}

/// Passive right accessory, used independently when the whole row opens a menu.
class AcademyMenuDisplay extends StatelessWidget {
  const AcademyMenuDisplay({
    super.key,
    required this.value,
    this.icon = AcademySymbols.upDown,
  });
  final String value;
  final IconData icon;
  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Flexible(
        child: Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: AcademyTheme.of(context).textTheme.bodyLarge.copyWith(
            color: AcademyTheme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      ),
      const SizedBox(width: 8),
      AcademySfIcon(
        icon,
        size: 15,
        boxSize: 20,
        color: AcademyTheme.of(context).colorScheme.onSurfaceVariant,
      ),
    ],
  );
}

class AcademyMenuRow extends StatelessWidget
    implements AcademyTableRowGeometry {
  const AcademyMenuRow({
    super.key,
    required this.label,
    required this.value,
    required this.items,
    this.activation = AcademyMenuActivation.row,
    this.icon,
    this.enabled = true,
    this.menuWidth,
    this.menuMaxHeight,
    this.useRootOverlay,
    this.onRowPressed,
  });
  final String label, value;
  final List<Widget> items;
  final AcademyMenuActivation activation;
  final IconData? icon;
  final bool enabled;
  final double? menuWidth, menuMaxHeight;
  final bool? useRootOverlay;

  /// Separate cell action, available only in accessory activation mode.
  final VoidCallback? onRowPressed;
  Widget _menu(Widget Function(BuildContext, VoidCallback) builder) =>
      AcademyMenu(
        items: items,
        width: menuWidth,
        maxHeight: menuMaxHeight,
        useRootOverlay: useRootOverlay,
        builder: builder,
      );
  @override
  double separatorStart(BuildContext context) =>
      AcademyTheme.of(context).paddings.tableRow.left +
      (icon != null
          ? AcademyTokens.tableIconExtent + AcademyTokens.inlineGap
          : 0);

  @override
  Widget build(BuildContext context) {
    final display = AcademyMenuDisplay(value: value);
    if (activation == AcademyMenuActivation.row) {
      return _menu(
        (context, toggle) => AcademyRow(
          title: label,
          icon: icon,
          enabled: enabled,
          onPressed: toggle,
          trailing: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 170),
            child: display,
          ),
        ),
      );
    }
    // Keep the label and accessory actions separate; no nested buttons.
    final row = Padding(
      padding: EdgeInsetsDirectional.only(
        start: AcademyTableRowScope.of(context),
        end: AcademyTableRowScope.contains(context)
            ? AcademyTheme.of(context).paddings.tableRow.right
            : 0,
      ),
      child: Row(
        children: [
          Expanded(
            child: AcademyRow(
              title: label,
              icon: icon,
              enabled: enabled,
              onPressed: onRowPressed,
              horizontalPadding: 0,
              trailing: const SizedBox.shrink(),
            ),
          ),
          const SizedBox(width: AcademyTokens.inlineGap),
          Flexible(
            fit: FlexFit.tight,
            child: Align(
              alignment: AlignmentDirectional.centerEnd,
              child: _menu(
                (context, toggle) => Semantics(
                  label: '$label: $value',
                  button: true,
                  enabled: enabled,
                  excludeSemantics: true,
                  onTap: enabled ? toggle : null,
                  child: CupertinoButton(
                    padding: EdgeInsets.zero,
                    minimumSize: const Size(
                      AcademyTokens.target,
                      AcademyTokens.target,
                    ),
                    onPressed: enabled ? toggle : null,
                    child: display,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
    return row;
  }
}

/// A visible separator usable as an explicit entry in the menu content.
class AcademyMenuSeparator extends StatelessWidget
    implements menu.CupertinoMenuEntry {
  const AcademyMenuSeparator({super.key});
  @override
  bool get isDivider => true;
  @override
  bool hasLeading(BuildContext context) => false;
  @override
  Widget build(BuildContext context) => Container(
    height: .5,
    color: AcademyTheme.of(context).colorScheme.outlineVariant,
  );
}
