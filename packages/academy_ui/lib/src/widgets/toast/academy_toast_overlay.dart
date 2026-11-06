import 'dart:async' show unawaited;
import 'dart:math' as math;

import 'package:flutter/cupertino.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter/services.dart';

import '../../theme/academy_theme.dart';
import '../icon/academy_sf_image.dart';
import '../navigation/chrome/academy_chrome.dart';
import '../navigation/chrome/academy_chrome_metrics.dart';

enum AcademyToastPosition { top, bottom }

const _animationDuration = AcademyTokens.toastMotion;

/// Row of a toast capsule: optional close button and icon, the message, and an
/// optional action or trailing icon.
class AcademyToastContent extends StatelessWidget {
  const AcademyToastContent({
    super.key,
    required this.message,
    required this.position,
    this.icon,
    this.trailingIcon,
    this.actionLabel,
    this.actionIcon,
    this.onAction,
    this.onClose,
  });

  final String message;
  final AcademyToastPosition position;
  final IconData? icon, trailingIcon;

  /// Accessibility name of the action; drawn as text unless [actionIcon] is set.
  final String? actionLabel;
  final IconData? actionIcon;
  final VoidCallback? onAction;

  /// Shows the round close button.
  final VoidCallback? onClose;

  @override
  Widget build(BuildContext context) {
    final theme = AcademyTheme.of(context);
    final colors = theme.colorScheme;
    final accent = colors.accentForeground;
    final style = theme.textTheme.toast.copyWith(color: colors.onSurface);
    final iconSize = theme.sizes.controlIcon;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (onClose != null) ...[
          // Same 24pt round control as the player's close.
          CupertinoButton(
            minimumSize: const Size(24, 24),
            padding: EdgeInsets.zero,
            onPressed: onClose,
            child: DecoratedBox(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: accent.withValues(alpha: 0.12),
                border: Border.all(color: accent.withValues(alpha: 0.4)),
              ),
              child: AcademySfImage(
                theme.icons.close,
                frameSize: 24,
                symbolSize: 12,
                foreground: accent,
              ),
            ),
          ),
          const SizedBox(width: 10),
        ],
        if (icon != null) ...[
          AcademySfIcon(
            icon!,
            size: iconSize,
            boxSize: 18,
            color: colors.onSurface,
          ),
          const SizedBox(width: AcademyTokens.inlineGap),
        ],
        Flexible(
          child: Text(
            message,
            textAlign: position == AcademyToastPosition.top
                ? TextAlign.center
                : TextAlign.start,
            style: style,
          ),
        ),
        if (actionLabel != null && onAction != null) ...[
          const SizedBox(width: AcademyTokens.inlineGap),
          Semantics(
            button: true,
            label: actionLabel,
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: onAction,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: ExcludeSemantics(
                  child: actionIcon != null
                      ? AcademySfImage(
                          actionIcon!,
                          frameSize: 24,
                          symbolSize: 18,
                          foreground: accent,
                        )
                      : Text(
                          actionLabel!,
                          style: style.copyWith(
                            color: accent,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                ),
              ),
            ),
          ),
        ],
        if (trailingIcon != null) ...[
          const SizedBox(width: AcademyTokens.inlineGap),
          AcademySfIcon(trailingIcon!, size: iconSize, boxSize: 18),
        ],
      ],
    );
  }
}

/// A toast driven by its [message]: non-null shows it, null hides it. It paints
/// in the root overlay, so it stays above modals. The owner decides when the
/// message ends, usually through [AcademyToastController]; use
/// [AcademyToastHost] for a fire-and-forget toast.
class AcademyToastOverlay extends StatefulWidget {
  const AcademyToastOverlay({
    super.key,
    required this.message,
    required this.position,
    this.icon,
    this.top = 0,
    this.bottom,
    this.actionLabel,
    this.actionIcon,
    this.onAction,
    this.onDismissed,
    this.showCloseButton = false,
  });

  final String? message;
  final AcademyToastPosition position;
  final IconData? icon;
  final double top;
  final double? bottom;

  /// Optional trailing action (for example "Undo"). Tapping it dismisses the
  /// toast and then runs [onAction].
  final String? actionLabel;

  /// When set, the action is drawn as this symbol only; the label stays as its
  /// accessibility name.
  final IconData? actionIcon;
  final VoidCallback? onAction;

  /// Called after the user swipes the toast away or taps its close button, so
  /// the owner can clear the message it passed in.
  final VoidCallback? onDismissed;
  final bool showCloseButton;

  @override
  State<AcademyToastOverlay> createState() => _AcademyToastOverlayState();
}

class _AcademyToastOverlayState extends State<AcademyToastOverlay> {
  String? _message;
  String? _announcedMessage;
  bool _isVisible = false;
  int _messageEpoch = 0;
  OverlayEntry? _overlayEntry;
  OverlayState? _overlayState;
  bool _overlaySyncScheduled = false;

  @override
  void initState() {
    super.initState();
    _syncMessage();
  }

  @override
  void didUpdateWidget(covariant AcademyToastOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.message != widget.message) _syncMessage();
    if (oldWidget.onAction != widget.onAction ||
        oldWidget.actionIcon != widget.actionIcon ||
        oldWidget.actionLabel != widget.actionLabel ||
        oldWidget.position != widget.position ||
        oldWidget.top != widget.top ||
        oldWidget.bottom != widget.bottom ||
        oldWidget.icon != widget.icon) {
      // didUpdateWidget runs during build: the overlay entry may only be
      // marked dirty after the frame.
      _scheduleOverlaySync();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_message != null) _scheduleOverlaySync();
  }

  @override
  void dispose() {
    _removeOverlayEntry();
    super.dispose();
  }

  void _syncMessage() {
    final epoch = ++_messageEpoch;
    final nextMessage = widget.message;
    if (nextMessage == null) {
      if (_message == null) return;
      _isVisible = false;
      final outgoingMessage = _message;
      _scheduleOverlaySync();
      Future<void>.delayed(_animationDuration, () {
        if (!mounted ||
            _messageEpoch != epoch ||
            _message != outgoingMessage ||
            widget.message != null) {
          return;
        }
        setState(() => _message = null);
        _removeOverlayEntry();
      });
      return;
    }

    _message = nextMessage;
    _isVisible = false;
    _scheduleOverlaySync();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || _messageEpoch != epoch || _message != nextMessage) return;
      setState(() => _isVisible = true);
      _markOverlayNeedsBuild();
      _announceIfNeeded(nextMessage);
    });
  }

  void _scheduleOverlaySync() {
    if (_overlaySyncScheduled) return;
    _overlaySyncScheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _overlaySyncScheduled = false;
      if (!mounted) return;
      _syncOverlayEntry();
    });
  }

  void _syncOverlayEntry() {
    final message = _message;
    if (message == null) {
      _removeOverlayEntry();
      return;
    }

    final overlayState = Overlay.maybeOf(context, rootOverlay: true);
    if (overlayState == null) return;

    if (_overlayState != overlayState) {
      _removeOverlayEntry();
      _overlayState = overlayState;
      _overlayEntry = OverlayEntry(builder: _buildToastOverlay);
      overlayState.insert(_overlayEntry!);
      return;
    }

    if (_overlayEntry == null) {
      _overlayEntry = OverlayEntry(builder: _buildToastOverlay);
      overlayState.insert(_overlayEntry!);
      return;
    }

    _markOverlayNeedsBuild();
  }

  void _markOverlayNeedsBuild() {
    final overlayEntry = _overlayEntry;
    if (overlayEntry != null && overlayEntry.mounted) {
      overlayEntry.markNeedsBuild();
    }
  }

  void _removeOverlayEntry() {
    _overlayEntry?.remove();
    _overlayEntry = null;
    _overlayState = null;
  }

  void _dismissToast() {
    ++_messageEpoch;
    _message = null;
    _isVisible = false;
    _removeOverlayEntry();
  }

  void _dismissByUser() {
    _dismissToast();
    widget.onDismissed?.call();
  }

  void _runAction() {
    final action = widget.onAction;
    _dismissToast();
    action?.call();
  }

  void _announceIfNeeded(String message) {
    if (_announcedMessage == message) return;
    _announcedMessage = message;
    if (widget.position == AcademyToastPosition.top) {
      HapticFeedback.selectionClick();
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      unawaited(
        SemanticsService.sendAnnouncement(
          View.of(context),
          message,
          Directionality.maybeOf(context) ?? TextDirection.ltr,
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    _scheduleOverlaySync();
    return const SizedBox.shrink();
  }

  Widget _buildToastOverlay(BuildContext context) {
    final message = _message;
    if (message == null) return const SizedBox.shrink();
    final theme = AcademyTheme.of(context);
    final top = widget.position == AcademyToastPosition.top;
    final closable = widget.showCloseButton;
    final content = Padding(
      padding: EdgeInsetsDirectional.fromSTEB(
        closable
            ? 10
            : widget.icon == null
            ? 20
            : 16,
        closable ? 10 : 12,
        widget.actionLabel != null ? 16 : 20,
        closable ? 10 : 12,
      ),
      child: AcademyToastContent(
        message: message,
        position: widget.position,
        icon: widget.icon,
        actionLabel: widget.actionLabel,
        actionIcon: widget.actionIcon,
        onAction: widget.onAction == null ? null : _runAction,
        onClose: closable ? _dismissByUser : null,
      ),
    );
    final motion = MediaQuery.maybeDisableAnimationsOf(context) ?? false
        ? Duration.zero
        : _animationDuration;
    final child = IgnorePointer(
      ignoring: !_isVisible,
      child: AnimatedSlide(
        offset: _isVisible ? Offset.zero : Offset(0, top ? -0.2 : 0.2),
        duration: motion,
        curve: Curves.easeInOut,
        child: AnimatedOpacity(
          opacity: _isVisible ? 1 : 0,
          duration: motion,
          curve: Curves.easeInOut,
          child: Center(
            child: Semantics(
              onDismiss: _dismissByUser,
              child: Dismissible(
                key: ValueKey(_messageEpoch),
                direction: top ? DismissDirection.up : DismissDirection.down,
                resizeDuration: null,
                onDismissed: (_) => _dismissByUser(),
                child:
                    theme.toast.capsuleBuilder?.call(context, content) ??
                    AcademyChrome(radius: theme.radii.toast, child: content),
              ),
            ),
          ),
        ),
      ),
    );
    final mediaPadding = MediaQuery.maybePaddingOf(context) ?? EdgeInsets.zero;
    if (top) {
      return Positioned(
        left: 16 + mediaPadding.left,
        right: 16 + mediaPadding.right,
        top:
            (theme.toast.topInsetOf?.call(context) ?? mediaPadding.top) +
            widget.top,
        child: child,
      );
    }
    final bottomInset =
        theme.toast.bottomInsetOf?.call(context) ??
        academyChromeBottomOf(context);
    // The keyboard covers the bottom inset, so the larger one counts.
    final keyboard = MediaQuery.maybeViewInsetsOf(context)?.bottom ?? 0;
    return Positioned(
      left: 16 + mediaPadding.left,
      right: 16 + mediaPadding.right,
      bottom: (widget.bottom ?? 8) + math.max(bottomInset, keyboard),
      child: child,
    );
  }
}
