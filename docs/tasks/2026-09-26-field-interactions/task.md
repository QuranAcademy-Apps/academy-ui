# Field clear and focus animation

Added AcademyField trailing clear action with a constant 44px slot, fade-in/out, palette color and an isolated accessibility label. Clears enabled non-empty fields, sends one empty onChanged event and retains focus.

Added reversible 180ms border-color tween for focus/blur with constant layout insets and Reduced Motion support. Optional client-owned controller, safe listener replacement and internally owned fallback.

Validation: focus/blur intermediate colors, stable EditableText geometry, clear callback/focus, external ownership, disabled field and reduced-motion checks passed. The 41 existing library checks and all 20 catalogue tests passed; all 3 new interaction tests passed. Updated web release built for the browser.
