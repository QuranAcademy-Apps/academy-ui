import 'dart:async' show Timer;

import 'package:flutter/foundation.dart';

/// Owns a transient toast value that clears itself after [duration].
///
/// The toast is hot, independent UI: keep it on this narrow listenable instead
/// of a screen notifier so showing or hiding it repaints only the overlay. A
/// newer [show] restarts the window; nothing publishes after [dispose].
final class AcademyToastController<T extends Object> {
  AcademyToastController({this.duration = const Duration(seconds: 3)});

  final Duration duration;
  final ValueNotifier<T?> _value = ValueNotifier<T?>(null);
  Timer? _timer;
  bool _disposed = false;

  ValueListenable<T?> get listenable => _value;
  T? get value => _value.value;

  void show(T value, {Duration? duration}) {
    if (_disposed) return;
    _timer?.cancel();
    _value.value = value;
    _timer = Timer(duration ?? this.duration, hide);
  }

  void hide() {
    if (_disposed) return;
    _timer?.cancel();
    _timer = null;
    _value.value = null;
  }

  void dispose() {
    if (_disposed) return;
    _disposed = true;
    _timer?.cancel();
    _value.dispose();
  }
}
