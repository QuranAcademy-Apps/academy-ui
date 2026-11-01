import 'package:cupertino_ui/cupertino_ui.dart';

import '../../../core/utils/floating_chrome_insets.dart';

/// Height of the bar row (excluding the top safe-area inset and the fade tail).
const double kAppChromeBarHeight = 44;

/// Total vertical space the floating bar occupies *before* content should
/// begin, i.e. the safe-area top inset plus the bar row. Content scroll views
/// use this as their top inset so the first item rests just below the bar and
/// scrolls up under the fade.
double appChromeBarTopInset(BuildContext context) =>
    withEdgeBreathing(MediaQuery.paddingOf(context).top) + kAppChromeBarHeight;

/// Canonical gap between the bottom of the floating chrome bar and the first
/// row of content, applied uniformly across every chrome screen (lists, grouped
/// tables and card layouts alike). Use [appChromeContentTopInset] rather than
/// adding this by hand so the spacing never drifts per screen.
const double kAppChromeContentTopGap = 8;

/// Top inset a content scroll view should use so its first row clears the
/// floating bar *and* sits a uniform [kAppChromeContentTopGap] below it. This is
/// the single source of truth for nav-bar-to-content spacing — screens must not
/// add their own ad-hoc top padding on top of it.
double appChromeContentTopInset(BuildContext context) =>
    appChromeBarTopInset(context) + kAppChromeContentTopGap;

/// Vertical inset above and below the modal header row, kept equal to the
/// header's horizontal inset so the bar's controls sit symmetrically inside the
/// header (not crowding the sheet's top edge).
const double kAppChromeModalHeaderVerticalInset = 14;

/// Height of the chrome modal header row (the standard modal/sheet header
/// height, so sheet layouts keep consistent proportions). Sized so the
/// [kAppChromeBarHeight]-tall controls clear [kAppChromeModalHeaderVerticalInset]
/// above and below, giving the bar top/bottom symmetry that matches its sides.
const double kAppChromeModalHeaderHeight =
    kAppChromeBarHeight + 2 * kAppChromeModalHeaderVerticalInset;
