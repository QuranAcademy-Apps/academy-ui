import 'package:flutter/cupertino.dart';

import '../../theme/academy_theme.dart';
import '../icon/academy_sf_image.dart';
import 'academy_row.dart';

/// Metadata row. readOnly denotes a locked value and suppresses editing.
class AcademyValueRow extends StatelessWidget {
  const AcademyValueRow({
    super.key,
    required this.label,
    required this.value,
    this.subtitle,
    this.readOnly = false,
    this.onPressed,
    this.enabled = true,
  });
  final String label, value;
  final String? subtitle;
  final bool readOnly, enabled;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final theme = AcademyTheme.of(context);
    final callback = readOnly || !enabled ? null : onPressed;
    return Semantics(
      label: label,
      value: [value, ?subtitle].join(', '),
      readOnly: readOnly,
      button: callback != null,
      enabled: enabled,
      onTap: callback,
      excludeSemantics: true,
      child: AcademyRow(
        title: label,
        subtitle: subtitle,
        onPressed: callback,
        enabled: enabled,
        trailing: const SizedBox.shrink(),
        titleWidget: LayoutBuilder(
          builder: (context, constraints) {
            final labelText = Text(label, style: theme.textTheme.bodyLarge);
            final valueText = Text(
              value,
              textAlign: TextAlign.end,
              style: theme.textTheme.bodyLarge.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            );
            final valueContent = Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (readOnly) ...[
                  AcademySfIcon(
                    AcademySymbols.lock,
                    size: AcademyTokens.tableIconExtent / 2,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: AcademyTokens.labelGap),
                ],
                Flexible(child: valueText),
              ],
            );
            if (MediaQuery.textScalerOf(context).scale(1) >=
                    AcademyTokens.adaptiveTextScale ||
                constraints.maxWidth < AcademyTokens.metadataHorizontalWidth) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  labelText,
                  const SizedBox(height: AcademyTokens.labelGap),
                  valueContent,
                ],
              );
            }
            return Row(
              children: [
                ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: constraints.maxWidth * .5,
                  ),
                  child: labelText,
                ),
                const SizedBox(width: AcademyTokens.inlineGap),
                Expanded(child: valueContent),
              ],
            );
          },
        ),
      ),
    );
  }
}
