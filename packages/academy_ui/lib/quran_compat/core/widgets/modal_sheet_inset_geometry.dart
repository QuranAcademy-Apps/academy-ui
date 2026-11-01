import 'package:cupertino_ui/cupertino_ui.dart';

/// Hidden slice of a translated sheet, plus the device's bottom safe area.
double modalSheetInsetForFraction(
  BuildContext context, {
  required double fullHeight,
  required double fraction,
}) {
  final view = View.of(context);
  final ratio = view.devicePixelRatio;
  final mediaQuery = MediaQuery.of(context);
  final height = ratio > 0
      ? view.physicalSize.height / ratio
      : mediaQuery.size.height;
  if (height <= 0) return mediaQuery.padding.bottom;
  final top = ratio > 0 ? view.padding.top / ratio : mediaQuery.padding.top;
  final bottom = ratio > 0
      ? view.padding.bottom / ratio
      : mediaQuery.padding.bottom;
  final hidden = fullHeight - (fraction * height).clamp(0.0, height) + top;
  return (hidden > 0 ? hidden : 0) + bottom;
}
