import 'package:flutter/cupertino.dart';

import '../../theme/academy_theme.dart';

/// Common label/help/error layout for custom and built-in form fields.
class AcademyFieldDecoration extends StatelessWidget {
  const AcademyFieldDecoration({
    super.key,
    required this.child,
    this.label,
    this.help,
    this.error,
  });
  final Widget child;
  final String? label, help, error;
  @override
  Widget build(BuildContext context) {
    final theme = AcademyTheme.of(context);
    return Padding(
      padding: theme.paddings.fieldOuter,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (label != null) ...[
            ExcludeSemantics(
              child: Text(
                label!,
                style: theme.textTheme.bodySmall.copyWith(
                  color: theme.colorScheme.textFieldSecondaryForeground,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(height: AcademyTokens.labelGap),
          ],
          child,
          if (error != null || help != null) ...[
            const SizedBox(height: AcademyTokens.labelGap),
            Semantics(
              liveRegion: error != null,
              child: Text(
                error ?? help!,
                style: theme.textTheme.bodySmall.copyWith(
                  color: error != null
                      ? theme.colorScheme.textFieldErrorForeground
                      : theme.colorScheme.textFieldSecondaryForeground,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
