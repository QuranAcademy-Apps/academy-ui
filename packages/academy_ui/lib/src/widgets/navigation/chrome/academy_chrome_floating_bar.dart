import 'package:cupertino_ui/cupertino_ui.dart';

import 'academy_chrome_fade_material.dart';
import 'academy_chrome_metrics.dart';

/// Top bar that floats over page content, which scrolls under a soft fade.
/// Place it at the top of a [Stack].
class AcademyChromeFloatingBar extends StatelessWidget {
  const AcademyChromeFloatingBar({
    super.key,
    this.leading,
    this.middle,
    this.actions,
    this.barHeight = academyChromeBarHeight,
    this.horizontalPadding = 16,
  });

  final Widget? leading;
  final Widget? middle;
  final List<Widget>? actions;
  final double barHeight;
  final double horizontalPadding;

  @override
  Widget build(BuildContext context) {
    final chromeHeight =
        academyChromeTopOf(context) +
        barHeight +
        AcademyChromeFadeMaterial.extension;
    final trailing = actions != null && actions!.isNotEmpty
        ? Row(mainAxisSize: MainAxisSize.min, children: actions!)
        : null;
    return SizedBox(
      height: chromeHeight,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Cached as their own layers: the content scrolls under static chrome.
          const Positioned.fill(
            child: RepaintBoundary(child: AcademyChromeFadeMaterial()),
          ),
          RepaintBoundary(
            child: SafeArea(
              bottom: false,
              minimum: const EdgeInsets.only(top: academyChromeEdgeInset),
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
