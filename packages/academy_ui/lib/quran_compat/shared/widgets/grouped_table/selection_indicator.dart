part of '../grouped_table.dart';

class AppGroupedTableSelectedIndicator extends StatelessWidget {
  const AppGroupedTableSelectedIndicator({super.key, required this.isSelected});

  final bool isSelected;
  @override
  Widget build(BuildContext context) => isSelected
      ? AppSfIcon(
          AcademySymbols.checkmark,
          fontSize: 18,
          color:
              context.appColors.actionAccent ?? context.appColors.iconPrimary,
        )
      : const SizedBox(width: 18);
}
