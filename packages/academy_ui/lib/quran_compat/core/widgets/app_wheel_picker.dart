import 'package:cupertino_ui/cupertino_ui.dart';

import '../../theme/app_colors.dart';

/// Shared metrics for every wheel picker in the app. Keeping them here means
/// the repeat-settings picker, the start/end picker, the Fast Access picker and
/// the notification pickers all share one look and feel.
const double kAppWheelPickerItemExtent = 36;
const double _focusedFontSize = 25;
const double _inactiveFontSize = 18;
const double _selectionRadius = 9;
const double _selectionOpacity = 0.72;

/// Slightly flatter than Cupertino's default 1.07: a gentler cylinder curve
/// means less per-cell perspective foreshortening to re-composite each scroll
/// frame, while staying close to the native iOS wheel look.
const double _wheelDiameterRatio = 1.3;

/// A single styled wheel column used by every picker in the app.
///
/// It owns the "focused vs inactive" cell styling and the centered selection
/// overlay so callers only describe *what* the column contains, never *how* it
/// looks. The focused cell tracks the committed selection (reported on scroll
/// end) and the externally supplied [selectedIndex], so programmatic moves
/// (e.g. resetting the ayah column when the surah changes) stay in sync.
class AppWheelPickerColumn extends StatefulWidget {
  const AppWheelPickerColumn({
    super.key,
    required this.controller,
    required this.itemCount,
    required this.selectedIndex,
    required this.textBuilder,
    required this.onSelectedItemChanged,
    this.itemExtent = kAppWheelPickerItemExtent,
  });

  final FixedExtentScrollController controller;
  final int itemCount;
  final int selectedIndex;
  final String Function(int index) textBuilder;
  final ValueChanged<int> onSelectedItemChanged;
  final double itemExtent;

  @override
  State<AppWheelPickerColumn> createState() => _AppWheelPickerColumnState();
}

class _AppWheelPickerColumnState extends State<AppWheelPickerColumn> {
  late int _focusedIndex = widget.selectedIndex;

  @override
  void didUpdateWidget(covariant AppWheelPickerColumn oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedIndex != widget.selectedIndex) {
      _focusedIndex = widget.selectedIndex;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Stack(
      alignment: Alignment.center,
      children: [
        _SelectionOverlay(colors: colors, itemExtent: widget.itemExtent),
        CupertinoPicker.builder(
          scrollController: widget.controller,
          itemExtent: widget.itemExtent,
          diameterRatio: _wheelDiameterRatio,
          changeReportingBehavior: ChangeReportingBehavior.onScrollEnd,
          selectionOverlay: const SizedBox.shrink(),
          onSelectedItemChanged: _handleChanged,
          childCount: widget.itemCount,
          itemBuilder: (context, index) => AppWheelPickerCell(
            text: widget.textBuilder(index),
            isFocused: index == _focusedIndex,
            colors: colors,
          ),
        ),
      ],
    );
  }

  void _handleChanged(int index) {
    if (_focusedIndex != index) {
      setState(() => _focusedIndex = index);
    }
    widget.onSelectedItemChanged(index);
  }
}

/// A single cell of an [AppWheelPickerColumn]. Exposed so callers that still
/// drive a raw [CupertinoPicker] can render identical cells.
class AppWheelPickerCell extends StatelessWidget {
  const AppWheelPickerCell({
    super.key,
    required this.text,
    required this.isFocused,
    required this.colors,
  });

  final String text;
  final bool isFocused;
  final AppColors colors;

  @override
  Widget build(BuildContext context) {
    // Fixed font sizes + ellipsis (never FittedBox): the wheel's perspective
    // transform already scales each cell, and scaleDown's fractional text scale
    // on top of that defeats the glyph atlas cache — every scroll frame
    // re-rasterizes glyphs (CreateGlyphAtlas/UpdateAtlasBitmap), which is the
    // dominant raster cost. iOS pickers clip rather than scale, so this also
    // matches the reference.
    return SizedBox.expand(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: Center(
          child: Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isFocused ? colors.textPrimary : colors.textSecondary,
              fontSize: isFocused ? _focusedFontSize : _inactiveFontSize,
              fontWeight: FontWeight.w400,
              letterSpacing: 0,
              height: 1,
            ),
          ),
        ),
      ),
    );
  }
}

class _SelectionOverlay extends StatelessWidget {
  const _SelectionOverlay({required this.colors, required this.itemExtent});

  final AppColors colors;
  final double itemExtent;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        height: itemExtent,
        width: double.infinity,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: colors.backgroundPrimary.withValues(alpha: _selectionOpacity),
            borderRadius: BorderRadius.circular(_selectionRadius),
          ),
        ),
      ),
    );
  }
}
