import '../text_field/academy_text_input.dart';
import '../../foundation/localizations/academy_localizations.dart';

import 'package:flutter/cupertino.dart';

import '../../theme/academy_theme.dart';
import '../icon/academy_sf_image.dart';
import '../navigation/chrome/academy_chrome.dart';

class AcademySearchBar extends StatefulWidget {
  const AcademySearchBar({
    super.key,
    required this.controller,
    this.onChanged,
    this.onCancel,
    this.loading = false,
    this.chrome = true,
    this.placeholder,
    this.leading,
    this.trailing,
    this.focusNode,
    this.onSubmitted,
    this.enabled = true,
    this.clearable = false,
    this.cornerRadius,
    this.autofocus = false,
    this.backgroundColor,
    this.onClear,
  });
  final TextEditingController controller;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onCancel;
  final bool loading;
  final String? placeholder;
  final Widget? leading, trailing;
  final FocusNode? focusNode;
  final ValueChanged<String>? onSubmitted;
  final bool enabled, clearable;
  final double? cornerRadius;
  final bool autofocus;

  /// Called after the clear button emptied the field.
  final VoidCallback? onClear;

  /// Replaces the field fill (for example transparent inside a capsule).
  final Color? backgroundColor;

  /// Match the navigation surface when true; otherwise use the opaque field fill.
  final bool chrome;
  @override
  State<AcademySearchBar> createState() => _AcademySearchBarState();
}

class _AcademySearchBarState extends State<AcademySearchBar>
    with SingleTickerProviderStateMixin {
  FocusNode? _ownedFocus;
  FocusNode get _focus => widget.focusNode ?? (_ownedFocus ??= FocusNode());
  late final AnimationController _closeAnimation;
  late final Animation<double> _closeProgress;

  @override
  void initState() {
    super.initState();
    _closeAnimation = AnimationController(
      vsync: this,
      duration: AcademyTokens.searchOpenMotion,
      reverseDuration: AcademyTokens.motion,
    )..addStatusListener(_closeAnimationStatusChanged);
    _closeProgress = CurvedAnimation(
      parent: _closeAnimation,
      curve: Curves.easeOutCubic,
      reverseCurve: Curves.easeInCubic,
    );
    _focus.addListener(_changed);
  }

  @override
  void didUpdateWidget(AcademySearchBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.focusNode != widget.focusNode) {
      (oldWidget.focusNode ?? _ownedFocus!).removeListener(_changed);
      _focus.addListener(_changed);
    }
    if (oldWidget.focusNode != widget.focusNode ||
        oldWidget.onCancel != widget.onCancel ||
        oldWidget.enabled != widget.enabled) {
      _changed();
    }
  }

  void _closeAnimationStatusChanged(AnimationStatus status) {
    if (status == AnimationStatus.dismissed && mounted) setState(() {});
  }

  void _changed() {
    final showCloseButton =
        widget.enabled && _focus.hasFocus && widget.onCancel != null;
    if (MediaQuery.maybeOf(context)?.disableAnimations ?? false) {
      _closeAnimation.value = showCloseButton ? 1 : 0;
    } else if (showCloseButton) {
      _closeAnimation.forward();
    } else {
      _closeAnimation.reverse();
    }
    setState(() {});
  }

  @override
  void dispose() {
    _closeAnimation
      ..removeStatusListener(_closeAnimationStatusChanged)
      ..dispose();
    _focus.removeListener(_changed);
    _ownedFocus?.dispose();
    super.dispose();
  }

  void _clear() {
    widget.controller.clear();
    widget.onChanged?.call('');
  }

  void _cancel() {
    _clear();
    _focus.unfocus();
    widget.onCancel?.call();
  }

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, c) {
      final showCloseButton =
          widget.enabled && _focus.hasFocus && widget.onCancel != null;
      final keepCloseButton =
          showCloseButton ||
          _closeAnimation.status != AnimationStatus.dismissed;
      final theme = AcademyTheme.of(context);
      final field = AcademyTextInput(
        focusNode: _focus,
        autofocus: widget.autofocus,
        onCleared: widget.onClear,
        backgroundColor: widget.backgroundColor,
        controller: widget.controller,
        placeholder:
            widget.placeholder ?? AcademyLocalizations.of(context).search,
        onChanged: widget.onChanged,
        onSubmitted: widget.onSubmitted,
        enabled: widget.enabled,
        clearable: widget.clearable,
        textInputAction: TextInputAction.search,
        padding: theme.paddings.search,
        cornerRadius: widget.cornerRadius ?? theme.radii.search,
        chrome: widget.chrome,
        highlightOnFocus: false,
        leading:
            widget.leading ??
            AcademySfIcon(
              AcademySymbols.search,
              size: 18,
              color: widget.chrome
                  ? AcademyChrome.foregroundColor(
                      context,
                      theme.colorScheme.onSurfaceVariant,
                    )
                  : theme.colorScheme.textFieldSecondaryForeground,
            ),
        trailing: widget.loading
            ? const CupertinoActivityIndicator()
            : widget.trailing,
      );
      final closeButton = AcademyChromeButton(
        icon: AcademySymbols.close,
        label: AcademyLocalizations.of(context).closeSearch,
        onPressed: _cancel,
      );
      return Row(
        children: [
          Expanded(child: field),
          if (keepCloseButton)
            AnimatedBuilder(
              key: const ValueKey('search-close-transition'),
              animation: _closeProgress,
              child: closeButton,
              builder: (context, child) {
                final progress = _closeProgress.value;
                return SizedBox(
                  width: 56 * progress,
                  child: Align(
                    alignment: AlignmentDirectional.centerEnd,
                    child: Opacity(
                      opacity: progress,
                      child: Transform.translate(
                        offset: Offset(
                          (Directionality.of(context) == TextDirection.rtl
                                  ? -12
                                  : 12) *
                              (1 - progress),
                          0,
                        ),
                        child: Transform.scale(
                          scale: .82 + .18 * progress,
                          child: child,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
        ],
      );
    },
  );
}
