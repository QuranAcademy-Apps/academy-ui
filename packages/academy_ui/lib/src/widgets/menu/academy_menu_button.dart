import 'package:flutter/cupertino.dart';

import 'academy_menu_anchor.dart';
import '../icon/academy_sf_image.dart';
import '../../theme/academy_theme.dart';
import '../navigation/chrome/academy_chrome.dart';

/// Quran menu indicator, including the two-line theme/font selector.
class AcademyMenuButton extends StatelessWidget {
  const AcademyMenuButton({
    super.key,
    required this.title,
    required this.items,
    this.subtitle,
    this.chevronOnLeading = false,
    this.enabled = true,
    this.style = AcademyChromeStyle.none,
    this.minimumHeight = 44,
    this.radius,
    this.expand = false,
  });
  final String title;
  final String? subtitle;
  final List<Widget> items;
  final bool chevronOnLeading, enabled;
  final AcademyChromeStyle style;
  final double minimumHeight;
  final double? radius;
  final bool expand;
  @override
  Widget build(BuildContext context) => AcademyMenuAnchor(
    consumeOutsideTaps: true,
    menuChildren: items,
    builder: (context, controller, _) {
      final theme = AcademyTheme.of(context);
      final chevron = AcademySfIcon(
        AcademyTheme.of(context).icons.upDown,
        size: 15,
        color: AcademyChrome.foregroundColor(
          context,
          theme.colorScheme.onSurfaceVariant,
          style: style,
          minimumContrast: 3,
        ),
      );
      return AcademyChrome(
        style: style,
        radius: radius ?? AcademyTheme.of(context).radii.menuButton,
        child: CupertinoButton(
          padding: AcademyTheme.of(context).paddings.menuButton,
          minimumSize: Size(44, minimumHeight),
          onPressed: enabled
              ? () => controller.isOpen ? controller.close() : controller.open()
              : null,
          child: Row(
            mainAxisSize: expand ? MainAxisSize.max : MainAxisSize.min,
            children: [
              if (chevronOnLeading) ...[
                chevron,
                const SizedBox(width: AcademyTokens.inlineGap),
              ],
              Flexible(
                fit: expand ? FlexFit.tight : FlexFit.loose,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: theme.textTheme.bodyLarge),
                    if (subtitle != null)
                      Text(
                        subtitle!,
                        style: theme.textTheme.bodySmall.copyWith(
                          color: AcademyChrome.foregroundColor(
                            context,
                            theme.colorScheme.onSurfaceVariant,
                            style: style,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              if (!chevronOnLeading) ...[
                const SizedBox(width: AcademyTokens.inlineGap),
                chevron,
              ],
            ],
          ),
        ),
      );
    },
  );
}
