import 'package:academy_ui/academy_ui.dart' show PressScale;
import 'package:cupertino_ui/cupertino_ui.dart';

import '../../../core/widgets/gradient_control_chrome.dart';
import '../../../core/widgets/sf_button.dart';
import '../../../theme/app_colors.dart';
import 'app_chrome_bar_metrics.dart';

/// Circular gradient icon button — the tab-bar equivalent of the reader's
/// `ReaderBarCircleButton`. Pass a null [onPressed] to render the disabled
/// (inactive tint) state.
class AppChromeBarIconButton extends StatelessWidget {
  const AppChromeBarIconButton({
    super.key,
    required this.systemName,
    required this.onPressed,
    this.onLongPress,
    this.size = kAppChromeBarHeight,
    this.semanticLabel,
  });

  final String systemName;
  final VoidCallback? onPressed;
  final VoidCallback? onLongPress;
  final double size;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return SizedBox.square(
      dimension: size,
      child: GradientControlChrome(
        radius: size / 2,
        child: Center(
          child: SFButton.systemName(
            systemName: systemName,
            size: SFButtonSize.large,
            background: SFIconButtonBackground.bar,
            backgroundColor: const Color(0x00000000),
            tintColor: onPressed == null
                ? colors.iconInactive
                : colors.iconPrimary,
            semanticLabel: semanticLabel,
            onTap: onPressed,
            onLongPress: onLongPress,
          ),
        ),
      ),
    );
  }
}

/// A single icon action inside an [AppChromeBarIconGroup].
class AppChromeBarIconAction {
  const AppChromeBarIconAction({
    this.systemName,
    this.assetPath,
    required this.onPressed,
    this.semanticLabel,
  }) : assert(
         (systemName == null) != (assetPath == null),
         'Provide exactly one of systemName or assetPath',
       );

  final String? systemName;
  final String? assetPath;
  final VoidCallback? onPressed;
  final String? semanticLabel;
}

/// A subtle separator between actions within an [AppChromeBarIconGroup].
class AppChromeBarIconGroupDivider extends StatelessWidget {
  const AppChromeBarIconGroupDivider({super.key, required this.height});

  final double height;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 1,
      height: height,
      child: Center(
        child: SizedBox(
          width: 1,
          height: 20,
          child: ColoredBox(color: context.appColors.separator),
        ),
      ),
    );
  }
}

/// Gradient pill capsule that hosts several icon buttons sharing a single
/// chrome surface (e.g. search + next), the multi-control sibling of
/// [AppChromeBarIconButton]. Each action stays individually tappable while the
/// whole group reads as one floating control, matching the reader's grouped
/// capsules.
class AppChromeBarIconGroup extends StatelessWidget {
  const AppChromeBarIconGroup({
    super.key,
    required this.actions,
    this.height = kAppChromeBarHeight,
  }) : assert(actions.length > 0, 'Provide at least one action');

  final List<AppChromeBarIconAction> actions;
  final double height;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return SizedBox(
      height: height,
      child: GradientControlChrome(
        radius: GradientControlChrome.capsuleRadius,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (var index = 0; index < actions.length; index++) ...[
              if (index > 0) AppChromeBarIconGroupDivider(height: height),
              SizedBox.square(
                dimension: height,
                child: Center(
                  child: actions[index].assetPath != null
                      ? _AppChromeBarAssetAction(
                          assetPath: actions[index].assetPath!,
                          size: height,
                          tintColor: actions[index].onPressed == null
                              ? colors.iconInactive
                              : colors.iconPrimary,
                          semanticLabel: actions[index].semanticLabel,
                          onPressed: actions[index].onPressed,
                        )
                      : SFButton.systemName(
                          systemName: actions[index].systemName!,
                          size: SFButtonSize.large,
                          background: SFIconButtonBackground.bar,
                          backgroundColor: const Color(0x00000000),
                          tintColor: actions[index].onPressed == null
                              ? colors.iconInactive
                              : colors.iconPrimary,
                          semanticLabel: actions[index].semanticLabel,
                          onTap: actions[index].onPressed,
                        ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _AppChromeBarAssetAction extends StatelessWidget {
  const _AppChromeBarAssetAction({
    required this.assetPath,
    required this.size,
    required this.tintColor,
    required this.semanticLabel,
    required this.onPressed,
  });

  final String assetPath;
  final double size;
  final Color tintColor;
  final String? semanticLabel;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) => Semantics(
    button: true,
    enabled: onPressed != null,
    label: semanticLabel ?? assetPath,
    child: PressScale(
      enabled: onPressed != null,
      onTap: onPressed,
      child: SizedBox.square(
        dimension: size,
        child: Center(
          child: SizedBox.square(
            dimension: 20,
            child: Image.asset(
              assetPath,
              fit: BoxFit.contain,
              color: tintColor,
              colorBlendMode: BlendMode.srcIn,
            ),
          ),
        ),
      ),
    ),
  );
}

/// Circular gradient surface hosting an arbitrary [child] (not necessarily an
/// SF button). Use this for reader chrome controls that aren't a plain icon
/// button; for a standard icon button prefer [AppChromeBarIconButton].
class AppChromeCircleSurface extends StatelessWidget {
  const AppChromeCircleSurface({
    super.key,
    required this.child,
    this.size = kAppChromeBarHeight,
  });

  final Widget child;
  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: size,
      child: GradientControlChrome(
        radius: size / 2,
        child: Center(child: child),
      ),
    );
  }
}

/// Canonical chrome back button: a circular [AppChromeBarIconButton] with the
/// reader's `chevron.left` glyph that pops the current route by default.
class AppChromeBarBackButton extends StatelessWidget {
  const AppChromeBarBackButton({
    super.key,
    this.onPressed,
    this.systemName,
    this.size = kAppChromeBarHeight,
    this.semanticLabel,
  });

  final VoidCallback? onPressed;
  final String? systemName;
  final double size;
  final String? semanticLabel;

  static String systemNameFor(TextDirection textDirection) =>
      textDirection == TextDirection.rtl ? 'chevron.right' : 'chevron.left';

  @override
  Widget build(BuildContext context) {
    return AppChromeBarIconButton(
      systemName: systemName ?? systemNameFor(Directionality.of(context)),
      size: size,
      semanticLabel: semanticLabel,
      onPressed: onPressed ?? () => Navigator.of(context).maybePop(),
    );
  }
}

/// Gradient pill capsule sized to its [child] (intrinsic width = content +
/// horizontal padding), the tab-bar equivalent of the reader's center capsule.
class AppChromeBarCapsule extends StatelessWidget {
  const AppChromeBarCapsule({
    super.key,
    required this.child,
    this.height = kAppChromeBarHeight,
    this.horizontalPadding = 20,
  });

  final Widget child;
  final double height;
  final double horizontalPadding;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: GradientControlChrome(
        radius: GradientControlChrome.capsuleRadius,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
          // mainAxisSize.min keeps the pill hugging its content rather than
          // stretching to the full available bar width.
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [Flexible(child: child)],
          ),
        ),
      ),
    );
  }
}

/// Convenience capsule that renders a single centered [title] line.
class AppChromeBarTitleCapsule extends StatelessWidget {
  const AppChromeBarTitleCapsule({
    super.key,
    required this.title,
    this.subtitle,
    this.height = kAppChromeBarHeight,
  });

  final String title;
  final String? subtitle;
  final double height;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final subtitle = this.subtitle;
    return AppChromeBarCapsule(
      height: height,
      child: subtitle == null || subtitle.isEmpty
          ? Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: colors.textPrimary,
                fontSize: 15,
                // Match the "Коран" tab's title weight (ChapterMenu uses w700) so all
                // tab titles read with the same boldness.
                fontWeight: FontWeight.w700,
              ),
            )
          : Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: colors.textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: colors.textSecondary,
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
    );
  }
}
