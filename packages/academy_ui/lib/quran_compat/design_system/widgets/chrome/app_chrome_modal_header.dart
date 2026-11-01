import 'package:cupertino_ui/cupertino_ui.dart';

import 'app_chrome_bar_controls.dart';
import 'app_chrome_bar_metrics.dart';
import '../../../l10n/quran_compat_strings.dart';

/// Chrome header for modal bottom sheets. Unlike [AppFloatingChromeBar] this is
/// a real laid-out row (no top safe area, no fade tail) meant to sit at the top
/// of a sheet's `Column`, so it never fights the sheet's detent drag or route
/// padding. Content below it needs no top inset.
///
/// Renders a centered [AppChromeBarTitleCapsule] (or [middle]), an optional
/// [leading] (e.g. a nested-navigator back button), and a trailing row of
/// [actions] followed by a circular `xmark` close button (when [showClose]).
class AppChromeModalHeader extends StatelessWidget {
  const AppChromeModalHeader({
    super.key,
    this.title,
    this.middle,
    this.leading,
    this.actions,
    this.onClose,
    this.showClose = true,
    this.height = kAppChromeModalHeaderHeight,
    this.horizontalPadding = 14,
  }) : assert(
         title != null || middle != null,
         'Provide either a title or a middle widget',
       );

  final String? title;
  final Widget? middle;
  final Widget? leading;
  final List<Widget>? actions;
  final VoidCallback? onClose;
  final bool showClose;
  final double height;
  final double horizontalPadding;

  @override
  Widget build(BuildContext context) {
    final leading = this.leading;
    final closeButton = showClose
        ? AppChromeBarIconButton(
            systemName: 'xmark',
            semanticLabel: QuranCompatStrings.of(context).close,
            onPressed: onClose ?? () => Navigator.of(context).maybePop(),
          )
        : null;
    final trailingChildren = <Widget>[...?actions, ?closeButton];
    final trailing = trailingChildren.isNotEmpty
        ? Row(mainAxisSize: MainAxisSize.min, children: trailingChildren)
        : null;
    final middleWidget = middle ?? AppChromeBarTitleCapsule(title: title!);

    return SizedBox(
      height: height,
      // RepaintBoundary so the static header controls (clip + stroke shader +
      // shadow each) are cached as their own layer and aren't re-rasterized
      // while sheet content scrolls under the floating header. (P1)
      child: RepaintBoundary(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
          child: CustomMultiChildLayout(
            delegate: _AppChromeModalHeaderLayout(
              hasLeading: leading != null,
              hasTrailing: trailing != null,
              textDirection: Directionality.of(context),
            ),
            children: [
              if (leading != null)
                LayoutId(id: _AppChromeModalHeaderSlot.leading, child: leading),
              LayoutId(
                id: _AppChromeModalHeaderSlot.middle,
                child: middleWidget,
              ),
              if (trailing != null)
                LayoutId(
                  id: _AppChromeModalHeaderSlot.trailing,
                  child: trailing,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

enum _AppChromeModalHeaderSlot { leading, middle, trailing }

class _AppChromeModalHeaderLayout extends MultiChildLayoutDelegate {
  _AppChromeModalHeaderLayout({
    required this.hasLeading,
    required this.hasTrailing,
    required this.textDirection,
  });

  static const _controlsGap = 8.0;

  final bool hasLeading;
  final bool hasTrailing;
  final TextDirection textDirection;

  @override
  void performLayout(Size size) {
    final looseConstraints = BoxConstraints.loose(size);
    final leadingSize = hasLeading
        ? layoutChild(_AppChromeModalHeaderSlot.leading, looseConstraints)
        : Size.zero;
    final trailingSize = hasTrailing
        ? layoutChild(_AppChromeModalHeaderSlot.trailing, looseConstraints)
        : Size.zero;

    final middleLeft = leadingSize.width + (hasLeading ? _controlsGap : 0);
    final middleRight =
        size.width - trailingSize.width - (hasTrailing ? _controlsGap : 0);
    final middleWidth = (middleRight - middleLeft).clamp(0.0, size.width);
    final middleSize = layoutChild(
      _AppChromeModalHeaderSlot.middle,
      BoxConstraints(maxWidth: middleWidth, maxHeight: size.height),
    );
    final preferredMiddleLeft = (size.width - middleSize.width) / 2;
    final maximumMiddleLeft = middleRight - middleSize.width;
    final middleOffset = maximumMiddleLeft < middleLeft
        ? middleLeft
        : preferredMiddleLeft.clamp(middleLeft, maximumMiddleLeft).toDouble();

    if (hasLeading) {
      positionChild(
        _AppChromeModalHeaderSlot.leading,
        Offset(
          textDirection == TextDirection.rtl
              ? size.width - leadingSize.width
              : 0,
          (size.height - leadingSize.height) / 2,
        ),
      );
    }
    positionChild(
      _AppChromeModalHeaderSlot.middle,
      Offset(middleOffset, (size.height - middleSize.height) / 2),
    );
    if (hasTrailing) {
      positionChild(
        _AppChromeModalHeaderSlot.trailing,
        Offset(
          textDirection == TextDirection.rtl
              ? 0
              : size.width - trailingSize.width,
          (size.height - trailingSize.height) / 2,
        ),
      );
    }
  }

  @override
  bool shouldRelayout(_AppChromeModalHeaderLayout oldDelegate) =>
      hasLeading != oldDelegate.hasLeading ||
      hasTrailing != oldDelegate.hasTrailing ||
      textDirection != oldDelegate.textDirection;
}
