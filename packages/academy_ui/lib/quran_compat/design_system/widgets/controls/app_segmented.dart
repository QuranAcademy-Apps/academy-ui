import 'dart:math' as math;

import 'package:academy_ui/academy_ui.dart' show AcademySegmentedControl;
import 'package:cupertino_ui/cupertino_ui.dart';

import '../../../theme/app_colors.dart';

/// Quran's 36 pt text selector: [AcademySegmentedControl] with the app's
/// geometry (full-pill track, 0.5 pt bordered thumb) and palette fills.
class AppSegmented<T extends Object> extends StatelessWidget {
  const AppSegmented.control({
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
    final appColors = AppColorsProvider.maybeOf(context);
    final minWidth = _minSegmentWidth * values.length;
    return ConstrainedBox(
      constraints: BoxConstraints(minWidth: minWidth, minHeight: _minHeight),
      child: SizedBox(
        width: math.max(width ?? minWidth, minWidth),
        height: _minHeight,
        child: AcademySegmentedControl<T>(
          items: values,
          value: value,
          labelFor: labelFor,
          onChanged: onChanged,
          height: _minHeight,
          cornerRadius: _minHeight / 2,
          selectionCornerRadius: (_minHeight - 2.4 - 1.2) / 2,
          backgroundColor:
              backgroundColor ??
              appColors?.fillPrimary ??
              CupertinoDynamicColor.resolve(
                const CupertinoDynamicColor.withBrightness(
                  color: Color(0xFFDADADE),
                  darkColor: Color(0xFF3A3A3C),
                ),
                context,
              ),
          selectedColor:
              selectedColor ??
              appColors?.fillSecondary ??
              CupertinoDynamicColor.resolve(
                const CupertinoDynamicColor.withBrightness(
                  color: Color(0xFFFFFFFF),
                  darkColor: Color(0xFF636366),
                ),
                context,
              ),
          textColor:
              textColor ?? CupertinoDynamicColor.resolve(_labelColor, context),
          selectionBorderColor: CupertinoDynamicColor.resolve(
            _selectedBorderColor,
            context,
          ),
          selectionShadowColor: CupertinoDynamicColor.resolve(
            _selectedShadowColor,
            context,
          ),
        ),
      ),
    );
  }
}
