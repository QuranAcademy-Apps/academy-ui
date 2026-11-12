import '../../foundation/localizations/academy_localizations.dart';

import '../icon/academy_sf_image.dart';

import 'package:cupertino_ui/cupertino_ui.dart';

import '../../theme/academy_theme.dart';

import '../button/academy_button.dart';

enum AcademyFeedbackKind { loading, empty, error }

class AcademyFeedback extends StatelessWidget {
  const AcademyFeedback({
    super.key,
    required this.kind,
    required String this.title,
    required String this.message,
    this.onRetry,
    this.loadingIndicator,
  }) : retryLabel = null,
       messageColor = null,
       _compactPadding = null;

  /// Text only, with an optional filled retry button below it. The retry label
  /// is supplied by the host so it follows the app language.
  const AcademyFeedback.compact({
    super.key,
    this.message,
    this.onRetry,
    this.retryLabel,
    this.messageColor,
    EdgeInsetsGeometry padding = const EdgeInsets.symmetric(horizontal: 32),
  }) : assert(message != null || onRetry != null),
       assert(onRetry == null || retryLabel != null),
       kind = AcademyFeedbackKind.empty,
       title = null,
       loadingIndicator = null,
       _compactPadding = padding;
  final AcademyFeedbackKind kind;

  /// Replaces the activity indicator of [AcademyFeedbackKind.loading], for
  /// example with a content skeleton.
  final Widget? loadingIndicator;
  final String? title;
  final String? message;
  final VoidCallback? onRetry;
  final String? retryLabel;

  /// Compact message color; default: the theme's secondary text color.
  final Color? messageColor;
  final EdgeInsetsGeometry? _compactPadding;

  Widget _compact(BuildContext context, EdgeInsetsGeometry padding) {
    final theme = AcademyTheme.of(context);
    return Center(
      child: Padding(
        padding: padding,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (message != null) ...[
              Text(
                message!,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyLarge.copyWith(
                  color: messageColor ?? theme.colorScheme.onSurfaceVariant,
                ),
              ),
              if (onRetry != null) const SizedBox(height: 16),
            ],
            if (onRetry != null)
              CupertinoButton.filled(
                padding: const EdgeInsets.symmetric(
                  horizontal: 22,
                  vertical: 10,
                ),
                onPressed: onRetry,
                child: Text(retryLabel!),
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final compactPadding = _compactPadding;
    if (compactPadding != null) return _compact(context, compactPadding);
    final theme = AcademyTheme.of(context);
    return Padding(
      padding: AcademyTheme.of(context).paddings.feedback,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 300),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (kind == AcademyFeedbackKind.loading)
                Padding(
                  padding: AcademyTheme.of(context).paddings.feedbackIcon,
                  child:
                      loadingIndicator ??
                      theme.feedbackLoadingIndicator ??
                      const CupertinoActivityIndicator(radius: 12),
                )
              else
                AcademySfIcon(
                  kind == AcademyFeedbackKind.error
                      ? AcademyTheme.of(context).icons.loadError
                      : AcademyTheme.of(context).icons.empty,
                  size: AcademyTheme.of(context).sizes.feedbackIcon,
                  fontWeight: FontWeight.w400,
                  color: theme.colorScheme.onSurfaceVariant.withValues(
                    alpha: .65,
                  ),
                ),
              const SizedBox(height: 16),
              Semantics(
                header: true,
                child: Text(
                  title!,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.feedbackTitle,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                message!,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              if (kind == AcademyFeedbackKind.error && onRetry != null) ...[
                const SizedBox(height: AcademyTokens.inlineGap),
                AcademyTextButton(
                  label: AcademyLocalizations.of(context).retry,
                  onPressed: onRetry,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
