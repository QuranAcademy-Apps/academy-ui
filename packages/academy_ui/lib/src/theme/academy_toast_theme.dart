import 'package:flutter/widgets.dart';

/// App-wide look and placement of [AcademyToastOverlay].
@immutable
class AcademyToastTheme {
  const AcademyToastTheme({
    this.capsuleBuilder,
    this.bottomInsetOf,
    this.topInsetOf,
  });

  /// Draws the capsule around the content; default: [AcademyChrome].
  final Widget Function(BuildContext context, Widget child)? capsuleBuilder;

  /// Bottom system inset; default: [academyChromeBottomOf].
  final double Function(BuildContext context)? bottomInsetOf;

  /// Top inset, for example below a navigation bar; default: the safe area.
  final double Function(BuildContext context)? topInsetOf;
}
