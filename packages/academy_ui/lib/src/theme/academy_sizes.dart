import 'package:flutter/foundation.dart';

/// Component sizes a client can replace through its theme. An explicit widget
/// parameter takes precedence. Touch targets stay at least 44pt: see
/// [AcademyTokens.target].
@immutable
class AcademySizes {
  const AcademySizes({
    this.buttonHeight = 52.0,
    this.fieldHeight = 48.0,
    this.rowHeight = 52.0,
    this.rowIcon = 22.0,
    this.rowIconExtent = 30.0,
    this.rowTileIcon = 17.0,
    this.rowChevron = 16.0,
    this.chevron = 14.0,
    this.checkmark = 18.0,
    this.fieldIcon = 22.0,
    this.fieldMessageIcon = 12.0,
    this.controlIcon = 18.0,
    this.smallControlIcon = 16.0,
    this.smallIcon = 12.0,
    this.deleteIcon = 20.0,
    this.menuIcon = 17.0,
    this.indicatorIcon = 15.0,
    this.stepperIcon = 17.0,
    this.statusIcon = 13.0,
    this.completionIcon = 13.0,
    this.progressIcon = 14.0,
    this.progressCardIcon = 30.0,
    this.feedbackIcon = 44.0,
    this.placeholderIcon = 32.0,
    this.tabIcon = 24.0,
    this.compactTabIcon = 22.0,
    this.compactIcon = 17.0,
    this.settingsIcon = 29.0,
  });

  /// Primary button height.
  final double buttonHeight;

  /// Floating and picker field height.
  final double fieldHeight;

  /// Minimum table row height.
  final double rowHeight;

  /// Row leading symbol.
  final double rowIcon;

  /// Row leading column and tile.
  final double rowIconExtent;

  /// Symbol inside a colored row tile.
  final double rowTileIcon;

  /// Row navigation chevron.
  final double rowChevron;

  /// [AcademyChevron] symbol.
  final double chevron;

  /// [AcademyCheckmark].
  final double checkmark;

  /// Trailing symbol of picker fields.
  final double fieldIcon;

  /// Symbol beside a field error.
  final double fieldMessageIcon;

  /// Clear, search, drag, calendar arrows, toast and segment symbols.
  final double controlIcon;

  /// Lock, option check and select indicator.
  final double smallControlIcon;

  /// Select chip close and prayer strip arrow.
  final double smallIcon;

  /// Drag table delete symbol.
  final double deleteIcon;

  /// Menu row symbols.
  final double menuIcon;

  /// Down and up-down menu indicators.
  final double indicatorIcon;

  /// Stepper plus and minus.
  final double stepperIcon;

  /// [AcademyStatus] symbol.
  final double statusIcon;

  /// Checklist completion mark.
  final double completionIcon;

  /// Progress tile completion symbol.
  final double progressIcon;

  /// Progress card completion symbol.
  final double progressCardIcon;

  /// [AcademyFeedback] symbol.
  final double feedbackIcon;

  /// [AcademyImage] placeholder symbol.
  final double placeholderIcon;

  /// Tab bar symbol.
  final double tabIcon;

  /// Compact tab bar symbol.
  final double compactTabIcon;

  /// [AcademyCompactIconButton] symbol.
  final double compactIcon;

  /// [AcademySettingsSquareButton] symbol.
  final double settingsIcon;

  AcademySizes copyWith({
    double? buttonHeight,
    double? fieldHeight,
    double? rowHeight,
    double? rowIcon,
    double? rowIconExtent,
    double? rowTileIcon,
    double? rowChevron,
    double? chevron,
    double? checkmark,
    double? fieldIcon,
    double? fieldMessageIcon,
    double? controlIcon,
    double? smallControlIcon,
    double? smallIcon,
    double? deleteIcon,
    double? menuIcon,
    double? indicatorIcon,
    double? stepperIcon,
    double? statusIcon,
    double? completionIcon,
    double? progressIcon,
    double? progressCardIcon,
    double? feedbackIcon,
    double? placeholderIcon,
    double? tabIcon,
    double? compactTabIcon,
    double? compactIcon,
    double? settingsIcon,
  }) => AcademySizes(
    buttonHeight: buttonHeight ?? this.buttonHeight,
    fieldHeight: fieldHeight ?? this.fieldHeight,
    rowHeight: rowHeight ?? this.rowHeight,
    rowIcon: rowIcon ?? this.rowIcon,
    rowIconExtent: rowIconExtent ?? this.rowIconExtent,
    rowTileIcon: rowTileIcon ?? this.rowTileIcon,
    rowChevron: rowChevron ?? this.rowChevron,
    chevron: chevron ?? this.chevron,
    checkmark: checkmark ?? this.checkmark,
    fieldIcon: fieldIcon ?? this.fieldIcon,
    fieldMessageIcon: fieldMessageIcon ?? this.fieldMessageIcon,
    controlIcon: controlIcon ?? this.controlIcon,
    smallControlIcon: smallControlIcon ?? this.smallControlIcon,
    smallIcon: smallIcon ?? this.smallIcon,
    deleteIcon: deleteIcon ?? this.deleteIcon,
    menuIcon: menuIcon ?? this.menuIcon,
    indicatorIcon: indicatorIcon ?? this.indicatorIcon,
    stepperIcon: stepperIcon ?? this.stepperIcon,
    statusIcon: statusIcon ?? this.statusIcon,
    completionIcon: completionIcon ?? this.completionIcon,
    progressIcon: progressIcon ?? this.progressIcon,
    progressCardIcon: progressCardIcon ?? this.progressCardIcon,
    feedbackIcon: feedbackIcon ?? this.feedbackIcon,
    placeholderIcon: placeholderIcon ?? this.placeholderIcon,
    tabIcon: tabIcon ?? this.tabIcon,
    compactTabIcon: compactTabIcon ?? this.compactTabIcon,
    compactIcon: compactIcon ?? this.compactIcon,
    settingsIcon: settingsIcon ?? this.settingsIcon,
  );
}
