import 'package:flutter/widgets.dart';

/// Propagates the user's "Reduce Transparency" preference to the floating-chrome
/// widgets ([GradientControlChrome], [AppChromeFadeMaterial], …) without coupling
/// them to the settings service.
///
/// Provided once near the app root next to `AppColorsProvider`, driven by
/// `AppSettingsService.reduceTransparency`. When enabled, chrome renders as
/// opaque plates + flat outlined controls (no translucent gradients, shadows, or
/// backdrop blur) — an accessibility / low-end opt-in.
class AppChromeStyle extends InheritedWidget {
  const AppChromeStyle({
    super.key,
    required this.reduceTransparency,
    required super.child,
  });

  final bool reduceTransparency;

  static AppChromeStyle? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<AppChromeStyle>();

  /// Reads the flag, defaulting to `false` when no provider is in scope (e.g.
  /// isolated widget tests) so chrome keeps its full translucent look unless
  /// explicitly reduced.
  static bool reduceTransparencyOf(BuildContext context) =>
      maybeOf(context)?.reduceTransparency ?? false;

  @override
  bool updateShouldNotify(AppChromeStyle oldWidget) =>
      reduceTransparency != oldWidget.reduceTransparency;
}
