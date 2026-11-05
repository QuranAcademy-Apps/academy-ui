import 'package:flutter/widgets.dart';

/// App-wide look and placement of [AcademyToastOverlay].
@immutable
class AcademyToastTheme {
  const AcademyToastTheme({this.capsuleBuilder, this.bottomInsetOf});

  /// Draws the capsule around the content; default: [AcademyChrome].
  final Widget Function(BuildContext context, Widget child)? capsuleBuilder;

  /// Bottom system inset; default: [academyChromeBottomOf].
  final double Function(BuildContext context)? bottomInsetOf;
}
