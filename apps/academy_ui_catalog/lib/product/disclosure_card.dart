import 'package:flutter/cupertino.dart';

import 'package:academy_ui/academy_ui.dart';


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
                  expanded
                      ? AcademyTheme.of(context).icons.up
                      : AcademyTheme.of(context).icons.down,
                  size: AcademyTheme.of(context).sizes.controlIcon,
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
      borderRadius: BorderRadius.circular(
        AcademyTheme.of(context).radii.disclosure,
      ),
      child: content,
    );
  }
}
