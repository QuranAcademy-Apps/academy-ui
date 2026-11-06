# Sources and bundled notices

- UI sources: owner-provided working copy of Yalla and quran_flutter. Revisions,
  paths and source hashes are recorded in `SOURCE_MANIFEST.json`. This extraction
  does not assign a new open-source license to the owners' application code.
- `assets/fonts/Inter.ttf`: Inter, SIL Open Font License 1.1;
  full notice is preserved in `assets/fonts/OFL.txt`.
- `third_party/stupid_simple_sheet`: Tim Lehmann for whynotmake.it,
  MIT license, preserved in its `LICENSE`. The owner-provided Quran fork adds
  `RouteSnapshotMode.animatingAndScrolling` and scroll-aware snapshot handling.
  Keep this fork until equivalent fixes exist upstream; replacing it with the
  published package of the same version removes these changes.
- `flutter_sficon`, `cupertino_ui`, `cupertino_icons` and other resolved packages
  remain external dependencies under their own licenses.

Academy adaptations: shared palette/chrome, opaque
content, blur default 20, keyboard-owned route offset, metrics-based geometry,
settled detent scroll insets, live theme propagation and shared nested modal API.
Donor application files were not modified.
