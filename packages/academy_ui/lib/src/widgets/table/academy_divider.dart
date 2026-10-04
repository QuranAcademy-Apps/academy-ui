import 'package:flutter/cupertino.dart';

import '../../theme/academy_theme.dart';

// Preserve imports that historically exposed the row scope with the divider.
export '../../foundation/table/academy_table_row_scope.dart';

class AcademyDivider extends StatelessWidget {
  const AcademyDivider({super.key});
  @override
  Widget build(BuildContext context) => Padding(
    padding: AcademyTheme.of(context).paddings.divider,
    child: Container(
      height: .5,
      color: AcademyTheme.of(context).colorScheme.outlineVariant,
    ),
  );
}
