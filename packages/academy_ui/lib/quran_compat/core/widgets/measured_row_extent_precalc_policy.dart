import 'package:super_sliver_list/super_sliver_list.dart';

/// Precalc-политика для списков с однотипными строками фикс-высоты.
///
/// Пока высота строки не измерена — даём `SuperListView` считать экстенты (как
/// обычно); как только высота известна, extent точен и precalc выключается.
class MeasuredRowExtentPrecalcPolicy extends ExtentPrecalculationPolicy {
  MeasuredRowExtentPrecalcPolicy({
    required this.needsPrecalc,
    this.isUserScrolling,
    this.maxItems,
  });

  /// true пока высота строки ещё не измерена.
  final bool Function() needsPrecalc;

  /// Не считать экстенты во время пользовательского скролла (опц.).
  final bool Function()? isUserScrolling;

  /// Считать экстенты только для списков не длиннее N (опц.).
  final int? maxItems;

  @override
  bool shouldPrecalculateExtents(ExtentPrecalculationContext context) {
    if (!needsPrecalc()) return false;
    if (isUserScrolling?.call() ?? false) return false;
    final max = maxItems;
    return max == null || context.numberOfItems <= max;
  }
}
