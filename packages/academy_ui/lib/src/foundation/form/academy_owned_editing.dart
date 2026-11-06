import 'package:flutter/widgets.dart';

/// A [FocusNode] that the caller may supply and that the state otherwise owns.
/// A supplied node stays the caller's: it is never disposed here.
mixin AcademyOwnedFocus<W extends StatefulWidget> on State<W> {
  FocusNode? _ownedFocus;

  /// The node [widget] supplies, if any.
  FocusNode? suppliedFocusNode(W widget);
  void onFocusChanged();

  FocusNode get focus =>
      suppliedFocusNode(widget) ?? (_ownedFocus ??= FocusNode());

  void attachFocus() => focus.addListener(onFocusChanged);

  void updateFocus(W oldWidget) {
    final previous = suppliedFocusNode(oldWidget);
    if (previous == suppliedFocusNode(widget)) return;
    (previous ?? _ownedFocus)?.removeListener(onFocusChanged);
    focus.addListener(onFocusChanged);
  }

  void disposeFocus() {
    focus.removeListener(onFocusChanged);
    _ownedFocus?.dispose();
  }
}

/// A [TextEditingController] that the caller may supply and that the state
/// otherwise owns. Dropping a supplied controller keeps the text on screen.
mixin AcademyOwnedController<W extends StatefulWidget> on State<W> {
  TextEditingController? _ownedController;

  /// The controller [widget] supplies, if any.
  TextEditingController? suppliedController(W widget);
  void onTextChanged();

  TextEditingController get controller =>
      suppliedController(widget) ??
      (_ownedController ??= TextEditingController());

  void attachController() => controller.addListener(onTextChanged);

  void updateController(W oldWidget) {
    final supplied = suppliedController(oldWidget);
    if (supplied == suppliedController(widget)) return;
    final previous = supplied ?? _ownedController!;
    final value = previous.value;
    previous.removeListener(onTextChanged);
    _ownedController?.dispose();
    _ownedController = suppliedController(widget) == null
        ? TextEditingController.fromValue(value)
        : null;
    controller.addListener(onTextChanged);
  }

  void disposeController() {
    controller.removeListener(onTextChanged);
    _ownedController?.dispose();
  }
}
