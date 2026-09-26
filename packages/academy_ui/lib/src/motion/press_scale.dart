// Adapted from quran_flutter/lib/core/widgets/press_scale.dart.
import 'dart:async' show Timer, unawaited;

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/physics.dart';
import 'package:flutter/widgets.dart';

class PressScale extends StatefulWidget {
  const PressScale({
    super.key,
    required this.child,
    this.onTap,
    this.onLongPress,
    this.enabled = true,
    this.longPressOnly = false,
    this.pressedScale = 0.9,
    this.pressDuration = const Duration(milliseconds: 260),
    this.releaseDuration,
    this.pressDelay = Duration.zero,
    this.longPressDuration,
    this.externalPressed,
  });

  final Widget child;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final bool enabled;

  /// Реагирует только на long-press (translucent, без tap-рекогнайзера), так
  /// что одиночный тап проваливается к родительскому жесту (например, к
  /// тогглу баров ридера). Скейл-фидбек даётся по контакту пальца.
  final bool longPressOnly;
  final double pressedScale;
  final Duration pressDuration;
  final Duration? releaseDuration;
  final Duration pressDelay;

  /// Кастомный порог long-press (только для [longPressOnly]). Когда задан —
  /// используется собственный распознаватель с этой длительностью вместо
  /// дефолтных ~500 мс (например, маркер аята: меню по короткому удержанию).
  final Duration? longPressDuration;

  /// Внешний драйвер нажатия. Когда задан — собственные жесты не подключаются,
  /// а скейл управляется этим сигналом (true = нажат). Нужно, когда жест висит
  /// на отдельном виджете (напр. оверлей хит-зоны номера страницы), а скейл —
  /// на самой вьюшке.
  final ValueListenable<bool>? externalPressed;

  @override
  State<PressScale> createState() => _PressScaleState();
}

class _PressScaleState extends State<PressScale>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  Timer? _pressTimer;

  bool get _canPress => widget.enabled;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController.unbounded(vsync: this, value: 1);
    final external = widget.externalPressed;
    if (external != null) {
      external.addListener(_handleExternalPressed);
      if (external.value) _press();
    }
  }

  @override
  void didUpdateWidget(PressScale oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.externalPressed != widget.externalPressed) {
      oldWidget.externalPressed?.removeListener(_handleExternalPressed);
      widget.externalPressed?.addListener(_handleExternalPressed);
    }
    if (!_canPress && _controller.value != 1) {
      _springToRest();
    }
  }

  @override
  void dispose() {
    widget.externalPressed?.removeListener(_handleExternalPressed);
    _pressTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _handleExternalPressed() {
    if (widget.externalPressed?.value ?? false) {
      _press();
    } else {
      _release();
    }
  }

  void _press() {
    if (!_canPress) return;
    _pressTimer?.cancel();
    if (widget.pressDelay > Duration.zero) {
      _pressTimer = Timer(widget.pressDelay, _animateToPressed);
      return;
    }
    _animateToPressed();
  }

  void _animateToPressed() {
    if (!_canPress || !mounted) return;
    _controller.stop();
    unawaited(
      _controller.animateTo(
        widget.pressedScale,
        duration: widget.pressDuration,
        curve: Curves.easeOutCubic,
      ),
    );
  }

  void _release() {
    if (!_canPress) return;
    _pressTimer?.cancel();
    if (widget.releaseDuration != null) {
      _animateToRest();
    } else {
      _springToRest();
    }
  }

  void _animateToRest() {
    _controller.stop();
    unawaited(
      _controller.animateTo(
        1,
        duration: widget.releaseDuration!,
        curve: Curves.easeOutCubic,
      ),
    );
  }

  void _springToRest() {
    final velocity = _controller.velocity;
    _controller.stop();
    unawaited(
      _controller.animateWith(
        SpringSimulation(
          const SpringDescription(mass: 1, stiffness: 360, damping: 28),
          _controller.value,
          1,
          velocity,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final animatedChild = AnimatedBuilder(
      animation: _controller,
      child: widget.child,
      builder: (context, child) {
        return Transform.scale(scale: _controller.value, child: child);
      },
    );

    if (widget.externalPressed != null) {
      // Жесты на стороне внешнего виджета; здесь только скейл-анимация.
      return animatedChild;
    }

    if (widget.longPressOnly) {
      final longPressDuration = widget.longPressDuration;
      if (longPressDuration != null) {
        // Тот же контракт, что ниже, но с кастомным порогом удержания —
        // GestureDetector не даёт настроить длительность long-press.
        return RawGestureDetector(
          behavior: HitTestBehavior.translucent,
          gestures: <Type, GestureRecognizerFactory>{
            LongPressGestureRecognizer:
                GestureRecognizerFactoryWithHandlers<
                  LongPressGestureRecognizer
                >(
                  () => LongPressGestureRecognizer(duration: longPressDuration),
                  (instance) {
                    instance
                      ..onLongPressDown = _canPress ? (_) => _press() : null
                      ..onLongPressCancel = _canPress ? _release : null
                      ..onLongPress = _canPress ? widget.onLongPress : null
                      ..onLongPressUp = _canPress ? _release : null;
                  },
                ),
          },
          child: animatedChild,
        );
      }
      // Только long-press: tap-рекогнайзера нет, поэтому одиночный тап
      // проваливается к родителю; скейл — по контакту (onLongPressDown).
      return GestureDetector(
        behavior: HitTestBehavior.translucent,
        onLongPressDown: _canPress ? (_) => _press() : null,
        onLongPressCancel: _canPress ? _release : null,
        onLongPress: _canPress ? widget.onLongPress : null,
        onLongPressUp: _canPress ? _release : null,
        child: animatedChild,
      );
    }

    return _buildTapAndLongPressDetector(animatedChild);
  }

  Widget _buildTapAndLongPressDetector(Widget child) {
    final longPressDuration = widget.longPressDuration;
    if (longPressDuration == null) {
      return GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: _canPress ? (_) => _press() : null,
        onTapUp: _canPress ? (_) => _release() : null,
        onTapCancel: _canPress ? _release : null,
        onTap: _canPress ? widget.onTap : null,
        onLongPress: _canPress ? widget.onLongPress : null,
        onLongPressEnd: _canPress ? (_) => _release() : null,
        onLongPressCancel: _canPress ? _release : null,
        child: child,
      );
    }

    return RawGestureDetector(
      behavior: HitTestBehavior.opaque,
      gestures: <Type, GestureRecognizerFactory>{
        TapGestureRecognizer:
            GestureRecognizerFactoryWithHandlers<TapGestureRecognizer>(
              TapGestureRecognizer.new,
              (instance) {
                instance
                  ..onTapDown = _canPress ? (_) => _press() : null
                  ..onTapUp = _canPress ? (_) => _release() : null
                  ..onTapCancel = _canPress ? _release : null
                  ..onTap = _canPress ? widget.onTap : null;
              },
            ),
        LongPressGestureRecognizer:
            GestureRecognizerFactoryWithHandlers<LongPressGestureRecognizer>(
              () => LongPressGestureRecognizer(duration: longPressDuration),
              (instance) {
                instance
                  ..onLongPressStart = _canPress ? (_) => _press() : null
                  ..onLongPress = _canPress ? widget.onLongPress : null
                  ..onLongPressEnd = _canPress ? (_) => _release() : null
                  ..onLongPressCancel = _canPress ? _release : null;
              },
            ),
      },
      child: child,
    );
  }
}
