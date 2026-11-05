import '../icon/academy_sf_image.dart';

import 'package:flutter/cupertino.dart';

import '../../theme/academy_theme.dart';

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
          padding: AcademyTheme.of(context).paddings.feedbackCard,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AcademySfIcon(
                AcademyTheme.of(context).icons.photo,
                size: 32,
                fontWeight: FontWeight.w400,
                color: theme.colorScheme.onSurfaceVariant.withValues(
                  alpha: .65,
                ),
              ),
              const SizedBox(height: AcademyTokens.inlineGap),
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
      borderRadius: BorderRadius.circular(AcademyTheme.of(context).radii.image),
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
