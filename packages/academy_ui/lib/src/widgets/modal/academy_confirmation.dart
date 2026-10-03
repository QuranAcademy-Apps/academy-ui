import '../../foundation/localizations/academy_localizations.dart';

import 'package:flutter/cupertino.dart';

import 'academy_modal.dart';

import '../../theme/academy_theme.dart';

import '../button/academy_button.dart';
import '../navigation/chrome/academy_chrome_metrics.dart';

Future<void> showAcademySheet(
  BuildContext context, {
  required String title,
  required Widget child,
  double? height,
  AcademyModalHeaderBehavior headerBehavior = AcademyModalHeaderBehavior.fade,
  double headerFadeExtent = 24,
}) => showAcademyModal<void>(
  context,
  title: title,
  autoHeight: height,
  headerBehavior: headerBehavior,
  headerFadeExtent: headerFadeExtent,
  builder: (context) => AcademyModalScrollView(
    padding: AcademyTheme.of(context).paddings.modal,
    child: child,
  ),
);

Future<bool?> showAcademyConfirmation(
  BuildContext context, {
  required String title,
  required String message,
  String? confirmLabel,
  String? cancelLabel,
}) {
  final theme = AcademyTheme.of(context);
  final padding = theme.paddings.feedbackCard;
  final width = MediaQuery.sizeOf(context).width - padding.horizontal;
  double textHeight(String text, TextStyle style, double horizontalPadding) {
    final painter = TextPainter(
      text: TextSpan(text: text, style: style),
      textDirection: Directionality.of(context),
      textScaler: MediaQuery.textScalerOf(context),
    )..layout(maxWidth: (width - horizontalPadding).clamp(1, double.infinity));
    final height = painter.height;
    painter.dispose();
    return height;
  }

  final strings = AcademyLocalizations.of(context);
  final confirm = confirmLabel ?? strings.confirm;
  final cancel = cancelLabel ?? strings.back;
  final view = View.of(context);
  final height =
      academyChromeHeightOf(context) +
      theme.paddings.chromeBottom.vertical +
      padding.vertical +
      textHeight(message, theme.textTheme.bodyLarge, 0) +
      24 +
      (textHeight(
                confirm,
                theme.textTheme.bodyLarge,
                theme.paddings.button.horizontal,
              ) +
              theme.paddings.button.vertical)
          .clamp(44, double.infinity) +
      AcademyTokens.inlineGap +
      (textHeight(
                cancel,
                theme.textTheme.bodyLarge,
                theme.paddings.textButton.horizontal,
              ) +
              theme.paddings.textButton.vertical)
          .clamp(44, double.infinity) +
      view.padding.bottom / view.devicePixelRatio;
  return showAcademyModal<bool>(
    context,
    title: title,
    autoHeight: height,
    expandOnFocus: false,
    builder: (context) => AcademyModalListView(
      padding: AcademyTheme.of(context).paddings.feedbackCard,
      children: [
        Text(message),
        const SizedBox(height: 24),
        AcademyButton(
          label: confirm,
          onPressed: () => closeAcademyModal(context, true),
        ),
        const SizedBox(height: AcademyTokens.inlineGap),
        AcademyTextButton(
          label: cancel,
          onPressed: () => closeAcademyModal(context, false),
        ),
      ],
    ),
  );
}
