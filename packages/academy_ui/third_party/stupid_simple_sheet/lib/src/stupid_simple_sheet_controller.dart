import 'package:flutter/widgets.dart';

import 'snapping_point.dart';
import 'stupid_simple_sheet_transition.dart';

/// A mixin that provides imperative control over a sheet's animation.
///
/// Mix this into your [PopupRoute] that also uses
/// [StupidSimpleSheetTransitionMixin] to allow children of the sheet to
/// imperatively control the sheet's position.
mixin StupidSimpleSheetController<T> on StupidSimpleSheetTransitionMixin<T> {
  /// Retrieves the current [StupidSimpleSheetController] from the given
  /// [BuildContext].
  ///
  /// This will only work if called from a context that is inside the
  /// [StupidSimpleSheetRoute].
  static StupidSimpleSheetController<T>? maybeOf<T>(BuildContext context) {
    final route = ModalRoute.of(context);
    if (route case final StupidSimpleSheetController<T> route) {
      return route;
    }

    return null;
  }

  /// Can be used to imperatively animate the sheet to a relative position, but
  /// can't close it.
  ///
  /// The [relativePosition] must be larger than 0.0 (fully closed) and
  /// lower than or equal to 1.0 (fully open).
  ///
  /// If [snap] is true, the sheet will snap to the nearest snapping point
  /// after reaching the target position.
  ///
  /// If you want to close the sheet, use [Navigator.pop] instead.
  TickerFuture animateToRelative(double relativePosition, {bool snap = false}) {
    assert(
      relativePosition > 0.0 && relativePosition <= 1.0,
      'Relative position must be larger than 0.0 and less than or equal to 1.0',
    );

    assert(
      controller != null,
      'Controller is null. Make sure the route is pushed before calling.',
    );

    // We only animate if this route is still current
    if (!isCurrent) return TickerFuture.complete();

    final double target;

    if (snap) {
      // Find the closest snapping point that isn't 0.0
      final config = effectiveSnappingConfig;

      target = switch (config.findClosestSnapPoint(relativePosition)) {
        0.0 => config.points.first,
        final v => v,
      };
    } else {
      target = relativePosition;
    }

    final simulation = motion.createSimulation(
      start: controller!.value,
      end: target,
      velocity: controller!.velocity,
    );

    animationTargetValue = target;
    stickingPoint = target;
    return controller!.animateWith(simulation);
  }

  /// Updates the snapping configuration to an override for the sheet.
  ///
  /// Pass `null` to [newConfig] to reset the configuration to the one
  /// originally passed to the route constructor.
  ///
  /// If [animateToComply] is `true`, the sheet will immediately animate to
  /// comply with the new snapping configuration. This will snap the sheet to
  /// the nearest valid snapping point in the new configuration.
  ///
  /// Example:
  /// ```dart
  /// // Update to a new configuration and animate to comply
  /// controller.updateSheetSnappingConfig(
  ///   SheetSnappingConfig([0.3, 0.6, 1.0]),
  ///   animateToComply: true,
  /// );
  ///
  /// // Reset to the original configuration
  /// controller.updateSheetSnappingConfig(null);
  /// ```
  TickerFuture overrideSnappingConfig(
    SheetSnappingConfig? newConfig, {
    bool animateToComply = false,
  }) {
    assert(
      controller != null,
      'Controller is null. Make sure the route is pushed before calling.',
    );

    snappingConfigOverride = newConfig;

    // Only animate to comply if requested and if this route is still current
    if (animateToComply && isCurrent) {
      final currentPosition = controller!.value;

      // Find the nearest snapping point in the new configuration
      final targetPosition =
          effectiveSnappingConfig.findClosestSnapPoint(currentPosition);

      // If the current position is already at a valid snap point, don't animate
      if ((targetPosition - currentPosition).abs() < 0.001) {
        return TickerFuture.complete();
      }

      final simulation = motion.createSimulation(
        start: currentPosition,
        end: targetPosition,
        velocity: controller!.velocity,
      );

      animationTargetValue = targetPosition;
      stickingPoint = targetPosition;

      return controller!.animateWith(simulation);
    }

    return TickerFuture.complete();
  }
}
