import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/cupertino.dart';

import 'chrome/academy_chrome.dart';
import 'academy_sf_image.dart';
import 'academy_components.dart';
import 'modal/academy_modal.dart';

class AcademyRingProgress extends StatelessWidget {
  const AcademyRingProgress({super.key, required this.value});
  final double value;
  @override
  Widget build(BuildContext context) => Semantics(
    label: 'Прогресс',
    value: '${(value.clamp(0, 1) * 100).round()}%',
    child: SizedBox.square(
      dimension: 36,
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0, end: value.clamp(0, 1)),
        duration: MediaQuery.disableAnimationsOf(context)
            ? Duration.zero
            : const Duration(milliseconds: 320),
        builder: (context, v, child) => CustomPaint(
          painter: _Ring(v, CupertinoTheme.of(context).primaryColor),
        ),
      ),
    ),
  );
}

class _Ring extends CustomPainter {
  _Ring(this.value, this.color);
  final double value;
  final Color color;
  @override
  void paint(Canvas canvas, Size size) {
    final rect = (Offset.zero & size).deflate(2);
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round
      ..color = color.withValues(alpha: .2);
    canvas.drawOval(rect, paint);
    paint.color = color;
    canvas.drawArc(rect, -math.pi / 2, 2 * math.pi * value, false, paint);
  }

  @override
  bool shouldRepaint(_Ring old) => old.value != value || old.color != color;
}

enum AcademyToastPosition { top, bottom }

/// Capsule toast; timer pauses while held, swipe dismisses along either axis.
class AcademyToastHost extends StatefulWidget {
  const AcademyToastHost({
    super.key,
    required this.child,
    this.bottomObstruction = 0,
  });
  final Widget child;
  final double bottomObstruction;
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
  Offset _drag = Offset.zero;
  bool _dragging = false;
  bool _held = false;
  late final _animation = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 300),
  );
  double get _direction => _position == AcademyToastPosition.top ? -1 : 1;

  void _schedule() {
    _timer?.cancel();
    if (_held) return;
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
      _message = message;
      _position = position;
      _leadingIcon = leadingIcon;
      _trailingIcon = trailingIcon;
      _duration = duration;
      _drag = Offset.zero;
      _dragging = false;
      _held = false;
    });
    _animation.duration = MediaQuery.disableAnimationsOf(context)
        ? Duration.zero
        : const Duration(milliseconds: 300);
    _animation.forward(from: 0);
    _schedule();
  }

  Future<void> _dismiss() async {
    _timer?.cancel();
    try {
      await _animation.reverse().orCancel;
      if (mounted) setState(() => _message = null);
    } on TickerCanceled {
      // A replacement toast or host disposal cancels the outgoing animation.
    }
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
          left: 16,
          right: 16,
          top: _position == AcademyToastPosition.top
              ? MediaQuery.paddingOf(context).top + 8
              : null,
          bottom: _position == AcademyToastPosition.bottom
              ? MediaQuery.viewInsetsOf(context).bottom +
                    math.max(
                      MediaQuery.paddingOf(context).bottom,
                      widget.bottomObstruction,
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
              child: AnimatedContainer(
                duration: _dragging || MediaQuery.disableAnimationsOf(context)
                    ? Duration.zero
                    : const Duration(milliseconds: 200),
                curve: Curves.easeOut,
                transform: Matrix4.translationValues(_drag.dx, _drag.dy, 0),
                child: Listener(
                  onPointerDown: (_) {
                    _held = true;
                    _timer?.cancel();
                  },
                  onPointerUp: (_) {
                    _held = false;
                    if (!_dragging) _schedule();
                  },
                  onPointerCancel: (_) {
                    _held = false;
                    if (!_dragging) _schedule();
                  },
                  child: GestureDetector(
                    key: const ValueKey('academy-toast'),
                    behavior: HitTestBehavior.opaque,
                    onTap: _dismiss,
                    onPanStart: (_) {
                      _timer?.cancel();
                      setState(() => _dragging = true);
                    },
                    onPanUpdate: (event) => setState(() {
                      _drag += event.delta;
                    }),
                    onPanEnd: (event) {
                      _dragging = false;
                      if (_drag.distance > 48 ||
                          event.velocity.pixelsPerSecond.distance > 350) {
                        _dismiss();
                      } else {
                        setState(() => _drag = Offset.zero);
                        _schedule();
                      }
                    },
                    onPanCancel: () {
                      setState(() {
                        _dragging = false;
                        _drag = Offset.zero;
                      });
                      _schedule();
                    },
                    child: Semantics(
                      liveRegion: true,
                      button: true,
                      hint: 'Смахните или нажмите, чтобы закрыть',
                      onDismiss: _dismiss,
                      child: AcademyChrome(
                        style: AcademyChromeStyle.flat,
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal:
                                _leadingIcon == null && _trailingIcon == null
                                ? 20
                                : 16,
                            vertical: 12,
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (_leadingIcon != null) ...[
                                AcademySfIcon(
                                  _leadingIcon!,
                                  size: 18,
                                  boxSize: 18,
                                ),
                                const SizedBox(width: 12),
                              ],
                              Flexible(
                                child: Text(
                                  _message!,
                                  textAlign:
                                      _position == AcademyToastPosition.top
                                      ? TextAlign.center
                                      : TextAlign.start,
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              if (_trailingIcon != null) ...[
                                const SizedBox(width: 12),
                                AcademySfIcon(
                                  _trailingIcon!,
                                  size: 18,
                                  boxSize: 18,
                                ),
                              ],
                            ],
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

class AcademyTip {
  const AcademyTip({
    required this.target,
    required this.title,
    required this.message,
  });
  final GlobalKey target;
  final String title, message;
}

/// Adapts Quran's targeted tips to a small route-owned sequence, without reader services.
Future<void> showAcademyTips(
  BuildContext context,
  List<AcademyTip> tips,
) async {
  for (var i = 0; i < tips.length; i++) {
    if (!context.mounted) return;
    final target = tips[i].target.currentContext;
    if (target == null) continue;
    await Scrollable.ensureVisible(
      target,
      duration: MediaQuery.disableAnimationsOf(context)
          ? Duration.zero
          : const Duration(milliseconds: 180),
      alignment: .2,
    );
    if (!context.mounted) return;
    final next = await showAcademyModal<bool>(
      context,
      title: tips[i].title,
      builder: (context) => AcademyModalListView(
        padding: const EdgeInsets.all(24),
        children: [
          Text(tips[i].message),
          const SizedBox(height: 12),
          Text('${i + 1} / ${tips.length}'),
          const SizedBox(height: 24),
          AcademyButton(
            label: i == tips.length - 1 ? 'Готово' : 'Далее',
            onPressed: () => closeAcademyModal(context, true),
          ),
          const SizedBox(height: 12),
          AcademyTextButton(
            label: 'Пропустить',
            onPressed: () => closeAcademyModal(context, false),
          ),
        ],
      ),
    );
    if (next != true) return;
  }
}
