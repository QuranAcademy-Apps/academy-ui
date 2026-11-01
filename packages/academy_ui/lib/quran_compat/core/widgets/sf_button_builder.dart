part of './sf_button.dart';

extension SFButtonBuilder on SFButton {
  SFButton copyWith({
    String? systemName,
    IconData? iconData,
    SFButtonType? type,
    SFButtonSize? size,
    SFIconButtonBackground? background,
    double? tapAreaScale,
    Color? tintColor,
    Color? backgroundColor,
    Color? borderColor,
    double? borderWidth,
    FontWeight? fontWeight,
    Widget? contextMenu,
    VoidCallback? onTap,
    String? semanticLabel,
    String? semanticHint,
  }) {
    return SFButton(
      systemName: systemName ?? this.systemName,
      iconData: iconData ?? this.iconData,
      type: type ?? this.type,
      size: size ?? this.size,
      background: background ?? this.background,
      tapAreaScale: tapAreaScale ?? this.tapAreaScale,
      tintColor: tintColor ?? this.tintColor,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      borderColor: borderColor ?? this.borderColor,
      borderWidth: borderWidth ?? this.borderWidth,
      fontWeight: fontWeight ?? this.fontWeight,
      contextMenu: contextMenu ?? this.contextMenu,
      onTap: onTap ?? this.onTap,
      semanticLabel: semanticLabel ?? this.semanticLabel,
      semanticHint: semanticHint ?? this.semanticHint,
    );
  }

  SFButton tintColor(Color color) {
    return copyWith(tintColor: color);
  }

  SFButton backgroundColor(Color color) {
    return copyWith(backgroundColor: color);
  }

  SFButton border({required Color color, double width = 1}) {
    return copyWith(borderColor: color, borderWidth: width);
  }

  SFButton symbolWeight(FontWeight weight) {
    return copyWith(fontWeight: weight);
  }

  SFButton background(SFIconButtonBackground newBackground) {
    return copyWith(background: newBackground);
  }

  SFButton size(SFButtonSize newSize) {
    return copyWith(size: newSize);
  }

  SFButton type(SFButtonType newType) {
    return copyWith(type: newType);
  }

  SFButton semantics({String? label, String? hint}) {
    return copyWith(semanticLabel: label, semanticHint: hint);
  }
}
