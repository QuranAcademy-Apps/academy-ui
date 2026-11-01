import 'package:academy_ui/academy_ui.dart' show PressScale;
import 'package:cupertino_ui/cupertino_ui.dart';

import '../../../core/utils/floating_chrome_insets.dart';
import '../../../core/widgets/app_sf_icon.dart';
import '../../../core/widgets/gradient_control_chrome.dart';
import '../../../theme/app_colors.dart';

/// Visual height of the floating pill tab bar.
const double kAppFloatingTabBarHeight = 60;

/// Gap between the pill and the bottom safe-area boundary.
const double kAppFloatingTabBarBottomGap = 8;

/// Width cap of the floating pill on wide screens (tablets/landscape) — the
/// same 416 the audio player panel uses (`_PlayerRouteFrame`), so the two
/// floating surfaces share one footprint instead of stretching edge-to-edge.
const double kAppFloatingTabBarMaxWidth = 416;

/// Bottom inset that tab content scroll views should add so their last items
/// clear the floating pill (which overlays the content). The page's safe-area
/// bottom is already reserved by the host scaffold, so this is just the pill
/// footprint plus a comfortable gap.
const double kAppFloatingTabBarContentInset =
    kAppFloatingTabBarHeight + kAppFloatingTabBarBottomGap + 16;

/// Bottom content inset every scroll view hosted in [AppFloatingTabScaffold]
/// should add: the device safe-area bottom plus the floating pill footprint, so
/// the last item scrolls clear of the pill. Pair with `appChromeBarTopInset`
/// (from `app_chrome_bar.dart`) for the top. Centralised here so screens never
/// hand-roll the value and forget the safe area or the pill height.
double appChromeBottomInset(BuildContext context) =>
    withEdgeBreathing(MediaQuery.paddingOf(context).bottom) +
    kAppFloatingTabBarContentInset;

/// A single tab descriptor for [AppFloatingTabBar].
class AppFloatingTabItem {
  const AppFloatingTabItem({required this.icon, required this.label});

  final IconData icon;
  final String label;
}

/// Uniform inset between the bar edge and the sliding highlight capsule,
/// applied on all four sides. Because the inner capsule radius is the bar
/// radius minus this inset, the two corners stay perfectly concentric (the
/// Telegram-style nested-stadium look).
const double _kTabBarInnerPadding = 6;

/// Square footprint each tab glyph is centered within, so icons of differing
/// intrinsic size share one baseline and a consistent icon-to-label gap.
const double _kTabIconBox = 26;
const double _kTabIconLabelGap = 2;
const double _kTabLabelLineHeight = 11;
const double _kTabLabelHeightSlack = 2;
const double _kTabItemContentHeight =
    _kTabIconBox +
    _kTabIconLabelGap +
    _kTabLabelLineHeight +
    _kTabLabelHeightSlack;

/// Motion of the sliding highlight when the active tab changes.
const Duration _kHighlightSlideDuration = Duration(milliseconds: 260);
const Curve _kHighlightSlideCurve = Curves.easeOutCubic;

/// Floating, rounded "pill" tab bar styled with the app chrome
/// ([GradientControlChrome]) to match the redesigned top bars. Driven by a
/// [CupertinoTabController] so it stays in sync with [CupertinoTabScaffold].
///
/// The active tab is marked by a soft, accent-tinted highlight capsule that
/// slides between slots when the selection changes. The capsule is a stadium
/// whose corner radius is derived from the bar's own radius so the two nest
/// concentrically; its icon/label use the accent tint while inactive tabs use
/// the inactive icon tint and secondary label.
class AppFloatingTabBar extends StatelessWidget {
  const AppFloatingTabBar({
    super.key,
    required this.controller,
    required this.items,
    this.margin = EdgeInsets.zero,
    this.height = kAppFloatingTabBarHeight,
  });

  final CupertinoTabController controller;
  final List<AppFloatingTabItem> items;
  final EdgeInsets margin;
  final double height;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    // In dark mode the pill renders with a near-black chrome surface
    // (GradientControlChrome dark gradient). The White ("Светлая") scheme keeps
    // a near-black accent (#2B2B2B) in both brightnesses, so the active tab's
    // accent-tinted icon/label would vanish against that dark pill. Lift the
    // effective accent to a legible light tone in that case; warm Classic/Beige
    // accents contrast fine and are left untouched.
    final isDarkChrome =
        CupertinoTheme.brightnessOf(context) == Brightness.dark;
    final accent = (isDarkChrome && colors.accent.computeLuminance() < 0.1)
        ? colors.textPrimary
        : colors.accent;
    // Soft accent-tinted highlight. The tint scales gently with the accent's
    // luminance: darker accents (e.g. the near-black White theme) read strongly
    // on the light bar at a lower alpha, while the warm Classic accent needs a
    // touch more density to stay legible over the cream bar.
    final highlight =
        colors.tabSelectionBackground ??
        accent.withValues(alpha: accent.computeLuminance() < 0.1 ? 0.12 : 0.16);
    // Inner capsule height after vertical padding; its radius (= half height)
    // produces a stadium that nests concentrically inside the bar's radius.
    final innerHeight = height - _kTabBarInnerPadding * 2;
    final count = items.length;

    return Padding(
      padding: margin,
      child: AnimatedBuilder(
        animation: controller,
        builder: (context, _) {
          final current = controller.index;
          // Alignment x for the active slot: -1 (first) .. +1 (last).
          final alignX = count <= 1 ? 0.0 : -1.0 + 2.0 * current / (count - 1);
          return SizedBox(
            height: height,
            child: GradientControlChrome(
              radius: height / 2,
              // No drop shadow: list content stays crisp where it scrolls
              // behind and below the pill, instead of being dimmed by a halo.
              enableShadow: false,
              child: Padding(
                padding: const EdgeInsets.all(_kTabBarInnerPadding),
                // StackFit.expand gives both layers the full inner height, so
                // the row's own vertical centering and the highlight capsule
                // share the exact same bounds — the content is centered first,
                // then the capsule is laid behind it.
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    // Sliding highlight capsule behind the tab row. It occupies
                    // a single slot and animates its alignment when the active
                    // index changes, so it glides across rather than popping.
                    IgnorePointer(
                      child: AnimatedAlign(
                        duration: _kHighlightSlideDuration,
                        curve: _kHighlightSlideCurve,
                        alignment: AlignmentDirectional(alignX, 0),
                        child: FractionallySizedBox(
                          widthFactor: 1 / count,
                          heightFactor: 1,
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              color: highlight,
                              borderRadius: BorderRadius.circular(
                                innerHeight / 2,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Row(
                      children: [
                        for (var i = 0; i < count; i++)
                          Expanded(
                            child: _TabItem(
                              item: items[i],
                              isActive: i == current,
                              accent: accent,
                              colors: colors,
                              onTap: () => controller.index = i,
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _TabItem extends StatelessWidget {
  const _TabItem({
    required this.item,
    required this.isActive,
    required this.accent,
    required this.colors,
    required this.onTap,
  });

  final AppFloatingTabItem item;
  final bool isActive;
  final Color accent;
  final AppColors colors;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final foreground = isActive
        ? accent
        : colors.tabInactiveForeground ?? colors.iconInactive;
    final labelColor = isActive
        ? accent
        : colors.tabInactiveForeground ?? colors.textSecondary;

    return PressScale(
      onTap: onTap,
      pressedScale: 0.94,
      child: Semantics(
        button: true,
        selected: isActive,
        label: item.label,
        child: SizedBox.expand(
          child: Center(
            child: SizedBox(
              height: _kTabItemContentHeight,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  AnimatedScale(
                    scale: isActive ? 1.08 : 1,
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeOut,
                    // Use AppSfIcon's boxed glyph path so SF Symbol font
                    // metrics are centered in the same fixed footprint for
                    // every tab icon.
                    child: AppSfIcon(
                      item.icon,
                      fontSize: 22,
                      boxSize: _kTabIconBox,
                      fontWeight: isActive ? FontWeight.w700 : FontWeight.w600,
                      color: foreground,
                    ),
                  ),
                  const SizedBox(height: _kTabIconLabelGap),
                  Text(
                    item.label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    // Trim the font's ascent/descent leading so the label's box
                    // hugs the glyphs. Without this the descent padding biases
                    // the column upward, leaving the capsule's bottom inset
                    // visibly larger.
                    textHeightBehavior: const TextHeightBehavior(
                      applyHeightToFirstAscent: false,
                      applyHeightToLastDescent: false,
                    ),
                    style: TextStyle(
                      color: labelColor,
                      fontSize: _kTabLabelLineHeight,
                      height: 1.0,
                      letterSpacing: 0.0,
                      fontWeight: isActive ? FontWeight.w700 : FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
