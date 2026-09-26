import 'academy_sf_image.dart';

import 'package:flutter/cupertino.dart';

import 'modal/academy_modal.dart';
export 'modal/academy_modal.dart' show showAcademyModal;

import 'academy_theme.dart';
import 'modal/modal_sheet_corner_mask.dart';

class AcademyButton extends StatelessWidget {
  const AcademyButton({
    super.key,
    required this.label,
    this.onPressed,
    this.pending = false,
    this.secondary = false,
  });
  final String label;
  final VoidCallback? onPressed;
  final bool pending;
  final bool secondary;

  @override
  Widget build(BuildContext context) {
    final theme = AcademyTheme.of(context);
    final p = theme.colorScheme;
    final disabled = !pending && onPressed == null;
    final background = disabled
        ? Color.lerp(p.onSurface, p.surface, .88)!
        : secondary
        ? Color.lerp(p.primary, p.surface, .84)!
        : p.primary;
    final foreground = disabled
        ? p.onSurfaceVariant
        : secondary
        ? p.primary
        : p.onPrimary;
    return Semantics(
      liveRegion: pending,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: disabled
                ? p.outlineVariant
                : secondary
                ? p.primary.withValues(alpha: .24)
                : background,
          ),
        ),
        child: CupertinoButton(
          onPressed: pending ? null : onPressed,
          color: background,
          disabledColor: background,
          borderRadius: BorderRadius.circular(14),
          minimumSize: const Size(44, 52),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          child: DefaultTextStyle(
            style: theme.textTheme.labelLarge.copyWith(color: foreground),
            textAlign: TextAlign.center,
            child: pending
                ? Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CupertinoActivityIndicator(radius: 9, color: foreground),
                      const SizedBox(width: 10),
                      Flexible(child: Text(label)),
                    ],
                  )
                : Text(label),
          ),
        ),
      ),
    );
  }
}

/// Quiet auxiliary action; retains a full Cupertino touch target.
class AcademyTextButton extends StatelessWidget {
  const AcademyTextButton({
    super.key,
    required this.label,
    required this.onPressed,
  });
  final String label;
  final VoidCallback? onPressed;
  @override
  Widget build(BuildContext context) {
    final theme = AcademyTheme.of(context);
    return CupertinoButton(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      minimumSize: const Size(44, 44),
      onPressed: onPressed,
      child: Text(
        label,
        textAlign: TextAlign.center,
        style: theme.textTheme.labelLarge.copyWith(
          color: onPressed == null
              ? theme.colorScheme.onSurfaceVariant
              : theme.colorScheme.primary,
        ),
      ),
    );
  }
}

class AcademyField extends StatefulWidget {
  const AcademyField({
    super.key,
    required this.label,
    this.help,
    this.error,
    this.placeholder,
    this.enabled = true,
    this.onChanged,
    this.keyboardType,
    this.controller,
  });
  final String label;
  final String? help, error, placeholder;
  final bool enabled;
  final ValueChanged<String>? onChanged;
  final TextInputType? keyboardType;
  final TextEditingController? controller;
  @override
  State<AcademyField> createState() => _AcademyFieldState();
}

class _AcademyFieldState extends State<AcademyField> {
  final _focus = FocusNode();
  final _ownedController = TextEditingController();
  TextEditingController get _controller =>
      widget.controller ?? _ownedController;
  @override
  void initState() {
    super.initState();
    _focus.addListener(_focusChanged);
    _controller.addListener(_focusChanged);
  }

  void _focusChanged() => setState(() {});
  @override
  void didUpdateWidget(AcademyField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      (oldWidget.controller ?? _ownedController).removeListener(_focusChanged);
      _controller.addListener(_focusChanged);
    }
  }

  void _clear() {
    _controller.clear();
    widget.onChanged?.call('');
    _focus.requestFocus();
  }

  @override
  void dispose() {
    _controller.removeListener(_focusChanged);
    _ownedController.dispose();
    _focus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = AcademyTheme.of(context);
    final p = theme.colorScheme;
    final duration = MediaQuery.disableAnimationsOf(context)
        ? Duration.zero
        : AcademyTokens.motion;
    final canClear = widget.enabled && _controller.text.isNotEmpty;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ExcludeSemantics(
            child: Text(
              widget.label,
              style: theme.textTheme.bodySmall.copyWith(
                color: p.onSurfaceVariant,
              ),
            ),
          ),
          const SizedBox(height: 6),
          Semantics(
            label: widget.label,
            child: TweenAnimationBuilder<Color?>(
              tween: ColorTween(
                end: _focus.hasFocus ? p.primary : p.outlineVariant,
              ),
              duration: duration,
              curve: Curves.easeInOut,
              builder: (context, borderColor, _) => CupertinoTextField(
                controller: _controller,
                focusNode: _focus,
                enabled: widget.enabled,
                onChanged: widget.onChanged,
                keyboardType: widget.keyboardType,
                // Reserve the trailing slot so clearing and focus never shift text.
                suffix: SizedBox.square(
                  dimension: 44,
                  child: IgnorePointer(
                    ignoring: !canClear,
                    child: ExcludeSemantics(
                      excluding: !canClear,
                      child: AnimatedOpacity(
                        opacity: canClear ? 1 : 0,
                        duration: duration,
                        child: Semantics(
                          label: 'Очистить ${widget.label}',
                          container: true,
                          button: true,
                          child: CupertinoButton(
                            padding: EdgeInsets.zero,
                            minimumSize: const Size(44, 44),
                            onPressed: canClear ? _clear : null,
                            child: AcademySfIcon(
                              AcademySymbols.close,
                              size: 16,
                              boxSize: 22,
                              color: p.onSurfaceVariant,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                textInputAction: TextInputAction.done,
                onSubmitted: (_) => _focus.unfocus(),
                placeholder: widget.placeholder ?? 'Введите значение',
                placeholderStyle: theme.textTheme.bodyLarge.copyWith(
                  color: p.onSurfaceVariant,
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 12,
                ),
                style: theme.textTheme.bodyLarge.copyWith(
                  color: widget.enabled ? p.onSurface : p.onSurfaceVariant,
                ),
                decoration: BoxDecoration(
                  color: p.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: borderColor ?? p.outlineVariant,
                    // Keep layout insets constant when focus changes.
                    width: 1.5,
                  ),
                ),
              ),
            ),
          ),
          if (widget.error != null || widget.help != null) ...[
            const SizedBox(height: 6),
            Semantics(
              liveRegion: widget.error != null,
              child: Text(
                widget.error ?? widget.help!,
                style: theme.textTheme.bodySmall.copyWith(
                  color: widget.error != null ? p.error : p.onSurfaceVariant,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class AcademySurface extends StatelessWidget {
  const AcademySurface({super.key, required this.child});
  final Widget child;
  @override
  Widget build(BuildContext context) {
    final content = Padding(
      padding: const EdgeInsets.all(AcademyTokens.gutter),
      child: child,
    );
    if (ModalSheetSurfaceScope.isInModalSheet(context)) {
      return ModalSheetMaskedFill(
        color: AcademyTheme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(AcademyTokens.radius),
        child: content,
      );
    }
    return DecoratedBox(
      decoration: ShapeDecoration(
        color: AcademyTheme.of(context).colorScheme.surface,
        shape: RoundedSuperellipseBorder(
          borderRadius: BorderRadius.circular(AcademyTokens.radius),
        ),
      ),
      child: content,
    );
  }
}

class AcademyStatus extends StatelessWidget {
  const AcademyStatus({
    super.key,
    required this.label,
    this.tone = AcademyTone.neutral,
  });
  final String label;
  final AcademyTone tone;
  @override
  Widget build(BuildContext context) {
    final palette = AcademyTheme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: palette.toneContainer(tone),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: AcademyTheme.of(context).textTheme.bodySmall.copyWith(
          color: palette.toneForeground(tone),
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

enum AcademyFeedbackKind { loading, empty, error }

class AcademyFeedback extends StatelessWidget {
  const AcademyFeedback({
    super.key,
    required this.kind,
    required this.title,
    required this.message,
    this.onRetry,
  });
  final AcademyFeedbackKind kind;
  final String title;
  final String message;
  final VoidCallback? onRetry;
  @override
  Widget build(BuildContext context) {
    final theme = AcademyTheme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 300),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (kind == AcademyFeedbackKind.loading)
                const Padding(
                  padding: EdgeInsets.all(10),
                  child: CupertinoActivityIndicator(radius: 12),
                )
              else
                AcademySfIcon(
                  kind == AcademyFeedbackKind.error
                      ? AcademySymbols.cloud
                      : AcademySymbols.search,
                  size: 44,
                  fontWeight: FontWeight.w400,
                  color: theme.colorScheme.onSurfaceVariant.withValues(
                    alpha: .65,
                  ),
                ),
              const SizedBox(height: 16),
              Semantics(
                header: true,
                child: Text(
                  title,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.titleLarge.copyWith(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                message,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              if (kind == AcademyFeedbackKind.error && onRetry != null) ...[
                const SizedBox(height: 12),
                AcademyTextButton(label: 'Повторить', onPressed: onRetry),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class AcademyImage extends StatelessWidget {
  const AcademyImage({super.key, this.url, required this.label});
  final String? url;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = AcademyTheme.of(context);
    final fallback = ColoredBox(
      color: AcademyTheme.of(context).colorScheme.surfaceContainerHighest,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AcademySfIcon(
                AcademySymbols.photo,
                size: 32,
                fontWeight: FontWeight.w400,
                color: theme.colorScheme.onSurfaceVariant.withValues(
                  alpha: .65,
                ),
              ),
              const SizedBox(height: 12),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 240),
                child: Text(
                  label,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodySmall.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
    return ClipRRect(
      borderRadius: BorderRadius.circular(AcademyTokens.radius),
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 220),
        child: url == null
            ? fallback
            : Image.network(
                url!,
                fit: BoxFit.cover,
                semanticLabel: label,
                frameBuilder: (_, child, frame, synchronous) => frame == null
                    ? fallback
                    : AspectRatio(aspectRatio: 16 / 10, child: child),
                errorBuilder: (_, error, stack) => fallback,
                loadingBuilder: (_, child, progress) =>
                    progress == null ? child : fallback,
              ),
      ),
    );
  }
}

Future<void> showAcademySheet(
  BuildContext context, {
  required String title,
  required Widget child,
}) => showAcademyModal<void>(
  context,
  title: title,
  builder: (context) => AcademyModalScrollView(
    padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
    child: child,
  ),
);

Future<bool?> showAcademyConfirmation(
  BuildContext context, {
  required String title,
  required String message,
  String confirmLabel = 'Подтвердить',
  String cancelLabel = 'Назад',
}) => showAcademyModal<bool>(
  context,
  title: title,
  builder: (context) => AcademyModalListView(
    padding: const EdgeInsets.all(24),
    children: [
      Text(message),
      const SizedBox(height: 24),
      AcademyButton(
        label: confirmLabel,
        onPressed: () => closeAcademyModal(context, true),
      ),
      const SizedBox(height: 12),
      AcademyTextButton(
        label: cancelLabel,
        onPressed: () => closeAcademyModal(context, false),
      ),
    ],
  ),
);

/// Adapted from quran_flutter's SFButton: independent hit area and round fill.
class AcademyIconButton extends StatelessWidget {
  const AcademyIconButton({
    super.key,
    required this.label,
    required this.icon,
    required this.onPressed,
  });
  final String label;
  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => Semantics(
    label: label,
    button: true,
    excludeSemantics: true,
    onTap: onPressed,
    child: CupertinoButton(
      padding: EdgeInsets.zero,
      minimumSize: const Size(48, 48),
      onPressed: onPressed,
      child: AcademySfImage(
        icon,
        foreground: AcademyTheme.of(context).colorScheme.onSurface,
        background: AcademyTheme.of(context)
            .colorScheme
            .surfaceContainerHighest,
      ),
    ),
  );
}
