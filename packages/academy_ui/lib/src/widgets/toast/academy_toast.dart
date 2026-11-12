import '../../theme/academy_theme.dart';
import '../../foundation/localizations/academy_localizations.dart';

import 'dart:async';
import 'dart:math' as math;

import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:flutter/gestures.dart';

import '../navigation/chrome/academy_chrome.dart';
import 'academy_toast_overlay.dart';

export 'academy_toast_overlay.dart';
export 'academy_toast_controller.dart';

/// Capsule toast; holding pauses its timer, swiping toward its edge dismisses.
class AcademyToastHost extends StatefulWidget {
  const AcademyToastHost({
    super.key,
    required this.child,
    this.bottomObstruction = 0,
    this.style = AcademyChromeStyle.flat,
  });
  final Widget child;
  final double bottomObstruction;

  /// Toast material; pass the app's chrome style to match its navigation.
  final AcademyChromeStyle style;
  static void show(
    BuildContext context,
    String message, {
    AcademyToastPosition position = AcademyToastPosition.bottom,
    IconData? icon,
    IconData? leadingIcon,
    IconData? trailingIcon,
    Duration duration = const Duration(seconds: 3),
  }) => context.findAncestorStateOfType<_AcademyToastHostState>()?.show(
    message,
    position,
    leadingIcon ?? icon,
    trailingIcon,
    duration,
  );
  @override
  State<AcademyToastHost> createState() => _AcademyToastHostState();
}

class _AcademyToastHostState extends State<AcademyToastHost>
    with SingleTickerProviderStateMixin {
  Timer? _timer;
  String? _message;
  IconData? _leadingIcon, _trailingIcon;
  Duration _duration = const Duration(seconds: 3);
  AcademyToastPosition _position = AcademyToastPosition.bottom;
  double _drag = 0;
  double? _dragOrigin;
  int? _pointer;
  int _version = 0;
  bool _dragging = false;
  bool _dismissing = false;
  bool get _held => _pointer != null;
  late final _animation = AnimationController(
    vsync: this,
    duration: AcademyTokens.toastMotion,
  );
  double get _direction => _position == AcademyToastPosition.top ? -1 : 1;

  void _schedule() {
    _timer?.cancel();
    if (_held || _dismissing || _message == null) return;
    _timer = Timer(_duration, _dismiss);
  }

  void show(
    String message,
    AcademyToastPosition position,
    IconData? leadingIcon,
    IconData? trailingIcon,
    Duration duration,
  ) {
    _timer?.cancel();
    setState(() {
      _version++;
      _message = message;
      _position = position;
      _leadingIcon = leadingIcon;
      _trailingIcon = trailingIcon;
      _duration = duration;
      _drag = 0;
      _dragOrigin = null;
      _pointer = null;
      _dragging = false;
      _dismissing = false;
    });
    _animation.duration = MediaQuery.disableAnimationsOf(context)
        ? Duration.zero
        : AcademyTokens.toastMotion;
    _animation.forward(from: 0);
    _schedule();
  }

  Future<void> _dismiss() async {
    if (_message == null || _dismissing) return;
    _dismissing = true;
    final version = _version;
    _timer?.cancel();
    try {
      await _animation.reverse().orCancel;
      if (mounted && version == _version) setState(() => _message = null);
    } on TickerCanceled {
      // A replacement toast or host disposal cancels the outgoing animation.
    }
  }

  void _contactStart(PointerDownEvent event) {
    if (_pointer != null || _dismissing || event.buttons != kPrimaryButton) {
      return;
    }
    _pointer = event.pointer;
    _dragOrigin = event.position.dy;
    _timer?.cancel();
  }

  void _contactEnd(PointerEvent event) {
    if (event.pointer != _pointer) return;
    _pointer = null;
    if (!_dragging) {
      _dragOrigin = null;
      _schedule();
    }
  }

  void _startDrag(DragStartDetails event) {
    if (_dismissing || _dragOrigin == null) return;
    _dragging = true;
    _updateDrag(event.globalPosition.dy);
  }

  void _updateDrag(double globalY) {
    if (!_dragging || _dismissing || _dragOrigin == null) return;
    // Follow only the permitted vertical direction, with bounded travel even
    // when the finger stays down. Absolute displacement avoids accumulating
    // outward travel when the user first drags in the wrong direction.
    final outward = ((globalY - _dragOrigin!) * _direction).clamp(0.0, 96.0);
    setState(() => _drag = _direction * outward);
  }

  void _endDrag(DragEndDetails event) {
    if (!_dragging || _dismissing) return;
    _dragging = false;
    final travel = _drag * _direction;
    final velocity = (event.primaryVelocity ?? 0) * _direction;
    if (travel >= 48 || travel > 0 && velocity > 350) {
      _dismiss();
    } else {
      _cancelDrag();
    }
  }

  void _cancelDrag() {
    if (_dismissing) return;
    setState(() {
      _dragging = false;
      _drag = 0;
      _dragOrigin = null;
    });
    _schedule();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _animation.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Stack(
    children: [
      widget.child,
      if (_message != null)
        Positioned(
          // Clear the side safe areas in landscape too.
          left: 16 + MediaQuery.paddingOf(context).left,
          right: 16 + MediaQuery.paddingOf(context).right,
          top: _position == AcademyToastPosition.top
              ? MediaQuery.paddingOf(context).top + 8
              : null,
          bottom: _position == AcademyToastPosition.bottom
              // The keyboard covers the safe area and the obstruction, so the
              // largest of them counts.
              ? math.max(
                      MediaQuery.viewInsetsOf(context).bottom,
                      math.max(
                        MediaQuery.paddingOf(context).bottom,
                        widget.bottomObstruction,
                      ),
                    ) +
                    8
              : null,
          child: Align(
            alignment: Alignment.center,
            child: AnimatedBuilder(
              animation: _animation,
              builder: (context, child) => Opacity(
                opacity: _animation.value,
                child: Transform.translate(
                  offset: Offset(
                    0,
                    _direction *
                        (1 - Curves.easeOut.transform(_animation.value)) *
                        40,
                  ),
                  child: child,
                ),
              ),
              child: KeyedSubtree(
                key: ValueKey(_version),
                child: AnimatedContainer(
                  duration: _dragging || MediaQuery.disableAnimationsOf(context)
                      ? Duration.zero
                      : const Duration(milliseconds: 200),
                  curve: Curves.easeOut,
                  transform: Matrix4.translationValues(0, _drag, 0),
                  child: Listener(
                    onPointerDown: _contactStart,
                    onPointerUp: _contactEnd,
                    onPointerCancel: _contactEnd,
                    child: GestureDetector(
                      key: const ValueKey('academy-toast'),
                      behavior: HitTestBehavior.opaque,
                      onTap: _dismiss,
                      dragStartBehavior: DragStartBehavior.down,
                      onVerticalDragStart: _startDrag,
                      onVerticalDragUpdate: (event) =>
                          _updateDrag(event.globalPosition.dy),
                      onVerticalDragEnd: _endDrag,
                      onVerticalDragCancel: _cancelDrag,
                      child: Semantics(
                        liveRegion: true,
                        button: true,
                        hint: _position == AcademyToastPosition.top
                            ? AcademyLocalizations.of(context)
                                  .toastDismissUpHint
                            : AcademyLocalizations.of(context)
                                  .toastDismissDownHint,
                        onDismiss: _dismiss,
                        child: AcademyChrome(
                          style: widget.style,
                          radius: AcademyTheme.of(context).radii.toast,
                          child: Padding(
                            padding:
                                _leadingIcon == null && _trailingIcon == null
                                ? AcademyTheme.of(context).paddings.toast
                                : AcademyTheme.of(context)
                                      .paddings
                                      .toastWithIcons,
                            child: AcademyToastContent(
                              message: _message!,
                              position: _position,
                              icon: _leadingIcon,
                              trailingIcon: _trailingIcon,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
    ],
  );
}
