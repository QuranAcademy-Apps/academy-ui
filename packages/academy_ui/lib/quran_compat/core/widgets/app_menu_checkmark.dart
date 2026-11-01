import 'package:academy_ui/academy_ui.dart' show AcademySymbols;
import 'package:flutter/widgets.dart';

import 'app_sf_icon.dart';

class AppMenuCheckmark extends StatelessWidget {
  const AppMenuCheckmark({super.key, this.fontWeight = FontWeight.w600});

  static const double size = 17;

  final FontWeight fontWeight;

  @override
  Widget build(BuildContext context) {
    return AppSfIcon(
      AcademySymbols.checkmark,
      fontSize: size,
      fontWeight: fontWeight,
    );
  }
}
