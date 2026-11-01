import 'package:flutter/cupertino.dart';

import 'dart:math' as math;

import '../../../theme/academy_theme.dart';
import '../../../foundation/interaction/academy_interaction.dart';
import '../../icon/academy_sf_image.dart';
import 'academy_chrome.dart';
import 'academy_chrome_metrics.dart';

class AcademyTab {
  const AcademyTab({
    required this.label,
    required this.icon,
    required this.builder,
  });
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
  }) : assert(tabs.length > 0),
       assert(index >= 0 && index < tabs.length);
  final List<AcademyTab> tabs;
  final int index;
  final ValueChanged<int> onChanged;
  final AcademyChromeStyle? style;
  final double surfaceOpacity;
  final double? blurSigma;
  final AcademyTabBarDensity? density;
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

    final height = heightOf(context, density: density);
    final text = AcademyTheme.of(context).textTheme;
    final labelStyle = smallLabels
        ? text.compactTabLabel
        : text.tabLabel.copyWith(height: 1);
    final iconFrame = telegram ? 32.0 : 30.0;
    final naturalWidths = tabs.map((tab) {
      final painter = TextPainter(
        text: TextSpan(text: tab.label, style: labelStyle),
        textDirection: Directionality.of(context),
        textScaler: MediaQuery.textScalerOf(context),
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
            telegram ? _TelegramTabMetrics.maxWidth : 416.0,
          );
          final panelWidth = compact
              ? math.min(
                  availableWidth,
                  naturalWidths.fold<double>(0, (sum, width) => sum + width) +
                      tabPadding.horizontal,
                )
              : availableWidth;
          final availableItemsWidth = math.max(
            0.0,
            panelWidth - tabPadding.horizontal,
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
          final barWidth = innerWidth + tabPadding.horizontal;
          final precedingWidth = widths
              .take(index)
              .fold<double>(0, (sum, width) => sum + width);
          final itemHeight = height - tabPadding.vertical;
          final selectionWidth = telegram && widths[index] < itemHeight
              ? math.min(innerWidth, itemHeight * 1.2)
              : widths[index];
          final selectionStart =
              (precedingWidth + (widths[index] - selectionWidth) / 2)
                  .clamp(0.0, math.max(0.0, innerWidth - selectionWidth))
                  .toDouble();
          final unselectedColor = AcademyChrome.foregroundColor(
            context,
            p.onSurfaceVariant,
            style: style,
            surfaceOpacity: surfaceOpacity,
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
              child: SizedBox(
                height: height,
                child: Padding(
                  padding: tabPadding,
                  child: LayoutBuilder(
                    builder: (context, c) => Stack(
                      children: [
                        AnimatedPositioned(
                          duration: MediaQuery.disableAnimationsOf(context)
                              ? Duration.zero
                              : AcademyTokens.pressMotion,
                          curve: Curves.easeOutCubic,
                          left: Directionality.of(context) == TextDirection.rtl
                              ? innerWidth - selectionStart - selectionWidth
                              : selectionStart,
                          top: 0,
                          bottom: 0,
                          width: selectionWidth,
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              color: p.primaryContainer,
                              borderRadius: BorderRadius.circular(
                                math.min(
                                  itemHeight / 2,
                                  AcademyTheme.of(context).radii.tabSelection,
                                ),
                              ),
                            ),
                          ),
                        ),
                        Row(
                          children: [
                            for (var i = 0; i < tabs.length; i++)
                              SizedBox(
                                width: widths[i],
                                child: AcademyActionSemantics(
                                  enabled: true,
                                  selected: i == index,
                                  label: '',
                                  child: CupertinoButton(
                                    padding: EdgeInsets.zero,
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
                                                    size: 24,
                                                    boxSize: iconFrame,
                                                    paintExtent: iconFrame,
                                                    color: i == index
                                                        ? p.onPrimaryContainer
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
                                                  textAlign: TextAlign.center,
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: labelStyle.copyWith(
                                                    color: i == index
                                                        ? p.onPrimaryContainer
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
                                              SizedBox.square(
                                                dimension: iconFrame,
                                                child: AcademySfIcon(
                                                  tabs[i].icon,
                                                  size: 22,
                                                  boxSize: iconFrame,
                                                  paintExtent: compact
                                                      ? 32
                                                      : iconFrame,
                                                  color: i == index
                                                      ? p.onPrimaryContainer
                                                      : unselectedColor,
                                                ),
                                              ),
                                              const SizedBox(height: 2),
                                              Text(
                                                tabs[i].label,
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                textHeightBehavior:
                                                    const TextHeightBehavior(
                                                      applyHeightToFirstAscent:
                                                          false,
                                                      applyHeightToLastDescent:
                                                          false,
                                                    ),
                                                style: labelStyle.copyWith(
                                                  color: i == index
                                                      ? p.onPrimaryContainer
                                                      : unselectedColor,
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
          );
        },
      ),
    );
  }
}

/// Lazily builds visited pages and preserves their state; no business navigation.
class AcademyTabScaffold extends StatefulWidget {
  const AcademyTabScaffold({super.key, required this.tabs})
    : assert(tabs.length > 0);
  final List<AcademyTab> tabs;
  @override
  State<AcademyTabScaffold> createState() => _AcademyTabScaffoldState();
}

class _AcademyTabScaffoldState extends State<AcademyTabScaffold> {
  int _index = 0;
  final Set<int> _visited = {0};
  @override
  void didUpdateWidget(AcademyTabScaffold oldWidget) {
    super.didUpdateWidget(oldWidget);
    _index = _index.clamp(0, widget.tabs.length - 1);
    _visited.removeWhere((index) => index >= widget.tabs.length);
    _visited.add(_index);
  }

  @override
  Widget build(BuildContext context) {
    final telegram =
        AcademyFloatingTabBar.densityOf(context) ==
        AcademyTabBarDensity.telegram;
    final sideInset = telegram
        ? (academyChromeBottomOf(context) <= 28 ? 20.0 : 12.0)
        : 16.0;
    return Stack(
      children: [
        Positioned.fill(
          child: IndexedStack(
            index: _index,
            children: [
              for (var i = 0; i < widget.tabs.length; i++)
                TickerMode(
                  enabled: i == _index,
                  child: _visited.contains(i)
                      ? Builder(builder: widget.tabs[i].builder)
                      : const SizedBox.shrink(),
                ),
            ],
          ),
        ),
        Positioned(
          left: sideInset,
          right: sideInset,
          bottom: academyChromeBottomOf(context),
          child: AcademyFloatingTabBar(
            tabs: widget.tabs,
            index: _index,
            onChanged: (i) => setState(() {
              _index = i;
              _visited.add(i);
            }),
          ),
        ),
      ],
    );
  }
}
