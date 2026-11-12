import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:flutter/foundation.dart';

enum AcademyTextRole {
  bodyLarge,
  bodyRow,
  bodyStrong,
  bodyDetail,
  caption,
  footnote,
  labelMedium,
  actionTitle,
  bodyMedium,
  bodySmall,
  sectionLabel,
  sectionHeading,
  labelLarge,
  titleSmall,
  titleMedium,
  titleLarge,
  headlineMedium,
  displaySmall,
  tableBadge,
  status,
  feedbackTitle,
  segmentLabel,
  toast,
  tabLabel,
  compactTabLabel,

  /// Floating label of a field; default: [bodySmall] at 12pt.
  fieldLabel,

  /// Help and error below a field; default: [bodySmall] at 12pt.
  fieldMessage,

  /// Text-only tab; default: [tabLabel] at 14pt semibold.
  tabText,

  /// Label of the primary (call-to-action) [AcademyButton].
  buttonLabel,
}

/// Font families and role-specific styles shared by every component.
/// Client fonts must be declared in the host application's pubspec.
@immutable
class AcademyTypographySettings {
  const AcademyTypographySettings({
    this.fontFamily = 'CupertinoSystemText',
    this.displayFontFamily = 'CupertinoSystemDisplay',
    this.fontPackage,
    this.styles = const {},
    this.tracking,
  });
  final String fontFamily, displayFontFamily;

  /// Replaces the built-in system-font tracking curve for every role (including
  /// the large headline roles). Receives the resolved font size. Applies only
  /// to the system font families; custom families always use zero tracking.
  final double Function(double size)? tracking;
  final String? fontPackage;

  /// Treat this map as immutable. Use [withStyle] to update a role.
  final Map<AcademyTextRole, TextStyle> styles;
  AcademyTypographySettings copyWith({
    String? fontFamily,
    String? displayFontFamily,
    String? fontPackage,
    bool clearFontPackage = false,
    Map<AcademyTextRole, TextStyle>? styles,
    double Function(double size)? tracking,
  }) => AcademyTypographySettings(
    fontFamily: fontFamily ?? this.fontFamily,
    displayFontFamily: displayFontFamily ?? this.displayFontFamily,
    fontPackage: clearFontPackage ? null : fontPackage ?? this.fontPackage,
    styles: Map.unmodifiable(styles ?? this.styles),
    tracking: tracking ?? this.tracking,
  );
  AcademyTypographySettings withStyle(AcademyTextRole role, TextStyle style) =>
      copyWith(styles: {...styles, role: style});
}

class AcademyTypography {
  const AcademyTypography(
    this.color, {
    this.settings = const AcademyTypographySettings(),
  });
  final Color color;
  final AcademyTypographySettings settings;
  static double trackingForSize(double size) {
    if (defaultTargetPlatform != TargetPlatform.iOS &&
            defaultTargetPlatform != TargetPlatform.macOS ||
        size >= 20) {
      return 0;
    }
    const anchors = <List<double>>[
      [10, .12],
      [11, .06],
      [12, 0],
      [13, -.08],
      [14, -.15],
      [15, -.23],
      [16, -.31],
      [17, -.43],
      [18, -.44],
      [19, -.45],
    ];
    if (size <= 10) return .12;
    if (size >= 19) return -.45;
    for (var i = 0; i < anchors.length - 1; i++) {
      final lo = anchors[i], hi = anchors[i + 1];
      if (size >= lo[0] && size <= hi[0]) {
        return lo[1] + (hi[1] - lo[1]) * (size - lo[0]) / (hi[0] - lo[0]);
      }
    }
    return 0;
  }

  TextStyle style(AcademyTextRole role) {
    final derived = switch (role) {
      AcademyTextRole.fieldLabel => style(
        AcademyTextRole.bodySmall,
      ).copyWith(fontSize: 12, height: 1.2),
      AcademyTextRole.fieldMessage => style(
        AcademyTextRole.bodySmall,
      ).copyWith(fontSize: 12),
      AcademyTextRole.tabText => style(
        AcademyTextRole.tabLabel,
      ).copyWith(fontSize: 14, fontWeight: FontWeight.w600, height: 1),
      _ => null,
    };
    if (derived != null) return derived.merge(settings.styles[role]);
    final (size, weight) = switch (role) {
      AcademyTextRole.bodyRow => (17.0, FontWeight.w400),
      AcademyTextRole.bodyStrong => (17.0, FontWeight.w600),
      AcademyTextRole.bodyDetail => (15.0, FontWeight.w400),
      AcademyTextRole.caption => (12.0, FontWeight.w400),
      AcademyTextRole.footnote => (13.0, FontWeight.w400),
      AcademyTextRole.labelMedium => (15.0, FontWeight.w600),
      AcademyTextRole.actionTitle => (16.0, FontWeight.w600),
      AcademyTextRole.bodyLarge => (17.0, FontWeight.w400),
      AcademyTextRole.bodyMedium => (15.0, FontWeight.w400),
      AcademyTextRole.bodySmall => (13.0, FontWeight.w400),
      AcademyTextRole.sectionLabel => (12.0, FontWeight.w400),
      AcademyTextRole.sectionHeading => (20.0, FontWeight.w700),
      AcademyTextRole.labelLarge => (17.0, FontWeight.w600),
      AcademyTextRole.titleSmall => (17.0, FontWeight.w600),
      AcademyTextRole.titleMedium => (17.0, FontWeight.w600),
      AcademyTextRole.titleLarge => (22.0, FontWeight.w600),
      AcademyTextRole.headlineMedium => (28.0, FontWeight.w700),
      AcademyTextRole.displaySmall => (32.0, FontWeight.w700),
      AcademyTextRole.tableBadge => (12.0, FontWeight.w500),
      AcademyTextRole.status => (13.0, FontWeight.w600),
      AcademyTextRole.feedbackTitle => (20.0, FontWeight.w700),
      AcademyTextRole.segmentLabel => (13.0, FontWeight.w600),
      AcademyTextRole.toast => (15.0, FontWeight.w600),
      AcademyTextRole.tabLabel => (11.0, FontWeight.w400),
      AcademyTextRole.compactTabLabel => (10.0, FontWeight.w600),
      AcademyTextRole.buttonLabel => (17.0, FontWeight.w600),
      AcademyTextRole.fieldLabel ||
      AcademyTextRole.fieldMessage ||
      AcademyTextRole.tabText => (12.0, FontWeight.w400),
    };
    final custom = settings.styles[role];
    final resolvedSize = custom?.fontSize ?? size;
    final system =
        settings.fontFamily == 'CupertinoSystemText' &&
        settings.displayFontFamily == 'CupertinoSystemDisplay';
    return TextStyle(
      inherit: false,
      fontFamily: resolvedSize >= 20
          ? settings.displayFontFamily
          : settings.fontFamily,
      package: settings.fontPackage,
      fontSize: size,
      fontWeight: weight,
      letterSpacing: !system
          ? 0
          : settings.tracking?.call(resolvedSize) ??
                (role == AcademyTextRole.headlineMedium ||
                        role == AcademyTextRole.displaySmall
                    ? -.6
                    : trackingForSize(resolvedSize)),
      height: switch (role) {
        AcademyTextRole.bodyRow || AcademyTextRole.bodyStrong => 22 / 17,
        AcademyTextRole.bodyDetail || AcademyTextRole.labelMedium => 20 / 15,
        AcademyTextRole.caption => 16 / 12,
        AcademyTextRole.footnote => 18 / 13,
        AcademyTextRole.actionTitle => 21 / 16,
        AcademyTextRole.sectionHeading => 25 / 20,
        _ => null,
      },
      color: color,
    ).merge(custom);
  }

  TextStyle get bodyRow => style(AcademyTextRole.bodyRow);
  TextStyle get bodyStrong => style(AcademyTextRole.bodyStrong);
  TextStyle get bodyDetail => style(AcademyTextRole.bodyDetail);
  TextStyle get caption => style(AcademyTextRole.caption);
  TextStyle get footnote => style(AcademyTextRole.footnote);
  TextStyle get labelMedium => style(AcademyTextRole.labelMedium);
  TextStyle get actionTitle => style(AcademyTextRole.actionTitle);
  TextStyle get bodyLarge => style(AcademyTextRole.bodyLarge);
  TextStyle get bodyMedium => style(AcademyTextRole.bodyMedium);
  TextStyle get bodySmall => style(AcademyTextRole.bodySmall);
  TextStyle get sectionLabel => style(AcademyTextRole.sectionLabel);
  TextStyle get sectionHeading => style(AcademyTextRole.sectionHeading);
  TextStyle get labelLarge => style(AcademyTextRole.labelLarge);
  TextStyle get titleSmall => style(AcademyTextRole.titleSmall);
  TextStyle get titleMedium => style(AcademyTextRole.titleMedium);
  TextStyle get titleLarge => style(AcademyTextRole.titleLarge);
  TextStyle get headlineMedium => style(AcademyTextRole.headlineMedium);
  TextStyle get displaySmall => style(AcademyTextRole.displaySmall);
  TextStyle get tableBadge => style(AcademyTextRole.tableBadge);
  TextStyle get status => style(AcademyTextRole.status);
  TextStyle get feedbackTitle => style(AcademyTextRole.feedbackTitle);
  TextStyle get segmentLabel => style(AcademyTextRole.segmentLabel);
  TextStyle get toast => style(AcademyTextRole.toast);
  TextStyle get fieldLabel => style(AcademyTextRole.fieldLabel);
  TextStyle get fieldMessage => style(AcademyTextRole.fieldMessage);
  TextStyle get tabText => style(AcademyTextRole.tabText);
  TextStyle get tabLabel => style(AcademyTextRole.tabLabel);
  TextStyle get compactTabLabel => style(AcademyTextRole.compactTabLabel);

  /// Follows [labelLarge] (including its client override) unless the client
  /// styles [AcademyTextRole.buttonLabel] itself.
  TextStyle get buttonLabel =>
      settings.styles.containsKey(AcademyTextRole.buttonLabel)
      ? style(AcademyTextRole.buttonLabel)
      : labelLarge;
}
