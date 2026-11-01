import 'dart:math' as math;

import 'package:academy_ui/academy_ui.dart' show SoftFadeSwitcher;
import 'package:cupertino_ui/cupertino_ui.dart';

import '../../../core/utils/floating_chrome_insets.dart';
import '../../../core/widgets/app_page_scaffold.dart';
import '../../../core/widgets/modal_sheet_detents.dart';
import '../../../theme/app_colors.dart';
import 'app_chrome_bar.dart';
import 'app_chrome_search_bar.dart';
import 'app_floating_tab_bar.dart';
import '../../../core/widgets/modal_sheet_corner_mask.dart';

/// Gap between the last scrollable row and the bottom safe-area boundary on a
/// pushed (non-tab) chrome screen.
const double kAppChromePushedBottomGap = 16;

/// Standard page scaffold for the floating-chrome look: content is edge-to-edge
/// and scrolls underneath a floating [AppFloatingChromeBar] overlaid at the top.
///
/// The [body] builder receives the content insets it must apply to its scroll
/// view (as `padding`) so the first row rests just below the bar and the last
/// row clears the home indicator / floating tab pill. Callers must NOT wrap the
/// body in their own top `SafeArea` — the insets already account for it.
///
/// Set [hasTabBar] to true for screens hosted inside [AppFloatingTabScaffold]
/// (the bottom inset then clears the floating tab pill); leave it false for
/// pushed detail screens (bottom inset only clears the home indicator).
class AppChromePageScaffold extends StatelessWidget {
  const AppChromePageScaffold({
    super.key,
    this.title,
    this.middle,
    this.leading,
    this.actions,
    this.showBackButton = true,
    this.backgroundColor,
    this.resizeToAvoidBottomInset = true,
    this.hasTabBar = false,
    this.searchActive = false,
    this.searchController,
    this.searchFocusNode,
    this.searchPlaceholder,
    this.onSearchChanged,
    this.onSearchClear,
    this.onSearchCancel,
    this.searchAutofocus = true,
    this.searchFieldWrapper,
    required this.body,
  }) : assert(
         title != null || middle != null,
         'Provide either a title or a middle widget',
       );

  final String? title;
  final Widget? middle;

  /// Overrides the default leading widget. When null and [showBackButton] is
  /// true, an [AppChromeBarBackButton] is shown.
  final Widget? leading;
  final List<Widget>? actions;
  final bool showBackButton;
  final Color? backgroundColor;
  final bool resizeToAvoidBottomInset;
  final bool hasTabBar;

  /// When true the floating bar shows the search field (a full-width
  /// [AppChromeSearchBar] with a Cancel button) instead of the title/actions.
  /// The host owns the trigger (e.g. a magnifier in [actions]) and the search
  /// state; this scaffold only renders the field. Mirrors the search support of
  /// [AppChromeModalScaffold] so pushed and modal screens search identically.
  final bool searchActive;
  final TextEditingController? searchController;
  final FocusNode? searchFocusNode;
  final String? searchPlaceholder;
  final ValueChanged<String>? onSearchChanged;
  final VoidCallback? onSearchClear;
  final VoidCallback? onSearchCancel;
  final bool searchAutofocus;

  /// Lets a host wrap the inner search field (e.g. with a detent helper) without
  /// leaking that concern into the scaffold.
  final Widget Function(BuildContext context, Widget field)? searchFieldWrapper;

  /// Builds the page body. Receives the [EdgeInsets] the scroll view should use
  /// as `padding` so content clears the floating bars.
  final Widget Function(BuildContext context, EdgeInsets contentInsets) body;

  Widget _buildBar(BuildContext context) {
    if (searchActive) {
      assert(
        onSearchCancel != null,
        'searchActive requires onSearchCancel so the field can be dismissed',
      );
      return KeyedSubtree(
        key: const ValueKey('chrome-page-search'),
        child: AppFloatingChromeBar(
          middle: AppChromeSearchBar(
            placeholder: searchPlaceholder ?? '',
            controller: searchController,
            focusNode: searchFocusNode,
            autofocus: searchAutofocus,
            onChanged: onSearchChanged,
            onClear: onSearchClear,
            onCancel: onSearchCancel ?? () {},
            fieldWrapper: searchFieldWrapper,
          ),
        ),
      );
    }
    final effectiveLeading =
        leading ?? (showBackButton ? const AppChromeBarBackButton() : null);
    return KeyedSubtree(
      key: const ValueKey('chrome-page-bar'),
      child: AppFloatingChromeBar(
        leading: effectiveLeading,
        middle: middle ?? AppChromeBarTitleCapsule(title: title!),
        actions: actions,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final effectiveBackground = backgroundColor ?? colors.backgroundSecondary;
    // Horizontal safe-area insets (notch / home indicator on the side in
    // landscape). The floating bar wraps its own row in a SafeArea, but the
    // edge-to-edge body scroll view doesn't — fold the side insets into the
    // content padding so rows clear the cutout instead of running under it.
    final padding = MediaQuery.paddingOf(context);
    final viewPadding = MediaQuery.viewPaddingOf(context);
    final leftInset = math.max(padding.left, viewPadding.left);
    final rightInset = math.max(padding.right, viewPadding.right);
    final contentInsets = EdgeInsets.only(
      top: appChromeContentTopInset(context),
      left: leftInset,
      right: rightInset,
      bottom: hasTabBar
          ? appChromeBottomInset(context)
          : floatingChromeBottomInsetOf(context) + kAppChromePushedBottomGap,
    );

    return AppPageScaffold(
      safeArea: false,
      backgroundColor: effectiveBackground,
      resizeToAvoidBottomInset: resizeToAvoidBottomInset,
      child: Stack(
        children: [
          Positioned.fill(child: body(context, contentInsets)),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            // Crossfade the bar when it swaps to/from the search field.
            child: SoftFadeSwitcher(child: _buildBar(context)),
          ),
        ],
      ),
    );
  }
}

/// Modal-sheet counterpart of [AppChromePageScaffold]: content is edge-to-edge
/// and scrolls underneath a *floating* [AppChromeModalHeader] (a soft
/// [AppChromeFadeMaterial] sits behind the header so rows dissolve as they
/// scroll up), instead of butting against an opaque laid-out header row.
///
/// The [body] builder receives the content insets to apply to its scroll view
/// as `padding`: `top` clears the floating header. The enclosing sheet's
/// off-screen detent slice is NOT folded into `insets.bottom` — the body must
/// add [ModalSheetScrollInsets.of] at a leaf (a `Builder` around its scroll
/// padding) so a detent change rebuilds only that leaf, not the whole body. The
/// leaf read returns 0 outside a sheet, so the same body works when pushed. Do
/// NOT override the bottom with `MediaQuery.padding` (zeroed inside the sheet),
/// or the list gets cut off at a partial detent.
///
/// Pass [header] to supply a custom header (e.g. one that swaps to a search
/// row); otherwise [title]/[middle] build a standard [AppChromeModalHeader].
///
/// Built-in search: set [searchActive] true (driven by the host's search state)
/// and the header swaps to a full-width [AppChromeSearchBar] with a close
/// button. The host owns the trigger (a magnifier button in [leading]/[actions])
/// and the search state; this scaffold only renders the field. Provide at least
/// [onSearchCancel] when [searchActive] can become true.
class AppChromeModalScaffold extends StatelessWidget {
  const AppChromeModalScaffold({
    super.key,
    this.title,
    this.middle,
    this.leading,
    this.actions,
    this.onClose,
    this.showClose = true,
    this.header,
    this.headerHeight = kAppChromeModalHeaderHeight,
    this.backgroundColor,
    this.searchActive = false,
    this.searchController,
    this.searchFocusNode,
    this.searchPlaceholder,
    this.onSearchChanged,
    this.onSearchClear,
    this.onSearchCancel,
    this.searchAutofocus = true,
    this.searchFieldWrapper,
    required this.body,
  }) : assert(
         header != null || title != null || middle != null,
         'Provide a header, a title, or a middle widget',
       );

  final String? title;
  final Widget? middle;
  final Widget? leading;
  final List<Widget>? actions;
  final VoidCallback? onClose;
  final bool showClose;

  /// Custom header overriding the built-in [AppChromeModalHeader]. Use for
  /// headers that aren't a standard title row. Should render [headerHeight]
  /// tall. Ignored while [searchActive] (the search field takes over).
  final Widget? header;
  final double headerHeight;
  final Color? backgroundColor;

  /// When true the header shows the search field instead of the title/[header].
  final bool searchActive;
  final TextEditingController? searchController;
  final FocusNode? searchFocusNode;
  final String? searchPlaceholder;
  final ValueChanged<String>? onSearchChanged;
  final VoidCallback? onSearchClear;
  final VoidCallback? onSearchCancel;
  final bool searchAutofocus;

  /// Lets a host wrap the inner search field (e.g. with `ModalDetentFocus`
  /// inside a snapping sheet) without leaking that concern into the scaffold.
  final Widget Function(BuildContext context, Widget field)? searchFieldWrapper;

  final Widget Function(BuildContext context, EdgeInsets contentInsets) body;

  Widget _buildHeader() {
    if (searchActive) {
      assert(
        onSearchCancel != null,
        'searchActive requires onSearchCancel so the field can be dismissed',
      );
      // Keyed so the search ↔ resting swap crossfades via [SoftFadeSwitcher].
      return KeyedSubtree(
        key: const ValueKey('chrome-modal-search'),
        child: AppChromeModalHeader(
          height: headerHeight,
          showClose: false,
          middle: AppChromeSearchBar(
            placeholder: searchPlaceholder ?? '',
            controller: searchController,
            focusNode: searchFocusNode,
            autofocus: searchAutofocus,
            onChanged: onSearchChanged,
            onClear: onSearchClear,
            onCancel: onSearchCancel ?? () {},
            fieldWrapper: searchFieldWrapper,
          ),
        ),
      );
    }
    return KeyedSubtree(
      key: const ValueKey('chrome-modal-header'),
      child:
          header ??
          AppChromeModalHeader(
            title: title,
            middle: middle,
            leading: leading,
            actions: actions,
            onClose: onClose,
            showClose: showClose,
            height: headerHeight,
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final effectiveBackground = backgroundColor ?? colors.backgroundPrimary;
    // Only the static top inset (floating header) is folded here. The bottom
    // off-screen detent slice is intentionally NOT read at this level: reading
    // it here makes the whole scaffold — and the body it builds — a dependent of
    // [ModalSheetScrollInsets], so every detent change (drag-snap, rotation,
    // search-grow) rebuilt the entire body, including heavy lists. Each body now
    // adds [ModalSheetScrollInsets.of] at a leaf around its own scroll padding,
    // so only that leaf rebuilds. The leaf read is 0 outside a sheet, so the
    // same body works unchanged when pushed.
    // (docs/tasks/2026-06-24-modal-insets-rebuild-audit)
    final contentInsets = EdgeInsets.only(top: headerHeight);

    return ModalSheetRoundedSurface(
      // Скруглённый верх рисует статичная заливка подложки (без клипа над скролл-
      // боди). Подложка же даёт scope формы шита: опак-контент тела
      // (GroupedTable/строки) маскирует свою заливку по форме шита у углов
      // (ModalSheetMaskedFill) и не заезжает в вырез при скролле.
      color: effectiveBackground,
      child: Stack(
        children: [
          Positioned.fill(child: body(context, contentInsets)),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SizedBox(
              // Keep the fade inside the header; initial content starts after
              // this inset and can scroll underneath it.
              height: headerHeight,
              // Empty header space belongs to the sheet's drag gesture, not
              // to the scroll view that now extends underneath it.
              child: Listener(
                behavior: HitTestBehavior.opaque,
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    // Only the static fade needs the sheet's rounded corners.
                    // Clipping controls here cuts their shadows at the header's
                    // bottom edge, leaving a visible horizontal seam.
                    const Positioned.fill(
                      child: RepaintBoundary(
                        child: ClipRSuperellipse(
                          borderRadius: BorderRadius.vertical(
                            top: appModalSheetTopRadius,
                          ),
                          clipBehavior: Clip.antiAlias,
                          child: AppChromeFadeMaterial(),
                        ),
                      ),
                    ),
                    // Crossfade the header when it swaps to/from the search field.
                    SoftFadeSwitcher(child: _buildHeader()),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
