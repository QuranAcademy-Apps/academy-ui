import '../../../foundation/localizations/academy_localizations.dart';

import 'package:flutter/cupertino.dart';

import '../../../theme/academy_theme.dart';
import '../../text_field/academy_text_input.dart';
import 'academy_chrome.dart';

/// Quran's search/header swap, extracted into a control with a stable toggle.
/// The expanded navigation search and its toggle share the selected chrome.
/// This does not change ordinary form fields or modal search surfaces.
class AcademyExpandingSearch extends StatefulWidget {
  const AcademyExpandingSearch({
    super.key,
    required this.controller,
    this.resting,
    this.placeholder,
    this.onChanged,
    this.onOpenChanged,
    this.onSubmitted,
    this.focusNode,
    this.enabled = true,
    this.readOnly = false,
  });
  final TextEditingController controller;
  final Widget? resting;
  final String? placeholder;
  final ValueChanged<String>? onChanged;
  final ValueChanged<bool>? onOpenChanged;
  final ValueChanged<String>? onSubmitted;

  /// A supplied node remains owned by the caller.
  final FocusNode? focusNode;
  final bool enabled, readOnly;
  @override
  State<AcademyExpandingSearch> createState() => AcademyExpandingSearchState();
}

/// Use a `GlobalKey<AcademyExpandingSearchState>` to open or close the search
/// from outside (for example, a tap on `AcademySearchScrim`).
class AcademyExpandingSearchState extends State<AcademyExpandingSearch>
    with SingleTickerProviderStateMixin {
  FocusNode? _ownedFocus;
  FocusNode get _focus => widget.focusNode ?? (_ownedFocus ??= FocusNode());
  late final _animation = AnimationController(
    vsync: this,
    duration: AcademyTokens.selectionMotion,
  );
  late final _progress = CurvedAnimation(
    parent: _animation,
    curve: Curves.easeInOutCubic,
  );
  bool _open = false;

  bool get isOpen => _open;

  void open() {
    if (!_open) _toggle();
  }

  void close() {
    if (_open) _toggle();
  }

  void _toggle() {
    if (!widget.enabled) return;
    setState(() => _open = !_open);
    if (MediaQuery.disableAnimationsOf(context)) {
      _animation.value = _open ? 1 : 0;
    } else if (_open) {
      _animation.forward();
    } else {
      _animation.reverse();
    }
    if (_open) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && _open) _focus.requestFocus();
      });
    } else {
      _focus.unfocus();
      widget.controller.clear();
      widget.onChanged?.call('');
    }
    widget.onOpenChanged?.call(_open);
  }

  @override
  void didUpdateWidget(AcademyExpandingSearch oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!widget.enabled) _focus.unfocus();
  }

  @override
  void dispose() {
    _progress.dispose();
    _animation.dispose();
    _ownedFocus?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final duration = MediaQuery.disableAnimationsOf(context)
        ? Duration.zero
        : AcademyTokens.motion;
    return Row(
      children: [
        Expanded(
          child: Stack(
            // The field is anchored to the toggle and grows toward the
            // leading edge; the resting content keeps its own start alignment.
            alignment: AlignmentDirectional.centerEnd,
            children: [
              if (widget.resting != null)
                IgnorePointer(
                  ignoring: _open,
                  child: ExcludeSemantics(
                    excluding: _open,
                    child: AnimatedOpacity(
                      opacity: _open ? 0 : 1,
                      duration: duration,
                      child: Align(
                        alignment: AlignmentDirectional.centerStart,
                        child: widget.resting!,
                      ),
                    ),
                  ),
                ),
              ExcludeSemantics(
                excluding: !_open,
                child: ExcludeFocus(
                  excluding: !_open,
                  child: SizeTransition(
                    sizeFactor: _progress,
                    axis: Axis.horizontal,
                    alignment: AlignmentDirectional.centerEnd,
                    child: AcademyTextInput(
                      controller: widget.controller,
                      focusNode: _focus,
                      enabled: widget.enabled,
                      readOnly: widget.readOnly,
                      onSubmitted: widget.onSubmitted,
                      placeholder:
                          widget.placeholder ??
                          AcademyLocalizations.of(context).search,
                      onChanged: widget.onChanged,
                      textInputAction: TextInputAction.search,
                      chrome: true,
                      clearable: false,
                      highlightOnFocus: false,
                      cornerRadius: AcademyTheme.of(context)
                          .radii
                          .expandingSearch,
                      padding: AcademyTheme.of(context)
                          .paddings
                          .expandingSearch,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        AcademyChromeButton(
          icon: _open
              ? AcademyTheme.of(context).icons.close
              : AcademyTheme.of(context).icons.search,
          label: _open
              ? AcademyLocalizations.of(context).closeSearch
              : AcademyLocalizations.of(context).openSearch,
          onPressed: widget.enabled ? _toggle : null,
        ),
      ],
    );
  }
}
