part of '../app_toast.dart';

enum AppToastPosition { top, bottom }

const _appToastAnimationDuration = Duration(milliseconds: 300);

class AppToastOverlay extends StatefulWidget {
  const AppToastOverlay({
    super.key,
    required this.message,
    required this.position,
    this.systemName,
    this.top = 0,
    this.bottom,
    this.actionLabel,
    this.actionSystemName,
    this.onAction,
    this.onDismissed,
    this.showCloseButton = false,
  });

  final String? message;
  final AppToastPosition position;
  final IconData? systemName;
  final double top;
  final double? bottom;

  /// Optional trailing action (for example "Undo"). Tapping it dismisses the
  /// toast and then runs [onAction].
  final String? actionLabel;

  /// When set, the action is drawn as this SF Symbol only; the label stays
  /// as its accessibility name.
  final String? actionSystemName;
  final VoidCallback? onAction;

  /// Called after the user swipes the toast away or taps its close button, so
  /// the owner can clear the message it passed in.
  final VoidCallback? onDismissed;
  final bool showCloseButton;

  @override
  State<AppToastOverlay> createState() => _AppToastOverlayState();
}

class _AppToastOverlayState extends State<AppToastOverlay> {
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
  void didUpdateWidget(covariant AppToastOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.message != widget.message) _syncMessage();
    if (oldWidget.onAction != widget.onAction ||
        oldWidget.actionSystemName != widget.actionSystemName ||
        oldWidget.actionLabel != widget.actionLabel) {
      // didUpdateWidget runs during build: the overlay entry may only be
      // marked dirty after the frame.
      _scheduleOverlaySync();
    }
    if (oldWidget.position != widget.position ||
        oldWidget.top != widget.top ||
        oldWidget.bottom != widget.bottom ||
        oldWidget.systemName != widget.systemName) {
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
      Future<void>.delayed(_appToastAnimationDuration, () {
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
    if (widget.position == .top) {
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

    final colors = AppColorsProvider.maybeOf(context);
    final iconColor =
        colors?.iconPrimary ??
        CupertinoDynamicColor.resolve(CupertinoColors.label, context);
    final textColor =
        colors?.textPrimary ??
        CupertinoDynamicColor.resolve(CupertinoColors.label, context);
    final accentColor =
        colors?.accent ??
        CupertinoDynamicColor.resolve(CupertinoColors.activeBlue, context);

    final child = IgnorePointer(
      ignoring: !_isVisible,
      child: AnimatedSlide(
        offset: _isVisible
            ? Offset.zero
            : Offset(0, widget.position == .top ? -0.2 : 0.2),
        duration: _appToastAnimationDuration,
        curve: Curves.easeInOut,
        child: AnimatedOpacity(
          opacity: _isVisible ? 1 : 0,
          duration: _appToastAnimationDuration,
          curve: Curves.easeInOut,
          child: Center(
            child: Semantics(
              onDismiss: _dismissByUser,
              child: Dismissible(
                key: ValueKey(_messageEpoch),
                direction: widget.position == .top
                    ? DismissDirection.up
                    : DismissDirection.down,
                resizeDuration: null,
                onDismissed: (_) => _dismissByUser(),
                child: GradientControlChromeCapsule(
                  child: Padding(
                    padding: EdgeInsetsDirectional.fromSTEB(
                      widget.showCloseButton
                          ? 10
                          : widget.systemName == null
                          ? 20
                          : 16,
                      widget.showCloseButton ? 10 : 12,
                      widget.actionLabel != null ? 16 : 20,
                      widget.showCloseButton ? 10 : 12,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (widget.showCloseButton) ...[
                          // Same 24pt round control as the player's close.
                          CupertinoButton(
                            minimumSize: const Size(24, 24),
                            padding: EdgeInsets.zero,
                            onPressed: _dismissByUser,
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: accentColor.withValues(alpha: 0.12),
                                border: Border.all(
                                  color: accentColor.withValues(alpha: 0.4),
                                ),
                              ),
                              child: SFImageView.systemName(
                                systemName: 'xmark',
                                size: const SFButtonSize.custom(
                                  frameSize: Size.square(24),
                                  symbolSize: 12,
                                ),
                                foreground: accentColor,
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                        ],
                        if (widget.systemName != null) ...[
                          Icon(widget.systemName, color: iconColor, size: 18),
                          const SizedBox(width: 12),
                        ],
                        Flexible(
                          child: Text(
                            message,
                            textAlign: widget.position == .top
                                ? TextAlign.center
                                : TextAlign.start,
                            style: AppTypography.subheadline.copyWith(
                              color: textColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        if (widget.actionLabel != null &&
                            widget.onAction != null) ...[
                          const SizedBox(width: 12),
                          Semantics(
                            button: true,
                            label: widget.actionLabel,
                            child: GestureDetector(
                              behavior: HitTestBehavior.opaque,
                              onTap: _runAction,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 4,
                                ),
                                child: ExcludeSemantics(
                                  child: widget.actionSystemName != null
                                      ? SFImageView.systemName(
                                          systemName: widget.actionSystemName!,
                                          size: const SFButtonSize.custom(
                                            frameSize: Size.square(24),
                                            symbolSize: 18,
                                          ),
                                          foreground: accentColor,
                                        )
                                      : Text(
                                          widget.actionLabel!,
                                          style: AppTypography.subheadline
                                              .copyWith(
                                                color: accentColor,
                                                fontWeight: FontWeight.w700,
                                              ),
                                        ),
                                ),
                              ),
                            ),
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
    );

    switch (widget.position) {
      case .top:
        final mediaPadding =
            MediaQuery.maybePaddingOf(context) ?? EdgeInsets.zero;
        return Positioned(
          left: 16,
          right: 16,
          top: mediaPadding.top + widget.top,
          child: child,
        );
      case .bottom:
        final bottomInset = floatingChromeBottomInsetOf(context);
        final bottomGap = widget.bottom ?? 8;
        return Positioned(
          left: 16,
          right: 16,
          bottom: bottomGap + bottomInset,
          child: child,
        );
    }
  }
}
