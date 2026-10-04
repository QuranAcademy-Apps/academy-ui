import 'package:flutter/cupertino.dart';

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
    this.floatingLabel,
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
    this.backgroundColor,
  }) : assert(cornerRadius == null || cornerRadius >= 0);

  final TextEditingController? controller;
  final FocusNode? focusNode;
  final ValueChanged<String>? onChanged, onSubmitted;

  /// Optional in-field label that floats on focus or when a value is present.
  final String? floatingLabel;
  final String? placeholder, semanticLabel;
  final Widget? leading, trailing;
  final bool enabled, readOnly, obscureText, autofocus, clearable, chrome;
  final bool highlightOnFocus;
  final Color? backgroundColor;
  final TextInputType? keyboardType;
  final TextInputAction textInputAction;
  final double? cornerRadius;
  final EdgeInsetsGeometry? padding;

  @override
  State<AcademyTextInput> createState() => _AcademyTextInputState();
}

class _AcademyTextInputState extends State<AcademyTextInput> {
  TextEditingController? _ownedController;
  FocusNode? _ownedFocus;
  TextEditingController get _controller =>
      widget.controller ?? (_ownedController ??= TextEditingController());
  FocusNode get _focus => widget.focusNode ?? (_ownedFocus ??= FocusNode());

  @override
  void initState() {
    super.initState();
    _focus.addListener(_changed);
    _controller.addListener(_changed);
  }

  void _changed() => setState(() {});

  @override
  void didUpdateWidget(AcademyTextInput oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      (oldWidget.controller ?? _ownedController!).removeListener(_changed);
      _controller.addListener(_changed);
    }
    if (oldWidget.focusNode != widget.focusNode) {
      (oldWidget.focusNode ?? _ownedFocus!).removeListener(_changed);
      _focus.addListener(_changed);
    }
  }

  void _clear() {
    _controller.clear();
    widget.onChanged?.call('');
    _focus.requestFocus();
  }

  @override
  void dispose() {
    _focus.removeListener(_changed);
    _controller.removeListener(_changed);
    _ownedController?.dispose();
    _ownedFocus?.dispose();
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
                  AcademySymbols.clear,
                  size: 18,
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
    final floating = widget.floatingLabel != null;
    final raised = _focus.hasFocus || _controller.text.isNotEmpty;
    final labelStyle = theme.textTheme.bodySmall;
    final labelHeight =
        MediaQuery.textScalerOf(context).scale(labelStyle.fontSize ?? 13) *
        (labelStyle.height ?? 1.2);
    final direction = Directionality.of(context);
    final fieldPadding = theme.paddings.field.resolve(direction);
    final fieldStart = direction == TextDirection.ltr
        ? fieldPadding.left
        : fieldPadding.right;
    final fieldEnd = direction == TextDirection.ltr
        ? fieldPadding.right
        : fieldPadding.left;
    final inputPadding = floating
        ? EdgeInsetsDirectional.fromSTEB(
            fieldStart,
            8 + labelHeight + 4,
            fieldEnd,
            12,
          )
        : widget.padding ?? theme.paddings.field;
    final input = Semantics(
      label: widget.semanticLabel ?? widget.floatingLabel,
      child: TweenAnimationBuilder<Color?>(
        tween: ColorTween(
          end: !widget.enabled
              ? (MediaQuery.highContrastOf(context)
                    ? AcademyContrast.foreground(
                        colors.textFieldDisabledBorder,
                        colors.textFieldDisabledBackground,
                        minimum: 3,
                      )
                    : colors.textFieldDisabledBorder)
              : widget.highlightOnFocus && _focus.hasFocus
              ? colors.textFieldFocusBorder
              : MediaQuery.highContrastOf(context)
              ? colors.textFieldControlBorder
              : colors.textFieldBorder,
        ),
        duration: duration,
        curve: Curves.easeInOut,
        builder: (context, borderColor, _) {
          final editor = CupertinoTextField(
            controller: _controller,
            focusNode: _focus,
            enabled: widget.enabled,
            readOnly: widget.readOnly,
            obscureText: widget.obscureText,
            autofocus: widget.autofocus,
            onChanged: widget.onChanged,
            onSubmitted: (value) {
              _focus.unfocus();
              widget.onSubmitted?.call(value);
            },
            keyboardType: widget.keyboardType,
            textInputAction: widget.textInputAction,
            cursorColor: colors.accentForeground,
            placeholder: floating
                ? null
                : widget.placeholder ??
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
                : floating
                ? SizedBox(
                    width: AcademyTokens.target,
                    child: Center(child: widget.leading),
                  )
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
                      color: borderColor ?? colors.textFieldBorder,
                      width: 1,
                    ),
                  ),
          );
          if (!floating) return editor;
          return Stack(
            children: [
              editor,
              Positioned.fill(
                child: IgnorePointer(
                  child: ExcludeSemantics(
                    child: Padding(
                      padding: EdgeInsetsDirectional.only(
                        start:
                            fieldStart +
                            (widget.leading == null ? 0 : AcademyTokens.target),
                        end:
                            (widget.clearable ? AcademyTokens.target : 0) +
                            (widget.trailing == null
                                ? 0
                                : AcademyTokens.target) +
                            12,
                      ),
                      child: AnimatedAlign(
                        alignment: raised
                            ? AlignmentDirectional.topStart
                            : AlignmentDirectional.centerStart,
                        duration: duration,
                        curve: Curves.easeInOut,
                        child: AnimatedPadding(
                          duration: duration,
                          curve: Curves.easeInOut,
                          padding: EdgeInsets.only(top: raised ? 8 : 0),
                          child: AnimatedDefaultTextStyle(
                            duration: duration,
                            curve: Curves.easeInOut,
                            style:
                                (raised
                                        ? labelStyle
                                        : theme.textTheme.bodyLarge)
                                    .copyWith(
                                      color: widget.enabled
                                          ? colors.textFieldSecondaryForeground
                                          : colors.textFieldDisabledForeground,
                                    ),
                            child: Text(
                              widget.floatingLabel!,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
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
