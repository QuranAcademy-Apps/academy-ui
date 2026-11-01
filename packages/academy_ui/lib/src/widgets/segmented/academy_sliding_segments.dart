// Ported from quran_flutter AppSegmentedControl.
import 'package:flutter/cupertino.dart';

const academySlidingSegmentsDuration = Duration(milliseconds: 250);
const academySlidingSegmentsCurve = Curves.easeOutCubic;

/// Full-width sliding selector: the selected segment (optionally wider than
/// the others) glides to its slot. Colors are explicit; [contentBuilder] draws
/// each segment in the foreground color it is given.
class AcademySlidingSegments<T extends Object> extends StatelessWidget {
  const AcademySlidingSegments({
    super.key,
    required this.items,
    required this.selection,
    required this.onSelectionChanged,
    required this.backgroundColor,
    required this.selectedBackgroundColor,
    required this.foregroundColor,
    required this.selectedForegroundColor,
    required this.contentBuilder,
    this.height = 32,
    this.selectedWidth,
  });

  final List<T> items;
  final T selection;
  final ValueChanged<T> onSelectionChanged;
  final Color backgroundColor;
  final Color selectedBackgroundColor;
  final Color foregroundColor;
  final Color selectedForegroundColor;
  final Widget Function(T item, Color foregroundColor) contentBuilder;

  /// Text segments can grow with Dynamic Type; icon segments retain 32 points.
  final double height;
  final double? selectedWidth;

  static const _spacing = 2.0;
  static const _horizontalInset = 2.0;
  static const _controlCornerRadius = 16.0;
  static const _itemCornerRadius = 14.0;

  int get _selectedIndex {
    final index = items.indexOf(selection);
    return index < 0 ? 0 : index;
  }

  @override
  Widget build(BuildContext context) {
    final duration = MediaQuery.disableAnimationsOf(context)
        ? Duration.zero
        : academySlidingSegmentsDuration;
    return LayoutBuilder(
      builder: (context, constraints) {
        final availableWidth =
            constraints.maxWidth -
            _horizontalInset * 2 -
            _spacing * (items.length - 1);
        final activeWidth = items.length > 1
            ? (selectedWidth ?? availableWidth / items.length).clamp(
                0.0,
                availableWidth,
              )
            : availableWidth;
        final otherWidth = items.length > 1
            ? (availableWidth - activeWidth) / (items.length - 1)
            : 0.0;
        return ClipRRect(
          borderRadius: BorderRadius.circular(_controlCornerRadius),
          child: SizedBox(
            height: height,
            child: Stack(
              alignment: Alignment.centerLeft,
              children: [
                DecoratedBox(
                  decoration: BoxDecoration(
                    color: backgroundColor,
                    borderRadius: BorderRadius.circular(_controlCornerRadius),
                  ),
                  child: const SizedBox.expand(),
                ),
                if (items.isNotEmpty)
                  Positioned.fill(
                    child: Stack(
                      children: [
                        AnimatedPositionedDirectional(
                          duration: duration,
                          curve: academySlidingSegmentsCurve,
                          start:
                              _horizontalInset +
                              (otherWidth + _spacing) * _selectedIndex,
                          top: _horizontalInset,
                          width: activeWidth,
                          height: height - _horizontalInset * 2,
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              color: selectedBackgroundColor,
                              borderRadius: BorderRadius.circular(
                                _itemCornerRadius,
                              ),
                              boxShadow: const [
                                BoxShadow(
                                  color: Color(0x1A000000),
                                  blurRadius: 2,
                                  offset: Offset(0, 1),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: _horizontalInset,
                  ),
                  child: Row(
                    children: [
                      for (final item in items) ...[
                        if (item != items.first)
                          const SizedBox(width: _spacing),
                        TweenAnimationBuilder<double>(
                          tween: Tween(
                            end:
                                (item == selection ? activeWidth : otherWidth) /
                                availableWidth,
                          ),
                          duration: duration,
                          curve: academySlidingSegmentsCurve,
                          builder: (context, value, child) => Expanded(
                            flex: (value * 1000000).round(),
                            child: child!,
                          ),
                          child: CupertinoButton(
                            padding: EdgeInsets.zero,
                            minimumSize: Size.zero,
                            onPressed: () {
                              if (item == selection) {
                                return;
                              }
                              onSelectionChanged(item);
                            },
                            child: contentBuilder(
                              item,
                              item == selection
                                  ? selectedForegroundColor
                                  : foregroundColor,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
