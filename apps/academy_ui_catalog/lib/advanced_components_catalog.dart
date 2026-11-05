import 'package:academy_ui/academy_ui.dart';
import 'package:flutter/cupertino.dart';

import 'catalog_pages.dart';

enum AdvancedCatalogSection { forms, dates, interaction }

class AdvancedComponentsCatalog extends StatefulWidget {
  const AdvancedComponentsCatalog({super.key, required this.section});
  final AdvancedCatalogSection section;
  @override
  State<AdvancedComponentsCatalog> createState() =>
      _AdvancedComponentsCatalogState();
}

class _AdvancedComponentsCatalogState extends State<AdvancedComponentsCatalog> {
  final _form = GlobalKey<FormState>();
  final _name = TextEditingController();
  String? _language;
  Set<String> _topics = {};
  DateTime? _date = DateTime(2026, 10, 2);
  AcademyDateRange? _range;
  AcademyTime? _time = const AcademyTime(9, 30);
  String _wheel = 'Средний';
  double _fontSize = 18;
  bool _offline = false;
  static const _languages = [
    AcademySelectOption(value: 'ru', label: 'Русский', group: 'Языки'),
    AcademySelectOption(value: 'en', label: 'English', group: 'Языки'),
    AcademySelectOption(value: 'ar', label: 'العربية', group: 'Языки'),
    AcademySelectOption(value: 'soon', label: 'Скоро', enabled: false),
  ];
  static const _options = [
    AcademySelectOption(
      value: 'reading',
      label: 'Чтение',
      subtitle: 'Текст и переводы',
    ),
    AcademySelectOption(
      value: 'audio',
      label: 'Аудио',
      subtitle: 'Прослушивание',
    ),
    AcademySelectOption(value: 'practice', label: 'Практика'),
  ];
  Future<List<AcademySelectOption<String>>> _load(String query) async {
    await Future<void>.delayed(const Duration(milliseconds: 400));
    if (_offline) throw StateError('Demo offline');
    return _options
        .where((o) => o.label.toLowerCase().contains(query.toLowerCase()))
        .toList();
  }

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => switch (widget.section) {
    AdvancedCatalogSection.forms => catalogPage(context, 'Формы и выбор', [
      const Text('Настройте язык и темы.'),
      Form(
        key: _form,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AcademyTextFormField(
              controller: _name,
              label: 'Имя',
              help: 'Обязательное поле',
              validator: (v) =>
                  v == null || v.trim().isEmpty ? 'Введите имя' : null,
            ),
            const AcademyAutocomplete<String>(
              label: 'Подсказки снизу',
              placement: AcademyPopoverPlacement.below,
              options: _options,
              help: 'Чтение, аудио или практика. Нажмите на поле.',
            ),
            AcademySelect<String>(
              label: 'Язык',
              value: _language,
              options: _languages,
              presentation: AcademySelectPresentation.menu,
              onChanged: (v) => setState(() => _language = v),
              validator: (v) => v == null ? 'Выберите язык' : null,
            ),
            AcademyMultiSelect<String>(
              label: 'Темы',
              presentation: AcademySelectPresentation.menu,
              values: _topics,
              options: _options,
              onChanged: (v) => setState(() => _topics = v),
            ),
            const AcademySelect<String>(
              label: 'Недоступное поле',
              value: 'ru',
              onChanged: null,
              options: _languages,
            ),
            const AcademyAutocomplete<String>(
              label: 'Подсказки сверху',
              placement: AcademyPopoverPlacement.above,
              options: _options,
            ),
            const AcademyAutocomplete<String>(
              label: 'Пустой результат',
              emptyHint: 'Попробуйте другое слово.',
              help: 'Нажмите на поле, чтобы увидеть пустой результат.',
            ),
            AcademyAutocomplete<String>(
              label: 'Подсказки с загрузкой',
              help: 'Введите «Аудио» для результата или другое слово для пустого поиска.',
              loader: _load,
              emptyHint: 'Попробуйте «Чтение», «Аудио» или «Практика».',
              onSelected: (value) =>
                  AcademyToastHost.show(context, 'Выбрано: $value'),
            ),
            Row(
              children: [
                Expanded(child: Text('Имитировать ошибку загрузки')),
                CupertinoSwitch(
                  value: _offline,
                  onChanged: (v) => setState(() => _offline = v),
                ),
              ],
            ),
            AcademyButton(
              label: 'Проверить форму',
              onPressed: () {
                if (_form.currentState!.validate()) {
                  AcademyToastHost.show(context, 'Форма заполнена');
                }
              },
            ),
            AcademyTextButton(
              label: 'Сбросить',
              onPressed: () => _form.currentState!.reset(),
            ),
          ],
        ),
      ),
    ]),
    AdvancedCatalogSection.dates => catalogPage(context, 'Даты и значения', [
      AcademyDateInput(
        label: 'Дата',
        value: _date,
        onChanged: (v) => setState(() => _date = v),
        firstDate: DateTime(2020),
        lastDate: DateTime(2035),
      ),
      AcademyTimeField(
        label: 'Время',
        value: _time,
        onChanged: (v) => setState(() => _time = v),
      ),
      example(
        'Календарь',
        AcademyCalendar(
          value: _date,
          onChanged: (v) => setState(() => _date = v),
          firstDate: DateTime(2026),
          lastDate: DateTime(2027, 12, 31),
        ),
      ),
      example(
        'Период — выберите начало и конец',
        AcademyRangeCalendar(
          value: _range,
          onChanged: (v) => setState(() => _range = v),
          firstDate: DateTime(2026),
          lastDate: DateTime(2027, 12, 31),
        ),
      ),
      if (_range != null)
        Text(
          '${_range!.start.day}.${_range!.start.month} — ${_range!.end.day}.${_range!.end.month}',
        ),
      example(
        'Лента дней',
        AcademyLineCalendar(
          firstDate: DateTime(2026, 10, 1),
          dayCount: 31,
          value: _date,
          onChanged: (v) => setState(() => _date = v),
        ),
      ),
      example(
        'Колёсный выбор',
        AcademyPicker<String>(
          items: const ['Маленький', 'Средний', 'Большой'],
          value: _wheel,
          labelFor: (v) => v,
          onChanged: (v) => setState(() => _wheel = v),
        ),
      ),
      AcademySlider(
        label: 'Размер текста',
        value: _fontSize,
        min: 12,
        max: 32,
        divisions: 20,
        formatValue: (v) => '${v.round()} пт',
        onChanged: (v) => setState(() => _fontSize = v),
      ),
    ]),
    AdvancedCatalogSection.interaction => catalogPage(
      context,
      'Фокус и подсказки',
      [
        const Text(
          'Проверьте Tab, Enter, Space и Escape. Рамка фокуса появляется при работе с клавиатурой. Подсказка — при наведении, фокусе или удержании.',
        ),
        const SizedBox(height: 24),
        Wrap(
          alignment: WrapAlignment.spaceEvenly,
          spacing: 16,
          runSpacing: 16,
          children: [
            for (final (placement, label) in const [
              (AcademyPopoverPlacement.above, 'Сверху'),
              (AcademyPopoverPlacement.below, 'Снизу'),
              (AcademyPopoverPlacement.start, 'Слева'),
              (AcademyPopoverPlacement.end, 'Справа'),
            ])
              Column(
                children: [
                  AcademyTooltip(
                    message: 'Справка по этому действию.',
                    placement: placement,
                    width: 140,
                    child: AcademyIconButton(
                      icon: AcademySymbols.info,
                      label: label,
                      onPressed: () {},
                    ),
                  ),
                  Text(
                    label,
                    style: AcademyTheme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
          ],
        ),
        const SizedBox(height: 24),
        AcademyPopover(
          matchAnchorWidth: true,
          builder: (context, control) =>
              AcademyButton(label: 'Открыть панель', onPressed: control.toggle),
          contentBuilder: (context, close) => SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: AcademyTheme.of(context).paddings.menuOverlay * 2,
                  child: const Text(
                    'Дополнительная информация об этом действии.',
                    textAlign: TextAlign.start,
                  ),
                ),
                SizedBox(
                  height: 1 / MediaQuery.devicePixelRatioOf(context),
                  child: ColoredBox(
                    color: AcademyTheme.of(context).colorScheme.outlineVariant,
                  ),
                ),
                Align(
                  alignment: AlignmentDirectional.centerEnd,
                  child: AcademyTextButton(label: 'Готово', onPressed: close),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),
        AcademyTappable(
          onPressed: () => AcademyToastHost.show(context, 'Нажато'),
          builder: (context, states) => AcademySurface(
            child: Text(
              states.contains(WidgetState.pressed)
                  ? 'Нажатие'
                  : states.contains(WidgetState.hovered)
                  ? 'Наведение'
                  : 'Карточка с общей обработкой взаимодействия',
            ),
          ),
        ),
      ],
    ),
  };
}
