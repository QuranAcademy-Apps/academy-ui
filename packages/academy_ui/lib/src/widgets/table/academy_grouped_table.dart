import 'package:flutter/cupertino.dart';

import 'academy_table.dart';
import '../../theme/academy_theme.dart';
import '../../foundation/surface/academy_surface_mask.dart';

class AcademyTableSection {
  const AcademyTableSection({
    this.title,
    this.footer,
    required this.rows,
    this.header,
    this.headerTrailing,
    this.footerWidget,
    this.headerStyle,
    this.footerStyle,
    this.cornerRadius,
    this.showSeparators = true,
    this.separatorBuilder,
  });
  final String? title, footer;
  final List<Widget> rows;
  final Widget? header, headerTrailing, footerWidget;
  final TextStyle? headerStyle, footerStyle;
  final double? cornerRadius;
  final bool showSeparators;
  final Widget Function(BuildContext, int)? separatorBuilder;
}

/// Inline by default; scrolling ownership may instead be delegated to the table.
class AcademyGroupedTable extends StatelessWidget {
  const AcademyGroupedTable({
    super.key,
    required this.sections,
    this.padding,
    this.sectionSpacing = 24,
    this.scrollable = false,
    this.controller,
    this.physics,
    this.hideEmptySections = true,
    this.animated = false,
  });
  final List<AcademyTableSection> sections;
  final EdgeInsetsGeometry? padding;
  final double sectionSpacing;
  final bool scrollable, hideEmptySections, animated;
  final ScrollController? controller;
  final ScrollPhysics? physics;
  @override
  Widget build(BuildContext context) {
    final visible = sections
        .where((section) => !hideEmptySections || section.rows.isNotEmpty)
        .toList();
    Widget section(int index) {
      final child = AcademyTableSectionView(section: visible[index]);
      return animated
          ? AnimatedSize(
              duration: MediaQuery.disableAnimationsOf(context)
                  ? Duration.zero
                  : AcademyTokens.layoutMotion,
              alignment: Alignment.topCenter,
              child: child,
            )
          : child;
    }

    if (scrollable) {
      return ListView.separated(
        padding: padding ?? AcademyTheme.of(context).paddings.groupedTable,
        controller: controller,
        physics: physics,
        addRepaintBoundaries: !ModalSheetSurfaceScope.isInModalSheet(context),
        itemCount: visible.length,
        itemBuilder: (_, index) => section(index),
        separatorBuilder: (_, _) => SizedBox(height: sectionSpacing),
      );
    }
    return Padding(
      padding: padding ?? AcademyTheme.of(context).paddings.groupedTable,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (var i = 0; i < visible.length; i++) ...[
            if (i > 0) SizedBox(height: sectionSpacing),
            section(i),
          ],
        ],
      ),
    );
  }
}
