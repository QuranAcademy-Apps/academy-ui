part of '../modal_sheet_detents.dart';

const double _landscapeTopGap = 8;

bool isLandscapeModalPresentation(BuildContext context) {
  final size = MediaQuery.sizeOf(context);
  return size.width > size.height;
}

double landscapeModalHeight(BuildContext context, double height) {
  if (!isLandscapeModalPresentation(context)) return height;

  final mediaQuery = MediaQuery.of(context);
  final maxHeight =
      _modalSheetRouteHeight(context) -
      mediaQuery.padding.top -
      _landscapeTopGap;
  return maxHeight.clamp(0.0, mediaQuery.size.height).toDouble();
}

class LandscapeModalSheetFrame extends StatefulWidget {
  const LandscapeModalSheetFrame({
    super.key,
    required this.child,
    this.insets,
    this.alignment = AlignmentDirectional.bottomCenter,
  });

  final Widget child;
  final EdgeInsetsGeometry? insets;
  final AlignmentGeometry alignment;

  @override
  State<LandscapeModalSheetFrame> createState() =>
      _LandscapeModalSheetFrameState();
}

class _LandscapeModalSheetFrameState extends State<LandscapeModalSheetFrame>
    with WidgetsBindingObserver {
  bool? _isLandscape;

  // Keeps the child's element subtree (e.g. a nested Navigator and its route
  // stack) alive when the orientation flips the wrapping layout between the
  // plain portrait child and the landscape Stack. Without a stable global key
  // the structural change would reparent the child into a different element
  // slot, destroying its State and popping nested screens back to the root.
  final GlobalKey _childKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _scheduleRouteDetentSync();
  }

  @override
  void didChangeMetrics() {
    _scheduleRouteDetentSync();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final child = KeyedSubtree(key: _childKey, child: widget.child);
    if (!isLandscapeModalPresentation(context)) return child;

    return SizedBox(
      width: double.infinity,
      height: MediaQuery.sizeOf(context).height,
      child: Stack(
        children: [
          Positioned.fill(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => Navigator.of(context).maybePop(),
            ),
          ),
          SafeArea(
            left: true,
            top: false,
            right: true,
            bottom: false,
            child: Padding(
              padding:
                  widget.insets ??
                  AcademyTheme.of(context).paddings.landscapeModal,
              child: Align(
                alignment: widget.alignment,
                child: SizedBox(
                  width: double.infinity,
                  height: landscapeModalHeight(
                    context,
                    ModalSheetDetent.full.heightOf(context),
                  ),
                  // Без клипа над контентом, как в портрете: верхние углы держит
                  // подложка SheetBackground внутри child (её shape реагирует и на
                  // квадрат-дебаг). Скруглённый клип над скроллом = offscreen-пас.
                  child: child,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _scheduleRouteDetentSync() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final isLandscape = isLandscapeModalPresentation(context);
      final wasLandscape = _isLandscape;
      if (wasLandscape == isLandscape) return;
      _isLandscape = isLandscape;

      final controller = StupidSimpleSheetController.maybeOf<dynamic>(context);
      if (controller == null) return;

      if (isLandscape) {
        // Portrait → landscape: collapse to the single full detent.
        controller.overrideSnappingConfig(_landscapeFullSnappingConfig);
        controller.animateToRelative(1);
      } else if (wasLandscape == true) {
        // Landscape → portrait: restore the portrait detents. The last config
        // a nested screen requested via [setModalSheetDetentHeight] takes
        // precedence over the route's seeded portrait config. Animate
        // explicitly to its initial detent rather than `animateToComply`, which
        // would snap to whatever is nearest the landscape full position and
        // leave the sheet stuck open.
        final portraitConfig = _portraitSnappingConfig[controller];
        if (portraitConfig != null) {
          controller.overrideSnappingConfig(portraitConfig);
          controller.animateToRelative(portraitConfig.initialSnap);
        } else {
          controller.overrideSnappingConfig(null, animateToComply: true);
        }
        setState(() {});
      }
    });
  }
}
