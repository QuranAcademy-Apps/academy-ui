import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';

import 'academy_menu_anchor.dart';
import 'academy_table.dart';
import 'academy_theme.dart';
import 'academy_sf_image.dart';
import 'academy_components.dart';
import 'modal/modal_sheet_corner_mask.dart';
import 'chrome/academy_chrome.dart';

class AcademySearchBar extends StatefulWidget {
  const AcademySearchBar({
    super.key,
    required this.controller,
    this.onChanged,
    this.onCancel,
    this.loading = false,
    this.chrome = false,
  });
  final TextEditingController controller;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onCancel;
  final bool loading, chrome;
  @override
  State<AcademySearchBar> createState() => _AcademySearchBarState();
}

class _AcademySearchBarState extends State<AcademySearchBar>
    with SingleTickerProviderStateMixin {
  final _focus = FocusNode();
  late final AnimationController _closeAnimation;
  late final Animation<double> _closeProgress;

  @override
  void initState() {
    super.initState();
    _closeAnimation = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 220),
      reverseDuration: const Duration(milliseconds: 180),
    )..addStatusListener(_closeAnimationStatusChanged);
    _closeProgress = CurvedAnimation(
      parent: _closeAnimation,
      curve: Curves.easeOutCubic,
      reverseCurve: Curves.easeInCubic,
    );
    _focus.addListener(_changed);
  }

  void _closeAnimationStatusChanged(AnimationStatus status) {
    if (status == AnimationStatus.dismissed && mounted) setState(() {});
  }

  void _changed() {
    final showCloseButton = _focus.hasFocus && widget.onCancel != null;
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
    _focus.dispose();
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
      final showCloseButton = _focus.hasFocus && widget.onCancel != null;
      final keepCloseButton =
          showCloseButton ||
          _closeAnimation.status != AnimationStatus.dismissed;
      final field = AcademyChrome(
        style: AcademyChromeStyle.none,
        child: CupertinoTextField(
          focusNode: _focus,
          controller: widget.controller,
          placeholder: 'Поиск',
          placeholderStyle: AcademyTheme.of(context).textTheme.bodyLarge
              .copyWith(
                color: AcademyTheme.of(context).colorScheme.onSurfaceVariant,
              ),
          style: AcademyTheme.of(context).textTheme.bodyLarge,
          onChanged: widget.onChanged,
          textInputAction: TextInputAction.search,
          onSubmitted: (_) => _focus.unfocus(),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AcademyTheme.of(context).colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(14),
          ),
          prefix: const Padding(
            padding: EdgeInsetsDirectional.only(start: 12),
            child: AcademySfIcon(AcademySymbols.search, size: 18),
          ),
          suffix: widget.loading
              ? const Padding(
                  padding: EdgeInsets.all(12),
                  child: CupertinoActivityIndicator(),
                )
              : null,
        ),
      );
      final closeButton = AcademyChromeButton(
        icon: AcademySymbols.close,
        label: 'Закрыть поиск',
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

class AcademyStepper extends StatelessWidget {
  const AcademyStepper({
    super.key,
    required this.value,
    required this.onChanged,
    this.min = 0,
    this.max = 10,
  });
  final int value, min, max;
  final ValueChanged<int> onChanged;
  @override
  Widget build(BuildContext context) {
    final color = AcademyTheme.of(context).colorScheme.onSurface;
    Widget hit(bool increase) {
      final enabled = increase ? value < max : value > min;
      return SizedBox(
        width: 48,
        child: Semantics(
          label: increase ? 'Увеличить' : 'Уменьшить',
          value: '$value',
          excludeSemantics: true,
          onTap: enabled
              ? () {
                  HapticFeedback.selectionClick();
                  onChanged(value + (increase ? 1 : -1));
                }
              : null,
          button: true,
          enabled: enabled,
          child: CupertinoButton(
            padding: EdgeInsets.zero,
            minimumSize: Size.zero,
            onPressed: enabled
                ? () {
                    HapticFeedback.selectionClick();
                    onChanged(value + (increase ? 1 : -1));
                  }
                : null,
            child: const SizedBox.expand(),
          ),
        ),
      );
    }

    Widget glyph(IconData icon, bool enabled) => IgnorePointer(
      child: MediaQuery.withNoTextScaling(
        child: AcademySfIcon(
          icon,
          size: 17,
          boxSize: 17,
          color: color.withValues(alpha: enabled ? 1 : .35),
        ),
      ),
    );
    return SizedBox(
      width: 96,
      height: 44,
      child: Stack(
        alignment: AlignmentDirectional.centerStart,
        children: [
          PositionedDirectional(
            start: 0,
            child: Container(
              width: 96,
              height: 32,
              decoration: BoxDecoration(
                color: color.withValues(alpha: .12),
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          PositionedDirectional(
            start: 47.5,
            child: Container(
              width: 1,
              height: 18,
              color: color.withValues(alpha: .3),
            ),
          ),
          Positioned.fill(child: Row(children: [hit(false), hit(true)])),
          PositionedDirectional(
            start: 15.5,
            top: 13.5,
            child: glyph(AcademySymbols.minus, value > min),
          ),
          PositionedDirectional(
            start: 63.5,
            top: 13.5,
            child: glyph(AcademySymbols.plus, value < max),
          ),
        ],
      ),
    );
  }
}

class AcademyCheckmark extends StatelessWidget {
  const AcademyCheckmark({super.key, this.selected = true});
  final bool selected;
  @override
  Widget build(BuildContext context) => MediaQuery.withNoTextScaling(
    child: selected
        ? AcademySfIcon(
            AcademySymbols.checkmark,
            size: 18,
            boxSize: 18,
            color: AcademyTheme.of(context).colorScheme.onSurface,
          )
        : const SizedBox(width: 18),
  );
}

class AcademyInfoButton extends StatelessWidget {
  const AcademyInfoButton({super.key, required this.onPressed});
  final VoidCallback onPressed;
  @override
  Widget build(BuildContext context) => AcademyIconButton(
    label: 'Информация',
    icon: AcademySymbols.info,
    onPressed: onPressed,
  );
}

class AcademyChevron extends StatelessWidget {
  const AcademyChevron({super.key, this.turns = 0});
  final double turns;
  @override
  Widget build(BuildContext context) => AnimatedRotation(
    turns: turns,
    duration: MediaQuery.disableAnimationsOf(context)
        ? Duration.zero
        : const Duration(milliseconds: 180),
    child: AcademySfIcon(
      Directionality.of(context) == TextDirection.rtl
          ? AcademySymbols.back
          : AcademySymbols.forward,
      size: 16,
    ),
  );
}

class AcademyTableSection {
  const AcademyTableSection({
    this.title,
    this.footer,
    required this.rows,
    this.header,
    this.headerTrailing,
    this.footerWidget,
    this.headerStyle,
    this.footerStyle,
    this.cornerRadius = 14,
    this.showSeparators = true,
    this.separatorBuilder,
  });
  final String? title, footer;
  final List<Widget> rows;
  final Widget? header, headerTrailing, footerWidget;
  final TextStyle? headerStyle, footerStyle;
  final double cornerRadius;
  final bool showSeparators;
  final Widget Function(BuildContext, int)? separatorBuilder;
}

/// Inline by default; scrolling ownership may instead be delegated to the table.
class AcademyGroupedTable extends StatelessWidget {
  const AcademyGroupedTable({
    super.key,
    required this.sections,
    this.padding = EdgeInsets.zero,
    this.sectionSpacing = 24,
    this.scrollable = false,
    this.controller,
    this.physics,
    this.hideEmptySections = true,
    this.animated = false,
  });
  final List<AcademyTableSection> sections;
  final EdgeInsetsGeometry padding;
  final double sectionSpacing;
  final bool scrollable, hideEmptySections, animated;
  final ScrollController? controller;
  final ScrollPhysics? physics;
  @override
  Widget build(BuildContext context) {
    final visible = sections
        .where((section) => !hideEmptySections || section.rows.isNotEmpty)
        .toList();
    Widget section(int index) {
      final child = AcademyTableSectionView(section: visible[index]);
      return animated
          ? AnimatedSize(
              duration: MediaQuery.disableAnimationsOf(context)
                  ? Duration.zero
                  : const Duration(milliseconds: 280),
              alignment: Alignment.topCenter,
              child: child,
            )
          : child;
    }

    if (scrollable) {
      return ListView.separated(
        padding: padding,
        controller: controller,
        physics: physics,
        addRepaintBoundaries: !ModalSheetSurfaceScope.isInModalSheet(context),
        itemCount: visible.length,
        itemBuilder: (_, index) => section(index),
        separatorBuilder: (_, _) => SizedBox(height: sectionSpacing),
      );
    }
    return Padding(
      padding: padding,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (var i = 0; i < visible.length; i++) ...[
            if (i > 0) SizedBox(height: sectionSpacing),
            section(i),
          ],
        ],
      ),
    );
  }
}

/// Quran lazy anchor: allocate menu only on activation, release after closing.
class AcademyLazyMenu extends StatefulWidget {
  const AcademyLazyMenu({
    super.key,
    required this.items,
    required this.builder,
  });
  final List<Widget> Function(BuildContext) items;
  final Widget Function(BuildContext, VoidCallback) builder;
  @override
  State<AcademyLazyMenu> createState() => _AcademyLazyMenuState();
}

class _AcademyLazyMenuState extends State<AcademyLazyMenu> {
  final MenuController _controller = MenuController();
  bool _active = false;
  void _open() {
    if (_active) {
      _controller.close();
      return;
    }
    setState(() => _active = true);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && _active) _controller.open();
    });
  }

  @override
  Widget build(BuildContext context) => !_active
      ? widget.builder(context, _open)
      : AcademyMenuAnchor(
          controller: _controller,
          consumeOutsideTaps: true,
          onClose: () {
            if (mounted) setState(() => _active = false);
          },
          menuChildren: widget.items(context),
          builder: (context, controller, child) =>
              widget.builder(context, _open),
        );
}
