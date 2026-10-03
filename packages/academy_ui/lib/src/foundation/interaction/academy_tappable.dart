import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';

import '../../theme/academy_theme.dart';

/// Shared states for custom controls. Native Cupertino buttons remain native.
class AcademyTappable extends StatefulWidget {
  const AcademyTappable({
    super.key,
    required this.builder,
    this.onPressed,
    this.onLongPress,
    this.label,
    this.selected,
    this.focusNode,
    this.autofocus = false,
    this.borderRadius,
    this.focusColor,
  });
  final Widget Function(BuildContext, Set<WidgetState>) builder;
  final VoidCallback? onPressed, onLongPress;
  final String? label;
  final bool? selected;
  final FocusNode? focusNode;
  final bool autofocus;
  final BorderRadius? borderRadius;
  final Color? focusColor;
  @override
  State<AcademyTappable> createState() => _AcademyTappableState();
}

class _AcademyTappableState extends State<AcademyTappable> {
  bool _hovered = false, _focused = false, _pressed = false;
  bool get _enabled => widget.onPressed != null || widget.onLongPress != null;
  @override
  void didUpdateWidget(AcademyTappable oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!_enabled) _hovered = _focused = _pressed = false;
  }

  @override
  Widget build(BuildContext context) {
    final states = <WidgetState>{
      if (!_enabled) WidgetState.disabled,
      if (_hovered) WidgetState.hovered,
      if (_focused) WidgetState.focused,
      if (_pressed) WidgetState.pressed,
      if (widget.selected == true) WidgetState.selected,
    };
    return Semantics(
      button: true,
      enabled: _enabled,
      selected: widget.selected,
      label: widget.label,
      onTap: widget.onPressed,
      onLongPress: widget.onLongPress,
      child: FocusableActionDetector(
        enabled: _enabled,
        focusNode: widget.focusNode,
        autofocus: widget.autofocus,
        mouseCursor: _enabled
            ? SystemMouseCursors.click
            : SystemMouseCursors.basic,
        onShowHoverHighlight: (v) => setState(() => _hovered = v),
        onShowFocusHighlight: (v) => setState(() => _focused = v),
        shortcuts: const {
          SingleActivator(LogicalKeyboardKey.enter): ActivateIntent(),
          SingleActivator(LogicalKeyboardKey.space): ActivateIntent(),
        },
        actions: {
          ActivateIntent: CallbackAction<ActivateIntent>(
            onInvoke: (_) {
              widget.onPressed?.call();
              return null;
            },
          ),
        },
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          excludeFromSemantics: true,
          onTap: widget.onPressed,
          onLongPress: widget.onLongPress,
          onTapDown: _enabled ? (_) => setState(() => _pressed = true) : null,
          onTapUp: _enabled ? (_) => setState(() => _pressed = false) : null,
          onTapCancel: _enabled ? () => setState(() => _pressed = false) : null,
          child: AcademyFocusOutline(
            focused: _focused,
            borderRadius: widget.borderRadius,
            focusColor: widget.focusColor,
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: AcademyTheme.of(context).interaction.minimumTarget,
              ),
              child: widget.builder(context, Set.unmodifiable(states)),
            ),
          ),
        ),
      ),
    );
  }
}

/// A foreground border reserves no layout space when keyboard focus changes.
class AcademyFocusOutline extends StatelessWidget {
  const AcademyFocusOutline({
    super.key,
    required this.focused,
    required this.child,
    this.borderRadius,
    this.focusColor,
  });
  final bool focused;
  final Widget child;
  final BorderRadius? borderRadius;
  final Color? focusColor;
  @override
  Widget build(BuildContext context) => DecoratedBox(
    position: DecorationPosition.foreground,
    decoration: BoxDecoration(
      borderRadius:
          borderRadius ??
          BorderRadius.circular(AcademyTheme.of(context).radii.button),
      border: Border.all(
        color: focused
            ? focusColor ??
                  AcademyTheme.of(context).colorScheme.accentForeground
            : const Color(0x00000000),
        width: 2,
      ),
    ),
    child: child,
  );
}
