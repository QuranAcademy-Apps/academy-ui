import 'package:flutter/cupertino.dart';

import '../../theme/academy_theme.dart';

/// iOS search state over page content: while navigation search is open the
/// content dims (tap dismisses); once there is a query, [results] replace the
/// dimming on an opaque page-colored surface. Place it in the page `Stack`
/// below the floating bar.
class AcademySearchScrim extends StatelessWidget {
  const AcademySearchScrim({
    super.key,
    required this.active,
    this.results,
    this.onDismiss,
    this.dimColor,
  });

  /// Search field is open.
  final bool active;

  /// Results for a non-empty query; `null` shows the dimming only.
  final Widget? results;
  final VoidCallback? onDismiss;

  /// Defaults to a dark translucent veil that also works in dark mode.
  final Color? dimColor;

  @override
  Widget build(BuildContext context) {
    final theme = AcademyTheme.of(context);
    final duration = MediaQuery.disableAnimationsOf(context)
        ? Duration.zero
        : AcademyTokens.motion;
    final dim =
        dimColor ??
        (theme.brightness == Brightness.dark
            ? const Color(0x99000000)
            : const Color(0x52000000));
    final showResults = active && results != null;
    return IgnorePointer(
      ignoring: !active,
      child: Stack(
        fit: StackFit.expand,
        children: [
          AnimatedOpacity(
            opacity: active && !showResults ? 1 : 0,
            duration: duration,
            curve: Curves.easeOut,
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: onDismiss,
              child: ColoredBox(color: dim),
            ),
          ),
          AnimatedSwitcher(
            duration: duration,
            child: showResults
                ? ColoredBox(
                    key: const ValueKey('results'),
                    color: theme.scaffoldBackgroundColor,
                    child: results,
                  )
                : const SizedBox.shrink(key: ValueKey('empty')),
          ),
        ],
      ),
    );
  }
}
