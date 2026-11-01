import 'package:cupertino_ui/cupertino_ui.dart';

import '../../theme/app_colors.dart';
import './app_sf_icon.dart';
import './sf_button_style.dart';

class SFImageView extends StatelessWidget {
  final String? systemName;
  final IconData? iconData;
  final SFButtonType type;
  final SFButtonSize size;
  final SFIconButtonBackground background;
  final Color? foreground;
  final Color? backgroundColor;
  final Color? borderColor;
  final double borderWidth;
  final FontWeight? fontWeight;

  const SFImageView({
    super.key,
    this.systemName,
    this.iconData,
    this.type = SFButtonType.image,
    this.size = SFButtonSize.standard,
    this.background = SFIconButtonBackground.content,
    this.foreground,
    this.backgroundColor,
    this.borderColor,
    this.borderWidth = 0,
    this.fontWeight,
  }) : assert(
         systemName != null || iconData != null,
         'Either systemName or iconData must be provided',
       );

  const SFImageView.systemName({
    super.key,
    required this.systemName,
    this.type = SFButtonType.image,
    this.size = SFButtonSize.standard,
    this.background = SFIconButtonBackground.content,
    this.foreground,
    this.backgroundColor,
    this.borderColor,
    this.borderWidth = 0,
    this.fontWeight,
  }) : iconData = null;

  const SFImageView.iconData({
    super.key,
    required this.iconData,
    this.type = SFButtonType.image,
    this.size = SFButtonSize.standard,
    this.background = SFIconButtonBackground.content,
    this.foreground,
    this.backgroundColor,
    this.borderColor,
    this.borderWidth = 0,
    this.fontWeight,
  }) : systemName = null;

  @override
  Widget build(BuildContext context) {
    final colors = AppColorsProvider.maybeOf(context);
    final effectiveForeground =
        foreground ?? colors?.iconPrimary ?? CupertinoColors.black;
    final effectiveBackground = backgroundColor ?? background.resolve(colors);
    final icon = _buildIcon(effectiveForeground);
    final content = SizedBox(
      width: size.frameSize.width,
      height: size.frameSize.height,
      child: Center(child: icon),
    );

    if (type == SFButtonType.image) {
      return content;
    }

    return Container(
      width: size.frameSize.width,
      height: size.frameSize.height,
      decoration: BoxDecoration(
        color: effectiveBackground,
        borderRadius: BorderRadius.circular(size.frameSize.width / 2),
        border: borderColor == null || borderWidth <= 0
            ? null
            : Border.all(color: borderColor!, width: borderWidth),
      ),
      child: Center(child: icon),
    );
  }

  Widget _buildIcon(Color color) {
    final resolvedIconData = systemName != null
        ? sfIconDataForSystemName(systemName!)
        : iconData!;

    return AppSfIcon(
      resolvedIconData,
      fontSize: size.symbolSize,
      fontWeight: fontWeight ?? FontWeight.w700,
      color: color,
      semanticsLabel: systemName ?? 'icon',
    );
  }
}
