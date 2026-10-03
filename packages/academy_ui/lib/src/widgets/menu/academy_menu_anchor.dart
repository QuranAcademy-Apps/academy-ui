import '../../theme/academy_theme.dart';

// Adapted from Quran app_menu_anchor.dart: haptics and modal overlay bounds.
import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:flutter/services.dart';

import '../modal/modal_sheet_detents.dart';

/// [CupertinoMenuAnchor] с единым тактильным откликом на открытии меню.
///
/// Все pull-down меню приложения проходят через эту обёртку, чтобы хаптик при
/// открытии был одинаковым везде (тот же [HapticFeedback.selectionClick], что и
/// у показа/скрытия баров ридера). Перехват — через нативный
/// [CupertinoMenuAnchor.onOpen]: он срабатывает один раз в начале открытия,
/// независимо от того, чем меню открыли и кто владеет [MenuController].
///
/// Все остальные параметры форвардятся в [CupertinoMenuAnchor] без изменений,
/// так что замена `CupertinoMenuAnchor(` → `AcademyMenuAnchor(` чисто механическая.
class AcademyMenuAnchor extends StatelessWidget {
  const AcademyMenuAnchor({
    super.key,
    required this.menuChildren,
    this.builder,
    this.child,
    this.controller,
    this.onOpen,
    this.onClose,
    this.onAnimationStatusChanged,
    this.constraints,
    this.constrainCrossAxis = false,
    this.consumeOutsideTaps = false,
    this.enableSwipe = true,
    this.enableLongPressToOpen = false,
    this.useRootOverlay,
    this.overlayPadding,
    this.constrainToModalSheetBounds = true,
    this.childFocusNode,
  });

  final List<Widget> menuChildren;
  final RawMenuAnchorChildBuilder? builder;
  final Widget? child;
  final MenuController? controller;
  final VoidCallback? onOpen;
  final VoidCallback? onClose;
  final CupertinoMenuAnimationStatusChangedCallback? onAnimationStatusChanged;
  final BoxConstraints? constraints;
  final bool constrainCrossAxis;
  final bool consumeOutsideTaps;
  final bool enableSwipe;
  final bool enableLongPressToOpen;

  /// When omitted, menus in modal sheets use the root overlay automatically.
  final bool? useRootOverlay;
  final EdgeInsetsGeometry? overlayPadding;
  final bool constrainToModalSheetBounds;
  final FocusNode? childFocusNode;

  @override
  Widget build(BuildContext context) {
    final effectiveUseRootOverlay =
        useRootOverlay ?? ModalSheetScrollInsets.isInModalSheet(context);
    final hiddenBottom = _modalSheetHiddenBottom(
      context,
      effectiveUseRootOverlay,
    );
    final effectiveConstraints = _effectiveConstraints(context, hiddenBottom);
    final effectiveOverlayPadding = _effectiveOverlayPadding(
      context,
      hiddenBottom,
    );
    return CupertinoMenuAnchor(
      controller: controller,
      onOpen: () {
        AcademyTheme.of(context).interaction.selectionClick();
        onOpen?.call();
      },
      onClose: onClose,
      onAnimationStatusChanged: onAnimationStatusChanged,
      constraints: effectiveConstraints,
      constrainCrossAxis: constrainCrossAxis,
      consumeOutsideTaps: consumeOutsideTaps,
      enableSwipe: enableSwipe,
      enableLongPressToOpen: enableLongPressToOpen,
      useRootOverlay: effectiveUseRootOverlay,
      overlayPadding: effectiveOverlayPadding,
      menuChildren: menuChildren,
      builder: builder,
      childFocusNode: childFocusNode,
      child: child,
    );
  }

  double _modalSheetHiddenBottom(BuildContext context, bool useRootOverlay) {
    if (!constrainToModalSheetBounds) return 0;
    if (useRootOverlay) return 0;
    if (!ModalSheetScrollInsets.isInModalSheet(context)) return 0;
    return ModalSheetScrollInsets.of(context);
  }

  EdgeInsetsGeometry _effectiveOverlayPadding(
    BuildContext context,
    double hiddenBottom,
  ) {
    final resolved =
        overlayPadding ?? AcademyTheme.of(context).paddings.menuOverlay;
    if (hiddenBottom <= 0) return resolved;

    final padding = resolved.resolve(Directionality.of(context));
    return padding.copyWith(bottom: padding.bottom + hiddenBottom);
  }

  BoxConstraints? _effectiveConstraints(
    BuildContext context,
    double hiddenBottom,
  ) {
    if (hiddenBottom <= 0) return constraints;

    final overlay = Overlay.maybeOf(context);
    final overlayBox = overlay?.context.findRenderObject() as RenderBox?;
    if (overlayBox == null || !overlayBox.hasSize) return constraints;

    final padding =
        (overlayPadding ?? AcademyTheme.of(context).paddings.menuOverlay)
            .resolve(Directionality.of(context));
    final visibleMaxHeight =
        overlayBox.size.height - hiddenBottom - padding.top - padding.bottom;
    if (visibleMaxHeight <= 0) return constraints;

    final current = constraints;
    if (current == null) {
      return BoxConstraints(maxHeight: visibleMaxHeight);
    }

    final maxHeight = current.maxHeight < visibleMaxHeight
        ? current.maxHeight
        : visibleMaxHeight;
    return current.copyWith(
      maxHeight: maxHeight,
      minHeight: current.minHeight > maxHeight ? maxHeight : current.minHeight,
    );
  }
}
