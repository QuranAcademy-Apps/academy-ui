import 'package:flutter/cupertino.dart';
import 'package:stupid_simple_sheet/stupid_simple_sheet.dart';

import '../academy_sf_image.dart';
import '../academy_theme.dart';
import '../chrome/academy_chrome.dart';
import 'modal_sheet_corner_mask.dart';
import 'modal_sheet_detents.dart';

/// One route for forms, content, confirmations and nested modal flows.
///
/// The route owns keyboard displacement. Content must not add viewInsets again.
/// Use [AcademyModalListView] or [AcademyModalScrollView] to clear the part of the
/// full-height content that is below the resting detent.
Future<T?> showAcademyModal<T>(
  BuildContext context, {
  String? title,
  required WidgetBuilder builder,
  bool nestedNavigation = false,
  bool initiallyExpanded = false,
  ModalSheetDetent? initialDetent,
  List<ModalSheetDetent> detents = const [
    ModalSheetDetent.medium,
    ModalSheetDetent.large,
    ModalSheetDetent.full,
  ],
  double? autoHeight,
  bool dismissible = true,
  bool useRootNavigator = false,
  RouteSnapshotMode backgroundSnapshotMode =
      RouteSnapshotMode.animatingAndScrolling,
}) {
  final initial =
      initialDetent ??
      (initiallyExpanded ? ModalSheetDetent.full : ModalSheetDetent.medium);
  return showAcademyModalRoute<T>(
    context: context,
    useRootNavigator: useRootNavigator,
    isDismissible: dismissible,
    backgroundSnapshotMode: backgroundSnapshotMode,
    snappingConfig: modalSheetSnappingConfig(
      context: context,
      detents: detents,
      initialDetent: initial,
      autoHeight: autoHeight,
    ),
    builder: (sheetContext) => LandscapeModalSheetFrame(
      child: SizedBox(
        height: ModalSheetDetent.full.heightOf(sheetContext),
        child: CaptureModalSheetController(
          child: _ModalHost(
            title: title,
            builder: builder,
            restingDetent: initial,
            autoHeight: autoHeight,
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
}) {
  final scope = _ModalFlowScope.maybeOf(context);
  if (scope == null || !scope.nestedNavigation) {
    throw StateError('Open the modal with nestedNavigation: true first.');
  }
  return Navigator.of(context).push<T>(
    CupertinoPageRoute<T>(
      builder: (_) => AcademyModalScaffold(title: title, builder: builder),
    ),
  );
}

class _ModalFlowScope extends InheritedWidget {
  const _ModalFlowScope({
    required this.close,
    required this.nestedNavigation,
    required this.setExpansion,
    required super.child,
  });
  final void Function(Object?) close;
  final bool nestedNavigation;
  final void Function(Object, bool) setExpansion;
  static _ModalFlowScope? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<_ModalFlowScope>();
  @override
  bool updateShouldNotify(_ModalFlowScope oldWidget) =>
      close != oldWidget.close ||
      nestedNavigation != oldWidget.nestedNavigation;
}

class _ModalHost extends StatefulWidget {
  const _ModalHost({
    this.title,
    required this.builder,
    required this.close,
    required this.restingDetent,
    required this.nestedNavigation,
    this.autoHeight,
  });
  final String? title;
  final WidgetBuilder builder;
  final void Function(Object?) close;
  final ModalSheetDetent restingDetent;
  final bool nestedNavigation;
  final double? autoHeight;
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
    child: ModalDetentFocus(
      restingDetent: widget.restingDetent,
      autoHeight: widget.autoHeight,
      keepExpanded: _expandedBy.isNotEmpty,
      child: widget.nestedNavigation
          ? NavigatorPopHandler<Object?>(
              onPopWithResult: (_) => _navigatorKey.currentState!.maybePop(),
              child: Navigator(
                key: _navigatorKey,
                onGenerateRoute: (_) => CupertinoPageRoute<void>(
                  builder: (_) => AcademyModalScaffold(
                    title: widget.title,
                    builder: widget.builder,
                  ),
                ),
              ),
            )
          : AcademyModalScaffold(title: widget.title, builder: widget.builder),
    ),
  );
}

/// An opaque modal body with a single header and no rounded clip over scrolling.
class AcademyModalScaffold extends StatelessWidget {
  const AcademyModalScaffold({super.key, this.title, required this.builder});
  final String? title;
  final WidgetBuilder builder;

  @override
  Widget build(BuildContext context) {
    final flow = _ModalFlowScope.maybeOf(context);
    final canGoBack =
        flow?.nestedNavigation == true && Navigator.canPop(context);
    return ModalSheetRoundedSurface(
      color: AcademyTheme.of(context).colorScheme.surface,
      child: Column(
        children: [
          AcademyChromeModalHeader(
            title: title,
            onClose: flow == null ? null : () => flow.close(null),
            leading: canGoBack
                ? AcademyChromeButton(
                    icon: AcademySymbols.back,
                    label: 'Назад',
                    onPressed: () => Navigator.of(context).maybePop(),
                  )
                : null,
          ),
          Expanded(
            child: ClipRect(child: Builder(builder: builder)),
          ),
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
    this.padding = const EdgeInsets.fromLTRB(24, 8, 24, 24),
    this.controller,
  });
  final List<Widget> children;
  final EdgeInsets padding;
  final ScrollController? controller;
  @override
  Widget build(BuildContext context) => ListView(
    controller: controller,
    padding: padding.copyWith(
      bottom: padding.bottom + ModalSheetScrollInsets.of(context),
    ),
    addRepaintBoundaries: false,
    children: children,
  );
}

class AcademyModalScrollView extends StatelessWidget {
  const AcademyModalScrollView({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.fromLTRB(24, 8, 24, 24),
  });
  final Widget child;
  final EdgeInsets padding;
  @override
  Widget build(BuildContext context) => SingleChildScrollView(
    padding: padding.copyWith(
      bottom: padding.bottom + ModalSheetScrollInsets.of(context),
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
