import 'package:flutter/widgets.dart';

/// Look of [AcademyButton] and [AcademyTextButton] for a whole app.
@immutable
class AcademyButtonTheme {
  const AcademyButtonTheme({
    this.neutralBorder,
    this.foregroundForFill,
    this.textButtonStyle,
  });

  /// Outline of the neutral style; default: the chrome border.
  final Color? neutralBorder;

  /// Label color on an explicit [AcademyButton.backgroundColor]; default: the
  /// action label color, adjusted for contrast.
  final Color Function(Color fill)? foregroundForFill;

  /// [AcademyTextButton] label; default: [AcademyTextTheme.labelLarge].
  final TextStyle? textButtonStyle;
}
