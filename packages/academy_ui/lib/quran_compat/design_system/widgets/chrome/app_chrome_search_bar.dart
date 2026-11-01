import 'package:cupertino_ui/cupertino_ui.dart';

import '../../../core/widgets/gradient_control_chrome.dart';
import '../search/app_search_bar.dart';
import 'app_chrome_bar.dart';
import '../../../l10n/quran_compat_strings.dart';

/// Search field styled as a floating chrome capsule (gradient fill + stroke),
/// the chrome equivalent of [AppSearchBar]. Hosts an [AppSearchBar] with a
/// transparent fill inside a [GradientControlChrome] capsule and an optional
/// trailing Cancel button.
///
/// Shadow is disabled because the bar typically sits directly over scrolling
/// content; pair it with an [AppChromeFadeMaterial] for the edge fade.
class AppChromeSearchBar extends StatelessWidget {
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
  Widget build(BuildContext context) {
    Widget inner = AppSearchBar(
      placeholder: placeholder,
      controller: controller,
      focusNode: focusNode,
      autofocus: autofocus,
      isLoading: isLoading,
      backgroundColor: const Color(0x00000000),
      height: height,
      borderRadius: GradientControlChrome.capsuleRadius,
      onChanged: onChanged,
      onSubmitted: onSubmitted,
      onClear: onClear,
    );
    if (fieldWrapper != null) {
      inner = fieldWrapper!(context, inner);
    }
    final field = SizedBox(
      height: height,
      child: GradientControlChrome(
        radius: GradientControlChrome.capsuleRadius,
        enableShadow: false,
        child: inner,
      ),
    );

    if (onCancel == null) {
      return field;
    }

    return Row(
      children: [
        Expanded(child: field),
        const SizedBox(width: 8),
        AppChromeBarIconButton(
          systemName: 'xmark',
          semanticLabel: QuranCompatStrings.of(context).close,
          onPressed: onCancel,
        ),
      ],
    );
  }
}
