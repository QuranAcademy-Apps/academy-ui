# Component review

Requested fixes: table background, black dropdown background, icon/checkmark spacing, field focus layout shift.

- Tables use opaque surface on both pages and sheets. Fields retain their distinct surfaceContainerHighest fill.
- Option, chrome, lazy and reader menus share AcademyMenuAnchor and AcademyMenuItem with explicit palette and interaction states.
- Menu icons have a 16px outer inset, 12px text gap and 8px gap between accessories. Accessory width includes both icons and mirrors for RTL.
- Field border remains 1.5px across focus transitions; only its color changes. EditableText geometry stays unchanged.

Validation: original 22 library tests, 5 new regression checks (light/dark, LTR/RTL, focus), 2 catalogue tests passed. Both analyzers passed. Component previews regenerated. Dark table and open dropdown checked visually in browser. Updated release web build passed.

Scope: targeted review of these components and their related states, not a full-library audit.

## Follow-up: navigation search and leading icon column

Expanded navigation search now shares AcademyChrome with its toggle, including blur sigma 20 when selected. This is an explicit user-requested exception to the original opaque search rule; ordinary fields and modal searches retain their own fill.

AcademyRow and AcademyOptionMenu use a shared 30px leading frame. Divider indentation follows its 30px width plus the 12px text gap. Colored icon tiles use the same frame.

Verification: all 35 library tests passed, including all six chrome styles and table title alignment in LTR/RTL. Analyzer passed.
