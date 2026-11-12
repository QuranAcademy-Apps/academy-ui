import '../../foundation/localizations/academy_localizations.dart';
import 'chrome/academy_chrome.dart';
import 'chrome/academy_chrome_metrics.dart';
import 'chrome/academy_tabs.dart';
import '../../foundation/layout/academy_page_insets.dart';

import 'package:cupertino_ui/cupertino_ui.dart';

import '../../theme/academy_theme.dart';

/// Adapted from Quran AppPageScaffold with overlaid chrome and explicit insets;
/// extended from Yalla's page (2026-11-02): custom leading, bar height,
/// subtitle, soft top fade, header background and content width.
class AcademyPage extends StatelessWidget {
  const AcademyPage({
    super.key,
    required this.title,
    required this.child,
    this.trailing,
    this.leading,
    this.navigationBarHeight,
    this.showBackButton = true,
    this.titleWidget,
    this.subtitle,
    this.softTopFade = false,
    this.resizeToAvoidBottomInset = true,
    this.backgroundColor,
    this.headerBackgroundBuilder,
    this.maxContentWidth = 430,
    this.hasTabBar = false,
    this.bottomGap = 16,
  });
  final String title;
  final Widget child;
  final Widget? trailing;
  final Widget? leading;
  final double? navigationBarHeight;
  final bool showBackButton;
  final Widget? titleWidget;
  final String? subtitle;
  final bool softTopFade;
  final bool resizeToAvoidBottomInset;
  final Color? backgroundColor;

  /// Keeps [AcademyPageInsets.bottomOf] clear of an [AcademyTabScaffold] bar.
  final bool hasTabBar;

  /// Space above the bottom edge of a page without a tab bar.
  final double bottomGap;

  /// Use infinity for pages with photography that fills the viewport.
  final double maxContentWidth;
  final Widget Function(BuildContext context, Widget defaultBackground)?
  headerBackgroundBuilder;
  @override
  Widget build(BuildContext context) {
    final top = academyChromeTopOf(context);
    final barHeight =
        navigationBarHeight ??
        academyChromeHeightOf(context, subtitle: subtitle != null);
    final edge = Container(
      height:
          top + barHeight + (softTopFade ? academyChromeContentGap : 0) + 16,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AcademyTheme.of(context).scaffoldBackgroundColor,
            AcademyTheme.of(context).scaffoldBackgroundColor
                .withValues(alpha: 0),
          ],
          stops: softTopFade
              ? null
              : [(top + barHeight) / (top + barHeight + 16), 1],
        ),
      ),
    );
    return CupertinoPageScaffold(
      backgroundColor: backgroundColor,
      resizeToAvoidBottomInset: resizeToAvoidBottomInset,
      child: SafeArea(
        top: false,
        bottom: false,
        child: Stack(
          children: [
            Positioned.fill(
              child: Center(
                child: SizedBox(
                  width: maxContentWidth,
                  child: AcademyPageInsets(
                    top: top + barHeight + academyChromeContentGap,
                    bottom: hasTabBar
                        ? AcademyFloatingTabBar.bottomObstructionOf(context) +
                              24
                        : academyChromeBottomOf(context) + bottomGap,
                    child: child,
                  ),
                ),
              ),
            ),
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              // Cached as their own layers: the content scrolls under them.
              child: RepaintBoundary(
                child: IgnorePointer(
                  child: headerBackgroundBuilder?.call(context, edge) ?? edge,
                ),
              ),
            ),
            Positioned(
              top: top,
              left: 0,
              right: 0,
              child: RepaintBoundary(
                child: AcademyChromeBar(
                  height: barHeight,
                  title: titleWidget == null ? title : null,
                  middle: titleWidget,
                  subtitle: subtitle,
                  trailing: trailing == null
                      ? null
                      : Align(
                          alignment: Alignment.topCenter,
                          widthFactor: 1,
                          child: trailing,
                        ),
                  leading:
                      leading ??
                      (showBackButton && Navigator.of(context).canPop()
                          ? AcademyChromeButton(
                              icon: AcademyTheme.of(context).icons.back,
                              label: AcademyLocalizations.of(context).back,
                              onPressed: () => Navigator.maybePop(context),
                            )
                          : null),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
