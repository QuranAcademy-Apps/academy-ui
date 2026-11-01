import 'dart:async' show Timer, unawaited;

import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:flutter/foundation.dart';

import '../../../core/utils/display_chrome_android_bridge.dart';
import '../../../core/utils/floating_chrome_insets.dart';
import 'app_chrome_bar.dart';
import 'app_floating_tab_bar.dart';

/// One tab in an [AppFloatingTabScaffold]: its pill [icon]/[label] and the page
/// [builder]. A single descriptor keeps the pill item and the page in sync, so
/// adding/removing a tab is a one-line change.
class AppFloatingTab {
  const AppFloatingTab({
    required this.icon,
    required this.label,
    required this.builder,
  });

  final IconData icon;
  final String label;
  final WidgetBuilder builder;
}

/// Hosts [tabs] under the app's floating chrome:
///
/// * a lazily-built, state-preserving page stack (each page is built on first
///   visit and then kept alive offstage), and
/// * the floating [AppFloatingTabBar] pill plus the bottom edge fade overlaid.
///
/// Deliberately avoids `CupertinoTabScaffold`/`CupertinoTabBar`: the native bar
/// paints a backdrop-blur plate across the bottom safe area even when
/// transparent, and adds empty, tappable semantics under the pill. A plain
/// [IndexedStack] keeps content sharp edge-to-edge with only the pill on top.
///
/// Pages hosted here must inset their scroll views by `appChromeBarTopInset`
/// (top) and [appChromeBottomInset] (bottom) so content clears the bars.
class AppFloatingTabScaffold extends StatefulWidget {
  const AppFloatingTabScaffold({
    super.key,
    required this.tabs,
    this.controller,
    this.initialIndex = 0,
    this.horizontalMargin = 16,
    this.onTabChanged,
  });

  final List<AppFloatingTab> tabs;

  /// Optional external controller. When null the scaffold owns one.
  final CupertinoTabController? controller;
  final int initialIndex;
  final double horizontalMargin;
  final ValueChanged<int>? onTabChanged;

  @override
  State<AppFloatingTabScaffold> createState() => _AppFloatingTabScaffoldState();
}

class _AppFloatingTabScaffoldState extends State<AppFloatingTabScaffold>
    with WidgetsBindingObserver {
  CupertinoTabController? _ownController;
  late final Set<int> _visited = {widget.initialIndex};

  /// Debounce for the Android display-chrome warm: `didChangeMetrics` can fire
  /// in bursts (keyboard, system bars, rotation) and each warm is an async
  /// platform round-trip + setState. Collapse a burst into one refresh. (P4)
  Timer? _androidWarmDebounce;
  late int _lastReportedTabIndex;

  CupertinoTabController get _controller =>
      widget.controller ??
      (_ownController ??= CupertinoTabController(
        initialIndex: widget.initialIndex,
      ));

  bool get _isAndroid => defaultTargetPlatform == TargetPlatform.android;

  @override
  void initState() {
    super.initState();
    _lastReportedTabIndex = _controller.index;
    _controller.addListener(_handleTabChanged);
    if (_isAndroid) {
      WidgetsBinding.instance.addObserver(this);
      displayChromeAndroidListenable.addListener(_handleDisplayChromeChanged);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        unawaited(_refreshAndroidChrome());
      });
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_handleTabChanged);
    if (_isAndroid) {
      WidgetsBinding.instance.removeObserver(this);
      displayChromeAndroidListenable.removeListener(
        _handleDisplayChromeChanged,
      );
    }
    _androidWarmDebounce?.cancel();
    _ownController?.dispose();
    super.dispose();
  }

  void _handleTabChanged() {
    final index = _controller.index;
    if (index == _lastReportedTabIndex) return;
    _lastReportedTabIndex = index;
    widget.onTabChanged?.call(index);
  }

  @override
  void didChangeMetrics() {
    super.didChangeMetrics();
    if (_isAndroid) _scheduleAndroidWarm();
  }

  void _scheduleAndroidWarm() {
    _androidWarmDebounce?.cancel();
    _androidWarmDebounce = Timer(
      const Duration(milliseconds: 120),
      () => unawaited(_refreshAndroidChrome()),
    );
  }

  void _handleDisplayChromeChanged() {
    if (mounted) setState(() {});
  }

  Future<void> _refreshAndroidChrome() async {
    await warmDisplayChromeAndroidFromPlatform();
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final tabs = widget.tabs;
    final controller = _controller;

    // Lazy, state-preserving page stack. AnimatedBuilder rebuilds only on tab
    // change (not per frame); each page is built once visited and stays alive.
    final host = AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        final current = controller.index;
        _visited.add(current);
        return IndexedStack(
          index: current,
          children: [
            for (var i = 0; i < tabs.length; i++)
              if (_visited.contains(i))
                // Pause animation tickers on offstage tabs so hidden pages stop
                // driving frames while kept alive. (P3)
                TickerMode(
                  enabled: i == current,
                  child: tabs[i].builder(context),
                )
              else
                const SizedBox.shrink(),
          ],
        );
      },
    );

    final pill = Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      // RepaintBoundary so the static pill is cached as its own layer and is
      // not re-rasterized while the list scrolls beneath it. (P1)
      child: RepaintBoundary(
        child: Builder(
          builder: (context) {
            // Respect horizontal safe area so the pill never slides under a
            // landscape notch / rounded corner.
            final safe = MediaQuery.paddingOf(context);
            final margin = EdgeInsets.fromLTRB(
              widget.horizontalMargin + safe.left,
              0,
              widget.horizontalMargin + safe.right,
              // Pure edge-breathing safe-area inset (max(inset, 8)) with no
              // extra gap, so the pill sits at the same bottom as the reader
              // bottom bar.
              floatingChromeBottomInsetOf(context),
            );
            // Cap the pill at the audio player's panel width on wide screens.
            // The margin lives inside AppFloatingTabBar's padding, so allow
            // for it on top of the cap — margins never squeeze the pill.
            return Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: kAppFloatingTabBarMaxWidth + margin.horizontal,
                ),
                child: AppFloatingTabBar(
                  controller: controller,
                  margin: margin,
                  items: [
                    for (final tab in tabs)
                      AppFloatingTabItem(icon: tab.icon, label: tab.label),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );

    final fade = Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      // RepaintBoundary so the static gradient is cached and not re-rasterized
      // as the list scrolls under it. (P1)
      child: RepaintBoundary(
        child: Builder(
          builder: (context) => SizedBox(
            height:
                floatingChromeBottomInsetOf(context) +
                kAppFloatingTabBarHeight +
                AppChromeFadeMaterial.extension,
            child: const AppChromeFadeMaterial(
              direction: AppChromeFadeDirection.bottom,
            ),
          ),
        ),
      ),
    );

    final content = Stack(
      children: [
        Positioned.fill(child: host),
        fade,
        pill,
      ],
    );

    if (!_isAndroid) return content;

    // Android edge-to-edge: pin the bottom inset to the warmed tab-bar chrome
    // inset so pages compute their bottom content inset against a stable value.
    final mediaQuery = MediaQuery.of(context);
    final bottomChrome = androidTabBarBottomChromeInsetOf(context);
    return MediaQuery(
      data: mediaQuery.copyWith(
        padding: mediaQuery.padding.copyWith(bottom: bottomChrome),
        viewPadding: mediaQuery.viewPadding.copyWith(bottom: bottomChrome),
      ),
      child: content,
    );
  }
}
