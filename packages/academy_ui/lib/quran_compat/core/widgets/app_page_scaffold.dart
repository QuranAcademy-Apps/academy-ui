import 'package:cupertino_ui/cupertino_ui.dart';

/// App-standard Cupertino page scaffold with body safe-area handling.
///
/// The navigation bar is passed through unchanged so custom bar sizing stays
/// owned by the bar itself.
class AppPageScaffold extends StatelessWidget {
  const AppPageScaffold({
    super.key,
    this.navigationBar,
    this.backgroundColor,
    this.resizeToAvoidBottomInset = true,
    this.safeArea = true,
    this.safeAreaTop,
    this.safeAreaBottom = true,
    this.safeAreaLeft = true,
    this.safeAreaRight = true,
    this.minimumSafeAreaPadding = EdgeInsets.zero,
    this.maintainBottomViewPadding = false,
    this.removeTopPaddingForNavigationBar = false,
    required this.child,
  });

  final ObstructingPreferredSizeWidget? navigationBar;
  final Color? backgroundColor;
  final bool resizeToAvoidBottomInset;
  final bool safeArea;
  final bool? safeAreaTop;
  final bool safeAreaBottom;
  final bool safeAreaLeft;
  final bool safeAreaRight;
  final EdgeInsets minimumSafeAreaPadding;
  final bool maintainBottomViewPadding;
  final bool removeTopPaddingForNavigationBar;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final safeAreaBody = safeArea
        ? SafeArea(
            left: safeAreaLeft,
            top: safeAreaTop ?? (navigationBar == null),
            right: safeAreaRight,
            bottom: safeAreaBottom,
            minimum: minimumSafeAreaPadding,
            maintainBottomViewPadding: maintainBottomViewPadding,
            child: child,
          )
        : child;
    final body = backgroundColor == null
        ? safeAreaBody
        : ColoredBox(color: backgroundColor!, child: safeAreaBody);

    final scaffold = CupertinoPageScaffold(
      navigationBar: navigationBar,
      backgroundColor: backgroundColor,
      resizeToAvoidBottomInset: resizeToAvoidBottomInset,
      child: body,
    );
    if (!removeTopPaddingForNavigationBar) {
      return scaffold;
    }

    return MediaQuery.removePadding(
      context: context,
      removeTop: true,
      child: scaffold,
    );
  }
}
