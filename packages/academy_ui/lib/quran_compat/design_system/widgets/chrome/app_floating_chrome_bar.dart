import 'package:cupertino_ui/cupertino_ui.dart';

import '../../../core/utils/floating_chrome_insets.dart';
import 'app_chrome_bar_metrics.dart';
import 'app_chrome_fade_material.dart';

/// Floating top bar that overlays the page content. Content behind it stays
/// visible and scrolls under a soft gradient fade, matching the reader's
/// `ReaderTopBar`. Place it at the top of a [Stack] via
/// `Positioned(top: 0, left: 0, right: 0, child: AppFloatingChromeBar(...))`.
class AppFloatingChromeBar extends StatelessWidget {
  const AppFloatingChromeBar({
    super.key,
    this.leading,
    this.middle,
    this.actions,
    this.barHeight = kAppChromeBarHeight,
    this.horizontalPadding = 16,
  });

  final Widget? leading;
  final Widget? middle;
  final List<Widget>? actions;
  final double barHeight;
  final double horizontalPadding;

  @override
  Widget build(BuildContext context) {
    final topInset = withEdgeBreathing(MediaQuery.paddingOf(context).top);
    final chromeHeight = topInset + barHeight + AppChromeFadeMaterial.extension;
    final trailing = (actions != null && actions!.isNotEmpty)
        ? Row(mainAxisSize: MainAxisSize.min, children: actions!)
        : null;

    return SizedBox(
      height: chromeHeight,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // RepaintBoundary so the static fade is cached and not re-rasterized
          // while content scrolls under it. (P1, see chrome-performance.md)
          const Positioned.fill(
            child: RepaintBoundary(child: AppChromeFadeMaterial()),
          ),
          // RepaintBoundary so the static gradient controls (each a clip +
          // stroke shader + drop shadow) are cached as their own layer and are
          // not re-rasterized while page content scrolls under the bar. (P1)
          RepaintBoundary(
            child: SafeArea(
              bottom: false,
              minimum: const EdgeInsets.only(top: kEdgeBreathingInset),
              child: SizedBox(
                height: barHeight,
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      if (leading != null)
                        Align(
                          alignment: AlignmentDirectional.centerStart,
                          child: leading,
                        ),
                      if (middle != null) Center(child: middle),
                      if (trailing != null)
                        Align(
                          alignment: AlignmentDirectional.centerEnd,
                          child: trailing,
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
