// ignore_for_file: prefer_initializing_formals

import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:flutter/gestures.dart';

const _mouseDragDevices = {PointerDeviceKind.mouse};

/// Enables pressed mouse/trackpad dragging only where native Apple pointer
/// interaction is supported by the app.
class AppScrollBehavior extends CupertinoScrollBehavior {
  const AppScrollBehavior._({required bool mouseDragEnabled})
    : _mouseDragEnabled = mouseDragEnabled;

  static const _withMouseDrag = AppScrollBehavior._(mouseDragEnabled: true);
  static const _withoutMouseDrag = AppScrollBehavior._(mouseDragEnabled: false);

  factory AppScrollBehavior.forEnvironment({
    required TargetPlatform platform,
    required bool isWeb,
  }) {
    final supportsNativeApplePointer =
        !isWeb &&
        (platform == TargetPlatform.macOS || platform == TargetPlatform.iOS);
    return supportsNativeApplePointer ? _withMouseDrag : _withoutMouseDrag;
  }

  final bool _mouseDragEnabled;

  @override
  Set<PointerDeviceKind> get dragDevices => _mouseDragEnabled
      ? super.dragDevices.union(_mouseDragDevices)
      : super.dragDevices;
}

/// Restores Flutter's default mouse-drag exclusion for scrollables containing
/// selectable or editable text while preserving every other inherited setting.
class SelectionSafeScrollBoundary extends StatelessWidget {
  const SelectionSafeScrollBoundary({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final inheritedBehavior = ScrollConfiguration.of(context);
    if (!inheritedBehavior.dragDevices.contains(PointerDeviceKind.mouse)) {
      return child;
    }

    return ScrollConfiguration(
      behavior: inheritedBehavior.copyWith(
        dragDevices: inheritedBehavior.dragDevices.difference(
          _mouseDragDevices,
        ),
      ),
      child: child,
    );
  }
}
