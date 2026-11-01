import 'package:flutter/cupertino.dart';

import '../../foundation/interaction/academy_interaction.dart';
import '../../foundation/motion/academy_press_effect.dart';
import '../../theme/academy_theme.dart';

/// Pick one of a few options shown as picture tiles: a [previewBuilder]
/// illustration over a caption. Use where the options are easier to
/// recognise than to read (reading layout, theme); keep
/// `AcademySegmentedControl` for plain value lists.
///
/// The selected tile gets an accent outline and caption. The outline width is
/// constant, so selecting never shifts the layout.
class AcademyChoiceTiles<T extends Object> extends StatelessWidget {
  const AcademyChoiceTiles({
    super.key,
    required this.items,
    required this.value,
    required this.labelFor,
    required this.previewBuilder,
    required this.onChanged,
    this.previewHeight = 72,
  }) : assert(items.length > 0),
       assert(previewHeight > 0);

  final List<T> items;
  final T value;
  final String Function(T) labelFor;

  /// Illustration for one tile; `selected` lets it tint itself.
  final Widget Function(BuildContext context, T item, bool selected)
  previewBuilder;
  final ValueChanged<T>? onChanged;
  final double previewHeight;

  static const _gap = AcademyTokens.inlineGap;
  static const _outline = 2.0;

  @override
  Widget build(BuildContext context) {
    final theme = AcademyTheme.of(context);
    final radius = BorderRadius.circular(theme.radii.table * .7);
    final animate = !MediaQuery.disableAnimationsOf(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var i = 0; i < items.length; i++) ...[
          if (i > 0) const SizedBox(width: _gap),
          Expanded(
            child: Builder(
              builder: (context) {
                final item = items[i];
                final selected = item == value;
                return AcademyActionSemantics(
                  label: labelFor(item),
                  enabled: onChanged != null,
                  selected: selected,
                  child: AcademyPressEffect(
                    enabled: onChanged != null,
                    child: CupertinoButton(
                      padding: EdgeInsets.zero,
                      minimumSize: Size.zero,
                      onPressed: onChanged == null
                          ? null
                          : () {
                              if (selected) return;
                              theme.interaction.selectionClick();
                              onChanged!(item);
                            },
                      child: ExcludeSemantics(
                        child: AnimatedContainer(
                          duration: animate
                              ? AcademyTokens.selectionMotion
                              : Duration.zero,
                          curve: Curves.easeInOutCubic,
                          padding: const EdgeInsets.fromLTRB(
                            AcademyTokens.space,
                            AcademyTokens.space,
                            AcademyTokens.space,
                            AcademyTokens.inlineGap,
                          ),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.surface,
                            borderRadius: radius,
                            border: Border.all(
                              width: _outline,
                              color: selected
                                  ? theme.colorScheme.primary
                                  : const Color(0x00000000),
                            ),
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              SizedBox(
                                height: previewHeight,
                                width: double.infinity,
                                child: previewBuilder(context, item, selected),
                              ),
                              const SizedBox(height: AcademyTokens.space),
                              Text(
                                labelFor(item),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.center,
                                style: theme.textTheme.segmentLabel.copyWith(
                                  color: selected
                                      ? theme.colorScheme.accentForeground
                                      : theme.colorScheme.onSurface,
                                ),
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
          ),
        ],
      ],
    );
  }
}
