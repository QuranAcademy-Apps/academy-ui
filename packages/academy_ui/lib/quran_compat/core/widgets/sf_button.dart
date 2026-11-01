import 'package:academy_ui/academy_ui.dart' show PressScale;
import 'package:cupertino_ui/cupertino_ui.dart';

import '../../theme/app_colors.dart';
import './sf_button_style.dart';
import './sf_image_view.dart';

export './sf_button_style.dart';
export './sf_image_view.dart';

part './sf_button_builder.dart';

/// Flutter equivalent of the iOS SFButton.
class SFButton extends StatelessWidget {
  final String? systemName;
  final IconData? iconData;
  final SFButtonType type;
  final SFButtonSize size;
  final SFIconButtonBackground background;
  final double tapAreaScale;
  final Color? tintColor;
  final Color? backgroundColor;
  final Color? borderColor;
  final double borderWidth;
  final FontWeight? fontWeight;
  final Widget? contextMenu;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final String? semanticLabel;
  final String? semanticHint;

  const SFButton({
    super.key,
    this.systemName,
    this.iconData,
    this.type = SFButtonType.withBackground,
    this.size = SFButtonSize.standard,
    this.background = SFIconButtonBackground.content,
    this.tapAreaScale = 1.0,
    this.tintColor,
    this.backgroundColor,
    this.borderColor,
    this.borderWidth = 0,
    this.fontWeight,
    this.contextMenu,
    this.onTap,
    this.onLongPress,
    this.semanticLabel,
    this.semanticHint,
  }) : assert(
         systemName != null || iconData != null,
         'Either systemName or iconData must be provided',
       );

  const SFButton.systemName({
    super.key,
    required this.systemName,
    this.type = SFButtonType.withBackground,
    this.size = SFButtonSize.standard,
    this.background = SFIconButtonBackground.content,
    this.tapAreaScale = 1.0,
    this.tintColor,
    this.backgroundColor,
    this.borderColor,
    this.borderWidth = 0,
    this.fontWeight,
    this.contextMenu,
    this.onTap,
    this.onLongPress,
    this.semanticLabel,
    this.semanticHint,
  }) : iconData = null;

  const SFButton.iconData({
    super.key,
    required this.iconData,
    this.type = SFButtonType.withBackground,
    this.size = SFButtonSize.standard,
    this.background = SFIconButtonBackground.content,
    this.tapAreaScale = 1.0,
    this.tintColor,
    this.backgroundColor,
    this.borderColor,
    this.borderWidth = 0,
    this.fontWeight,
    this.contextMenu,
    this.onTap,
    this.onLongPress,
    this.semanticLabel,
    this.semanticHint,
  }) : systemName = null;

  @override
  Widget build(BuildContext context) {
    final colors = AppColorsProvider.maybeOf(context);
    final imageView = SFImageView(
      systemName: systemName,
      iconData: iconData,
      type: type,
      size: size,
      foreground: tintColor ?? colors?.iconPrimary ?? CupertinoColors.black,
      backgroundColor: backgroundColor ?? background.resolve(colors),
      borderColor: borderColor,
      borderWidth: borderWidth,
      fontWeight: fontWeight,
    );

    final tapArea = SizedBox(
      width: size.frameSize.width * tapAreaScale,
      height: size.frameSize.height * tapAreaScale,
      child: Center(child: ExcludeSemantics(child: imageView)),
    );

    final button = Semantics(
      button: true,
      enabled: onTap != null || onLongPress != null || contextMenu != null,
      image: false,
      label: semanticLabel ?? systemName,
      hint: semanticHint,
      child: PressScale(
        enabled: onTap != null || onLongPress != null || contextMenu != null,
        onTap: onTap,
        onLongPress: onLongPress,
        child: tapArea,
      ),
    );

    if (contextMenu == null) {
      return button;
    }

    return CupertinoContextMenu(actions: [contextMenu!], child: button);
  }
}

/// Flutter equivalent of the iOS SFImageView.
