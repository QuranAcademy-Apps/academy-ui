import 'package:flutter/cupertino.dart';

import '../../../foundation/interaction/academy_interaction.dart';
import '../../../foundation/motion/press_scale.dart';
import '../../../theme/academy_theme.dart';
import '../../icon/academy_sf_image.dart';
import '../../menu/academy_menu_anchor.dart';
import 'academy_chrome.dart';
import 'academy_chrome_metrics.dart';

/// Round chrome button that opens a pull-down menu, like the «…» menu of the
/// Quran reader. Items are ordinary `AcademyMenuItem`s owned by the app.
class AcademyChromeMenuButton extends StatelessWidget {
  const AcademyChromeMenuButton({
    super.key,
    required this.label,
    required this.items,
    this.icon = AcademySymbols.more,
    this.style,
    this.blurSigma,
  });
  final String label;
  final IconData icon;
  final List<Widget> items;
  final AcademyChromeStyle? style;
  final double? blurSigma;

  @override
  Widget build(BuildContext context) => AcademyMenuAnchor(
    consumeOutsideTaps: true,
    menuChildren: items,
    builder: (context, controller, child) => AcademyActionSemantics(
      label: label,
      enabled: items.isNotEmpty,
      expanded: controller.isOpen,
      child: PressScale(
        enabled: !MediaQuery.disableAnimationsOf(context),
        child: SizedBox.square(
          dimension: academyChromeBarHeight,
          child: AcademyChrome(
            radius: AcademyTheme.of(context).radii.chromeButton,
            style: style,
            blurSigma: blurSigma,
            child: CupertinoButton(
              padding: EdgeInsets.zero,
              minimumSize: Size.zero,
              onPressed: items.isEmpty
                  ? null
                  : () => controller.isOpen
                        ? controller.close()
                        : controller.open(),
              child: ExcludeSemantics(
                child: AcademySfImage(
                  icon,
                  foreground: AcademyChrome.foregroundColor(
                    context,
                    CupertinoTheme.of(context).primaryColor,
                    style: style,
                    minimumContrast: 3,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    ),
  );
}
