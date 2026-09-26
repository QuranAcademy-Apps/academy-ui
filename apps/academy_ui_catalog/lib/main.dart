import 'package:academy_ui/academy_ui.dart';
import 'package:flutter/cupertino.dart';

import 'appearance_store.dart';
import 'client_palette.dart';
import 'catalog_pages.dart';
import 'modal_catalog.dart';
import 'quran_controls_catalog.dart';

void main() => runApp(const CatalogApp());

class CatalogApp extends StatefulWidget {
  const CatalogApp({super.key, this.appearance});
  final AcademyAppearanceController? appearance;
  @override
  State<CatalogApp> createState() => _CatalogAppState();
}

class _CatalogAppState extends State<CatalogApp> {
  bool _customColors = false;
  late final _appearance =
      widget.appearance ??
      AcademyAppearanceController(store: PreferencesAppearanceStore());
  @override
  void dispose() {
    if (widget.appearance == null) _appearance.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AcademyApp(
    title: 'Academy UI Catalog',
    appearance: _appearance,
    colorsBuilder: _customColors ? catalogClientColors : null,
    home: Builder(
      builder: (context) => AcademyToastHost(
        bottomObstruction: AcademyFloatingTabBar.bottomObstructionOf(context),
        child: AcademyTabScaffold(
          tabs: [
            AcademyTab(
              label: 'Каталог',
              icon: AcademySymbols.checklist,
              builder: (_) => const CatalogIndex(),
            ),
            AcademyTab(
              label: 'Quran',
              icon: AcademySymbols.book,
              builder: (_) => const QuranControlsCatalog(),
            ),
            AcademyTab(
              label: 'Модалки',
              icon: AcademySymbols.expand,
              builder: (_) => const ModalCatalog(),
            ),
            AcademyTab(
              label: 'Оформление',
              icon: AcademySymbols.gear,
              builder: (_) => AppearancePage(
                controller: _appearance,
                customColors: _customColors,
                onCustomColorsChanged: (value) =>
                    setState(() => _customColors = value),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
