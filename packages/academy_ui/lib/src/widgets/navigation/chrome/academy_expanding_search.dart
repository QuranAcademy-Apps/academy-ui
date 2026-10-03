import '../../../foundation/localizations/academy_localizations.dart';

import 'package:flutter/cupertino.dart';

import '../../icon/academy_sf_image.dart';
import '../../../theme/academy_theme.dart';
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
  });
  final TextEditingController controller;
  final Widget? resting;
  final String? placeholder;
  final ValueChanged<String>? onChanged;
  final ValueChanged<bool>? onOpenChanged;
  @override
  State<AcademyExpandingSearch> createState() => _AcademyExpandingSearchState();
}

class _AcademyExpandingSearchState extends State<AcademyExpandingSearch>
    with SingleTickerProviderStateMixin {
  final _focus = FocusNode();
  late final _animation = AnimationController(
    vsync: this,
    duration: AcademyTokens.selectionMotion,
  );
  late final _progress = CurvedAnimation(
    parent: _animation,
    curve: Curves.easeInOutCubic,
  );
  bool _open = false;

  void _toggle() {
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
  void dispose() {
    _progress.dispose();
    _animation.dispose();
    _focus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = AcademyTheme.of(context);
    final duration = MediaQuery.disableAnimationsOf(context)
        ? Duration.zero
        : AcademyTokens.motion;
    return Row(
      children: [
        Expanded(
          child: Stack(
            alignment: AlignmentDirectional.centerStart,
            children: [
              if (widget.resting != null)
                IgnorePointer(
                  ignoring: _open,
                  child: ExcludeSemantics(
                    excluding: _open,
                    child: AnimatedOpacity(
                      opacity: _open ? 0 : 1,
                      duration: duration,
                      child: widget.resting!,
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
                    child: AcademyChrome(
                      radius: AcademyTheme.of(context).radii.expandingSearch,
                      child: CupertinoTextField(
                        controller: widget.controller,
                        focusNode: _focus,
                        placeholder:
                            widget.placeholder ??
                            AcademyLocalizations.of(context).search,
                        onChanged: widget.onChanged,
                        textInputAction: TextInputAction.search,
                        padding: AcademyTheme.of(context)
                            .paddings
                            .expandingSearch,
                        style: theme.textTheme.bodyLarge,
                        placeholderStyle: theme.textTheme.bodyLarge.copyWith(
                          color: AcademyChrome.foregroundColor(
                            context,
                            theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                        decoration: const BoxDecoration(),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        AcademyChromeButton(
          icon: _open ? AcademySymbols.close : AcademySymbols.search,
          label: _open
              ? AcademyLocalizations.of(context).closeSearch
              : AcademyLocalizations.of(context).openSearch,
          onPressed: _toggle,
        ),
      ],
    );
  }
}
