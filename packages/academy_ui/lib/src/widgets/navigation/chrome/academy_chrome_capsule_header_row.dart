import 'package:flutter/widgets.dart';

/// Row of [AcademyChromeModalHeader.capsule]: the middle stays centered in the
/// row until the controls beside it push it aside.
class AcademyChromeCapsuleHeaderRow extends StatelessWidget {
  const AcademyChromeCapsuleHeaderRow({
    super.key,
    this.leading,
    required this.middle,
    this.trailing,
  });

  final Widget? leading;
  final Widget middle;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) => CustomMultiChildLayout(
    delegate: _Layout(
      hasLeading: leading != null,
      hasTrailing: trailing != null,
      textDirection: Directionality.of(context),
    ),
    children: [
      if (leading != null) LayoutId(id: _Slot.leading, child: leading!),
      LayoutId(id: _Slot.middle, child: middle),
      if (trailing != null) LayoutId(id: _Slot.trailing, child: trailing!),
    ],
  );
}

enum _Slot { leading, middle, trailing }

class _Layout extends MultiChildLayoutDelegate {
  _Layout({
    required this.hasLeading,
    required this.hasTrailing,
    required this.textDirection,
  });

  static const _controlsGap = 8.0;

  final bool hasLeading;
  final bool hasTrailing;
  final TextDirection textDirection;

  @override
  void performLayout(Size size) {
    final loose = BoxConstraints.loose(size);
    final leadingSize = hasLeading
        ? layoutChild(_Slot.leading, loose)
        : Size.zero;
    final trailingSize = hasTrailing
        ? layoutChild(_Slot.trailing, loose)
        : Size.zero;

    final middleLeft = leadingSize.width + (hasLeading ? _controlsGap : 0);
    final middleRight =
        size.width - trailingSize.width - (hasTrailing ? _controlsGap : 0);
    final middleWidth = (middleRight - middleLeft).clamp(0.0, size.width);
    final middleSize = layoutChild(
      _Slot.middle,
      BoxConstraints(maxWidth: middleWidth, maxHeight: size.height),
    );
    final preferredLeft = (size.width - middleSize.width) / 2;
    final maximumLeft = middleRight - middleSize.width;
    final middleOffset = maximumLeft < middleLeft
        ? middleLeft
        : preferredLeft.clamp(middleLeft, maximumLeft).toDouble();

    final rtl = textDirection == TextDirection.rtl;
    if (hasLeading) {
      positionChild(
        _Slot.leading,
        Offset(
          rtl ? size.width - leadingSize.width : 0,
          (size.height - leadingSize.height) / 2,
        ),
      );
    }
    positionChild(
      _Slot.middle,
      Offset(middleOffset, (size.height - middleSize.height) / 2),
    );
    if (hasTrailing) {
      positionChild(
        _Slot.trailing,
        Offset(
          rtl ? 0 : size.width - trailingSize.width,
          (size.height - trailingSize.height) / 2,
        ),
      );
    }
  }

  @override
  bool shouldRelayout(_Layout oldDelegate) =>
      hasLeading != oldDelegate.hasLeading ||
      hasTrailing != oldDelegate.hasTrailing ||
      textDirection != oldDelegate.textDirection;
}
