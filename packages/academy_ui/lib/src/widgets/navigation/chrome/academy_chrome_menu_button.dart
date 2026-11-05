import 'package:flutter/cupertino.dart';

import '../../../theme/academy_theme.dart';
import '../../menu/academy_menu_anchor.dart';
import 'academy_chrome.dart';

/// Round chrome button that opens a pull-down menu, like the «…» menu of the
/// Quran reader. Items are ordinary `AcademyMenuItem`s owned by the app.
class AcademyChromeMenuButton extends StatelessWidget {
  const AcademyChromeMenuButton({
    super.key,
    required this.label,
    required this.items,
    this.icon,
    this.style,
    this.blurSigma,
  });
  final String label;

  /// Default: the theme's [AcademyIcons.more].
  final IconData? icon;
  final List<Widget> items;
  final AcademyChromeStyle? style;
  final double? blurSigma;

  @override
  Widget build(BuildContext context) => AcademyMenuAnchor(
    consumeOutsideTaps: true,
    menuChildren: items,
    builder: (context, controller, child) => AcademyChromeButton(
      icon: icon ?? AcademyTheme.of(context).icons.more,
      label: label,
      style: style,
      blurSigma: blurSigma,
      semanticsExpanded: controller.isOpen,
      onPressed: items.isEmpty
          ? null
          : () => controller.isOpen ? controller.close() : controller.open(),
    ),
  );
}
