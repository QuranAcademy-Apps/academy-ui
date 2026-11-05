import 'package:academy_ui/academy_ui.dart';
import 'package:flutter/cupertino.dart';

import 'catalog_pages.dart';
import 'catalog_settings.dart';
import 'component_catalog.dart';
import 'component_registry.dart';

Widget familyPicker(String value, ValueChanged<String> onChanged) =>
    AcademySelect<String>(
      key: const ValueKey('family-picker'),
      label: 'Группа компонентов',
      value: value,
      options: [
        for (final c in componentRegistry)
          AcademySelectOption(
            value: c.id,
            label: c.title,
            group: c.category.title,
          ),
      ],
      onChanged: (value) {
        if (value != null) onChanged(value);
      },
    );

class CatalogPreviewPage extends StatefulWidget {
  const CatalogPreviewPage({super.key, this.selection});
  final ValueNotifier<String>? selection;
  @override
  State<CatalogPreviewPage> createState() => _CatalogPreviewPageState();
}

class _CatalogPreviewPageState extends State<CatalogPreviewPage> {
  String _family = 'buttons';
  @override
  void initState() {
    super.initState();
    _family = widget.selection?.value ?? _family;
    widget.selection?.addListener(_selectionChanged);
  }

  void _selectionChanged() {
    if (_family != widget.selection!.value) {
      setState(() => _family = widget.selection!.value);
    }
  }

  @override
  void dispose() {
    widget.selection?.removeListener(_selectionChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => catalogPage(context, 'Внешний вид', [
    familyPicker(_family, (v) {
      setState(() => _family = v);
      widget.selection?.value = v;
    }),
    ComponentReferencePage(
      key: ValueKey(_family),
      component: componentById(_family),
      embedded: true,
    ),
    AcademyGroupedTable(
      sections: [
        AcademyTableSection(
          title: 'Готовые экраны',
          rows: [
            for (final scenario in scenarioRegistry)
              AcademyRow(
                title: scenario.title,
                onPressed: () => Navigator.of(context)
                    .push(CupertinoPageRoute<void>(builder: scenario.builder)),
              ),
          ],
        ),
      ],
    ),
  ], tab: true);
}

// Explicit links from families to theme roles. Foundations exposes every role.
const _radiusRoles = <String, List<AcademyRadiusRole>>{
  'buttons': [
    AcademyRadiusRole.button,
    AcademyRadiusRole.pillButton,
    AcademyRadiusRole.settingsButton,
  ],
  'text-fields': [
    AcademyRadiusRole.field,
    AcademyRadiusRole.search,
    AcademyRadiusRole.expandingSearch,
  ],
  'select': [AcademyRadiusRole.field, AcademyRadiusRole.modal],
  'calendar': [AcademyRadiusRole.surface],
  'picker': [AcademyRadiusRole.field, AcademyRadiusRole.modal],
  'numbers': [AcademyRadiusRole.stepper, AcademyRadiusRole.progress],
  'segments': [
    AcademyRadiusRole.segment,
    AcademyRadiusRole.segmentSelection,
    AcademyRadiusRole.compactSegment,
    AcademyRadiusRole.compactSegmentSelection,
  ],
  'table': [
    AcademyRadiusRole.table,
    AcademyRadiusRole.tableBadge,
    AcademyRadiusRole.rowIcon,
  ],
  'surface': [AcademyRadiusRole.surface, AcademyRadiusRole.disclosure],
  'navigation': [
    AcademyRadiusRole.chrome,
    AcademyRadiusRole.chromeButton,
    AcademyRadiusRole.tabBar,
    AcademyRadiusRole.tabSelection,
  ],
  'menus': [AcademyRadiusRole.menuButton, AcademyRadiusRole.chrome],
  'modal': [AcademyRadiusRole.modal],
  'popover': [AcademyRadiusRole.surface],
  'help': [AcademyRadiusRole.surface],
  'metadata': [AcademyRadiusRole.surface],
  'media': [AcademyRadiusRole.image, AcademyRadiusRole.rowIcon],
  'feedback': [
    AcademyRadiusRole.status,
    AcademyRadiusRole.toast,
    AcademyRadiusRole.progress,
  ],
  'journey': [AcademyRadiusRole.progress, AcademyRadiusRole.surface],
};
const _paddingRoles = <String, List<AcademyPaddingRole>>{
  'buttons': [
    AcademyPaddingRole.button,
    AcademyPaddingRole.pillButton,
    AcademyPaddingRole.textButton,
  ],
  'text-fields': [
    AcademyPaddingRole.field,
    AcademyPaddingRole.fieldOuter,
    AcademyPaddingRole.search,
    AcademyPaddingRole.searchPrefix,
    AcademyPaddingRole.searchLoading,
    AcademyPaddingRole.expandingSearch,
  ],
  'select': [
    AcademyPaddingRole.field,
    AcademyPaddingRole.fieldOuter,
    AcademyPaddingRole.menuOverlay,
  ],
  'calendar': [AcademyPaddingRole.surface],
  'picker': [AcademyPaddingRole.field, AcademyPaddingRole.modalContent],
  'numbers': [AcademyPaddingRole.field],
  'segments': [AcademyPaddingRole.surface],
  'table': [
    AcademyPaddingRole.tableHeader,
    AcademyPaddingRole.tableRow,
    AcademyPaddingRole.tableBody,
    AcademyPaddingRole.tableFooter,
    AcademyPaddingRole.tableBadge,
    AcademyPaddingRole.rowSubtitle,
    AcademyPaddingRole.divider,
    AcademyPaddingRole.groupedTable,
  ],
  'surface': [
    AcademyPaddingRole.surface,
    AcademyPaddingRole.disclosureHeader,
    AcademyPaddingRole.disclosureBody,
  ],
  'navigation': [
    AcademyPaddingRole.chromeCapsule,
    AcademyPaddingRole.chromeBar,
    AcademyPaddingRole.chromeBottom,
    AcademyPaddingRole.tabBar,
    AcademyPaddingRole.compactTabBar,
  ],
  'menus': [
    AcademyPaddingRole.menuButton,
    AcademyPaddingRole.menuOverlay,
    AcademyPaddingRole.chromeMenu,
  ],
  'modal': [
    AcademyPaddingRole.modal,
    AcademyPaddingRole.modalContent,
    AcademyPaddingRole.landscapeModal,
  ],
  'popover': [AcademyPaddingRole.menuOverlay],
  'help': [AcademyPaddingRole.field],
  'metadata': [AcademyPaddingRole.surface],
  'media': [AcademyPaddingRole.surface],
  'feedback': [
    AcademyPaddingRole.status,
    AcademyPaddingRole.feedback,
    AcademyPaddingRole.feedbackIcon,
    AcademyPaddingRole.feedbackCard,
    AcademyPaddingRole.toast,
    AcademyPaddingRole.toastWithIcons,
  ],
  'journey': [AcademyPaddingRole.surface],
};

class CatalogSettingsPage extends StatefulWidget {
  const CatalogSettingsPage({
    super.key,
    required this.settings,
    this.selection,
    required this.appearance,
    required this.customColors,
    required this.onCustomColorsChanged,
  });
  final CatalogSettings settings;
  final ValueNotifier<String>? selection;
  final AcademyAppearanceController appearance;
  final bool customColors;
  final ValueChanged<bool> onCustomColorsChanged;
  @override
  State<CatalogSettingsPage> createState() => _CatalogSettingsPageState();
}

class _CatalogSettingsPageState extends State<CatalogSettingsPage> {
  String _family = 'buttons';
  AcademyRadiusRole _radius = AcademyRadiusRole.button;
  AcademyPaddingRole _padding = AcademyPaddingRole.button;
  AcademyTextRole _font = AcademyTextRole.labelLarge;
  AcademyColorRole _color = AcademyColorRole.accentFill;
  String _panel = 'Скругления';
  String? _colorError;
  final _hex = TextEditingController();
  @override
  void initState() {
    super.initState();
    final family = widget.selection?.value;
    if (family != null) _selectFamily(family);
    widget.selection?.addListener(_selectionChanged);
  }

  void _selectionChanged() {
    if (_family != widget.selection!.value) {
      _selectFamily(widget.selection!.value);
    }
  }

  @override
  void dispose() {
    widget.selection?.removeListener(_selectionChanged);
    _hex.dispose();
    super.dispose();
  }

  void _selectFamily(String family) => setState(() {
    _family = family;
    widget.selection?.value = family;
    _radius = (_radiusRoles[family] ?? AcademyRadiusRole.values).first;
    _padding = (_paddingRoles[family] ?? AcademyPaddingRole.values).first;
    _font = switch (family) {
      'buttons' => AcademyTextRole.labelLarge,
      'text-fields' ||
      'select' ||
      'calendar' ||
      'picker' => AcademyTextRole.bodyLarge,
      'segments' => AcademyTextRole.segmentLabel,
      'feedback' => AcademyTextRole.status,
      _ => AcademyTextRole.bodyRow,
    };
    _color = family == 'text-fields' || family == 'select'
        ? AcademyColorRole.textFieldBackground
        : AcademyColorRole.accentFill;
    _colorError = null;
    _hex.clear();
  });
  Widget _role<T extends Enum>(
    String label,
    T value,
    List<T> values,
    ValueChanged<T> changed,
  ) => AcademyInlineOptionMenu(
    label: label,
    value: value.name,
    options: values.map((r) => r.name).toList(),
    onSelected: (v) =>
        setState(() => changed(values.firstWhere((r) => r.name == v))),
  );
  Widget _number(
    String label,
    double value,
    double max,
    ValueChanged<double> changed,
  ) => AcademySlider(
    label: label,
    value: value.clamp(0, max),
    min: 0,
    max: max,
    divisions: max.round(),
    formatValue: (_) => '${value.round()} пт',
    onChanged: changed,
  );
  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: widget.settings,
    builder: (context, _) {
      final settings = widget.settings;
      final theme = AcademyTheme.of(context);
      final padding = settings.paddings.value(_padding);
      final font = theme.textTheme.style(_font);
      final color = theme.colorScheme.value(_color);
      return catalogPage(context, 'Настройки', [
        AcademyGroupedTable(
          sections: [
            AcademyTableSection(
              rows: [
                AcademyRow(
                  title: 'Оформление каталога',
                  subtitle: 'Тема, акцент и навигация',
                  onPressed: () => Navigator.of(context).push(
                    CupertinoPageRoute<void>(
                      builder: (_) {
                        var custom = widget.customColors;
                        return StatefulBuilder(
                          builder: (context, update) => AppearancePage(
                            controller: widget.appearance,
                            customColors: custom,
                            onCustomColorsChanged: (v) {
                              widget.onCustomColorsChanged(v);
                              update(() => custom = v);
                            },
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 16),
        familyPicker(_family, _selectFamily),
        AcademyInlineOptionMenu(
          label: 'Параметры',
          value: _panel,
          options: const ['Скругления', 'Отступы', 'Шрифты', 'Цвета'],
          onSelected: (v) => setState(() => _panel = v),
        ),
        if (_panel == 'Скругления') ...[
          const AcademyTableHeader(title: 'Скругления'),
          _role(
            'Элемент',
            _radius,
            _radiusRoles[_family] ?? AcademyRadiusRole.values,
            (r) => _radius = r,
          ),
          _number(
            'Радиус',
            settings.radii.value(_radius),
            settings.radii.value(_radius) > 64 ? 999 : 64,
            (v) => settings.setRadius(_radius, v),
          ),
        ],
        if (_panel == 'Отступы') ...[
          const AcademyTableHeader(title: 'Отступы'),
          _role(
            'Область',
            _padding,
            _paddingRoles[_family] ?? AcademyPaddingRole.values,
            (r) => _padding = r,
          ),
          for (final (label, side) in [
            ('Слева', 0),
            ('Сверху', 1),
            ('Справа', 2),
            ('Снизу', 3),
          ])
            _number(
              label,
              [padding.left, padding.top, padding.right, padding.bottom][side],
              48,
              (v) {
                final values = [
                  padding.left,
                  padding.top,
                  padding.right,
                  padding.bottom,
                ];
                values[side] = v;
                settings.setPadding(
                  _padding,
                  EdgeInsets.fromLTRB(
                    values[0],
                    values[1],
                    values[2],
                    values[3],
                  ),
                );
              },
            ),
        ],
        if (_panel == 'Шрифты') ...[
          const AcademyTableHeader(title: 'Шрифты'),
          _role(
            'Стиль текста',
            _font,
            AcademyTextRole.values,
            (r) => _font = r,
          ),
          AcademySlider(
            label: 'Размер',
            value: (font.fontSize ?? 17).clamp(10, 40),
            min: 10,
            max: 40,
            divisions: 30,
            formatValue: (v) => '${v.round()} пт',
            onChanged: (v) => settings.setFont(
              _font,
              TextStyle(
                fontSize: v,
                fontWeight: font.fontWeight,
                height: font.height,
              ),
            ),
          ),
          AcademyInlineOptionMenu(
            label: 'Начертание',
            value: '${font.fontWeight?.value ?? 400}',
            options: const ['300', '400', '500', '600', '700', '800'],
            onSelected: (v) => settings.setFont(
              _font,
              TextStyle(
                fontSize: font.fontSize,
                height: font.height,
                fontWeight: FontWeight.values.firstWhere(
                  (w) => w.value == int.parse(v),
                ),
              ),
            ),
          ),
          Text('Пример выбранного стиля', style: font),
          const SizedBox(height: 16),
        ],
        if (_panel == 'Цвета') ...[
          AcademyTableHeader(
            title:
                'Цвета · ${theme.brightness == Brightness.dark ? 'тёмная тема' : 'светлая тема'}',
          ),
          _role('Цветовая роль', _color, AcademyColorRole.values, (r) {
            _color = r;
            _hex.clear();
            _colorError = null;
          }),
          AcademyField(
            controller: _hex,
            label: 'Цвет HEX',
            placeholder:
                '#${color.toARGB32().toRadixString(16).padLeft(8, '0').toUpperCase()}',
            help: '#RRGGBB или #AARRGGBB',
            error: _colorError,
            clearable: false,
          ),
          AcademyButton(
            label: 'Применить цвет',
            onPressed: () {
              final raw = _hex.text.trim().replaceFirst(RegExp(r'^#'), '');
              if (!RegExp(r'^([0-9a-fA-F]{6}|[0-9a-fA-F]{8})$').hasMatch(raw)) {
                setState(() => _colorError = 'Введите 6 или 8 цифр HEX');
                return;
              }
              settings.setColor(
                theme.brightness,
                _color,
                Color(int.parse(raw.length == 6 ? 'FF$raw' : raw, radix: 16)),
              );
              setState(() => _colorError = null);
            },
          ),
        ],
        const SizedBox(height: 24),
        AcademyTableHeader(
          title: 'Предпросмотр · ${componentById(_family).title}',
        ),
        ComponentReferencePage(
          key: ValueKey('settings-$_family'),
          component: componentById(_family),
          embedded: true,
          showControls: false,
        ),
        AcademyTextButton(
          label: 'Сбросить изменения компонентов',
          onPressed: settings.reset,
        ),
        const Text(
          'Изменения общих ролей действуют во всём каталоге. Светлая и тёмная палитры настраиваются отдельно.',
        ),
        if (settings.error != null) Text(settings.error!),
      ], tab: true);
    },
  );
}
