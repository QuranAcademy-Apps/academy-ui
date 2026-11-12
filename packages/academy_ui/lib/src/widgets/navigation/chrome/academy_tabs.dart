import 'package:cupertino_ui/cupertino_ui.dart';

import 'dart:math' as math;

import '../../../theme/academy_theme.dart';
import '../../../foundation/layout/academy_text_fit.dart';
import '../../../foundation/interaction/academy_interaction.dart';
import '../../../foundation/motion/press_scale.dart';
import '../../icon/academy_sf_image.dart';
import 'academy_chrome.dart';
import 'academy_chrome_fade_material.dart';
import 'academy_chrome_metrics.dart';

/// Selected tab of an [AcademyTabScaffold].
class AcademyTabController extends ChangeNotifier {
  AcademyTabController({int initialIndex = 0})
    : assert(initialIndex >= 0),
      _index = initialIndex;

  int _index;
  int get index => _index;
  set index(int value) {
    assert(value >= 0);
    if (value == _index) return;
    _index = value;
    notifyListeners();
  }
}

class AcademyTab {
  const AcademyTab({
    this.key,
    required this.label,
    required this.icon,
    required this.builder,
  });

  /// Identifies the tab's button, for example in tests.
  final Key? key;
  final String label;
  final IconData icon;
  final WidgetBuilder builder;
}

// Geometry from Telegram-iOS TabBarComponent, commit 6ad963e5b62d354da79040f388ae2b9132fb17b8.
// Static images retain their intrinsic size there; our SF glyph uses its existing 32px frame.
abstract final class _TelegramTabMetrics {
  static const itemHeight = 56.0;
  static const maxWidth = 500.0;
  static const labelBottom = 8.0;
  static const labelHorizontalPadding = 10.0;
  static const imageTop = 3.0;
}

abstract final class _CompactTabMetrics {
  static const horizontalPadding = 16.0;
}

List<double> _telegramItemWidths(
  List<double> measured,
  double available,
  double pixelRatio,
) {
  double floorPixel(double value) => (value * pixelRatio).floor() / pixelRatio;
  final equal = floorPixel(available / measured.length);
  if (measured.every((width) => width <= equal)) {
    return List<double>.filled(measured.length, equal);
  }

  // Weighted fit, with a Flutter accessibility floor for narrow/large-text layouts.
  final minimum = math.min(44.0, available / measured.length);
  final widths = List<double>.filled(measured.length, 0);
  final pending = {for (var i = 0; i < measured.length; i++) i};
  var remaining = available;
  while (pending.isNotEmpty) {
    final sum = pending.fold<double>(0, (sum, i) => sum + measured[i]);
    final small = pending
        .where((i) => measured[i] * remaining / sum < minimum)
        .toList();
    if (small.isEmpty) {
      for (final i in pending) {
        widths[i] = floorPixel(measured[i] * remaining / sum);
      }
      break;
    }
    for (final i in small) {
      widths[i] = minimum;
      remaining -= minimum;
      pending.remove(i);
    }
  }
  return widths;
}

/// Quran floating pill: moving highlight, SF symbols, bounded tablet width.
class AcademyFloatingTabBar extends StatelessWidget {
  const AcademyFloatingTabBar({
    super.key,
    required this.tabs,
    required this.index,
    required this.onChanged,
    this.style,
    this.surfaceOpacity = 1,
    this.blurSigma,
    this.density,
    this.maxWidth = 416,
    this.contentWidth,
    this.scrollController,
    this.showIcons = true,
  }) : assert(tabs.length > 0),
       assert(index >= 0 && index < tabs.length);
  final List<AcademyTab> tabs;
  final int index;
  final ValueChanged<int> onChanged;
  final AcademyChromeStyle? style;
  final double surfaceOpacity;
  final double? blurSigma;
  final AcademyTabBarDensity? density;

  /// Widest panel for the standard and compact densities.
  final double maxWidth;

  /// Scrollable row width for many text-only tabs; the panel stays bounded.
  final double? contentWidth;
  final ScrollController? scrollController;

  /// Text-only variant: a 44pt control with bold 14pt labels and no symbols.
  final bool showIcons;

  /// Height of the text-only variant ([showIcons] false).
  static const textOnlyHeight = academyChromeBarHeight;
  static AcademyTabBarDensity densityOf(BuildContext context) =>
      AcademyChromeTheme.maybeOf(context)?.tabBarDensity ??
      AcademyTabBarDensity.standard;
  static double heightOf(
    BuildContext context, {
    AcademyTabBarDensity? density,
  }) {
    final resolved = density ?? densityOf(context);
    final theme = AcademyTheme.of(context);
    final labelSize =
        (resolved == AcademyTabBarDensity.standard
                ? theme.textTheme.tabLabel
                : theme.textTheme.compactTabLabel)
            .fontSize!;
    final padding = resolved == AcademyTabBarDensity.standard
        ? theme.paddings.tabBar
        : theme.paddings.compactTabBar;
    if (resolved == AcademyTabBarDensity.standard && theme.tabBar.fixedHeight) {
      return 60.0 + padding.vertical - 12;
    }
    final baseHeight = switch (resolved) {
      AcademyTabBarDensity.standard => 60.0,
      AcademyTabBarDensity.compact => 56.0,
      AcademyTabBarDensity.telegram =>
        _TelegramTabMetrics.itemHeight + padding.vertical,
    };
    final defaultLabel = resolved == AcademyTabBarDensity.standard
        ? 11.0
        : 10.0;
    final defaultPadding = resolved == AcademyTabBarDensity.standard
        ? 12.0
        : 8.0;
    return baseHeight +
        (resolved == AcademyTabBarDensity.telegram
            ? 0
            : padding.vertical - defaultPadding) +
        (labelSize - defaultLabel).clamp(0, double.infinity) +
        (MediaQuery.textScalerOf(context).scale(labelSize) - labelSize).clamp(
          0,
          double.infinity,
        );
  }

  static double bottomObstructionOf(BuildContext context) =>
      academyChromeBottomOf(context) + heightOf(context);
  @override
  Widget build(BuildContext context) {
    final p = AcademyTheme.of(context).colorScheme;
    final resolved = density ?? densityOf(context);
    final compact = resolved == AcademyTabBarDensity.compact;
    final telegram = resolved == AcademyTabBarDensity.telegram;
    final smallLabels = resolved != AcademyTabBarDensity.standard;
    final tabPadding = smallLabels
        ? AcademyTheme.of(context).paddings.compactTabBar
        : AcademyTheme.of(context).paddings.tabBar;

    final chrome = AcademyChromeTheme.colorsOf(context);
    final tabTheme = AcademyTheme.of(context).tabBar;
    final standard = resolved == AcademyTabBarDensity.standard;
    final textOnly = !showIcons && !telegram;
    final height = textOnly
        ? textOnlyHeight
        : heightOf(context, density: density);
    final text = AcademyTheme.of(context).textTheme;
    final labelStyle = textOnly
        ? text.tabText
        : smallLabels
        ? text.compactTabLabel
        : tabTheme.labelStyle ?? text.tabLabel.copyWith(height: 1);
    final iconFrame = telegram
        ? 32.0
        : standard
        ? tabTheme.iconBoxSize
        : 30.0;
    final labelDirection = Directionality.of(context);
    final labelScaler = MediaQuery.textScalerOf(context);
    // Measured only by the layouts that size tabs to their labels.
    late final naturalWidths = tabs.map((tab) {
      final painter = TextPainter(
        text: TextSpan(text: tab.label, style: labelStyle),
        textDirection: labelDirection,
        textScaler: labelScaler,
        maxLines: 1,
      )..layout();
      final width =
          (compact ? math.max(iconFrame, painter.width) : painter.width) +
          (compact
                  ? _CompactTabMetrics.horizontalPadding
                  : _TelegramTabMetrics.labelHorizontalPadding) *
              2;
      painter.dispose();
      return width;
    }).toList();
    return Center(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final availableWidth = math.min(
            constraints.maxWidth,
            telegram ? _TelegramTabMetrics.maxWidth : maxWidth,
          );
          final panelWidth = compact
              ? math.min(
                  availableWidth,
                  naturalWidths.fold<double>(0, (sum, width) => sum + width) +
                      tabPadding.horizontal,
                )
              : availableWidth;
          final resolvedPadding = textOnly
              ? EdgeInsets.symmetric(horizontal: tabPadding.left)
              : tabPadding;
          final availableItemsWidth = math.max(
            0.0,
            contentWidth == null
                ? panelWidth - resolvedPadding.horizontal
                : math.max(
                    panelWidth - resolvedPadding.horizontal,
                    contentWidth! - resolvedPadding.horizontal,
                  ),
          );
          final widths = smallLabels
              ? _telegramItemWidths(
                  naturalWidths,
                  availableItemsWidth,
                  MediaQuery.devicePixelRatioOf(context),
                )
              : List<double>.filled(
                  tabs.length,
                  availableItemsWidth / tabs.length,
                );
          final innerWidth = widths.fold<double>(
            0,
            (sum, width) => sum + width,
          );
          final barWidth = contentWidth == null
              ? innerWidth + resolvedPadding.horizontal
              : panelWidth;
          final precedingWidth = widths
              .take(index)
              .fold<double>(0, (sum, width) => sum + width);
          final itemHeight = height - resolvedPadding.vertical;
          final selectionWidth = telegram && widths[index] < itemHeight
              ? math.min(innerWidth, itemHeight * 1.2)
              : widths[index];
          final selectionStart =
              (precedingWidth + (widths[index] - selectionWidth) / 2)
                  .clamp(0.0, math.max(0.0, innerWidth - selectionWidth))
                  .toDouble();
          final unselectedColor = AcademyChrome.foregroundColor(
            context,
            chrome.unselectedForeground ?? p.onSurfaceVariant,
            style: style,
            surfaceOpacity: surfaceOpacity,
          );
          final selectedIcon = chrome.selectedIcon ?? p.onPrimaryContainer;
          final selectedLabel = chrome.selectedLabel ?? p.onPrimaryContainer;
          final unselectedLabel = chrome.unselectedLabel == null
              ? unselectedColor
              : AcademyChrome.foregroundColor(
                  context,
                  chrome.unselectedLabel!,
                  style: style,
                  surfaceOpacity: surfaceOpacity,
                );
          final selectionRadius = math.min(
            itemHeight / 2 - (textOnly ? 4 : 0),
            AcademyTheme.of(context).radii.tabSelection,
          );
          return SizedBox(
            width: barWidth,
            child: AcademyChrome(
              radius: math.min(
                height / 2,
                AcademyTheme.of(context).radii.tabBar,
              ),
              surfaceOpacity: surfaceOpacity,
              style: style,
              blurSigma: blurSigma,
              showShadow: tabTheme.showShadow,
              child: SizedBox(
                height: height,
                child: Padding(
                  padding: resolvedPadding,
                  child: LayoutBuilder(
                    builder: (context, c) => _scrollable(
                      context,
                      selectionRadius,
                      SizedBox(
                        width: innerWidth,
                        child: Stack(
                          children: [
                            AnimatedPositioned(
                              duration: MediaQuery.disableAnimationsOf(context)
                                  ? Duration.zero
                                  : tabTheme.selectionDuration ??
                                        AcademyTokens.pressMotion,
                              curve: Curves.easeOutCubic,
                              left:
                                  Directionality.of(context) ==
                                      TextDirection.rtl
                                  ? innerWidth - selectionStart - selectionWidth
                                  : selectionStart,
                              top: textOnly ? 4 : 0,
                              bottom: textOnly ? 4 : 0,
                              width: selectionWidth,
                              child: DecoratedBox(
                                decoration: BoxDecoration(
                                  color: chrome.selection ?? p.primaryContainer,
                                  borderRadius: BorderRadius.circular(
                                    selectionRadius,
                                  ),
                                ),
                              ),
                            ),
                            Row(
                              children: [
                                for (var i = 0; i < tabs.length; i++)
                                  SizedBox(
                                    key: tabs[i].key,
                                    width: widths[i],
                                    child: AcademyActionSemantics(
                                      enabled: true,
                                      selected: i == index,
                                      label: '',
                                      child: _TabPress(
                                        pressedScale: standard
                                            ? tabTheme.pressedScale
                                            : null,
                                        onPressed: () => onChanged(i),
                                        child: telegram
                                            ? Stack(
                                                fit: StackFit.expand,
                                                children: [
                                                  Positioned(
                                                    top: _TelegramTabMetrics
                                                        .imageTop,
                                                    left: 0,
                                                    right: 0,
                                                    child: Center(
                                                      child: AcademySfIcon(
                                                        tabs[i].icon,
                                                        size: AcademyTheme.of(
                                                          context,
                                                        ).sizes.tabIcon,
                                                        boxSize: iconFrame,
                                                        paintExtent: iconFrame,
                                                        color: i == index
                                                            ? selectedIcon
                                                            : unselectedColor,
                                                      ),
                                                    ),
                                                  ),
                                                  Positioned(
                                                    left: 0,
                                                    right: 0,
                                                    bottom: _TelegramTabMetrics
                                                        .labelBottom,
                                                    child: Text(
                                                      tabs[i].label,
                                                      textAlign:
                                                          TextAlign.center,
                                                      maxLines: 1,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      style: labelStyle.copyWith(
                                                        color: i == index
                                                            ? selectedLabel
                                                            : unselectedColor,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              )
                                            : Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  if (!textOnly) ...[
                                                    _TabIconScale(
                                                      scale:
                                                          standard && i == index
                                                          ? tabTheme
                                                                .selectedIconScale
                                                          : 1,
                                                      child: SizedBox.square(
                                                        dimension: iconFrame,
                                                        child: AcademySfIcon(
                                                          tabs[i].icon,
                                                          size: AcademyTheme.of(
                                                            context,
                                                          ).sizes.compactTabIcon,
                                                          boxSize: iconFrame,
                                                          paintExtent: compact
                                                              ? 32
                                                              : iconFrame,
                                                          fontWeight: !standard
                                                              ? null
                                                              : i == index
                                                              ? tabTheme
                                                                    .selectedIconWeight
                                                              : tabTheme
                                                                    .iconWeight,
                                                          scaleWithText:
                                                              standard &&
                                                              tabTheme
                                                                  .iconScalesWithText,
                                                          color: i == index
                                                              ? selectedIcon
                                                              : unselectedColor,
                                                        ),
                                                      ),
                                                    ),
                                                    const SizedBox(height: 2),
                                                  ],
                                                  Padding(
                                                    padding:
                                                        EdgeInsets.symmetric(
                                                          horizontal: standard
                                                              ? tabTheme
                                                                    .labelPadding
                                                              : 2,
                                                        ),
                                                    child: Text(
                                                      tabs[i].label,
                                                      maxLines: 1,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      // Large text stops growing
                                                      // where the tab cannot hold
                                                      // the whole label.
                                                      textScaler:
                                                          compact ||
                                                              !tabTheme
                                                                  .fitLabels
                                                          ? null
                                                          : academyFitTextScaler(
                                                              context,
                                                              tabs[i].label,
                                                              labelStyle,
                                                              widths[i] - 4,
                                                              wholeText: true,
                                                            ),
                                                      textHeightBehavior:
                                                          const TextHeightBehavior(
                                                            applyHeightToFirstAscent:
                                                                false,
                                                            applyHeightToLastDescent:
                                                                false,
                                                          ),
                                                      style: labelStyle.copyWith(
                                                        fontWeight: !standard
                                                            ? null
                                                            : i == index
                                                            ? tabTheme
                                                                  .selectedLabelWeight
                                                            : tabTheme
                                                                  .labelWeight,
                                                        color: i == index
                                                            ? selectedLabel
                                                            : unselectedLabel,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _scrollable(BuildContext context, double radius, Widget content) {
    if (contentWidth == null) return content;
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: SingleChildScrollView(
        controller: scrollController,
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(
          parent: AlwaysScrollableScrollPhysics(),
        ),
        child: content,
      ),
    );
  }
}

class _TabPress extends StatelessWidget {
  const _TabPress({
    required this.pressedScale,
    required this.onPressed,
    required this.child,
  });

  final double? pressedScale;
  final VoidCallback onPressed;
  final Widget child;

  @override
  Widget build(BuildContext context) => pressedScale == null
      ? CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: onPressed,
          child: child,
        )
      : PressScale(
          pressedScale: pressedScale!,
          onTap: onPressed,
          child: SizedBox.expand(child: child),
        );
}

class _TabIconScale extends StatelessWidget {
  const _TabIconScale({required this.scale, required this.child});

  final double scale;
  final Widget child;

  @override
  Widget build(BuildContext context) => AnimatedScale(
    scale: scale,
    duration: const Duration(milliseconds: 200),
    curve: Curves.easeOut,
    child: child,
  );
}

/// Lazily builds visited pages and preserves their state; no business navigation.
class AcademyTabScaffold extends StatefulWidget {
  const AcademyTabScaffold({
    super.key,
    required this.tabs,
    this.controller,
    this.initialIndex = 0,
    this.onTabChanged,
  }) : assert(tabs.length > 0);
  final List<AcademyTab> tabs;

  /// Selected tab, for navigation from outside; default: an internal controller.
  final AcademyTabController? controller;
  final int initialIndex;

  /// Called when the selected tab changes, whoever changed it.
  final ValueChanged<int>? onTabChanged;
  @override
  State<AcademyTabScaffold> createState() => _AcademyTabScaffoldState();
}

class _AcademyTabScaffoldState extends State<AcademyTabScaffold> {
  AcademyTabController? _own;
  late final Set<int> _visited = {_controller.index};
  late int _reported;

  AcademyTabController get _controller =>
      widget.controller ??
      (_own ??= AcademyTabController(initialIndex: widget.initialIndex));

  @override
  void initState() {
    super.initState();
    _reported = _controller.index;
    _controller.addListener(_tabChanged);
  }

  @override
  void didUpdateWidget(AcademyTabScaffold oldWidget) {
    super.didUpdateWidget(oldWidget);
    final old = oldWidget.controller ?? _own;
    if (old != null && !identical(old, _controller)) {
      old.removeListener(_tabChanged);
      _controller.addListener(_tabChanged);
    }
    if (_controller.index >= widget.tabs.length) {
      _controller.index = widget.tabs.length - 1;
    }
    _visited.removeWhere((index) => index >= widget.tabs.length);
    _visited.add(_controller.index);
  }

  @override
  void dispose() {
    _controller.removeListener(_tabChanged);
    _own?.dispose();
    super.dispose();
  }

  void _tabChanged() {
    final index = _controller.index;
    setState(() => _visited.add(index));
    if (index == _reported) return;
    _reported = index;
    widget.onTabChanged?.call(index);
  }

  @override
  Widget build(BuildContext context) {
    final index = _controller.index;
    final tabTheme = AcademyTheme.of(context).tabBar;
    double bottomOf(BuildContext context) =>
        tabTheme.bottomInsetOf?.call(context) ?? academyChromeBottomOf(context);
    return Stack(
      children: [
        Positioned.fill(
          child: IndexedStack(
            index: index,
            children: [
              for (var i = 0; i < widget.tabs.length; i++)
                TickerMode(
                  enabled: i == index,
                  child: _visited.contains(i)
                      ? Builder(builder: widget.tabs[i].builder)
                      : const SizedBox.shrink(),
                ),
            ],
          ),
        ),
        // Insets are read in these leaves: the keyboard changes them on every
        // frame, and must not rebuild the tabs above.
        if (tabTheme.showBottomFade)
          Builder(
            builder: (context) => Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: RepaintBoundary(
                child: SizedBox(
                  height:
                      bottomOf(context) +
                      AcademyFloatingTabBar.heightOf(context) +
                      AcademyChromeFadeMaterial.extension,
                  child: const AcademyChromeFadeMaterial(bottom: true),
                ),
              ),
            ),
          ),
        Builder(
          builder: (context) {
            final telegram =
                AcademyFloatingTabBar.densityOf(context) ==
                AcademyTabBarDensity.telegram;
            final sideInset =
                tabTheme.sideMargin ??
                (telegram
                    ? (academyChromeBottomOf(context) <= 28 ? 20.0 : 12.0)
                    : 16.0);
            final safe = tabTheme.avoidSideInsets
                ? MediaQuery.paddingOf(context)
                : EdgeInsets.zero;
            return Positioned(
              left: sideInset + safe.left,
              right: sideInset + safe.right,
              bottom: bottomOf(context),
              // Cached as its own layer: the list scrolls under a static bar.
              child: RepaintBoundary(
                child: AcademyFloatingTabBar(
                  tabs: widget.tabs,
                  index: index,
                  onChanged: (i) => _controller.index = i,
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
