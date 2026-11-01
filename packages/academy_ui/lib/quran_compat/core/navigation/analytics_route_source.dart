import 'package:flutter/widgets.dart';

/// Carries the named screen that opened a route without assigning the route a
/// name of its own. Modal sheets use this because their routes are intentionally
/// unnamed and must not be reported as screens.
final class AnalyticsRouteSource extends InheritedWidget {
  const AnalyticsRouteSource({
    super.key,
    required this.routeName,
    required super.child,
  });

  final String routeName;

  static String? maybeOf(BuildContext context) => context
      .dependOnInheritedWidgetOfExactType<AnalyticsRouteSource>()
      ?.routeName;

  @override
  bool updateShouldNotify(AnalyticsRouteSource oldWidget) =>
      routeName != oldWidget.routeName;
}

/// Route-settings payload for an unnamed route that preserves its origin for
/// a following named route observed by [AnalyticsRouteObserver].
final class AnalyticsRouteSourceSettings {
  const AnalyticsRouteSourceSettings(this.routeName);

  final String routeName;
}

String? analyticsRouteSourceOf(BuildContext context) =>
    AnalyticsRouteSource.maybeOf(context) ??
    ModalRoute.of(context)?.settings.name;
