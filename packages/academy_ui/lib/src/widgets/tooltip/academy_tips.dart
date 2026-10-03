import '../../theme/academy_theme.dart';
import '../../foundation/localizations/academy_localizations.dart';

import 'dart:async';

import 'package:flutter/cupertino.dart';

import '../button/academy_button.dart';
import '../modal/academy_modal.dart';

class AcademyTip {
  const AcademyTip({
    required this.target,
    required this.title,
    required this.message,
  });
  final GlobalKey target;
  final String title, message;
}

/// Adapts Quran's targeted tips to a small route-owned sequence, without reader services.
Future<void> showAcademyTips(
  BuildContext context,
  List<AcademyTip> tips,
) async {
  for (var i = 0; i < tips.length; i++) {
    if (!context.mounted) return;
    final target = tips[i].target.currentContext;
    if (target == null) continue;
    await Scrollable.ensureVisible(
      target,
      duration: MediaQuery.disableAnimationsOf(context)
          ? Duration.zero
          : AcademyTokens.motion,
      alignment: .2,
    );
    if (!context.mounted) return;
    final next = await showAcademyModal<bool>(
      context,
      title: tips[i].title,
      builder: (context) => AcademyModalListView(
        padding: AcademyTheme.of(context).paddings.modalContent,
        children: [
          Text(tips[i].message),
          const SizedBox(height: AcademyTokens.inlineGap),
          Text('${i + 1} / ${tips.length}'),
          const SizedBox(height: 24),
          AcademyButton(
            label: i == tips.length - 1
                ? AcademyLocalizations.of(context).done
                : AcademyLocalizations.of(context).next,
            onPressed: () => closeAcademyModal(context, true),
          ),
          const SizedBox(height: AcademyTokens.inlineGap),
          AcademyTextButton(
            label: AcademyLocalizations.of(context).skip,
            onPressed: () => closeAcademyModal(context, false),
          ),
        ],
      ),
    );
    if (next != true) return;
  }
}
