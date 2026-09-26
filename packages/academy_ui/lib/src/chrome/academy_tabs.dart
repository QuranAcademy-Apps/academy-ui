import 'package:flutter/cupertino.dart';

import 'dart:math' as math;

import '../academy_theme.dart';
import '../academy_sf_image.dart';
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
  static const inset = 4.0;
  static const maxWidth = 500.0;
  static const labelSize = 10.0;
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
    final labelSize = resolved == AcademyTabBarDensity.standard
        ? 11.0
        : _TelegramTabMetrics.labelSize;
    final baseHeight = switch (resolved) {
      AcademyTabBarDensity.standard => 60.0,
      AcademyTabBarDensity.compact => 56.0,
      AcademyTabBarDensity.telegram =>
        _TelegramTabMetrics.itemHeight + _TelegramTabMetrics.inset * 2,
    };
    return baseHeight +
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
    final inset = smallLabels ? _TelegramTabMetrics.inset : 6.0;
    final height = heightOf(context, density: density);
    final labelSize = smallLabels ? _TelegramTabMetrics.labelSize : 11.0;
    final labelStyle = AcademyTheme.of(context).textTheme.bodySmall.copyWith(
      fontSize: labelSize,
      fontWeight: smallLabels ? FontWeight.w600 : FontWeight.w400,
      letterSpacing: AcademyTypography.trackingForSize(labelSize),
      height: smallLabels ? null : 1,
    );
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
                      inset * 2,
                )
              : availableWidth;
          final availableItemsWidth = math.max(0.0, panelWidth - inset * 2);
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
          final barWidth = innerWidth + inset * 2;
          final precedingWidth = widths
              .take(index)
              .fold<double>(0, (sum, width) => sum + width);
          final itemHeight = height - inset * 2;
          final selectionWidth = telegram && widths[index] < itemHeight
              ? math.min(innerWidth, itemHeight * 1.2)
              : widths[index];
          final selectionStart =
              (precedingWidth + (widths[index] - selectionWidth) / 2)
                  .clamp(0.0, math.max(0.0, innerWidth - selectionWidth))
                  .toDouble();
          return SizedBox(
            width: barWidth,
            child: AcademyChrome(
              radius: height / 2,
              surfaceOpacity: surfaceOpacity,
              style: style,
              blurSigma: blurSigma,
              child: SizedBox(
                height: height,
                child: Padding(
                  padding: EdgeInsets.all(inset),
                  child: LayoutBuilder(
                    builder: (context, c) => Stack(
                      children: [
                        AnimatedPositioned(
                          duration: MediaQuery.disableAnimationsOf(context)
                              ? Duration.zero
                              : const Duration(milliseconds: 260),
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
                                (height - inset * 2) / 2,
                              ),
                            ),
                          ),
                        ),
                        Row(
                          children: [
                            for (var i = 0; i < tabs.length; i++)
                              SizedBox(
                                width: widths[i],
                                child: Semantics(
                                  excludeSemantics: true,
                                  onTap: () => onChanged(i),
                                  selected: i == index,
                                  button: true,
                                  label: tabs[i].label,
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
                                                        ? p.primary
                                                        : p.onSurfaceVariant,
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
                                                        ? p.primary
                                                        : p.onSurfaceVariant,
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
                                                      ? p.primary
                                                      : p.onSurfaceVariant,
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
                                                      ? p.primary
                                                      : p.onSurfaceVariant,
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
  const AcademyTabScaffold({super.key, required this.tabs});
  final List<AcademyTab> tabs;
  @override
  State<AcademyTabScaffold> createState() => _AcademyTabScaffoldState();
}

class _AcademyTabScaffoldState extends State<AcademyTabScaffold> {
  int _index = 0;
  final Set<int> _visited = {0};
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
