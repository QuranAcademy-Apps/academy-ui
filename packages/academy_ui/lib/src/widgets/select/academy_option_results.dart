import 'dart:async';

import 'package:flutter/cupertino.dart';

import '../../foundation/interaction/academy_tappable.dart';
import '../../foundation/localizations/academy_localizations.dart';
import '../../theme/academy_theme.dart';
import '../icon/academy_sf_image.dart';
import 'academy_select_option.dart';

typedef AcademyOptionLoader<T extends Object> =
    FutureOr<List<AcademySelectOption<T>>> Function(String query);

/// Async request sequencing shared by selection and free-text suggestions.
/// A stale completion never replaces a newer query or updates a disposed view.
class AcademyOptionResults<T extends Object> extends StatefulWidget {
  const AcademyOptionResults({
    super.key,
    required this.query,
    required this.options,
    required this.onSelected,
    this.loader,
    this.selected = const {},
    this.debounce = const Duration(milliseconds: 200),
    this.emptyMessage,
    this.emptyHint,
  });
  final String query;
  final List<AcademySelectOption<T>> options;
  final AcademyOptionLoader<T>? loader;
  final Set<T> selected;
  final ValueChanged<AcademySelectOption<T>> onSelected;
  final Duration debounce;
  final String? emptyMessage, emptyHint;
  @override
  State<AcademyOptionResults<T>> createState() =>
      _AcademyOptionResultsState<T>();
}

class _AcademyOptionResultsState<T extends Object>
    extends State<AcademyOptionResults<T>> {
  List<AcademySelectOption<T>> _options = [];
  Timer? _timer;
  int _request = 0;
  bool _loading = false, _error = false;
  @override
  void initState() {
    super.initState();
    _load(immediate: true);
  }

  @override
  void didUpdateWidget(covariant AcademyOptionResults<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.query != widget.query ||
        oldWidget.loader != widget.loader ||
        oldWidget.options != widget.options) {
      _load();
    }
  }

  void _load({bool immediate = false}) {
    _timer?.cancel();
    final request = ++_request;
    _error = false;
    final loader = widget.loader;
    if (loader == null) {
      final query = widget.query.trim().toLowerCase();
      _options = widget.options
          .where(
            (o) =>
                o.label.toLowerCase().contains(query) ||
                (o.subtitle?.toLowerCase().contains(query) ?? false),
          )
          .toList();
      _loading = false;
      return;
    }
    _loading = true;
    _options = [];
    final query = widget.query;
    Future<void> run() async {
      try {
        final options = await loader(query);
        if (!mounted || request != _request) return;
        setState(() {
          _options = options;
          _loading = false;
        });
      } catch (_) {
        if (!mounted || request != _request) return;
        setState(() {
          _error = true;
          _loading = false;
        });
      }
    }

    _timer = Timer(immediate ? Duration.zero : widget.debounce, run);
  }

  @override
  void dispose() {
    ++_request;
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final strings = AcademyLocalizations.of(context);
    final theme = AcademyTheme.of(context);
    if (_loading) {
      return Padding(
        padding: theme.paddings.field,
        child: Semantics(
          label: strings.loading,
          liveRegion: true,
          child: const CupertinoActivityIndicator(),
        ),
      );
    }
    if (_error) {
      return Padding(
        padding: theme.paddings.field,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(strings.loadError, style: theme.textTheme.bodyLarge),
            CupertinoButton(
              onPressed: () => setState(() => _load(immediate: true)),
              child: Text(
                strings.retry,
                style: theme.textTheme.bodyLarge.copyWith(
                  color: theme.colorScheme.primary,
                ),
              ),
            ),
          ],
        ),
      );
    }
    if (_options.isEmpty) {
      return Padding(
        padding: theme.paddings.field,
        child: Semantics(
          liveRegion: true,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                widget.emptyMessage ?? strings.noResults,
                style: theme.textTheme.bodyMedium,
              ),
              if (widget.emptyHint != null) ...[
                const SizedBox(height: 4),
                Text(
                  widget.emptyHint!,
                  style: theme.textTheme.bodySmall.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ],
          ),
        ),
      );
    }
    return FocusTraversalGroup(
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 4),
        shrinkWrap: true,
        itemCount: _options.length,
        itemBuilder: (context, index) {
          final option = _options[index];
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (option.group != null &&
                  (index == 0 || _options[index - 1].group != option.group))
                Padding(
                  padding: theme.paddings.tableHeader,
                  child: Text(
                    option.group!,
                    style: theme.textTheme.bodySmall.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              AcademyTappable(
                selected: widget.selected.contains(option.value),
                onPressed: option.enabled
                    ? () => widget.onSelected(option)
                    : null,
                builder: (context, states) => DecoratedBox(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(theme.radii.tableBadge),
                    color:
                        states.contains(WidgetState.hovered) ||
                            states.contains(WidgetState.pressed)
                        ? theme.colorScheme.surfaceContainerHighest
                        : const Color(0x00000000),
                  ),
                  child: Padding(
                    padding: theme.paddings.tableRow,
                    child: Row(
                      children: [
                        if (option.leading != null) ...[
                          option.leading!,
                          const SizedBox(width: AcademyTokens.inlineGap),
                        ],
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                option.label,
                                style: theme.textTheme.bodyLarge.copyWith(
                                  color: option.enabled
                                      ? theme.colorScheme.onSurface
                                      : theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                              if (option.subtitle != null)
                                Text(
                                  option.subtitle!,
                                  style: theme.textTheme.bodyMedium.copyWith(
                                    color: theme.colorScheme.onSurfaceVariant,
                                  ),
                                ),
                            ],
                          ),
                        ),
                        if (widget.selected.contains(option.value)) ...[
                          const SizedBox(width: 8),
                          AcademySfIcon(
                            AcademySymbols.checkmark,
                            size: 16,
                            color: theme.colorScheme.primary,
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
              if (index < _options.length - 1 &&
                  _options[index + 1].group == option.group)
                Padding(
                  padding: const EdgeInsetsDirectional.only(start: 16),
                  child: ColoredBox(
                    color: theme.colorScheme.outlineVariant,
                    child: SizedBox(
                      height: 1 / MediaQuery.devicePixelRatioOf(context),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
