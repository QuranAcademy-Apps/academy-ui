import 'package:flutter/cupertino.dart';

import '../../theme/academy_theme.dart';
import '../../foundation/localizations/academy_localizations.dart';
import '../icon/academy_sf_image.dart';

enum AcademyTimelineState { completed, current, upcoming }

@immutable
class AcademyTimelineItem {
  const AcademyTimelineItem({
    required this.title,
    required this.date,
    this.subtitle,
    this.state = AcademyTimelineState.upcoming,
  });
  final String title, date;
  final String? subtitle;
  final AcademyTimelineState state;
}

/// Vertical milestones in input order; owns no progress state or animations.
class AcademyTimeline extends StatelessWidget {
  const AcademyTimeline({super.key, required this.items});
  final List<AcademyTimelineItem> items;
  @override
  Widget build(BuildContext context) {
    final theme = AcademyTheme.of(context);
    final p = theme.colorScheme;
    final strings = AcademyLocalizations.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 0; i < items.length; i++)
          Semantics(
            container: true,
            excludeSemantics: true,
            label:
                '${i + 1}/${items.length}, ${items[i].title}, ${items[i].date}${items[i].subtitle == null ? '' : ', ${items[i].subtitle}'}',
            value: switch (items[i].state) {
              AcademyTimelineState.completed => strings.completed,
              AcademyTimelineState.current => strings.timelineCurrent,
              AcademyTimelineState.upcoming => strings.timelineUpcoming,
            },
            child: IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(
                    width: AcademyTokens.timelineDotExtent,
                    child: Column(
                      children: [
                        Container(
                          width: AcademyTokens.timelineDotExtent,
                          height: AcademyTokens.timelineDotExtent,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color:
                                items[i].state == AcademyTimelineState.upcoming
                                ? p.surfaceContainerHighest
                                : p.accentFill,
                            border: Border.all(
                              color:
                                  items[i].state ==
                                      AcademyTimelineState.upcoming
                                  ? p.outline
                                  : p.accentForeground,
                              width: AcademyTokens.timelineLineWidth,
                            ),
                          ),
                          alignment: Alignment.center,
                          child:
                              items[i].state == AcademyTimelineState.completed
                              ? AcademySfIcon(
                                  AcademyTheme.of(context).icons.checkmark,
                                  size:
                                      AcademyTheme.of(context)
                                          .sizes
                                          .rowIconExtent /
                                      2,
                                  color: p.onAccentFill,
                                )
                              : items[i].state == AcademyTimelineState.current
                              ? Container(
                                  width: AcademyTokens.space,
                                  height: AcademyTokens.space,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: p.onAccentFill,
                                  ),
                                )
                              : null,
                        ),
                        if (i < items.length - 1)
                          Expanded(
                            child: Center(
                              child: Container(
                                width: AcademyTokens.timelineLineWidth,
                                color:
                                    items[i].state ==
                                        AcademyTimelineState.completed
                                    ? p.accentForeground
                                    : p.outlineVariant,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(width: AcademyTokens.inlineGap),
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(
                        bottom: i < items.length - 1 ? AcademyTokens.gutter : 0,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            items[i].title,
                            style: theme.textTheme.bodyStrong,
                          ),
                          Text(
                            items[i].date,
                            style: theme.textTheme.footnote.copyWith(
                              color: p.onSurfaceVariant,
                            ),
                          ),
                          if (items[i].subtitle != null)
                            Padding(
                              padding: theme.paddings.rowSubtitle,
                              child: Text(
                                items[i].subtitle!,
                                style: theme.textTheme.bodyDetail,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
