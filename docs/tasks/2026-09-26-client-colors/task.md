# Client color contract

Request: strengthen compact segment background and make every design-system-owned color replaceable by the consuming app, following the iOS theme interface.

Reference inspected read-only: ios-quran-reader/QuranAcademy/Core/Theme/Models+Extensions/ThemeColors.swift. Its ThemeColors protocol separates semantic roles from concrete ClassicTheme/WhiteTheme values.

Implemented AcademyColors interface, AcademyPalette defaults, immutable AcademyColorsData and partial copyWith overrides. AcademyApp.colorsBuilder resolves light/dark and accent; academyTheme accepts a direct colors implementation. All literal component fills were moved to the palette, including status colors, colored-icon foreground, segment shadow and modal barrier. Native third-party widgets retain their own platform drawing; the interface covers colors owned by Academy UI.

Compact segments and compact utility buttons now use segmentBackground, independently from form surfaces. Segment selected fill and shadow are separate roles. Navigation effect colors and menu highlight also have explicit roles.

Catalogue Appearance includes a default/client example switch. Example palette is client-owned, demonstrates partial overrides and is intentionally not persisted. The standard palette was restored after browser verification.

Validation: existing 35 library tests plus 2 new client-palette tests passed; 2 catalogue tests passed; library and catalogue analyzers passed; release web build passed; actual-widget previews regenerated. Browser verified client background/text/surfaces change. New tests verify exact override values, fallback roles, fields/status/segments/shadow/barrier and live custom theme changes inside an open modal.

Modal barrier is resolved when a route opens; content follows subsequent theme changes. Partial overrides preserve already resolved dependent values; override related semantic roles when needed. No donor edits, commits or pushes.
