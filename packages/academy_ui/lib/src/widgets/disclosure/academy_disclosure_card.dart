import 'package:cupertino_ui/cupertino_ui.dart' hide CupertinoButton;
import 'package:flutter/cupertino.dart' show CupertinoButton;

import '../../foundation/interaction/academy_interaction.dart';

import '../icon/academy_sf_image.dart';
import '../../theme/academy_theme.dart';
import '../modal/modal_sheet_corner_mask.dart';

/// Quran TajweedDisclosureCard, with app-owned expansion and opaque fill.
class AcademyDisclosureCard extends StatelessWidget {
  const AcademyDisclosureCard({
    super.key,
    required this.title,
    required this.expanded,
    required this.onToggle,
    required this.child,
  });
  final String title;
  final bool expanded;
  final VoidCallback onToggle;
  final Widget child;
  @override
  Widget build(BuildContext context) {
    final theme = AcademyTheme.of(context);
    final content = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AcademyActionSemantics(
          label: '',
          enabled: true,
          expanded: expanded,
          child: CupertinoButton(
            padding: AcademyTheme.of(context).paddings.disclosureHeader,
            minimumSize: const Size(44, 56),
            onPressed: onToggle,
            child: Row(
              children: [
                Expanded(child: Text(title, style: theme.textTheme.titleSmall)),
                const SizedBox(width: AcademyTokens.inlineGap),
                AcademySfIcon(
                  expanded ? AcademySymbols.up : AcademySymbols.down,
                  size: 18,
                  boxSize: 22,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ],
            ),
          ),
        ),
        AnimatedCrossFade(
          firstChild: const SizedBox(width: double.infinity),
          secondChild: Padding(
            padding: AcademyTheme.of(context).paddings.disclosureBody,
            child: SizedBox(width: double.infinity, child: child),
          ),
          crossFadeState: expanded
              ? CrossFadeState.showSecond
              : CrossFadeState.showFirst,
          duration: MediaQuery.disableAnimationsOf(context)
              ? Duration.zero
              : AcademyTokens.motion,
          sizeCurve: Curves.easeInOut,
        ),
      ],
    );
    return ModalSheetMaskedFill(
      color: theme.colorScheme.surface,
      borderRadius: BorderRadius.circular(AcademyTheme.of(context).radii.table),
      child: content,
    );
  }
}
