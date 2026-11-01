import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:flutter/foundation.dart';

import './app_colors.dart';

/// iOS reference uses SwiftUI system styles backed by San Francisco.
class AppTypography {
  static const String fontFamily = 'CupertinoSystemText';
  static const String displayFontFamily = 'CupertinoSystemDisplay';

  /// iOS switches the SF Pro optical variant at 20pt: "Text" below,
  /// "Display" at/above. Native does this automatically; Flutter does not
  /// when the family is set explicitly, so we pick it per size.
  static const double _displayBreakpoint = 20;

  static const double bodySize = 17;
  static const double subheadlineSize = 15;
  static const double footnoteSize = 13;
  static const double captionSize = 12;
  static const double mushafChromeTitleSize = 11;
  static const double mushafPageNumberSize = 13;
  static const double mushafArabicPageNumberSize = 15;
  static const double tabLabelSize = 10;
  static const double pageTitleSize = 22;

  static bool get _isApplePlatform =>
      defaultTargetPlatform == TargetPlatform.iOS ||
      defaultTargetPlatform == TargetPlatform.macOS;

  static String _familyForSize(double size) =>
      size >= _displayBreakpoint ? displayFontFamily : fontFamily;

  /// SF Pro applies optical tracking that varies non-linearly with size.
  /// Flutter renders raw advance widths, so iOS text looks looser than
  /// native. These are Apple's published SF Pro Text tracking anchors (pt),
  /// linearly interpolated. Apple platforms only — other platforms use a
  /// different system font (Roboto) with its own metrics.
  static double trackingForSize(double size) {
    if (!_isApplePlatform || size >= _displayBreakpoint) return 0;
    const anchors = <List<double>>[
      [10, 0.12],
      [13, -0.08],
      [15, -0.24],
      [17, -0.43],
    ];
    if (size <= anchors.first[0]) return anchors.first[1];
    if (size >= anchors.last[0]) return anchors.last[1];
    for (var i = 0; i < anchors.length - 1; i++) {
      final lo = anchors[i];
      final hi = anchors[i + 1];
      if (size >= lo[0] && size <= hi[0]) {
        final t = (size - lo[0]) / (hi[0] - lo[0]);
        return lo[1] + (hi[1] - lo[1]) * t;
      }
    }
    return 0;
  }

  static TextStyle _system(double size, FontWeight weight) => TextStyle(
    fontFamily: _familyForSize(size),
    fontSize: size,
    fontWeight: weight,
    letterSpacing: trackingForSize(size),
  );

  static final TextStyle body = _system(bodySize, FontWeight.w400);

  static final TextStyle bodySemibold = _system(bodySize, FontWeight.w600);

  static final TextStyle subheadline = _system(
    subheadlineSize,
    FontWeight.w400,
  );

  static final TextStyle footnote = _system(footnoteSize, FontWeight.w400);

  static final TextStyle sectionLabel = _system(captionSize, FontWeight.w400);

  static final TextStyle mushafChromeTitle = _system(
    mushafChromeTitleSize,
    FontWeight.w600,
  );

  static final TextStyle mushafPageNumber = _system(
    mushafPageNumberSize,
    FontWeight.w600,
  );

  static final TextStyle tabLabel = _system(tabLabelSize, FontWeight.w400);

  static final TextStyle navTitle = _system(bodySize, FontWeight.w600);

  static final TextStyle pageTitle = _system(pageTitleSize, FontWeight.w600);

  static TextStyle listTitle(Color color) => body.copyWith(color: color);

  static TextStyle listTitleSemibold(Color color) =>
      bodySemibold.copyWith(color: color);

  static TextStyle listSubtitle(Color color) =>
      subheadline.copyWith(color: color);

  static TextStyle listFootnote(Color color) => footnote.copyWith(color: color);

  static TextStyle section(Color color) => sectionLabel.copyWith(color: color);

  static CupertinoTextThemeData cupertinoTextTheme(AppColors colors) {
    return CupertinoTextThemeData(
      primaryColor: colors.textPrimary,
      textStyle: body.copyWith(color: colors.textPrimary),
      actionTextStyle: body.copyWith(color: colors.accent),
      tabLabelTextStyle: tabLabel.copyWith(color: colors.textSecondary),
      navTitleTextStyle: navTitle.copyWith(color: colors.textPrimary),
      pickerTextStyle: body.copyWith(color: colors.textPrimary),
      dateTimePickerTextStyle: body.copyWith(color: colors.textPrimary),
    );
  }
}
