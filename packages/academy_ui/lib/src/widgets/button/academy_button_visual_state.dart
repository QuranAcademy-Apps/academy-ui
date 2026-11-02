import 'package:flutter/cupertino.dart';

import '../../theme/academy_colors.dart';

/// Shared visual state for primary and tinted actions. Pending retains the
/// active palette while preventing every activation channel.
@immutable
class AcademyButtonVisualState {
  AcademyButtonVisualState({
    required AcademyColors colors,
    required VoidCallback? onPressed,
    required bool pending,
    required bool tinted,
  }) : enabled = onPressed != null && !pending,
       disabled = onPressed == null && !pending,
       background = onPressed == null && !pending
           ? Color.lerp(colors.onSurface, colors.surface, .88)!
           : tinted
           ? colors.secondaryContainer
           : colors.actionFill,
       foreground = onPressed == null && !pending
           ? colors.onSurfaceVariant
           : tinted
           ? colors.secondary
           : colors.onActionFill,
       border = onPressed == null && !pending
           ? colors.outlineVariant
           : tinted
           ? colors.secondary.withValues(alpha: .24)
           : colors.actionFill;

  final bool enabled;
  final bool disabled;
  final Color background;
  final Color foreground;
  final Color border;
}
