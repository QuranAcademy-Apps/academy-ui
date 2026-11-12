import 'dart:math' as math;

import 'package:cupertino_ui/cupertino_ui.dart';

import '../../foundation/interaction/academy_interaction.dart';
import '../../foundation/layout/academy_text_metrics.dart';

import '../icon/academy_sf_image.dart';
import '../../theme/academy_theme.dart';

import 'academy_segment_style.dart';

/// Quran's 32px quick-settings pill and 31px compact segmented control.
/// The visual control stays small; each segment has a 44px interaction height.
class AcademySegmentedControl<T extends Object> extends StatelessWidget {
  const AcademySegmentedControl({
    super.key,
    required this.items,
    required this.value,
    required this.labelFor,
    required this.onChanged,
    this.iconFor,
    this.style = AcademySegmentStyle.pill,
    this.cornerRadius,
    this.selectionCornerRadius,
    this.height,
    this.minimumHeight,
    this.backgroundColor,
    this.selectedColor,
    this.textColor,
    this.selectionBorderColor,
    this.selectionShadowColor,
  }) : fitted = false,
       width = null,
       assert(items.length > 0),
       assert(cornerRadius == null || cornerRadius >= 0),
       assert(selectionCornerRadius == null || selectionCornerRadius >= 0);

  /// A text selector sized by [AcademySegmentedTheme]. A finite [width] sizes
  /// it, null gives the minimum and infinity fills the parent.
  const AcademySegmentedControl.fitted({
    super.key,
    required this.items,
    required this.value,
    required this.labelFor,
    required this.onChanged,
    this.width,
    this.backgroundColor,
    this.selectedColor,
    this.textColor,
  }) : fitted = true,
       iconFor = null,
       style = AcademySegmentStyle.pill,
       cornerRadius = null,
       selectionCornerRadius = null,
       height = null,
       minimumHeight = null,
       selectionBorderColor = null,
       selectionShadowColor = null,
       assert(items.length > 0),
       assert(width == null || width > 0);

  const AcademySegmentedControl.compact({
    super.key,
    required this.items,
    required this.value,
    required this.labelFor,
    required this.onChanged,
    this.iconFor,
    this.cornerRadius,
    this.selectionCornerRadius,
  }) : fitted = false,
       width = null,
       style = AcademySegmentStyle.compact,
       height = null,
       minimumHeight = null,
       backgroundColor = null,
       selectedColor = null,
       textColor = null,
       selectionBorderColor = null,
       selectionShadowColor = null,
       assert(items.length > 0),
       assert(cornerRadius == null || cornerRadius >= 0),
       assert(selectionCornerRadius == null || selectionCornerRadius >= 0);
  final bool fitted;
  final double? width;
  final List<T> items;
  final T value;
  final String Function(T) labelFor;
  final IconData Function(T)? iconFor;
  final ValueChanged<T>? onChanged;
  final AcademySegmentStyle style;
  final double? cornerRadius, selectionCornerRadius;

  /// Exact height of the control (visual and layout). Without it the control is
  /// 32 pt high inside a 44 pt interaction box.
  final double? height;

  /// Least visual height; it grows with the text and keeps the 44 pt interaction
  /// box. Ignored with [height].
  final double? minimumHeight;

  /// Overrides of the track, thumb and label colors, and of the thumb's hairline
  /// border and shadow, for hosts whose palette differs from the theme roles.
  final Color? backgroundColor,
      selectedColor,
      textColor,
      selectionBorderColor,
      selectionShadowColor;
  Widget _fitted(BuildContext context) {
    final look = AcademyTheme.of(context).segmented;
    final minWidth = look.minSegmentWidth * items.length;
    final control = AcademySegmentedControl<T>(
      items: items,
      value: value,
      labelFor: labelFor,
      onChanged: onChanged,
      minimumHeight: look.height,
      cornerRadius: look.cornerRadius,
      selectionCornerRadius: look.selectionCornerRadius,
      backgroundColor: backgroundColor,
      selectedColor: selectedColor,
      textColor: textColor ?? look.textColor,
      selectionBorderColor: look.selectionBorderColor,
      selectionShadowColor: look.selectionShadowColor,
    );
    final requested = width;
    // Infinity fills the parent, which the control does by itself; an infinite
    // SizedBox would break layout inside sheets.
    final preferred = requested == null
        ? minWidth
        : requested.isFinite
        ? math.max(requested, minWidth)
        : null;
    return ConstrainedBox(
      constraints: BoxConstraints(minWidth: minWidth, minHeight: look.height),
      child: preferred == null
          ? control
          : SizedBox(width: preferred, child: control),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (fitted) return _fitted(context);
    final theme = AcademyTheme.of(context);
    final selected = items.indexOf(value).clamp(0, items.length - 1);
    final pill = style == AcademySegmentStyle.pill;
    final exact = this.height;
    final height =
        exact ??
        math.max(
          minimumHeight ?? (pill ? 32.0 : 31.0),
          iconFor == null
              ? academyTextLineHeight(context, theme.textTheme.segmentLabel) +
                    12
              : 32.0,
        );
    final box = exact ?? math.max(44, height);
    return SizedBox(
      height: box,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final available = constraints.hasBoundedWidth
              ? constraints.maxWidth
              : 0.0;
          final width = math.max(
            AcademyTokens.target,
            available / items.length,
          );
          final content = SizedBox(
            width: width * items.length,
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  height: height,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color:
                          backgroundColor ??
                          theme.colorScheme.segmentBackground,
                      borderRadius: BorderRadius.circular(
                        cornerRadius ??
                            (pill
                                ? theme.radii.segment
                                : theme.radii.compactSegment),
                      ),
                    ),
                    child: const SizedBox.expand(),
                  ),
                ),
                if (!pill)
                  for (var i = 1; i < items.length; i++)
                    PositionedDirectional(
                      start: width * i,
                      top: (box - 16) / 2,
                      child: Container(
                        width: .5,
                        height: 16,
                        color: theme.colorScheme.outlineVariant,
                      ),
                    ),
                AnimatedPositionedDirectional(
                  duration: MediaQuery.disableAnimationsOf(context)
                      ? Duration.zero
                      : AcademyTokens.selectionMotion,
                  curve: Curves.easeInOutCubic,
                  start: width * selected + 2,
                  width: math.max(0, width - 4),
                  top: (box - height) / 2 + 2,
                  height: height - 4,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: selectedColor ?? theme.colorScheme.segmentSelected,
                      border: selectionBorderColor == null
                          ? null
                          : Border.all(color: selectionBorderColor!, width: .5),
                      borderRadius: BorderRadius.circular(
                        selectionCornerRadius ??
                            (pill
                                ? theme.radii.segmentSelection
                                : theme.radii.compactSegmentSelection),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color:
                              selectionShadowColor ??
                              theme.colorScheme.segmentShadow,
                          blurRadius: 2,
                          offset: Offset(0, 1),
                        ),
                      ],
                    ),
                  ),
                ),
                Row(
                  children: [
                    for (final item in items)
                      Expanded(
                        child: AcademyActionSemantics(
                          selected: item == value,
                          enabled: onChanged != null,
                          label: labelFor(item),
                          child: CupertinoButton(
                            padding: EdgeInsets.zero,
                            minimumSize: Size(
                              AcademyTokens.target,
                              exact ?? AcademyTokens.target,
                            ),
                            onPressed: onChanged == null
                                ? null
                                : () {
                                    if (item != value) onChanged!(item);
                                  },
                            child: ExcludeSemantics(
                              child: iconFor == null
                                  ? Text(
                                      labelFor(item),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: textColor == null
                                          ? theme.textTheme.segmentLabel
                                          : theme.textTheme.segmentLabel
                                                .copyWith(color: textColor),
                                    )
                                  : AcademySfIcon(
                                      iconFor!(item),
                                      size: AcademyTheme.of(context)
                                          .sizes
                                          .controlIcon,
                                      color: item == value
                                          ? theme.colorScheme.onSurface
                                          : theme.colorScheme.onSurfaceVariant,
                                    ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          );
          return available >= width * items.length
              ? content
              : SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: content,
                );
        },
      ),
    );
  }
}
