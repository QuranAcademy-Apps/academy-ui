import 'package:cupertino_ui/cupertino_ui.dart';

import '../../foundation/form/academy_field_style.dart';
import '../../foundation/form/academy_owned_editing.dart';
import '../../foundation/localizations/academy_localizations.dart';
import '../icon/academy_sf_image.dart';
import '../../theme/academy_theme.dart';
import '../navigation/chrome/academy_chrome.dart';

/// Shared editing, focus, decoration and accessory slots for every input variant.
/// Controllers and focus nodes supplied by the caller remain caller-owned.
class AcademyTextInput extends StatefulWidget {
  const AcademyTextInput({
    super.key,
    this.controller,
    this.focusNode,
    this.onChanged,
    this.onSubmitted,
    this.placeholder,
    this.semanticLabel,
    this.leading,
    this.trailing,
    this.enabled = true,
    this.readOnly = false,
    this.obscureText = false,
    this.autofocus = false,
    this.clearable = true,
    this.keyboardType,
    this.textInputAction = TextInputAction.done,
    this.cornerRadius,
    this.padding,
    this.chrome = false,
    this.highlightOnFocus = true,
    this.bordered = true,
    this.backgroundColor,
    this.onCleared,
  }) : assert(cornerRadius == null || cornerRadius >= 0);

  final TextEditingController? controller;
  final FocusNode? focusNode;
  final ValueChanged<String>? onChanged, onSubmitted;

  final String? placeholder, semanticLabel;
  final Widget? leading, trailing;
  final bool enabled, readOnly, obscureText, autofocus, clearable, chrome;

  /// Draws the resting outline; search fields stay borderless.
  final bool bordered;
  final bool highlightOnFocus;
  final Color? backgroundColor;

  /// Called after the clear button emptied the field.
  final VoidCallback? onCleared;
  final TextInputType? keyboardType;
  final TextInputAction textInputAction;
  final double? cornerRadius;
  final EdgeInsetsGeometry? padding;

  @override
  State<AcademyTextInput> createState() => _AcademyTextInputState();
}

class _AcademyTextInputState extends State<AcademyTextInput>
    with
        AcademyOwnedFocus<AcademyTextInput>,
        AcademyOwnedController<AcademyTextInput> {
  TextEditingController get _controller => controller;
  FocusNode get _focus => focus;

  @override
  FocusNode? suppliedFocusNode(AcademyTextInput widget) => widget.focusNode;
  @override
  TextEditingController? suppliedController(AcademyTextInput widget) =>
      widget.controller;
  @override
  void onFocusChanged() => setState(() {});
  @override
  void onTextChanged() => setState(() {});

  @override
  void initState() {
    super.initState();
    attachFocus();
    attachController();
  }

  @override
  void didUpdateWidget(AcademyTextInput oldWidget) {
    super.didUpdateWidget(oldWidget);
    updateController(oldWidget);
    updateFocus(oldWidget);
  }

  void _clear() {
    _controller.clear();
    widget.onChanged?.call('');
    widget.onCleared?.call();
    _focus.requestFocus();
  }

  @override
  void dispose() {
    disposeFocus();
    disposeController();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = AcademyTheme.of(context);
    final colors = theme.colorScheme;
    final radius = widget.cornerRadius ?? theme.radii.field;
    final duration = MediaQuery.disableAnimationsOf(context)
        ? Duration.zero
        : AcademyTokens.motion;
    final canClear =
        widget.enabled && !widget.readOnly && _controller.text.isNotEmpty;
    final clearSlot = SizedBox.square(
      dimension: AcademyTokens.target,
      child: IgnorePointer(
        ignoring: !canClear,
        child: ExcludeSemantics(
          excluding: !canClear,
          child: AnimatedOpacity(
            opacity: canClear ? 1 : 0,
            duration: duration,
            child: Semantics(
              label: AcademyLocalizations.of(context)
                  .clearField(widget.semanticLabel ?? widget.placeholder ?? ''),
              container: true,
              button: true,
              child: CupertinoButton(
                padding: EdgeInsets.zero,
                minimumSize: const Size(
                  AcademyTokens.target,
                  AcademyTokens.target,
                ),
                onPressed: canClear ? _clear : null,
                child: AcademySfIcon(
                  AcademyTheme.of(context).icons.clear,
                  size: AcademyTheme.of(context).sizes.controlIcon,
                  boxSize: 22,
                  color: widget.chrome
                      ? AcademyChrome.foregroundColor(
                          context,
                          colors.onSurfaceVariant,
                        )
                      : colors.textFieldSecondaryForeground,
                ),
              ),
            ),
          ),
        ),
      ),
    );
    final prefixInsets = theme.paddings.searchPrefix;
    final inputPadding = widget.padding ?? theme.paddings.field;
    final input = Semantics(
      label: widget.semanticLabel,
      child: TweenAnimationBuilder<Color?>(
        tween: ColorTween(
          end: academyFieldBorderColor(
            context,
            enabled: widget.enabled,
            focused: widget.highlightOnFocus && _focus.hasFocus,
            bordered: widget.bordered,
          ),
        ),
        duration: duration,
        curve: Curves.easeInOut,
        builder: (context, borderColor, _) {
          return CupertinoTextField(
            controller: _controller,
            focusNode: _focus,
            enabled: widget.enabled,
            readOnly: widget.readOnly,
            obscureText: widget.obscureText,
            autofocus: widget.autofocus,
            onChanged: widget.onChanged,
            // The text input action decides where focus goes: «next» moves on,
            // «done» closes the keyboard.
            onSubmitted: widget.onSubmitted,
            keyboardType: widget.keyboardType,
            textInputAction: widget.textInputAction,
            cursorColor: colors.accentForeground,
            placeholder:
                widget.placeholder ??
                AcademyLocalizations.of(context).inputPlaceholder,
            placeholderStyle: theme.textTheme.bodyLarge.copyWith(
              color: widget.chrome
                  ? AcademyChrome.foregroundColor(
                      context,
                      colors.onSurfaceVariant,
                    )
                  : widget.enabled
                  ? colors.textFieldSecondaryForeground
                  : colors.textFieldDisabledForeground,
            ),
            style: theme.textTheme.bodyLarge.copyWith(
              color: widget.chrome
                  ? AcademyChrome.foregroundColor(
                      context,
                      widget.enabled
                          ? colors.onSurface
                          : colors.onSurfaceVariant,
                    )
                  : widget.enabled
                  ? colors.textFieldForeground
                  : colors.textFieldDisabledForeground,
            ),
            padding: inputPadding,
            prefix: widget.leading == null
                ? null
                : Padding(
                    padding: EdgeInsetsDirectional.fromSTEB(
                      prefixInsets.left,
                      prefixInsets.top,
                      prefixInsets.right,
                      prefixInsets.bottom,
                    ),
                    child: widget.leading,
                  ),
            // Keep the clear slot reserved so text never shifts on focus/clear.
            suffix: widget.trailing == null && !widget.clearable
                ? null
                : Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (widget.clearable) clearSlot,
                      if (widget.trailing != null)
                        SizedBox.square(
                          dimension: AcademyTokens.target,
                          child: Center(child: widget.trailing),
                        ),
                    ],
                  ),
            decoration: widget.chrome
                ? const BoxDecoration()
                : BoxDecoration(
                    color:
                        widget.backgroundColor ??
                        (widget.enabled
                            ? colors.textFieldBackground
                            : colors.textFieldDisabledBackground),
                    borderRadius: BorderRadius.circular(radius),
                    border: Border.all(
                      color: borderColor ?? const Color(0x00000000),
                      width: 1,
                    ),
                  ),
          );
        },
      ),
    );
    return widget.chrome ? AcademyChrome(radius: radius, child: input) : input;
  }
}

/// Plain input without a visible header. Use [AcademyField] for a labelled field.
class AcademyTextField extends StatelessWidget {
  const AcademyTextField({
    super.key,
    this.controller,
    this.focusNode,
    this.onChanged,
    this.onSubmitted,
    this.placeholder,
    this.semanticLabel,
    this.leading,
    this.trailing,
    this.enabled = true,
    this.readOnly = false,
    this.obscureText = false,
    this.autofocus = false,
    this.clearable = true,
    this.keyboardType,
    this.textInputAction = TextInputAction.done,
    this.cornerRadius,
    this.padding,
  });
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final ValueChanged<String>? onChanged, onSubmitted;
  final String? placeholder, semanticLabel;
  final Widget? leading, trailing;
  final bool enabled, readOnly, obscureText, autofocus, clearable;
  final TextInputType? keyboardType;
  final TextInputAction textInputAction;
  final double? cornerRadius;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) => AcademyTextInput(
    controller: controller,
    focusNode: focusNode,
    onChanged: onChanged,
    onSubmitted: onSubmitted,
    placeholder: placeholder,
    semanticLabel: semanticLabel,
    leading: leading,
    trailing: trailing,
    enabled: enabled,
    readOnly: readOnly,
    obscureText: obscureText,
    autofocus: autofocus,
    clearable: clearable,
    keyboardType: keyboardType,
    textInputAction: textInputAction,
    cornerRadius: cornerRadius,
    padding: padding,
  );
}
