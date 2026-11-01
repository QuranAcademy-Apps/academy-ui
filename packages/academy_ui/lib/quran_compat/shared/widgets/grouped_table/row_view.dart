part of '../grouped_table.dart';

class _GroupedTableRowView extends StatelessWidget {
  const _GroupedTableRowView({required this.row});

  final GroupedTableRow row;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final titleStyle =
        row.titleStyle ?? AppTypography.listTitle(colors.textPrimary);
    final subtitleStyle =
        row.subtitleStyle ?? AppTypography.listSubtitle(colors.textSecondary);
    final trailingTitleStyle =
        row.trailingTitleStyle ?? AppTypography.listTitle(colors.iconSecondary);
    final accessory = _buildAccessory();
    final hasDragHandle = row.accessory is _AppAccessoryDragHandle;
    final canTap = row.enabled && row.onTap != null;
    final canLongPress = row.enabled && row.onLongPress != null;
    final defaultTitle = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(child: Text(row.title, style: titleStyle)),
            if (row.titleTrailing != null) ...[
              const SizedBox(width: 6),
              row.titleTrailing!,
            ],
          ],
        ),
        if (row.subtitleWidget != null)
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: row.subtitleWidget!,
          )
        else if (row.subtitle != null)
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Text(row.subtitle!, style: subtitleStyle),
          ),
      ],
    );
    final title = Padding(
      padding: EdgeInsets.symmetric(vertical: row.verticalPadding),
      child: row.titleWidget ?? defaultTitle,
    );
    final rowContent = Row(
      crossAxisAlignment: hasDragHandle
          ? CrossAxisAlignment.stretch
          : CrossAxisAlignment.center,
      children: [
        if (row.leading != null) ...[
          row.leading!,
          SizedBox(width: row.leadingGap),
        ],
        Expanded(child: title),
        if (row.trailingTitle != null) ...[
          const SizedBox(width: 12),
          Padding(
            padding: EdgeInsets.symmetric(vertical: row.verticalPadding),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 170),
              child: AppGroupedTableTrailingText(
                text: row.trailingTitle!,
                style: trailingTitleStyle,
              ),
            ),
          ),
        ],
        if (accessory != null) ...[const SizedBox(width: 8), accessory],
      ],
    );

    Widget content = ConstrainedBox(
      constraints: BoxConstraints(minHeight: row.minHeight),
      child: Padding(
        padding: EdgeInsetsDirectional.only(
          start: row.horizontalPadding,
          end: hasDragHandle ? 0 : row.horizontalPadding,
        ),
        child: hasDragHandle ? IntrinsicHeight(child: rowContent) : rowContent,
      ),
    );

    if (!row.enabled) {
      content = Opacity(opacity: 0.45, child: content);
    }

    if (canTap || canLongPress) {
      content = PressScale(
        onTap: row.onTap,
        onLongPress: row.onLongPress,
        pressedScale: 0.96,
        pressDuration: const Duration(milliseconds: 210),
        releaseDuration: const Duration(milliseconds: 210),
        pressDelay: const Duration(milliseconds: 120),
        child: content,
      );
    }

    if (row.excludeFromSemantics) {
      content = ExcludeSemantics(child: content);
    } else {
      content = Semantics(
        container: true,
        button: canTap || canLongPress,
        enabled: row.enabled,
        label: row.semanticLabel,
        hint: row.semanticHint,
        excludeSemantics: row.semanticLabel != null,
        child: MergeSemantics(child: content),
      );
    }

    return row.wrapper?.call(context, content) ?? content;
  }

  Widget? _buildAccessory() {
    switch (row.accessory) {
      case _AppAccessoryNone():
        return null;
      case _AppAccessorySelected(:final isSelected):
        return AppGroupedTableSelectedIndicator(isSelected: isSelected);
      case _AppAccessoryDisclosure(:final turns):
        return AppGroupedTableDisclosureIndicator(turns: turns ?? 0);
      case _AppAccessoryTrailingText(:final text):
        return AppGroupedTableTrailingTextAccessory(text: text);
      case _AppAccessoryTrailingTextDisclosure(:final text):
        return AppGroupedTableTrailingTextDisclosure(text: text);
      case _AppAccessoryToggle(:final value, :final onChanged):
        return AppSwitch(
          value: value,
          onChanged: row.enabled ? onChanged : null,
        );
      case _AppAccessoryToggleWithButton(
        :final value,
        :final onChanged,
        :final onButtonPressed,
      ):
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppAccessoryButton(
              onPressed: row.enabled ? onButtonPressed : null,
              size: const Size(36, 36),
              child: const AppSfIcon(AcademySymbols.more, fontSize: 17),
            ),
            AppSwitch(value: value, onChanged: row.enabled ? onChanged : null),
          ],
        );
      case _AppAccessoryMenu(
        :final title,
        :final itemBuilder,
        :final useRootOverlay,
      ):
        return AppMenu(
          title: title,
          itemBuilder: itemBuilder,
          enabled: row.enabled,
          useRootOverlay: useRootOverlay,
        );
      case _AppAccessorySegmented(:final child):
        return child;
      case _AppAccessoryButton(
        :final child,
        :final onPressed,
        :final size,
        :final semanticLabel,
        :final semanticHint,
      ):
        return AppAccessoryButton(
          onPressed: row.enabled ? onPressed : null,
          size: size,
          semanticLabel: semanticLabel,
          semanticHint: semanticHint,
          child: child,
        );
      case _AppAccessoryStepper(:final onDecrease, :final onIncrease):
        return AppStepper(
          onDecrease: row.enabled ? onDecrease : null,
          onIncrease: row.enabled ? onIncrease : null,
        );
      case _AppAccessoryDragHandle():
        return const AppDragHandle();
      case _AppAccessoryCustom(:final child):
        return child;
    }
  }
}
