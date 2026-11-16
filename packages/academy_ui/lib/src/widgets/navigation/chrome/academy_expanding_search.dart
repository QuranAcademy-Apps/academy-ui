import '../../../foundation/localizations/academy_localizations.dart';

import 'package:cupertino_ui/cupertino_ui.dart';

import '../../../theme/academy_theme.dart';
import '../../text_field/academy_text_input.dart';
import 'academy_chrome.dart';
import 'academy_chrome_metrics.dart';

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
    this.companion,
  });
  final TextEditingController controller;

  /// Puts the toggle at the leading edge, fused with this action in one
  /// [AcademyChromeGroup] (toggle first, divider, then the action). The field
  /// then grows toward the trailing edge; while open the action hides, the
  /// search icon stays leading and the close button moves to the trailing edge.
  final AcademyChromeAction? companion;
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
    final companion = widget.companion;
    final toggle = AcademyChromeAction(
      _open
          ? AcademyTheme.of(context).icons.close
          : AcademyTheme.of(context).icons.search,
      _open
          ? AcademyLocalizations.of(context).closeSearch
          : AcademyLocalizations.of(context).openSearch,
      widget.enabled ? _toggle : null,
    );
    if (companion != null) return _buildWithCompanion(context, toggle, companion);
    return Row(
      children: [
        Expanded(
          child: Stack(
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
                    child: _field(context),
                  ),
                ),
              ),
            ],
          ),
        ),
        if (companion == null) ...[
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
      ],
    );
  }

  Widget _field(BuildContext context) => AcademyTextInput(
    controller: widget.controller,
    focusNode: _focus,
    enabled: widget.enabled,
    readOnly: widget.readOnly,
    onSubmitted: widget.onSubmitted,
    placeholder:
        widget.placeholder ?? AcademyLocalizations.of(context).search,
    onChanged: widget.onChanged,
    textInputAction: TextInputAction.search,
    chrome: true,
    clearable: false,
    highlightOnFocus: false,
    cornerRadius: AcademyTheme.of(context).radii.expandingSearch,
    padding: AcademyTheme.of(context).paddings.expandingSearch,
  );

  /// Companion layout. The search capsule rounds into a circle as the
  /// companion collapses, the field fades in without growing, and the
  /// resting trailing action hands over to the close button in place.
  Widget _buildWithCompanion(
    BuildContext context,
    AcademyChromeAction toggle,
    AcademyChromeAction companion,
  ) {
    final theme = AcademyTheme.of(context);
    final l10n = AcademyLocalizations.of(context);
    final barHeight = academyChromeBarHeight;
    return Row(
      children: [
        AcademyChrome(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              AcademyChromeButton(
                icon: theme.icons.search,
                label: _open ? l10n.search : l10n.openSearch,
                onPressed: widget.enabled
                    ? (_open ? _focus.requestFocus : _toggle)
                    : null,
                style: AcademyChromeStyle.none,
              ),
              SizeTransition(
                sizeFactor: ReverseAnimation(_progress),
                axis: Axis.horizontal,
                alignment: AlignmentDirectional.centerStart,
                child: FadeTransition(
                  opacity: ReverseAnimation(_progress),
                  child: IgnorePointer(
                    ignoring: _open,
                    child: ExcludeSemantics(
                      excluding: _open,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: theme.chromeButton.groupDividerWidth,
                            height: 20,
                            color:
                                AcademyChromeTheme.colorsOf(context).border ??
                                theme.colorScheme.outlineVariant,
                          ),
                          AcademyChromeButton(
                            icon: companion.icon,
                            label: companion.label,
                            onPressed: companion.onPressed,
                            symbolBuilder: companion.symbolBuilder,
                            style: AcademyChromeStyle.none,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Stack(
            alignment: AlignmentDirectional.centerEnd,
            children: [
              if (widget.resting != null)
                IgnorePointer(
                  ignoring: _open,
                  child: ExcludeSemantics(
                    excluding: _open,
                    child: FadeTransition(
                      opacity: ReverseAnimation(_progress),
                      child: Align(
                        alignment: AlignmentDirectional.centerStart,
                        child: widget.resting!,
                      ),
                    ),
                  ),
                ),
              Padding(
                padding: EdgeInsetsDirectional.only(end: barHeight + 8),
                child: ExcludeSemantics(
                  excluding: !_open,
                  child: ExcludeFocus(
                    excluding: !_open,
                    child: IgnorePointer(
                      ignoring: !_open,
                      child: FadeTransition(
                        opacity: _progress,
                        child: _field(context),
                      ),
                    ),
                  ),
                ),
              ),
              IgnorePointer(
                ignoring: !_open,
                child: ExcludeSemantics(
                  excluding: !_open,
                  child: FadeTransition(
                    opacity: _progress,
                    child: ScaleTransition(
                      scale: Tween<double>(begin: 0.6, end: 1).animate(_progress),
                      child: AcademyChromeButton(
                        icon: toggle.icon,
                        label: toggle.label,
                        onPressed: toggle.onPressed,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
