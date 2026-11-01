import 'package:cupertino_ui/cupertino_ui.dart';

import 'package:academy_ui/academy_ui.dart' show AcademySearchBar;

import '../../../core/widgets/gradient_control_chrome.dart';
import 'app_chrome_bar.dart';
import '../../../l10n/quran_compat_strings.dart';

/// Search field styled as a floating chrome capsule (gradient fill + stroke),
/// hosting an [AcademySearchBar] with a
/// transparent fill inside a [GradientControlChrome] capsule and an optional
/// trailing Cancel button.
///
/// Shadow is disabled because the bar typically sits directly over scrolling
/// content; pair it with an [AppChromeFadeMaterial] for the edge fade.
class AppChromeSearchBar extends StatefulWidget {
  const AppChromeSearchBar({
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
    this.height = kAppChromeBarHeight,
    this.fieldWrapper,
  });

  final String placeholder;
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final VoidCallback? onClear;

  /// When provided, a trailing circular gradient `xmark`
  /// [AppChromeBarIconButton] is shown after the field to dismiss search.
  final VoidCallback? onCancel;
  final bool isLoading;
  final bool autofocus;
  final double height;

  /// Lets a host wrap the inner [AppSearchBar] (e.g. with `ModalDetentFocus`
  /// inside a snapping sheet) without leaking that concern here.
  final Widget Function(BuildContext context, Widget field)? fieldWrapper;

  @override
  State<AppChromeSearchBar> createState() => _AppChromeSearchBarState();
}

class _AppChromeSearchBarState extends State<AppChromeSearchBar> {
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
    Widget inner = AcademySearchBar(
      placeholder: widget.placeholder,
      controller: _controller,
      focusNode: widget.focusNode,
      autofocus: widget.autofocus,
      loading: widget.isLoading,
      chrome: false,
      clearable: true,
      backgroundColor: const Color(0x00000000),
      cornerRadius: GradientControlChrome.capsuleRadius,
      onChanged: widget.onChanged,
      onSubmitted: widget.onSubmitted,
    );
    if (widget.fieldWrapper != null) {
      inner = widget.fieldWrapper!(context, inner);
    }
    final field = SizedBox(
      height: widget.height,
      child: GradientControlChrome(
        radius: GradientControlChrome.capsuleRadius,
        enableShadow: false,
        child: inner,
      ),
    );

    if (widget.onCancel == null) {
      return field;
    }

    return Row(
      children: [
        Expanded(child: field),
        const SizedBox(width: 8),
        AppChromeBarIconButton(
          systemName: 'xmark',
          semanticLabel: QuranCompatStrings.of(context).close,
          onPressed: widget.onCancel,
        ),
      ],
    );
  }
}
