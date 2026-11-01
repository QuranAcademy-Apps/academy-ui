
import 'package:academy_ui/academy_ui.dart'
    show AcademyPillSegments, AcademySymbols;
import 'package:cupertino_ui/cupertino_ui.dart';

import '../../../core/widgets/app_menu_anchor.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_typography.dart';

class AppMenu extends StatelessWidget {
  const AppMenu({
    super.key,
    required this.title,
    required this.itemBuilder,
    required this.enabled,
    this.useRootOverlay,
  });

  final String title;
  final List<Widget> Function(BuildContext context) itemBuilder;
  final bool enabled;
  final bool? useRootOverlay;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final textTheme = CupertinoTheme.of(context).textTheme;

    return AppMenuAnchor(
      consumeOutsideTaps: true,
      useRootOverlay: useRootOverlay,
      menuChildren: itemBuilder(context),
      builder: (context, controller, child) => GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: enabled
            ? () => controller.isOpen ? controller.close() : controller.open()
            : null,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppMenuDisplay(
              title: title,
              style: textTheme.textStyle.copyWith(
                color: colors.textSecondary,
                fontSize: 17,
                fontWeight: FontWeight.w400,
                letterSpacing: 0,
              ),
              iconColor: colors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }
}

class AppMenuDisplay extends StatelessWidget {
  const AppMenuDisplay({
    super.key,
    required this.title,
    this.style,
    this.iconColor,
    this.iconSize = 15,
    this.spacing = 8,
  });

  final String title;
  final TextStyle? style;
  final Color? iconColor;
  final double iconSize;
  final double spacing;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final textTheme = CupertinoTheme.of(context).textTheme;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style:
              style ??
              textTheme.textStyle.copyWith(
                color: colors.textSecondary,
                fontSize: 17,
                fontWeight: FontWeight.w400,
                letterSpacing: AppTypography.trackingForSize(17),
              ),
        ),
        SizedBox(width: spacing),
        Icon(
          AcademySymbols.upDown,
          size: iconSize,
          color: iconColor ?? colors.textSecondary,
        ),
      ],
    );
  }
}

class AppSegmented<T extends Object> extends StatelessWidget {
  const AppSegmented.control({
    super.key,
    required this.value,
    required this.values,
    required this.labelFor,
    required this.onChanged,
    this.width,
    this.backgroundColor,
    this.selectedColor,
    this.textColor,
  }) : assert(values.length > 0),
       assert(width == null || width > 0);

  final T value;
  final List<T> values;
  final double? width;
  final String Function(T value) labelFor;
  final ValueChanged<T> onChanged;
  final Color? backgroundColor;
  final Color? selectedColor;
  final Color? textColor;

  @override
  Widget build(BuildContext context) {
    final appColors = AppColorsProvider.maybeOf(context);
    return AcademyPillSegments<T>(
      value: value,
      values: values,
      labelFor: labelFor,
      onChanged: onChanged,
      width: width,
      backgroundColor: backgroundColor ?? appColors?.fillPrimary,
      selectedColor: selectedColor ?? appColors?.fillSecondary,
      textColor: textColor,
    );
  }
}
