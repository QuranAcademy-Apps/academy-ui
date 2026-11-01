// Ported from quran_flutter AppSegmented.control.
import 'dart:math' as math;

import 'package:flutter/cupertino.dart';

import '../../theme/academy_theme.dart';

/// Rounded 36 pt text selector with a sliding white thumb. Colors fall back to
/// the iOS grouped-fill defaults; the host can pass its own.
class AcademyPillSegments<T extends Object> extends StatelessWidget {
  const AcademyPillSegments({
    super.key,
    required this.value,
    required this.values,
    required this.labelFor,
    required this.onChanged,
    this.width,
    this.backgroundColor,
    this.selectedColor,
    this.textColor,
  }) : assert(values.length > 0),
       assert(width == null || width > 0);

  static const double _minHeight = 36;
  static const double _minSegmentWidth = 41;
  static const double _optionTop = 2.4;
  static const double _optionBottom = 1.2;
  static const double _optionInset = 2;
  static const double _backgroundRadius = _minHeight / 2;
  static const double _selectedRadius =
      (_minHeight - _optionTop - _optionBottom) / 2;
  static const Duration _animationDuration = Duration(milliseconds: 240);
  static const Curve _animationCurve = Curves.easeInOutCubic;
  static const Color _labelColor = CupertinoDynamicColor.withBrightness(
    color: Color(0xFF000000),
    darkColor: Color(0xFFFFFFFF),
  );
  static const Color _selectedBorderColor =
      CupertinoDynamicColor.withBrightness(
        color: Color(0xFFE0DCDC),
        darkColor: Color(0x00000000),
      );
  static const Color _selectedShadowColor =
      CupertinoDynamicColor.withBrightness(
        color: Color(0x24000000),
        darkColor: Color(0x00000000),
      );

  final T value;
  final List<T> values;
  final double? width;
  final String Function(T value) labelFor;
  final ValueChanged<T> onChanged;
  final Color? backgroundColor;
  final Color? selectedColor;
  final Color? textColor;

  @override
  Widget build(BuildContext context) {
    final entries = values;
    final selectedValue = value;
    final selectedIndex = entries
        .indexOf(selectedValue)
        .clamp(0, entries.length - 1);
    final minWidth = _minSegmentWidth * entries.length;
    final preferredWidth = math.max(width ?? minWidth, minWidth);
    final foregroundColor =
        textColor ?? CupertinoDynamicColor.resolve(_labelColor, context);
    final resolvedBackgroundColor =
        backgroundColor ??
        CupertinoDynamicColor.resolve(
          const CupertinoDynamicColor.withBrightness(
            color: Color(0xFFDADADE),
            darkColor: Color(0xFF3A3A3C),
          ),
          context,
        );
    final resolvedSelectedColor =
        selectedColor ??
        CupertinoDynamicColor.resolve(
          const CupertinoDynamicColor.withBrightness(
            color: Color(0xFFFFFFFF),
            darkColor: Color(0xFF636366),
          ),
          context,
        );
    final resolvedSelectedBorderColor = CupertinoDynamicColor.resolve(
      _selectedBorderColor,
      context,
    );
    final resolvedSelectedShadowColor = CupertinoDynamicColor.resolve(
      _selectedShadowColor,
      context,
    );

    return ConstrainedBox(
      constraints: BoxConstraints(minWidth: minWidth, minHeight: _minHeight),
      child: SizedBox(
        width: preferredWidth,
        height: _minHeight,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final controlWidth = math.max(constraints.maxWidth, minWidth);
            final controlHeight = math.max(constraints.maxHeight, _minHeight);
            final slotWidth = controlWidth / entries.length;
            final optionWidth = math.max(0.0, slotWidth - _optionInset);
            final optionHeight = math.max(
              0.0,
              controlHeight - _optionTop - _optionBottom,
            );
            double optionLeft(int index) =>
                slotWidth * index + (index == 0 ? _optionInset : 0);

            return DecoratedBox(
              decoration: BoxDecoration(
                color: resolvedBackgroundColor,
                borderRadius: BorderRadius.circular(_backgroundRadius),
              ),
              child: Stack(
                children: [
                  AnimatedPositioned(
                    duration: _animationDuration,
                    curve: _animationCurve,
                    left: optionLeft(selectedIndex),
                    top: _optionTop,
                    width: optionWidth,
                    height: optionHeight,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: resolvedSelectedColor,
                        borderRadius: BorderRadius.circular(_selectedRadius),
                        border: Border.all(
                          color: resolvedSelectedBorderColor,
                          width: 0.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: resolvedSelectedShadowColor,
                            blurRadius: 2,
                            offset: Offset(0, 1),
                          ),
                        ],
                      ),
                    ),
                  ),
                  for (final entry in entries.asMap().entries)
                    Positioned(
                      left: optionLeft(entry.key),
                      top: _optionTop,
                      width: optionWidth,
                      height: optionHeight,
                      child: _AcademyPillSegmentsLabel<T>(
                        value: entry.value,
                        selectedValue: selectedValue,
                        label: labelFor(entry.value),
                        textColor: foregroundColor,
                        onChanged: onChanged,
                      ),
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _AcademyPillSegmentsLabel<T extends Object> extends StatelessWidget {
  const _AcademyPillSegmentsLabel({
    required this.value,
    required this.selectedValue,
    required this.label,
    required this.textColor,
    required this.onChanged,
  });

  final T value;
  final T selectedValue;
  final String label;
  final Color textColor;
  final ValueChanged<T> onChanged;

  @override
  Widget build(BuildContext context) {
    final isSelected = value == selectedValue;

    return Semantics(
      button: true,
      selected: isSelected,
      label: label,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: isSelected ? null : () => onChanged(value),
        child: Center(
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: AcademyTheme.of(context).textTheme.bodyLarge.copyWith(
              color: textColor,
              fontSize: 13,
              height: 1,
              fontWeight: FontWeight.w600,
              letterSpacing: -0.08,
            ),
          ),
        ),
      ),
    );
  }
}
