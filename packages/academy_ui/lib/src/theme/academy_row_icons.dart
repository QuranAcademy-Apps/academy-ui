import 'package:flutter/cupertino.dart';

import 'academy_theme.dart';

/// Semantic row tile roles. Dynamic system colors adapt to brightness.
/// Hues match the profile reference; callers can override a tile explicitly.
enum AcademyRowIcons {
  person,
  trip,
  document,
  alert,
  calendar,
  settings,
  info,
  hotel,
  passport;

  Color colorOf(BuildContext context) {
    final color = switch (this) {
      person => CupertinoColors.systemBlue,
      trip => CupertinoColors.systemOrange,
      document => CupertinoColors.systemGreen,
      alert => CupertinoColors.systemRed,
      calendar => CupertinoColors.systemTeal,
      settings => CupertinoColors.systemGrey,
      info => CupertinoColors.systemIndigo,
      hotel => CupertinoColors.systemPurple,
      passport => CupertinoColors.systemBrown,
    };
    return AcademyTheme.of(context).brightness == Brightness.dark
        ? color.darkColor
        : color.color;
  }
}
