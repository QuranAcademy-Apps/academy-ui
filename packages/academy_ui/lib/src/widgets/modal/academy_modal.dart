import '../../foundation/localizations/academy_localizations.dart';
import '../../foundation/navigation/academy_routes.dart';

import 'package:flutter/cupertino.dart';
import 'package:stupid_simple_sheet/stupid_simple_sheet.dart';

import '../../theme/academy_theme.dart';
import '../navigation/chrome/academy_chrome.dart';
import '../navigation/chrome/academy_chrome_fade_material.dart';
import '../navigation/chrome/academy_chrome_metrics.dart';
import '../../foundation/motion/soft_fade_switcher.dart';
import '../../foundation/surface/academy_surface_mask.dart';
import 'modal_sheet_detents.dart';

/// How scrolling content meets the pinned modal header.
enum AcademyModalHeaderBehavior {
  /// Content has a separate viewport below the header.
  separate,

  /// Content scrolls behind the header and fades toward its upper edge.
  fade,

  /// Content scrolls behind the header without an edge effect.
  overlay,
}

/// Initial scroll padding for content which extends beneath a modal header.
/// The built-in modal scroll views consume this automatically. Custom scroll
/// views should add [topOf] to their top content padding, not their viewport.
class AcademyModalContentInsets extends InheritedWidget {
  const AcademyModalContentInsets({
    super.key,
    required this.top,
    required super.child,
  });
  final double top;
  static double topOf(BuildContext context) =>
      context
          .dependOnInheritedWidgetOfExactType<AcademyModalContentInsets>()
          ?.top ??
      0;
  @override
  bool updateShouldNotify(AcademyModalContentInsets oldWidget) =>
      top != oldWidget.top;
}

/// One route for forms, content, confirmations and nested modal flows.
///
/// The route owns keyboard displacement. Content must not add viewInsets again.
/// Use [AcademyModalListView] or [AcademyModalScrollView] to clear the part of the
/// full-height content that is below the resting detent.
/// A single resting height is the default. Supply [detents] explicitly for a
/// resizable list or form; [autoHeight] selects a single compact height.
/// [grouped] paints the sheet with the grouped page background so inset tables
/// and cards keep their own opaque surface, as in a UIKit grouped sheet.
/// [header] false leaves the header to the content; [enableDrag] false keeps
/// gestures such as picker wheels inside the content (the barrier still closes).
/// [moveAboveKeyboard] false keeps the sheet where it rests and leaves the
/// keyboard inset in the content's MediaQuery (a hand-made keyboard layout);
/// combine it with [expandOnFocus] false.
Future<T?> showAcademyModal<T>(
  BuildContext context, {
  String? title,
  required WidgetBuilder builder,
  bool nestedNavigation = false,
  bool initiallyExpanded = false,
  ModalSheetDetent? initialDetent,
  List<ModalSheetDetent> detents = const [],
  double? autoHeight,
  AcademyModalHeaderBehavior headerBehavior =
      AcademyModalHeaderBehavior.separate,
  double headerFadeExtent = 24,
  bool grouped = false,
  bool expandOnFocus = true,
  bool dismissible = true,
  bool enableDrag = true,
  bool header = true,
  bool moveAboveKeyboard = true,
  bool useRootNavigator = false,
  RouteSnapshotMode backgroundSnapshotMode =
      RouteSnapshotMode.animatingAndScrolling,
  bool clipContent = true,
}) {
  assert(headerFadeExtent >= 0 && headerFadeExtent.isFinite);
  final initial =
      initialDetent ??
      (initiallyExpanded
          ? ModalSheetDetent.full
          : autoHeight != null
          ? ModalSheetDetent.auto
          : ModalSheetDetent.medium);
  return showAcademyModalRoute<T>(
    context: context,
    useRootNavigator: useRootNavigator,
    isDismissible: dismissible,
    enableDrag: enableDrag,
    moveAboveKeyboard: moveAboveKeyboard,
    backgroundSnapshotMode: backgroundSnapshotMode,
    snappingConfig: modalSheetSnappingConfig(
      context: context,
      detents: detents,
      initialDetent: initial,
      autoHeight: autoHeight,
    ),
    builder: (sheetContext) => LandscapeModalSheetFrame(
      child: SizedBox(
        height: modalSheetRouteHeight(sheetContext),
        child: CaptureModalSheetController(
          child: _ModalHost(
            title: title,
            headerBehavior: headerBehavior,
            headerFadeExtent: headerFadeExtent,
            grouped: grouped,
            header: header,
            clipContent: clipContent,
            builder: builder,
            restingDetent: initial,
            autoHeight: autoHeight,
            expandOnFocus: expandOnFocus,
            nestedNavigation: nestedNavigation,
            close: (result) => Navigator.of(sheetContext).pop<T>(result as T?),
          ),
        ),
      ),
    ),
  );
}

/// Closes the whole modal, including from an inner page, with a typed result.
void closeAcademyModal<T>(BuildContext context, [T? result]) {
  final scope = _ModalFlowScope.maybeOf(context);
  if (scope == null) {
    throw StateError('closeAcademyModal requires an Academy modal context.');
  }
  scope.close(result);
}

/// Pushes a page inside the current modal; does not touch app navigation.
Future<T?> pushAcademyModalPage<T>(
  BuildContext context, {
  String? title,
  required WidgetBuilder builder,
  AcademyModalHeaderBehavior? headerBehavior,
  double? headerFadeExtent,
  bool? grouped,
}) {
  final scope = _ModalFlowScope.maybeOf(context);
  if (scope == null || !scope.nestedNavigation) {
    throw StateError('Open the modal with nestedNavigation: true first.');
  }
  return Navigator.of(context).push<T>(
    AcademyPageRoute<T>(
      builder: (_) => AcademyModalScaffold(
        title: title,
        builder: builder,
        headerBehavior: headerBehavior ?? scope.headerBehavior,
        headerFadeExtent: headerFadeExtent ?? scope.headerFadeExtent,
        grouped: grouped ?? scope.grouped,
        clipContent: scope.clipContent,
      ),
    ),
  );
}

class _ModalFlowScope extends InheritedWidget {
  const _ModalFlowScope({
    required this.close,
    required this.nestedNavigation,
    required this.setExpansion,
    required this.headerBehavior,
    required this.headerFadeExtent,
    required this.grouped,
    required this.clipContent,
    required super.child,
  });
  final void Function(Object?) close;
  final bool nestedNavigation;
  final void Function(Object, bool) setExpansion;
  final AcademyModalHeaderBehavior headerBehavior;
  final double headerFadeExtent;
  final bool grouped;
  final bool clipContent;
  static _ModalFlowScope? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<_ModalFlowScope>();
  @override
  bool updateShouldNotify(_ModalFlowScope oldWidget) =>
      close != oldWidget.close ||
      nestedNavigation != oldWidget.nestedNavigation ||
      headerBehavior != oldWidget.headerBehavior ||
      headerFadeExtent != oldWidget.headerFadeExtent ||
      grouped != oldWidget.grouped ||
      clipContent != oldWidget.clipContent;
}

class _ModalHost extends StatefulWidget {
  const _ModalHost({
    this.title,
    required this.builder,
    required this.close,
    required this.restingDetent,
    required this.nestedNavigation,
    this.autoHeight,
    required this.expandOnFocus,
    required this.headerBehavior,
    required this.headerFadeExtent,
    required this.grouped,
    required this.header,
    required this.clipContent,
  });
  final String? title;
  final bool header;
  final bool clipContent;
  final WidgetBuilder builder;
  final void Function(Object?) close;
  final ModalSheetDetent restingDetent;
  final bool nestedNavigation;
  final double? autoHeight;
  final bool expandOnFocus;
  final AcademyModalHeaderBehavior headerBehavior;
  final double headerFadeExtent;
  final bool grouped;
  @override
  State<_ModalHost> createState() => _ModalHostState();
}

class _ModalHostState extends State<_ModalHost> {
  final _expandedBy = <Object>{};
  final _navigatorKey = GlobalKey<NavigatorState>();

  void _setExpansion(Object owner, bool expanded) {
    if (!mounted) return;
    final changed = expanded
        ? _expandedBy.add(owner)
        : _expandedBy.remove(owner);
    if (changed) setState(() {});
  }

  @override
  Widget build(BuildContext context) => _ModalFlowScope(
    close: widget.close,
    nestedNavigation: widget.nestedNavigation,
    setExpansion: _setExpansion,
    headerBehavior: widget.headerBehavior,
    headerFadeExtent: widget.headerFadeExtent,
    grouped: widget.grouped,
    clipContent: widget.clipContent,
    child: ModalDetentFocus(
      restingDetent: widget.restingDetent,
      focusedDetent: widget.expandOnFocus
          ? ModalSheetDetent.full
          : widget.restingDetent,
      autoHeight: widget.autoHeight,
      keepExpanded: widget.expandOnFocus && _expandedBy.isNotEmpty,
      child: widget.nestedNavigation
          ? NavigatorPopHandler<Object?>(
              onPopWithResult: (_) => _navigatorKey.currentState!.maybePop(),
              child: Navigator(
                key: _navigatorKey,
                onGenerateRoute: (_) => AcademyPageRoute<void>(
                  builder: (_) => AcademyModalScaffold(
                    title: widget.title,
                    builder: widget.builder,
                    headerBehavior: widget.headerBehavior,
                    headerFadeExtent: widget.headerFadeExtent,
                    grouped: widget.grouped,
                    header: widget.header,
                    clipContent: widget.clipContent,
                  ),
                ),
              ),
            )
          : AcademyModalScaffold(
              title: widget.title,
              builder: widget.builder,
              headerBehavior: widget.headerBehavior,
              headerFadeExtent: widget.headerFadeExtent,
              grouped: widget.grouped,
              header: widget.header,
              clipContent: widget.clipContent,
            ),
    ),
  );
}

/// An opaque modal body with a pinned header and configurable content underlap.
class AcademyModalScaffold extends StatelessWidget {
  const AcademyModalScaffold({
    super.key,
    this.title,
    required this.builder,
    this.headerBehavior = AcademyModalHeaderBehavior.separate,
    this.headerFadeExtent = 24,
    this.grouped = false,
    this.header = true,
    this.clipContent = true,
  }) : assert(headerFadeExtent >= 0 && headerFadeExtent < double.infinity),
       middle = null,
       leading = null,
       actionWidgets = null,
       onClose = null,
       showClose = true,
       headerWidget = null,
       headerHeight = academyChromeModalHeaderHeight,
       backgroundColor = null,
       search = null,
       body = null;

  /// Edge-to-edge content under a floating [AcademyChromeModalHeader.capsule]
  /// over a soft edge fade. [body] receives the insets its scroll view must
  /// apply as padding; the sheet's off-screen slice is added at a leaf with
  /// [ModalSheetScrollInsets.of], so a detent change rebuilds only that leaf.
  const AcademyModalScaffold.floating({
    super.key,
    this.title,
    this.middle,
    this.leading,
    this.actionWidgets,
    this.onClose,
    this.showClose = true,
    this.headerWidget,
    this.headerHeight = academyChromeModalHeaderHeight,
    this.backgroundColor,
    this.search,
    required Widget Function(BuildContext context, EdgeInsets contentInsets)
    this.body,
  }) : assert(headerWidget != null || title != null || middle != null),
       builder = null,
       headerBehavior = AcademyModalHeaderBehavior.fade,
       headerFadeExtent = 24,
       grouped = false,
       header = true,
       clipContent = false;
  final String? title;
  final WidgetBuilder? builder;

  /// Replaces the title capsule of a floating header.
  final Widget? middle;
  final Widget? leading;
  final List<Widget>? actionWidgets;
  final VoidCallback? onClose;
  final bool showClose;

  /// Replaces a floating header; should be [headerHeight] tall.
  final Widget? headerWidget;
  final double headerHeight;

  /// Default: the page background.
  final Color? backgroundColor;

  /// Non-null while a floating header shows a search field.
  final AcademyChromeSearch? search;
  final Widget Function(BuildContext context, EdgeInsets contentInsets)? body;

  /// False when the content draws its own [AcademyChromeModalHeader], for
  /// example to place local actions beside the title.
  final bool header;
  final AcademyModalHeaderBehavior headerBehavior;
  final double headerFadeExtent;

  /// Grouped page background instead of the card surface.
  final bool grouped;

  /// Clips content that scrolls under the header to the sheet's rounded
  /// corners. A rounded clip renders that content offscreen on every scroll
  /// frame, so a text-heavy list can drop frames. When false, only the header
  /// fade is clipped; opaque content must then mask its own fill with
  /// [ModalSheetMaskedFill], as tables and surfaces already do.
  final bool clipContent;

  Widget _floatingHeader() {
    final search = this.search;
    if (search != null) {
      return KeyedSubtree(
        key: const ValueKey('chrome-modal-search'),
        child: AcademyChromeModalHeader.capsule(
          height: headerHeight,
          showClose: false,
          middle: search.field(),
        ),
      );
    }
    return KeyedSubtree(
      key: const ValueKey('chrome-modal-header'),
      child:
          headerWidget ??
          AcademyChromeModalHeader.capsule(
            title: title,
            middle: middle,
            leading: leading,
            actionWidgets: actionWidgets,
            onClose: onClose,
            showClose: showClose,
            height: headerHeight,
          ),
    );
  }

  Widget _floating(BuildContext context) => ModalSheetRoundedSurface(
    // The rounded top comes from the static fill, with no clip over the
    // scrolling body; opaque content masks its own fill at the corners.
    color:
        backgroundColor ??
        AcademyTheme.of(context).colorScheme.scaffoldBackground,
    child: Stack(
      children: [
        Positioned.fill(
          child: body!(context, EdgeInsets.only(top: headerHeight)),
        ),
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: SizedBox(
            height: headerHeight,
            // Empty header space belongs to the sheet's drag gesture, not to
            // the scroll view that extends underneath it.
            child: Listener(
              behavior: HitTestBehavior.opaque,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  // Only the fade is clipped: clipping the controls would cut
                  // their shadows at the header's bottom edge.
                  const Positioned.fill(
                    child: RepaintBoundary(
                      child: ClipRSuperellipse(
                        borderRadius: BorderRadius.vertical(
                          top: academyModalSheetTopRadius,
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: AcademyChromeFadeMaterial(),
                      ),
                    ),
                  ),
                  SoftFadeSwitcher(child: _floatingHeader()),
                ],
              ),
            ),
          ),
        ),
      ],
    ),
  );

  @override
  Widget build(BuildContext context) {
    if (body != null) return _floating(context);
    final flow = _ModalFlowScope.maybeOf(context);
    final canGoBack =
        flow?.nestedNavigation == true && Navigator.canPop(context);
    final theme = AcademyTheme.of(context);
    final underlap =
        this.header && headerBehavior != AcademyModalHeaderBehavior.separate;
    final background = grouped
        ? theme.scaffoldBackgroundColor
        : theme.colorScheme.surface;
    final headerHeight =
        academyChromeHeightOf(context) +
        theme.paddings.chromeBottom.vertical +
        theme.paddings.chromeBar.vertical;
    // Cached as its own layer: the content scrolls under a static header.
    final header = RepaintBoundary(
      child: Listener(
        // Empty space around the header must not activate a scrolled-under row.
        behavior: HitTestBehavior.opaque,
        child: AcademyChromeModalHeader(
          title: title,
          onClose: flow == null ? null : () => flow.close(null),
          leading: canGoBack
              ? AcademyChromeButton(
                  icon: AcademyTheme.of(context).icons.back,
                  label: AcademyLocalizations.of(context).back,
                  onPressed: () => Navigator.of(context).maybePop(),
                )
              : null,
        ),
      ),
    );
    final content = AcademyModalContentInsets(
      top: underlap ? headerHeight : 0,
      child: Builder(builder: builder!),
    );
    Widget rounded(Widget child) => ClipPath(
      // A normal clip, without saveLayer, keeps custom scroll content and the
      // edge gradient inside the sheet's upper corners.
      clipper: ShapeBorderClipper(
        shape: RoundedSuperellipseBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(theme.radii.modal),
          ),
        ),
      ),
      child: child,
    );
    final fade = RepaintBoundary(
      child: IgnorePointer(
        child: ExcludeSemantics(
          child: DecoratedBox(
            key: const ValueKey('academy-modal-header-fade'),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [background, background.withValues(alpha: 0)],
                stops: [
                  (1 - headerFadeExtent / headerHeight).clamp(0.0, 1.0),
                  1,
                ],
              ),
            ),
          ),
        ),
      ),
    );
    Widget underlapped() => Stack(
      children: [
        Positioned.fill(child: content),
        if (headerBehavior == AcademyModalHeaderBehavior.fade)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: headerHeight,
            child: clipContent ? fade : rounded(fade),
          ),
        Positioned(top: 0, left: 0, right: 0, child: header),
      ],
    );
    return ModalSheetRoundedSurface(
      color: background,
      child: underlap
          ? (clipContent ? rounded(underlapped()) : underlapped())
          : Column(
              children: [
                if (this.header) header,
                Expanded(child: ClipRect(child: content)),
              ],
            ),
    );
  }
}

/// A scrollable modal body; bottom padding tracks the actual resting height.
class AcademyModalListView extends StatelessWidget {
  const AcademyModalListView({
    super.key,
    required this.children,
    this.padding,
    this.controller,
    this.physics,
  });
  final List<Widget> children;
  final EdgeInsets? padding;
  final ScrollController? controller;
  final ScrollPhysics? physics;
  @override
  Widget build(BuildContext context) => ListView(
    controller: controller,
    physics: physics,
    padding: (padding ?? AcademyTheme.of(context).paddings.modal).copyWith(
      top:
          (padding ?? AcademyTheme.of(context).paddings.modal).top +
          AcademyModalContentInsets.topOf(context),
      bottom:
          (padding ?? AcademyTheme.of(context).paddings.modal).bottom +
          ModalSheetScrollInsets.of(context),
    ),
    addRepaintBoundaries: false,
    children: children,
  );
}

class AcademyModalScrollView extends StatelessWidget {
  const AcademyModalScrollView({
    super.key,
    required this.child,
    this.padding,
    this.physics,
  });
  final Widget child;
  final EdgeInsets? padding;
  final ScrollPhysics? physics;
  @override
  Widget build(BuildContext context) => SingleChildScrollView(
    physics: physics,
    padding: (padding ?? AcademyTheme.of(context).paddings.modal).copyWith(
      top:
          (padding ?? AcademyTheme.of(context).paddings.modal).top +
          AcademyModalContentInsets.topOf(context),
      bottom:
          (padding ?? AcademyTheme.of(context).paddings.modal).bottom +
          ModalSheetScrollInsets.of(context),
    ),
    child: child,
  );
}

/// Keeps the sheet expanded while a search query is non-empty, even after blur.
/// Wrap an [AcademySearchBar] and supply its externally owned controller.
class AcademyModalSearch extends StatefulWidget {
  const AcademyModalSearch({
    super.key,
    required this.controller,
    required this.child,
  });
  final TextEditingController controller;
  final Widget child;
  @override
  State<AcademyModalSearch> createState() => _AcademyModalSearchState();
}

class _AcademyModalSearchState extends State<AcademyModalSearch> {
  final _owner = Object();
  _ModalFlowScope? _scope;
  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_changed);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _scope = _ModalFlowScope.maybeOf(context);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _changed();
    });
  }

  @override
  void didUpdateWidget(AcademyModalSearch oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.controller != oldWidget.controller) {
      oldWidget.controller.removeListener(_changed);
      widget.controller.addListener(_changed);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _changed();
      });
    }
  }

  void _changed() =>
      _scope?.setExpansion(_owner, widget.controller.text.isNotEmpty);
  @override
  void dispose() {
    widget.controller.removeListener(_changed);
    final scope = _scope;
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => scope?.setExpansion(_owner, false),
    );
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}

/// Keeps content pinned to the bottom (actions, pickers) inside the visible
/// part of a sheet resting below full height. The off-screen slice and the
/// home indicator are consumed like a SafeArea. Scroll views do not need it:
/// use [AcademyModalListView] or add [ModalSheetScrollInsets.of] to padding.
class AcademyModalFit extends StatelessWidget {
  const AcademyModalFit({
    super.key,
    required this.child,
    this.minimumBottom = 0,
  });
  final Widget child;

  /// Least space above the screen edge, for devices without a home indicator.
  final double minimumBottom;
  @override
  Widget build(BuildContext context) {
    final view = View.of(context);
    final safe = view.devicePixelRatio > 0
        ? view.padding.bottom / view.devicePixelRatio
        : 0.0;
    return Padding(
      padding: EdgeInsets.only(
        bottom:
            ModalSheetScrollInsets.of(context) +
            (minimumBottom - safe).clamp(0.0, double.infinity),
      ),
      child: MediaQuery.removePadding(
        context: context,
        removeBottom: true,
        child: child,
      ),
    );
  }
}
