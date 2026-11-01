import 'package:flutter/cupertino.dart';

import '../../theme/academy_theme.dart';

/// Centered secondary-text state for empty or failed content, with an
/// optional filled retry button below the message.
///
/// The retry label is supplied by the host so it follows the app language.
class AcademyMessageView extends StatelessWidget {
  const AcademyMessageView({
    super.key,
    this.message,
    this.onRetry,
    this.retryLabel,
    this.padding = const EdgeInsets.symmetric(horizontal: 32),
  }) : assert(message != null || onRetry != null),
       assert(onRetry == null || retryLabel != null);

  final String? message;
  final VoidCallback? onRetry;
  final String? retryLabel;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final theme = AcademyTheme.of(context);
    final message = this.message;
    final onRetry = this.onRetry;
    return Center(
      child: Padding(
        padding: padding,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (message != null) ...[
              Text(
                message,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyLarge.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
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
}
