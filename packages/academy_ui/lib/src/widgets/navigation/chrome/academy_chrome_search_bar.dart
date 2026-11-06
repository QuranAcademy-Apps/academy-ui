import 'package:flutter/cupertino.dart';

import '../../../foundation/localizations/academy_localizations.dart';
import '../../../theme/academy_theme.dart';
import '../../search/academy_search_bar.dart';
import 'academy_chrome.dart';
import 'academy_chrome_metrics.dart';

/// Search field on a floating chrome capsule, with an optional close button.
///
/// It has no shadow because it usually sits directly over scrolling content.
class AcademyChromeSearchBar extends StatefulWidget {
  const AcademyChromeSearchBar({
    super.key,
    required this.placeholder,
    this.controller,
    this.focusNode,
    this.onChanged,
    this.onSubmitted,
    this.onClear,
    this.onCancel,
    this.isLoading = false,
    this.autofocus = false,
    this.height = academyChromeBarHeight,
    this.fieldWrapper,
  });

  final String placeholder;
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final VoidCallback? onClear;

  /// Shows a close button after the field that dismisses search.
  final VoidCallback? onCancel;
  final bool isLoading;
  final bool autofocus;
  final double height;

  /// Wraps the inner field, for example with a sheet detent helper.
  final Widget Function(BuildContext context, Widget field)? fieldWrapper;

  @override
  State<AcademyChromeSearchBar> createState() => _AcademyChromeSearchBarState();
}

class _AcademyChromeSearchBarState extends State<AcademyChromeSearchBar> {
  TextEditingController? _owned;

  TextEditingController get _controller =>
      widget.controller ?? (_owned ??= TextEditingController());

  @override
  void dispose() {
    _owned?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = AcademyTheme.of(context);
    Widget inner = AcademySearchBar(
      placeholder: widget.placeholder,
      controller: _controller,
      focusNode: widget.focusNode,
      autofocus: widget.autofocus,
      loading: widget.isLoading,
      chrome: false,
      clearable: widget.onClear != null,
      onClear: widget.onClear,
      backgroundColor: const Color(0x00000000),
      cornerRadius: theme.radii.chrome,
      onChanged: widget.onChanged,
      onSubmitted: widget.onSubmitted,
    );
    if (widget.fieldWrapper != null) {
      inner = widget.fieldWrapper!(context, inner);
    }
    final field = SizedBox(
      height: widget.height,
      child: AcademyChrome(showShadow: false, child: inner),
    );
    if (widget.onCancel == null) return field;
    return Row(
      children: [
        Expanded(child: field),
        const SizedBox(width: 8),
        AcademyChromeButton(
          icon: theme.icons.close,
          label: AcademyLocalizations.of(context).close,
          onPressed: widget.onCancel,
        ),
      ],
    );
  }
}
