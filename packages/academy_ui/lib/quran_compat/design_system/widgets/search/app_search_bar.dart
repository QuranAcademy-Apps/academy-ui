import 'dart:math' as math;

import 'package:academy_ui/academy_ui.dart' show AcademySymbols;
import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:flutter/foundation.dart';

import '../../../theme/app_colors.dart';
import '../../../theme/app_typography.dart';

class AppSearchBar extends StatelessWidget {
  const AppSearchBar({
    super.key,
    required this.placeholder,
    this.controller,
    this.focusNode,
    this.onChanged,
    this.onSubmitted,
    this.onClear,
    this.onTap,
    this.isLoading = false,
    this.autofocus = false,
    this.enabled = true,
    this.backgroundColor,
    this.iconColor,
    this.textColor,
    this.placeholderColor,
    this.height = 40,
    this.borderRadius = 10,
  });

  final String placeholder;

  /// Parent-owned. This widget never disposes the controller.
  final TextEditingController? controller;

  /// Parent-owned. This widget never disposes the focus node.
  final FocusNode? focusNode;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final VoidCallback? onClear;
  final VoidCallback? onTap;
  final bool isLoading;
  final bool autofocus;
  final bool enabled;
  final Color? backgroundColor;
  final Color? iconColor;
  final Color? textColor;
  final Color? placeholderColor;
  final double height;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    final colors = AppColorsProvider.maybeOf(context);
    final resolvedBackground =
        backgroundColor ??
        colors?.backgroundSecondary ??
        CupertinoColors.systemGrey6.resolveFrom(context);
    final resolvedText =
        textColor ??
        colors?.textPrimary ??
        CupertinoColors.label.resolveFrom(context);
    final resolvedSecondary =
        placeholderColor ??
        colors?.textSecondary ??
        CupertinoColors.secondaryLabel.resolveFrom(context);
    final resolvedIcon = iconColor ?? resolvedSecondary;
    final showClear = onClear != null && (controller?.text.isNotEmpty ?? false);
    final allowAndroidImeLanguageSwitch =
        defaultTargetPlatform == TargetPlatform.android;
    final effectiveHeight = math.max(height, _heightForTextScale(context));

    // The min-height must constrain the field itself (not a Stack wrapper) so
    // that when the slot is taller than the row's intrinsic height (e.g. inside
    // the 44pt chrome capsule) the row fills it and its children center
    // vertically, instead of the row being top-aligned as a loose Stack child.
    final Widget field = ConstrainedBox(
      constraints: BoxConstraints(minHeight: effectiveHeight),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: resolvedBackground,
          borderRadius: BorderRadius.circular(borderRadius),
        ),
        child: Row(
          children: [
            Padding(
              padding: const EdgeInsetsDirectional.only(start: 12),
              child: isLoading
                  ? CupertinoActivityIndicator(
                      radius: 8,
                      color: resolvedSecondary,
                    )
                  : Icon(AcademySymbols.search, color: resolvedIcon, size: 17),
            ),
            Expanded(
              child: CupertinoTextField(
                controller: controller,
                focusNode: focusNode,
                autofocus: autofocus,
                enabled: enabled && onTap == null,
                autocorrect: allowAndroidImeLanguageSwitch,
                enableSuggestions: allowAndroidImeLanguageSwitch,
                textCapitalization: TextCapitalization.none,
                textInputAction: TextInputAction.search,
                placeholder: placeholder,
                placeholderStyle: AppTypography.body.copyWith(
                  color: resolvedSecondary,
                ),
                style: AppTypography.body.copyWith(color: resolvedText),
                decoration: const BoxDecoration(),
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 10,
                ),
                onChanged: onChanged,
                onSubmitted: onSubmitted,
              ),
            ),
            if (showClear)
              CupertinoButton(
                padding: const EdgeInsetsDirectional.only(end: 16),
                minimumSize: const Size(28, 28),
                onPressed: onClear,
                child: Icon(
                  AcademySymbols.clear,
                  color: resolvedSecondary,
                  size: 20,
                ),
              ),
          ],
        ),
      ),
    );

    if (onTap == null) return field;

    return Stack(
      children: [
        field,
        Positioned.fill(
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: onTap,
          ),
        ),
      ],
    );
  }

  double _heightForTextScale(BuildContext context) {
    final scaledBodyHeight =
        MediaQuery.textScalerOf(context).scale(AppTypography.bodySize) * 1.25;
    return scaledBodyHeight + 20;
  }
}
