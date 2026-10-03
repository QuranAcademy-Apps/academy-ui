import '../../foundation/localizations/academy_localizations.dart';
import '../icon/academy_sf_image.dart';
import 'chrome/academy_chrome.dart';
import 'chrome/academy_chrome_metrics.dart';
import '../../foundation/layout/academy_page_insets.dart';

import 'package:flutter/cupertino.dart';

import '../../theme/academy_theme.dart';

/// Adapted from Quran AppPageScaffold: opaque navigation + explicit safe area.
class AcademyPage extends StatelessWidget {
  const AcademyPage({
    super.key,
    required this.title,
    required this.child,
    this.trailing,
    this.titleWidget,
  });
  final String title;
  final Widget child;
  final Widget? trailing;
  final Widget? titleWidget;
  @override
  Widget build(BuildContext context) {
    final top = academyChromeTopOf(context);
    final barHeight = academyChromeHeightOf(context);
    return CupertinoPageScaffold(
      child: Stack(
        children: [
          Positioned.fill(
            child: Center(
              child: SizedBox(
                width: 430,
                child: AcademyPageInsets(
                  top: academyChromeContentTopOf(context),
                  child: child,
                ),
              ),
            ),
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: IgnorePointer(
              child: Container(
                height: top + barHeight + 16,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      AcademyTheme.of(context).scaffoldBackgroundColor,
                      AcademyTheme.of(context).scaffoldBackgroundColor
                          .withValues(alpha: 0),
                    ],
                    stops: [(top + barHeight) / (top + barHeight + 16), 1],
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            top: top,
            left: 0,
            right: 0,
            child: AcademyChromeBar(
              title: titleWidget == null ? title : null,
              middle: titleWidget,
              trailing: trailing,
              leading: Navigator.of(context).canPop()
                  ? AcademyChromeButton(
                      icon: AcademySymbols.back,
                      label: AcademyLocalizations.of(context).back,
                      onPressed: () => Navigator.maybePop(context),
                    )
                  : null,
            ),
          ),
        ],
      ),
    );
  }
}
