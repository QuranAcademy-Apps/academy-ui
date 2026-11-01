import 'package:academy_ui/academy_ui.dart';
import 'package:flutter/cupertino.dart';

import 'component_registry.dart';
import 'counter_components_catalog.dart';
import 'catalog_pages.dart';
import 'advanced_components_catalog.dart';
import 'profile_components_catalog.dart';
import 'quran_controls_catalog.dart';
import 'modal_catalog.dart';
import 'table_menu_examples.dart';
import 'text_fields_catalog.dart';

void openComponent(BuildContext context, ComponentDescriptor component) =>
    Navigator.of(context).push(
      CupertinoPageRoute<void>(
        builder: (_) =>
            ComponentReferencePage(component: component, showControls: false),
      ),
    );

class ScenarioDescriptor {
  const ScenarioDescriptor(this.id, this.title, this.builder);
  final String id, title;
  final WidgetBuilder builder;
}

final scenarioRegistry = <ScenarioDescriptor>[
  ScenarioDescriptor(
    'profile',
    'Профиль и поездки',
    (_) => const ProfileComponentsCatalog(),
  ),
  ScenarioDescriptor('quran', 'Quran', (_) => const QuranControlsCatalog()),
  ScenarioDescriptor(
    'forms',
    'Форма, поиск и загрузка',
    (_) =>
        const AdvancedComponentsCatalog(section: AdvancedCatalogSection.forms),
  ),
  ScenarioDescriptor(
    'dates',
    'Дата и настройки значений',
    (_) =>
        const AdvancedComponentsCatalog(section: AdvancedCatalogSection.dates),
  ),
  ScenarioDescriptor(
    'interaction',
    'Фокус и контекстная помощь',
    (_) => const AdvancedComponentsCatalog(
      section: AdvancedCatalogSection.interaction,
    ),
  ),
  ScenarioDescriptor(
    'table-menu',
    'Таблица, меню и перетаскивание',
    (_) => const TableMenuExamples(),
  ),
  ScenarioDescriptor('modals', 'Модалки', (_) => const ModalCatalog()),
];

class ScenariosIndex extends StatelessWidget {
  const ScenariosIndex({super.key});
  @override
  Widget build(BuildContext context) => catalogPage(context, 'Примеры', [
    AcademyGroupedTable(
      sections: [
        AcademyTableSection(
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

/// One canonical reference per registered family. Contextual demos link here.
class ComponentReferencePage extends StatefulWidget {
  const ComponentReferencePage({
    super.key,
    required this.component,
    this.embedded = false,
    this.showControls = true,
  });
  final ComponentDescriptor component;
  final bool embedded, showControls;
  @override
  State<ComponentReferencePage> createState() => _ComponentReferencePageState();
}

class _ComponentReferencePageState extends State<ComponentReferencePage> {
  final _text = TextEditingController();
  final _expandingText = TextEditingController();
  final _formText = TextEditingController();
  final _plainSearch = TextEditingController();
  final _loadingSearch = TextEditingController();
  bool _offline = false;
  final _form = GlobalKey<FormState>();
  final _tip = GlobalKey();
  Brightness? _brightness;
  TextDirection? _direction;
  bool _large = false, _expanded = false;
  int _number = 2, _segment = 0, _compactSegment = 0;
  double _slider = .4;
  String? _choice = 'ru';
  Set<String> _choices = {};
  DateTime? _date = DateTime(2026, 10, 4);
  AcademyDateRange? _range;
  AcademyTime? _time = const AcademyTime(9, 30);
  static const _options = [
    AcademySelectOption(value: 'ru', label: 'Русский'),
    AcademySelectOption(value: 'en', label: 'English'),
    AcademySelectOption(value: 'ar', label: 'العربية'),
  ];
  @override
  void dispose() {
    _text.dispose();
    _expandingText.dispose();
    _formText.dispose();
    _plainSearch.dispose();
    _loadingSearch.dispose();
    super.dispose();
  }

  List<Widget> _demo(BuildContext context, {String? family}) {
    void action() => AcademyToastHost.show(context, 'Действие выполнено');
    return switch (family ?? widget.component.id) {
      'buttons' => [
        example(
          'Основная и тонированная',
          Column(
            children: [
              AcademyButton(label: 'Выполнить', onPressed: action),
              AcademyButton(
                label: 'Дополнительно',
                style: AcademyButtonStyle.tinted,
                onPressed: action,
              ),
            ],
          ),
        ),
        example(
          'Недоступность и загрузка',
          const Column(
            children: [
              AcademyButton(label: 'Недоступно'),
              AcademyButton(label: 'Сохранение', pending: true),
            ],
          ),
        ),
        AcademyActionButton(
          title: 'Дополнительное действие',
          icon: AcademySymbols.info,
          style: AcademyButtonStyle.tinted,
          onPressed: action,
        ),
        AcademyActionButton(
          title: 'Действие с описанием',
          subtitle: 'Подробности команды',
          icon: AcademySymbols.info,
          onPressed: action,
        ),
        const AcademyActionButton(
          title: 'Недоступное действие',
          icon: AcademySymbols.info,
        ),
        const AcademyActionButton(
          title: 'Ожидание действия',
          icon: AcademySymbols.info,
          pending: true,
        ),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            AcademyPillButton(
              label: 'Открыть',
              icon: AcademySymbols.book,
              onPressed: action,
            ),
            const AcademyPillButton(
              label: 'Недоступно',
              icon: AcademySymbols.close,
            ),
            AcademyPillButton(
              label: 'Тихое действие',
              icon: AcademySymbols.info,
              tinted: false,
              onPressed: action,
            ),
            AcademyResumeCapsule(
              visible: true,
              title: 'Утренние азкары',
              caption: '4/17',
              onPressed: action,
            ),
            AcademyIconButton(
              icon: AcademySymbols.plus,
              label: 'Добавить',
              onPressed: action,
            ),
            AcademyInfoButton(onPressed: action),
            AcademyCompactIconButton(onPressed: action),
            AcademySettingsSquareButton(
              icon: AcademySymbols.gear,
              label: 'Настройки',
              onPressed: action,
            ),
          ],
        ),
        AcademyTextButton(label: 'Текстовое действие', onPressed: action),
        const AcademyTextButton(
          label: 'Недоступное текстовое действие',
          onPressed: null,
        ),
        const Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            AcademyIconButton(
              icon: AcademySymbols.plus,
              label: 'Недоступное добавление',
              onPressed: null,
            ),
            AcademyCompactIconButton(onPressed: null),
            AcademySettingsSquareButton(
              icon: AcademySymbols.gear,
              label: 'Недоступные настройки',
              onPressed: null,
            ),
          ],
        ),
      ],
      'text-fields' => [
        const TextFieldsCatalog(),
        ..._demo(context, family: 'form'),
        ..._demo(context, family: 'search'),
        ..._demo(context, family: 'autocomplete'),
      ],
      'form' => [
        Form(
          key: _form,
          child: AcademyTextFormField(
            controller: _formText,
            label: 'Имя',
            validator: (v) => v == null || v.isEmpty ? 'Введите имя' : null,
          ),
        ),
        AcademyButton(
          label: 'Проверить',
          onPressed: () => _form.currentState!.validate(),
        ),
        AcademyTextButton(
          label: 'Сбросить',
          onPressed: () => _form.currentState!.reset(),
        ),
        example(
          'Композиция TextInput + Decoration',
          AcademyFieldDecoration(
            label: 'Свой редактор',
            help: 'Decoration не владеет редактированием',
            child: AcademyTextInput(
              placeholder: 'Введите текст',
              semanticLabel: 'Свой редактор',
            ),
          ),
        ),
        AcademyFormField<bool>(
          value: _expanded,
          onChanged: (v) => setState(() => _expanded = v),
          builder: (state, change) => AcademyRow(
            title: 'Согласие в форме',
            trailing: CupertinoSwitch(
              value: state.value ?? false,
              onChanged: change,
            ),
          ),
        ),
        const AcademyFieldDecoration(
          label: 'Ошибка композиции',
          error: 'Проверьте значение',
          child: AcademyTextInput(placeholder: 'Введите текст'),
        ),
      ],
      'search' => [
        example(
          'Постоянный поиск',
          AcademySearchBar(controller: _text, onCancel: _text.clear),
        ),
        example(
          'Поиск в непрозрачном поле',
          AcademySearchBar(
            controller: _plainSearch,
            chrome: false,
            clearable: true,
          ),
        ),
        example(
          'Поиск с загрузкой',
          AcademySearchBar(controller: _loadingSearch, loading: true),
        ),
        example(
          'Поиск вместо заголовка',
          AcademyExpandingSearch(
            controller: _expandingText,
            resting: const Text('Заголовок страницы'),
          ),
        ),
      ],
      'select' => [
        AcademySelect<String>(
          label: 'Один вариант · автоматически',
          value: _choice,
          options: _options,
          onChanged: (v) => setState(() => _choice = v),
        ),
        AcademySelect<String>(
          label: 'Один вариант · меню',
          value: _choice,
          options: _options,
          presentation: AcademySelectPresentation.menu,
          onChanged: (v) => setState(() => _choice = v),
        ),
        AcademySelect<String>(
          label: 'Один вариант · popover',
          value: _choice,
          options: _options,
          presentation: AcademySelectPresentation.popover,
          onChanged: (v) => setState(() => _choice = v),
        ),
        AcademySelect<String>(
          label: 'Один вариант · модалка',
          value: _choice,
          options: _options,
          presentation: AcademySelectPresentation.sheet,
          onChanged: (v) => setState(() => _choice = v),
        ),
        for (final presentation in AcademySelectPresentation.values)
          AcademyMultiSelect<String>(
            label: 'Несколько вариантов: ${presentation.name}',
            presentation: presentation,
            values: _choices,
            options: _options,
            onChanged: (v) => setState(() => _choices = v),
          ),
        const AcademySelect<String>(
          label: 'Недоступное поле',
          value: 'ru',
          options: _options,
          onChanged: null,
        ),
        AcademySelect<String>(
          label: 'Нет вариантов',
          value: null,
          options: const [],
          onChanged: (v) {},
        ),
      ],
      'autocomplete' => [
        AcademyAutocomplete<String>(
          label: 'Подсказки с загрузкой',
          loader: (query) async {
            await Future<void>.delayed(const Duration(milliseconds: 400));
            if (_offline) throw StateError('Demo offline');
            return _options
                .where(
                  (o) => o.label.toLowerCase().contains(query.toLowerCase()),
                )
                .toList();
          },
        ),
        AcademyRow(
          title: 'Ошибка загрузки подсказок',
          trailing: CupertinoSwitch(
            value: _offline,
            onChanged: (v) => setState(() => _offline = v),
          ),
        ),
        const AcademyAutocomplete<String>(
          label: 'Недоступные подсказки',
          options: _options,
          enabled: false,
        ),
        for (final placement in [
          AcademyPopoverPlacement.above,
          AcademyPopoverPlacement.below,
        ])
          AcademyAutocomplete<String>(
            label: 'Подсказки: ${placement.name}',
            placement: placement,
            options: _options,
          ),
        const AcademyAutocomplete<String>(
          label: 'Пустой результат',
          emptyHint: 'Попробуйте другое слово',
        ),
      ],
      'calendar' => [
        AcademyCalendar(
          value: _date,
          onChanged: (v) => setState(() => _date = v),
        ),
        AcademyRangeCalendar(
          value: _range,
          onChanged: (v) => setState(() => _range = v),
        ),
        AcademyLineCalendar(
          firstDate: DateTime(2026, 10, 1),
          dayCount: 10,
          value: _date,
          onChanged: (v) => setState(() => _date = v),
        ),
      ],
      'picker' => [
        AcademyDateField(
          label: 'Дата',
          value: _date,
          onChanged: (v) => setState(() => _date = v),
        ),
        AcademyTimeField(
          label: 'Время',
          value: _time,
          onChanged: (v) => setState(() => _time = v),
        ),
        AcademyPicker<String>(
          items: const ['ru', 'en', 'ar'],
          value: _choice ?? 'ru',
          labelFor: (v) => v,
          onChanged: (v) => setState(() => _choice = v),
        ),
      ],
      'numbers' => [
        AcademySlider(
          label: 'Значение диапазона',
          value: _slider,
          onChanged: (v) => setState(() => _slider = v),
        ),
        AcademyStepper(
          value: _number,
          onChanged: (v) => setState(() => _number = v),
        ),
      ],
      'segments' => [
        AcademySegmentedControl<int>(
          items: const [0, 1, 2],
          value: _segment,
          labelFor: (v) => ['Первый', 'Второй', 'Третий'][v],
          onChanged: (v) => setState(() => _segment = v),
        ),
        AcademySegmentedControl<int>(
          items: const [0, 1, 2],
          value: _compactSegment,
          style: AcademySegmentStyle.compact,
          labelFor: (v) => ['1×', '1.5×', '2×'][v],
          onChanged: (v) => setState(() => _compactSegment = v),
        ),
        AcademyRow(
          title: 'Выбор',
          trailing: AcademyCheckmark(selected: _expanded),
          onPressed: () => setState(() => _expanded = !_expanded),
        ),
      ],
      'table' => [
        AcademyTableHeader.action(
          title: 'Секция',
          action: 'Изменить',
          onPressed: action,
        ),
        AcademyTableBody(
          rows: [
            const AcademyValueRow(label: 'Имя', value: 'Амина'),
            AcademyRow.action(
              title: 'Данные',
              action: 'Добавить',
              onPressed: action,
            ),
            AcademyRow(title: 'Переход', onPressed: action),
          ],
        ),
        AcademyGroupedTable(
          sections: const [
            AcademyTableSection(
              title: 'Группа',
              footer: 'Пояснение секции',
              rows: [AcademyRow(title: 'Строка без действия')],
            ),
          ],
        ),
        const AcademyTableHeader(title: 'Крупный заголовок', prominent: true),
        const AcademyDivider(),
        const TableMenuExamples(embedded: true),
      ],
      'surface' => [
        const AcademySurface(child: Text('Произвольное содержимое')),
        AcademyDisclosureCard(
          title: 'Подробнее',
          expanded: _expanded,
          onToggle: () => setState(() => _expanded = !_expanded),
          child: const Text('Управляемое раскрытие'),
        ),
        AcademyDisclosureTable(
          title: 'На все случаи жизни',
          subtitle: 'Крепость мусульманина',
          expanded: _expanded,
          onToggle: () => setState(() => _expanded = !_expanded),
          rows: const [
            AcademyRow(title: 'Сон и пробуждение', subtitle: '20 дуа'),
            AcademyRow(title: 'Мечеть и намаз', subtitle: '66 дуа'),
          ],
        ),
      ],
      'menus' => [
        AcademyMenuButton(
          title: 'Команды',
          items: [AcademyMenuItem(title: 'Выполнить', onPressed: action)],
        ),
        AcademyOptionMenu(
          label: 'Короткий выбор',
          value: _choice ?? 'ru',
          options: const ['ru', 'en', 'ar'],
          onSelected: (v) => setState(() => _choice = v),
        ),
        AcademyChromeMenu(
          label: 'Меню панели',
          value: _choice ?? 'ru',
          options: const ['ru', 'en', 'ar'],
          onSelected: (v) => setState(() => _choice = v),
        ),
        AcademyMenuRow(
          label: 'Команды строки',
          value: 'Открыть',
          items: [
            AcademyMenuItem(
              title: 'Выбранный пункт',
              checked: true,
              onPressed: action,
            ),
            const AcademyMenuSeparator(),
            AcademyMenuItem(
              title: 'С описанием',
              subtitle: 'Дополнительный текст',
              leadingIcon: AcademySymbols.book,
              onPressed: action,
            ),
            const AcademyMenuItem(title: 'Недоступный пункт'),
          ],
        ),
        AcademyLazyMenu(
          items: (_) => [
            AcademyMenuItem(
              title: 'Подготовлено при открытии',
              onPressed: action,
            ),
          ],
          builder: (_, open) =>
              AcademyTextButton(label: 'Ленивое меню', onPressed: open),
        ),
      ],
      'metadata' => [
        AcademyStatGroup(
          stats: [
            AcademyStat(label: 'Завершено', value: '12'),
            AcademyStat(label: 'Всего', value: '20'),
          ],
        ),
        AcademyPrayerStrip(
          caption: 'Аср через 1 ч 20 мин',
          highlighted: 2,
          onPressed: () {},
          times: const [
            AcademyPrayerTime(name: 'Фаджр', time: '05:12'),
            AcademyPrayerTime(name: 'Зухр', time: '12:31'),
            AcademyPrayerTime(name: 'Аср', time: '15:48'),
            AcademyPrayerTime(name: 'Магриб', time: '18:07'),
            AcademyPrayerTime(name: 'Иша', time: '19:34'),
          ],
        ),
        AcademyTimeline(
          items: [
            AcademyTimelineItem(
              title: 'Создано',
              date: '1 октября',
              state: AcademyTimelineState.completed,
            ),
            AcademyTimelineItem(
              title: 'В работе',
              date: '4 октября',
              state: AcademyTimelineState.current,
            ),
            AcademyTimelineItem(title: 'Проверка', date: '5 октября'),
          ],
        ),
      ],
      'media' => [
        const AcademyImage(label: 'Нет изображения'),
        for (final role in AcademyRowIcons.values)
          AcademyRow(
            title: role.name,
            iconColorRole: role,
            icon: switch (role) {
              AcademyRowIcons.person => AcademySymbols.person,
              AcademyRowIcons.trip => AcademySymbols.airplane,
              AcademyRowIcons.document => AcademySymbols.document,
              AcademyRowIcons.alert => AcademySymbols.bell,
              AcademyRowIcons.calendar => AcademySymbols.calendar,
              AcademyRowIcons.settings => AcademySymbols.gear,
              AcademyRowIcons.info => AcademySymbols.info,
              AcademyRowIcons.hotel => AcademySymbols.bed,
              AcademyRowIcons.passport => AcademySymbols.book,
            },
          ),
        const AcademySfImage(AcademySymbols.book),
        const AcademyChevron(),
      ],
      'foundations' => [
        Builder(
          builder: (context) {
            final theme = AcademyTheme.of(context);
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AcademyTableHeader(
                  title: 'Текст: ${AcademyTextRole.values.length} ролей',
                ),
                for (final role in AcademyTextRole.values)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Text(role.name, style: theme.textTheme.style(role)),
                  ),
                AcademyTableHeader(
                  title: 'Цвета: ${AcademyColorRole.values.length} ролей',
                ),
                for (final role in AcademyColorRole.values)
                  AcademyRow(
                    title: role.name,
                    trailing: SizedBox(
                      width: 32,
                      height: 24,
                      child: ColoredBox(color: theme.colorScheme.value(role)),
                    ),
                  ),
                AcademyTableHeader(
                  title: 'Радиусы: ${AcademyRadiusRole.values.length} ролей',
                ),
                for (final role in AcademyRadiusRole.values)
                  AcademyValueRow(
                    label: role.name,
                    value: '${theme.radii.value(role)}',
                  ),
                AcademyTableHeader(
                  title: 'Отступы: ${AcademyPaddingRole.values.length} ролей',
                ),
                for (final role in AcademyPaddingRole.values)
                  AcademyValueRow(
                    label: role.name,
                    value: '${theme.paddings.value(role)}',
                  ),
                const LoadingDotsLabel(text: 'Загрузка'),
                SoftFadeSwitcher(
                  child: Text(
                    _expanded ? 'Второе состояние' : 'Первое состояние',
                    key: ValueKey(_expanded),
                  ),
                ),
                AcademyButton(
                  label: 'Сменить состояние',
                  onPressed: () => setState(() => _expanded = !_expanded),
                ),
              ],
            );
          },
        ),
      ],
      'counter' => const [CounterComponentsDemo()],
      'journey' => [
        const AcademyJourneyProgress(
          title: 'Подготовка',
          completed: 2,
          total: 3,
        ),
        const AcademyJourneyProgress(
          title: 'Новый план',
          completed: 0,
          total: 0,
        ),
        AcademyChecklist(
          title: 'Чек-лист',
          items: [
            AcademyChecklistEntry(
              id: 'one',
              title: 'Первый шаг',
              completed: _expanded,
            ),
          ],
          onChanged: (_, done) => setState(() => _expanded = done),
        ),
        AcademyGuideStep(
          title: 'Шаг',
          description: 'Состоянием управляет клиент',
          step: _number,
          total: 3,
          onNext: () => setState(() => _number = _number % 3 + 1),
        ),
      ],
      'navigation' => [
        for (final style in AcademyChromeStyle.values)
          example(
            style.labelFor(context),
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: AcademyChromeGroup(
                style: style,
                actions: [
                  AcademyChromeAction(AcademySymbols.book, 'Книга', action),
                  AcademyChromeAction(AcademySymbols.search, 'Поиск', action),
                ],
              ),
            ),
          ),
        const AcademyChromeCapsule(child: Text('Навигационная капсула')),
        AcademyFloatingTabBar(
          tabs: [
            AcademyTab(
              label: 'Первый',
              icon: AcademySymbols.book,
              builder: (_) => const SizedBox(),
            ),
            AcademyTab(
              label: 'Второй',
              icon: AcademySymbols.gear,
              builder: (_) => const SizedBox(),
            ),
          ],
          index: _expanded ? 1 : 0,
          onChanged: (i) => setState(() => _expanded = i == 1),
        ),
      ],
      'feedback' => [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final tone in AcademyTone.values)
              AcademyStatus(
                label: switch (tone) {
                  AcademyTone.neutral => 'Обычный',
                  AcademyTone.success => 'Готово',
                  AcademyTone.warning => 'Внимание',
                  AcademyTone.error => 'Ошибка',
                },
                tone: tone,
              ),
          ],
        ),
        for (final kind in AcademyFeedbackKind.values)
          AcademyFeedback(
            kind: kind,
            title: switch (kind) {
              AcademyFeedbackKind.loading => 'Загрузка',
              AcademyFeedbackKind.empty => 'Пока ничего нет',
              AcademyFeedbackKind.error => 'Не удалось загрузить',
            },
            message: 'Пример состояния области',
            onRetry: kind == AcademyFeedbackKind.error ? action : null,
          ),
        AcademyRingProgress(value: _slider),
        AcademySlider(
          label: 'Прогресс',
          value: _slider,
          onChanged: (v) => setState(() => _slider = v),
        ),
        for (final position in AcademyToastPosition.values)
          AcademyButton(
            label: position == AcademyToastPosition.top
                ? 'Тост сверху'
                : 'Тост снизу',
            onPressed: () => AcademyToastHost.show(
              context,
              'Сохранено',
              position: position,
              leadingIcon: AcademySymbols.gear,
              trailingIcon: AcademySymbols.checkmark,
            ),
          ),
      ],
      'popover' => [
        for (final placement in AcademyPopoverPlacement.values)
          AcademyPopover(
            placement: placement,
            matchAnchorWidth: true,
            builder: (_, control) => AcademyButton(
              label: 'Панель: ${placement.name}',
              onPressed: control.toggle,
            ),
            contentBuilder: (_, close) => Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Padding(
                  padding: EdgeInsets.all(16),
                  child: Text('Содержимое панели'),
                ),
                AcademyTextButton(label: 'Готово', onPressed: close),
              ],
            ),
          ),
      ],
      'help' => [
        for (final placement in AcademyPopoverPlacement.values)
          AcademyTooltip(
            message: 'Справка по действию',
            placement: placement,
            child: AcademyButton(
              label: 'Подсказка: ${placement.name}',
              onPressed: action,
            ),
          ),
        AcademyButton(
          key: _tip,
          label: 'Элемент с объяснением',
          onPressed: action,
        ),
        AcademyTextButton(
          label: 'Показать объяснение',
          onPressed: () => showAcademyTips(context, [
            AcademyTip(
              target: _tip,
              title: 'Объяснение',
              message: 'Описание выбранного элемента',
            ),
          ]),
        ),
      ],
      'modal' => [const ModalCatalog(embedded: true)],
      _ => throw StateError('Missing demo: ${widget.component.id}'),
    };
  }

  @override
  Widget build(BuildContext context) {
    final inherited = AcademyTheme.of(context);
    final brightness = _brightness ?? inherited.brightness;
    final theme = _brightness == null
        ? inherited
        : academyTheme(
            brightness,
            accent: inherited.colorScheme.accentColor,
            colors: context
                .findAncestorWidgetOfExactType<AcademyApp>()
                ?.colorsBuilder
                ?.call(brightness, inherited.colorScheme.accentColor),
            radii: inherited.radii,
            paddings: inherited.paddings,
            typography: inherited.typography,
            interaction: inherited.interaction,
          );
    return AcademyTheme(
      data: theme,
      child: CupertinoTheme(
        data: theme.cupertino,
        child: Directionality(
          textDirection: _direction ?? Directionality.of(context),
          child: MediaQuery(
            data: MediaQuery.of(context).copyWith(
              textScaler: _large
                  ? const TextScaler.linear(2)
                  : MediaQuery.textScalerOf(context),
            ),
            child: Builder(
              builder: (context) {
                final children = <Widget>[
                  if (!widget.embedded) Text(widget.component.purpose),
                  const SizedBox(height: 8),
                  if (!widget.embedded)
                    Text(
                      widget.component.apis.join(' · '),
                      style: theme.textTheme.footnote,
                    ),
                  const SizedBox(height: 16),
                  if (widget.showControls)
                    AcademyGroupedTable(
                      sections: [
                        AcademyTableSection(
                          title: 'Проверка отображения',
                          rows: [
                            AcademyOptionMenu(
                              label: 'Тема примера',
                              value: _brightness == null
                                  ? 'По каталогу'
                                  : (_brightness == Brightness.dark
                                        ? 'Тёмная'
                                        : 'Светлая'),
                              options: const [
                                'По каталогу',
                                'Светлая',
                                'Тёмная',
                              ],
                              onSelected: (v) => setState(
                                () => _brightness = switch (v) {
                                  'Тёмная' => Brightness.dark,
                                  'Светлая' => Brightness.light,
                                  _ => null,
                                },
                              ),
                            ),
                            AcademyRow(
                              title: 'Текст 2×',
                              trailing: CupertinoSwitch(
                                value: _large,
                                onChanged: (v) => setState(() => _large = v),
                              ),
                            ),
                            AcademyOptionMenu(
                              label: 'Направление',
                              value: _direction == null
                                  ? 'По каталогу'
                                  : (_direction == TextDirection.rtl
                                        ? 'RTL'
                                        : 'LTR'),
                              options: const ['По каталогу', 'LTR', 'RTL'],
                              onSelected: (v) => setState(
                                () => _direction = switch (v) {
                                  'RTL' => TextDirection.rtl,
                                  'LTR' => TextDirection.ltr,
                                  _ => null,
                                },
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  const SizedBox(height: 24),
                  ..._demo(context)
                      .expand((w) => [w, const SizedBox(height: 16)]),
                  if (!widget.embedded && widget.component.related.isNotEmpty)
                    AcademyGroupedTable(
                      sections: [
                        AcademyTableSection(
                          title: 'Связанные компоненты',
                          rows: [
                            for (final id in widget.component.related)
                              AcademyRow(
                                title: componentById(id).title,
                                onPressed: () =>
                                    openComponent(context, componentById(id)),
                              ),
                          ],
                        ),
                      ],
                    ),
                  if (!widget.embedded && widget.component.scenarios.isNotEmpty)
                    AcademyGroupedTable(
                      sections: [
                        AcademyTableSection(
                          title: 'Примеры в сценариях',
                          rows: [
                            for (final id in widget.component.scenarios)
                              AcademyRow(
                                title: scenarioRegistry
                                    .singleWhere((s) => s.id == id)
                                    .title,
                                onPressed: () => Navigator.of(context).push(
                                  CupertinoPageRoute<void>(
                                    builder: scenarioRegistry
                                        .singleWhere((s) => s.id == id)
                                        .builder,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                ];
                return widget.embedded
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: children,
                      )
                    : catalogPage(context, widget.component.title, children);
              },
            ),
          ),
        ),
      ),
    );
  }
}
