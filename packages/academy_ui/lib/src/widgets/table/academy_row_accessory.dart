import 'package:flutter/cupertino.dart';

import '../../foundation/interaction/academy_interaction.dart';
import '../../foundation/localizations/academy_localizations.dart';
import '../../theme/academy_theme.dart';
import '../icon/academy_accessories.dart';
import '../icon/academy_chevron.dart';
import '../icon/academy_sf_image.dart';
import '../menu/academy_menu_anchor.dart';
import '../stepper/academy_stepper.dart';
import '../switch/academy_switch.dart';

/// Tells accessories of a disabled row to disable themselves too.
class AcademyRowEnabledScope extends InheritedWidget {
  const AcademyRowEnabledScope({
    super.key,
    required this.enabled,
    required super.child,
  });
  final bool enabled;
  static bool of(BuildContext context) =>
      context
          .dependOnInheritedWidgetOfExactType<AcademyRowEnabledScope>()
          ?.enabled ??
      true;
  @override
  bool updateShouldNotify(AcademyRowEnabledScope oldWidget) =>
      enabled != oldWidget.enabled;
}

/// One line of secondary text at the end of a row.
class AcademyRowTrailingText extends StatelessWidget {
  const AcademyRowTrailingText(
    this.text, {
    super.key,
    this.style,
    this.disclosure = false,
  });
  final String text;
  final TextStyle? style;

  /// Adds the row's chevron after the text.
  final bool disclosure;

  /// The look of the text: [style], else the table theme's trailing style.
  static TextStyle styleOf(BuildContext context, TextStyle? style) {
    final theme = AcademyTheme.of(context);
    return style ??
        theme.table.rowTrailingStyle ??
        theme.textTheme.bodyRow.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
        );
  }

  @override
  Widget build(BuildContext context) {
    if (disclosure) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          AcademyRowTrailingText(text, style: style),
          const SizedBox(width: 8),
          const AcademyRowDisclosure(),
        ],
      );
    }
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 170),
      child: Text(
        text,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        textAlign: TextAlign.end,
        style: styleOf(context, style),
      ),
    );
  }
}

/// The chevron of a row that opens something; [turns] rotates it.
class AcademyRowDisclosure extends StatelessWidget {
  const AcademyRowDisclosure({super.key, this.turns = 0});
  final double turns;
  @override
  Widget build(BuildContext context) =>
      AcademyTheme.of(context).table.chevronBuilder?.call(context, turns) ??
      AcademyChevron(turns: turns);
}

/// A fixed box for an accessory symbol, optionally tappable. A tappable one
/// keeps the symbol where the box puts it, at the row's end, and grows the touch
/// target around it toward the text.
class AcademyRowAccessoryButton extends StatelessWidget {
  const AcademyRowAccessoryButton({
    super.key,
    required this.child,
    this.onPressed,
    this.size = const Size.square(32),
    this.semanticLabel,
    this.semanticHint,
  });
  final Widget child;
  final VoidCallback? onPressed;
  final Size size;
  final String? semanticLabel, semanticHint;
  @override
  Widget build(BuildContext context) {
    final content = SizedBox.fromSize(
      size: size,
      child: Center(child: child),
    );
    if (onPressed == null) return content;
    return CupertinoButton(
      padding: EdgeInsets.zero,
      minimumSize: const Size(AcademyTokens.target, AcademyTokens.target),
      alignment: AlignmentDirectional.centerEnd,
      onPressed: onPressed,
      child: Semantics(
        button: true,
        enabled: true,
        label: semanticLabel,
        hint: semanticHint,
        child: content,
      ),
    );
  }
}

enum _Kind { toggle, toggleWithButton, stepper, menu, dragHandle }

/// The controls a row can carry at its end. Text, chevrons and checks are plain
/// widgets: [AcademyRowTrailingText], [AcademyRowDisclosure], [AcademyCheckmark].
class AcademyRowAccessory extends StatelessWidget {
  const AcademyRowAccessory.toggle({
    super.key,
    required bool this.value,
    required this.onChanged,
  }) : _kind = _Kind.toggle,
       onButtonPressed = null,
       onDecrease = null,
       onIncrease = null,
       title = null,
       itemBuilder = null,
       useRootOverlay = null,
       semanticLabel = null;

  /// A switch with a «more» button before it.
  const AcademyRowAccessory.toggleWithButton({
    super.key,
    required bool this.value,
    required this.onChanged,
    required this.onButtonPressed,
  }) : _kind = _Kind.toggleWithButton,
       onDecrease = null,
       onIncrease = null,
       title = null,
       itemBuilder = null,
       useRootOverlay = null,
       semanticLabel = null;

  const AcademyRowAccessory.stepper({
    super.key,
    required this.onDecrease,
    required this.onIncrease,
  }) : _kind = _Kind.stepper,
       value = null,
       onChanged = null,
       onButtonPressed = null,
       title = null,
       itemBuilder = null,
       useRootOverlay = null,
       semanticLabel = null;

  /// The current value with an up-down indicator, opening a pull-down menu.
  const AcademyRowAccessory.menu({
    super.key,
    required String this.title,
    required List<Widget> Function(BuildContext context) this.itemBuilder,
    this.useRootOverlay,
  }) : _kind = _Kind.menu,
       value = null,
       onChanged = null,
       onButtonPressed = null,
       onDecrease = null,
       onIncrease = null,
       semanticLabel = null;

  /// Full-height reorder handle, flush with the row's end.
  const AcademyRowAccessory.dragHandle({super.key, this.semanticLabel})
    : _kind = _Kind.dragHandle,
      value = null,
      onChanged = null,
      onButtonPressed = null,
      onDecrease = null,
      onIncrease = null,
      title = null,
      itemBuilder = null,
      useRootOverlay = null;

  final _Kind _kind;
  final bool? value;
  final ValueChanged<bool>? onChanged;
  final VoidCallback? onButtonPressed, onDecrease, onIncrease;
  final String? title;
  final List<Widget> Function(BuildContext context)? itemBuilder;
  final bool? useRootOverlay;
  final String? semanticLabel;

  /// The row gives this accessory its full height and no end padding.
  bool get stretches => _kind == _Kind.dragHandle;

  /// The value of a switch accessory, which the row announces as its own state.
  bool? get toggleValue => value;

  /// A lone switch reads as one element with the row. A switch beside another
  /// button stays separate.
  bool get mergesIntoRow => _kind == _Kind.toggle;

  /// Carries a 44pt touch target, which the row fits in without growing.
  bool get hasTallTarget =>
      _kind == _Kind.toggleWithButton || _kind == _Kind.menu;

  /// The current value of a menu, which moves under the title at large text.
  bool get movesUnderTitle => _kind == _Kind.menu;

  @override
  Widget build(BuildContext context) {
    final theme = AcademyTheme.of(context);
    final enabled = AcademyRowEnabledScope.of(context);
    Widget toggle() =>
        AcademySwitch(value: value!, onChanged: enabled ? onChanged : null);
    switch (_kind) {
      case _Kind.toggle:
        return toggle();
      case _Kind.toggleWithButton:
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            AcademyRowAccessoryButton(
              onPressed: enabled ? onButtonPressed : null,
              size: const Size(36, 36),
              semanticLabel: AcademyLocalizations.of(context).more,
              child: AcademySfIcon(
                theme.icons.more,
                fontSize: theme.sizes.menuIcon,
                scaleWithText: true,
                mirrorInRtl: false,
              ),
            ),
            toggle(),
          ],
        );
      case _Kind.stepper:
        return AcademyStepper.actions(
          onDecrease: enabled ? onDecrease : null,
          onIncrease: enabled ? onIncrease : null,
          color: theme.colorScheme.onSurface,
        );
      case _Kind.menu:
        return AcademyMenuAnchor(
          consumeOutsideTaps: true,
          useRootOverlay: useRootOverlay,
          menuChildren: itemBuilder!(context),
          builder: (context, controller, _) => AcademyActionSemantics(
            label: title!,
            enabled: enabled,
            expanded: controller.isOpen,
            child: CupertinoButton(
              padding: EdgeInsets.zero,
              minimumSize: const Size(
                AcademyTokens.target,
                AcademyTokens.target,
              ),
              onPressed: enabled
                  ? () => controller.isOpen
                        ? controller.close()
                        : controller.open()
                  : null,
              child: ExcludeSemantics(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Capped and ellipsized, so a long value cannot overflow.
                    AcademyRowTrailingText(title!),
                    const SizedBox(width: 8),
                    Icon(
                      theme.icons.upDown,
                      size: theme.sizes.indicatorIcon,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      case _Kind.dragHandle:
        return DecoratedBox(
          decoration: BoxDecoration(
            border: BorderDirectional(
              start: BorderSide(
                color: theme.colorScheme.outlineVariant,
                width: 0.5,
              ),
            ),
          ),
          child: SizedBox(
            width: 54,
            child: Center(
              child: AcademySfIcon(
                theme.icons.dragHandle,
                fontSize: 22,
                fontWeight: FontWeight.w700,
                scaleWithText: true,
                mirrorInRtl: false,
                color:
                    theme.table.accessoryIconColor ??
                    theme.colorScheme.onSurface,
                semanticsLabel:
                    semanticLabel ?? AcademyLocalizations.of(context).drag,
              ),
            ),
          ),
        );
    }
  }
}
