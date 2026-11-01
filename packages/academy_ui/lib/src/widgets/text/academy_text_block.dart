import 'package:flutter/cupertino.dart';

import '../../theme/academy_theme.dart';

/// Quran list-reader translation block: rounded tinted panel with an optional
/// bold label (translator / «Транслитерация») above the text.
/// `onCard` darkens the panel slightly for use inside an opaque card.
class AcademyTextBlock extends StatelessWidget {
  const AcademyTextBlock({
    super.key,
    required this.text,
    this.label,
    this.style,
    this.textAlign = TextAlign.start,
    this.textDirection,
    this.onCard = false,
  });

  final String text;
  final String? label;

  /// Text style; defaults to body text with Quran's 1.32 line height.
  final TextStyle? style;
  final TextAlign textAlign;
  final TextDirection? textDirection;
  final bool onCard;

  /// Quran's translation tint: the card color mixed with the separator.
  static Color backgroundOf(BuildContext context, {bool onCard = false}) {
    final colors = AcademyTheme.of(context).colorScheme;
    return onCard
        ? Color.lerp(colors.surface, colors.outlineVariant, .28)!
        : colors.surface;
  }

  @override
  Widget build(BuildContext context) {
    final theme = AcademyTheme.of(context);
    final textStyle = style ?? theme.textTheme.bodyLarge.copyWith(height: 1.32);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: backgroundOf(context, onCard: onCard),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (label case final label?) ...[
            Text(
              label,
              style: theme.textTheme.bodySmall.copyWith(
                fontWeight: FontWeight.w700,
                height: 1.25,
              ),
            ),
            const SizedBox(height: 8),
          ],
          Text(
            text,
            style: textStyle,
            textAlign: textAlign,
            textDirection: textDirection,
          ),
        ],
      ),
    );
  }
}
