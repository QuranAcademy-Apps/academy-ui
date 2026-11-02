import '../../foundation/localizations/academy_localizations.dart';

import '../icon/academy_sf_image.dart';

import 'package:flutter/cupertino.dart';

import '../../theme/academy_theme.dart';

import '../button/academy_button.dart';

enum AcademyFeedbackKind { loading, empty, error }

class AcademyFeedback extends StatelessWidget {
  const AcademyFeedback({
    super.key,
    required this.kind,
    required this.title,
    required this.message,
    this.onRetry,
    this.loadingIndicator,
  });
  final AcademyFeedbackKind kind;

  /// Replaces the activity indicator of [AcademyFeedbackKind.loading], for
  /// example with a content skeleton.
  final Widget? loadingIndicator;
  final String title;
  final String message;
  final VoidCallback? onRetry;
  @override
  Widget build(BuildContext context) {
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
                      const CupertinoActivityIndicator(radius: 12),
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
                  style: theme.textTheme.feedbackTitle,
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
