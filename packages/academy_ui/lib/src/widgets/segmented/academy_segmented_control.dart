import 'dart:math' as math;

import 'package:cupertino_ui/cupertino_ui.dart' hide CupertinoButton;
import 'package:flutter/cupertino.dart' show CupertinoButton;

import '../../foundation/interaction/academy_interaction.dart';

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
  }) : assert(items.length > 0),
       assert(cornerRadius == null || cornerRadius >= 0),
       assert(selectionCornerRadius == null || selectionCornerRadius >= 0);

  const AcademySegmentedControl.compact({
    super.key,
    required this.items,
    required this.value,
    required this.labelFor,
    required this.onChanged,
    this.iconFor,
    this.cornerRadius,
    this.selectionCornerRadius,
  }) : style = AcademySegmentStyle.compact,
       assert(items.length > 0),
       assert(cornerRadius == null || cornerRadius >= 0),
       assert(selectionCornerRadius == null || selectionCornerRadius >= 0);
  final List<T> items;
  final T value;
  final String Function(T) labelFor;
  final IconData Function(T)? iconFor;
  final ValueChanged<T>? onChanged;
  final AcademySegmentStyle style;
  final double? cornerRadius, selectionCornerRadius;
  @override
  Widget build(BuildContext context) {
    final theme = AcademyTheme.of(context);
    final selected = items.indexOf(value).clamp(0, items.length - 1);
    final pill = style == AcademySegmentStyle.pill;
    final height = math.max(
      pill ? 32.0 : 31.0,
      iconFor == null ? MediaQuery.textScalerOf(context).scale(13) + 12 : 32.0,
    );
    return SizedBox(
      height: math.max(44, height),
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
                      color: theme.colorScheme.segmentBackground,
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
                      top: (math.max(44, height) - 16) / 2,
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
                  top: (math.max(44, height) - height) / 2 + 2,
                  height: height - 4,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: theme.colorScheme.segmentSelected,
                      borderRadius: BorderRadius.circular(
                        selectionCornerRadius ??
                            (pill
                                ? theme.radii.segmentSelection
                                : theme.radii.compactSegmentSelection),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: theme.colorScheme.segmentShadow,
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
                            minimumSize: const Size(
                              AcademyTokens.target,
                              AcademyTokens.target,
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
                                      style: theme.textTheme.segmentLabel,
                                    )
                                  : AcademySfIcon(
                                      iconFor!(item),
                                      size: 18,
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

/// Compatibility name for existing clients; both styles use the shared control.
class AcademyCompactSegment<T extends Object>
    extends AcademySegmentedControl<T> {
  const AcademyCompactSegment({
    super.key,
    required super.items,
    required super.value,
    required super.labelFor,
    required super.onChanged,
    super.iconFor,
    super.style,
    super.cornerRadius,
    super.selectionCornerRadius,
  });
}
