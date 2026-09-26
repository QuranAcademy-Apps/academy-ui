import 'package:academy_ui/academy_ui.dart';
import 'package:flutter/cupertino.dart';

/// Example client-owned palette: a partial override of the standard contract.
AcademyColors catalogClientColors(Brightness brightness, Color accent) {
  final dark = brightness == Brightness.dark;
  final base = AcademyPalette(brightness, accent);
  final surface = dark ? const Color(0xFF26362E) : const Color(0xFFFFFBF0);
  return base.copyWith(
    scaffoldBackground: dark
        ? const Color(0xFF18251F)
        : const Color(0xFFF0EADD),
    surface: surface,
    surfaceContainerHighest: dark
        ? const Color(0xFF35463C)
        : const Color(0xFFE8E2D4),
    onSurface: dark ? const Color(0xFFF4F3DF) : const Color(0xFF253C2F),
    onSurfaceVariant: dark ? const Color(0xFFBCCBBE) : const Color(0xFF5B6B60),
    segmentBackground: dark ? const Color(0xFF526A59) : const Color(0xFFD3DDCD),
    segmentSelected: surface,
    segmentShadow: const Color(0x33253C2F),
    chromeSurface: surface,
    chromeGradientStart: dark
        ? const Color(0xFF35463C)
        : const Color(0xFFE8E2D4),
    chromeGradientEnd: surface,
    modalBarrier: const Color(0x66314236),
    menuHighlight: dark ? const Color(0xFF354D3F) : const Color(0xFFDEE8D8),
    toneContainers: {
      AcademyTone.success: dark
          ? const Color(0xFF24452F)
          : const Color(0xFFD9ECD2),
    },
  );
}
