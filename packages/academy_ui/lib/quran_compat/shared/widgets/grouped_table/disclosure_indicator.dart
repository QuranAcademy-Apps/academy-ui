part of '../grouped_table.dart';

class AppGroupedTableDisclosureIndicator extends StatelessWidget {
  const AppGroupedTableDisclosureIndicator({super.key, this.turns = 0});

  final double turns;

  @override
  Widget build(BuildContext context) {
    return AnimatedRotation(
      turns: turns,
      duration: const Duration(milliseconds: 180),
      child: AppChevron.right(
        color: context.appColors.iconDisclosure,
        strokeWidth: 1.8,
      ),
    );
  }
}

class AppGroupedTableTrailingTextAccessory extends StatelessWidget {
  const AppGroupedTableTrailingTextAccessory({super.key, required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return AppGroupedTableTrailingText(text: text);
  }
}

class AppGroupedTableTrailingTextDisclosure extends StatelessWidget {
  const AppGroupedTableTrailingTextDisclosure({super.key, required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        AppGroupedTableTrailingText(text: text),
        const SizedBox(width: 8),
        const AppGroupedTableDisclosureIndicator(),
      ],
    );
  }
}

class AppGroupedTableTrailingText extends StatelessWidget {
  const AppGroupedTableTrailingText({
    super.key,
    required this.text,
    this.style,
  });

  final String text;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 170),
      child: Text(
        text,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        textAlign: TextAlign.end,
        style: style ?? AppTypography.listTitle(colors.iconSecondary),
      ),
    );
  }
}
