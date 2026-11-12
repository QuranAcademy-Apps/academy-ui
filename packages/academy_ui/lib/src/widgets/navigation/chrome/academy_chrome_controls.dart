import 'package:cupertino_ui/cupertino_ui.dart';

import '../../../foundation/localizations/academy_localizations.dart';
import '../../../theme/academy_theme.dart';
import 'academy_chrome.dart';
import 'academy_chrome_metrics.dart';

/// Round button that pops the current route; the symbol follows text direction.
class AcademyChromeBackButton extends StatelessWidget {
  const AcademyChromeBackButton({
    super.key,
    this.onPressed,
    this.label,
    this.size,
    this.style,
    this.blurSigma,
  });

  /// Default: pops the current route.
  final VoidCallback? onPressed;

  /// Default: the localized "Back".
  final String? label;
  final double? size;
  final AcademyChromeStyle? style;
  final double? blurSigma;

  @override
  Widget build(BuildContext context) {
    final theme = AcademyTheme.of(context);
    final look = theme.chromeButton;
    return AcademyChromeButton(
      icon:
          (Directionality.of(context) == TextDirection.rtl
              ? look.backIconRtl
              : look.backIcon) ??
          theme.icons.back,
      label: label ?? AcademyLocalizations.of(context).back,
      size: size,
      style: style,
      blurSigma: blurSigma,
      onPressed: onPressed ?? () => Navigator.of(context).maybePop(),
    );
  }
}

/// Capsule with a centered title and an optional subtitle.
class AcademyChromeTitleCapsule extends StatelessWidget {
  const AcademyChromeTitleCapsule({
    super.key,
    required this.title,
    this.subtitle,
    this.height = academyChromeBarHeight,
    this.style,
    this.blurSigma,
  });

  final String title;
  final String? subtitle;
  final double height;
  final AcademyChromeStyle? style;
  final double? blurSigma;

  @override
  Widget build(BuildContext context) {
    final theme = AcademyTheme.of(context);
    final button = theme.chromeButton;
    final titleStyle = button.titleStyle ?? theme.textTheme.titleMedium;
    final subtitle = this.subtitle;
    Text line(String text, TextStyle style) => Text(
      text,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      textAlign: TextAlign.center,
      style: style,
    );
    return AcademyChromeCapsule.bar(
      height: height,
      style: style,
      blurSigma: blurSigma,
      child: subtitle == null || subtitle.isEmpty
          ? line(title, titleStyle)
          : Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                line(title, button.compactTitleStyle ?? titleStyle),
                line(
                  subtitle,
                  button.subtitleStyle ?? theme.textTheme.bodySmall,
                ),
              ],
            ),
    );
  }
}
