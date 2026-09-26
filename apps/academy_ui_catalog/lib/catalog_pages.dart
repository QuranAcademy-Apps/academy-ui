import 'package:academy_ui/academy_ui.dart';
import 'package:flutter/cupertino.dart';

import 'table_menu_examples.dart';

enum CatalogSection {
  buttons('Кнопки и действия', AcademySymbols.play),
  input('Поля и выбор', AcademySymbols.filters),
  lists('Таблицы и карточки', AcademySymbols.checklist),
  navigation('Навигация и меню', AcademySymbols.upDown),
  feedback('Состояния и тосты', AcademySymbols.info),
  progress('Прогресс и чек-листы', AcademySymbols.complete),
  foundations('Цвета, текст и иконки', AcademySymbols.sun),
  motion('Анимации и подсказки', AcademySymbols.expand);

  const CatalogSection(this.title, this.icon);
  final String title;
  final IconData icon;
}

Widget catalogPage(
  BuildContext context,
  String title,
  List<Widget> children, {
  bool tab = false,
}) => AcademyPage(
  title: title,
  child: Builder(
    builder: (context) => ListView(
      padding: EdgeInsets.fromLTRB(
        16,
        AcademyPageInsets.topOf(context),
        16,
        tab ? AcademyFloatingTabBar.bottomObstructionOf(context) + 24 : 24,
      ),
      children: children,
    ),
  ),
);

Widget example(String title, Widget child) => Padding(
  padding: const EdgeInsets.only(bottom: 24),
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [Text(title), const SizedBox(height: 10), child],
  ),
);

class CatalogIndex extends StatelessWidget {
  const CatalogIndex({super.key});
  @override
  Widget build(BuildContext context) => catalogPage(context, 'Academy UI', [
    const Text(
      'Все компоненты в одном приложении. Выберите раздел, чтобы проверить внешний вид и поведение.',
    ),
    const SizedBox(height: 24),
    AcademyGroupedTable(
      sections: [
        AcademyTableSection(
          title: 'Компоненты',
          rows: [
            for (final section in CatalogSection.values)
              AcademyRow(
                title: section.title,
                icon: section.icon,
                onPressed: () => Navigator.of(context).push(
                  CupertinoPageRoute<void>(
                    builder: (_) => ComponentExamples(section: section),
                  ),
                ),
              ),
          ],
        ),
      ],
    ),
    const AcademySurface(
      child: Text(
        'Во вкладке Quran — элементы из ваших скриншотов. В «Модалках» — формы, поиск, вложенные экраны и detents. Оформление применяется ко всему каталогу.',
      ),
    ),
  ], tab: true);
}

class ComponentExamples extends StatefulWidget {
  const ComponentExamples({super.key, required this.section});
  final CatalogSection section;
  @override
  State<ComponentExamples> createState() => _ComponentExamplesState();
}

class _ComponentExamplesState extends State<ComponentExamples> {
  final _search = TextEditingController();
  final _tipTarget = GlobalKey();
  int _count = 3, _step = 1;
  bool _enabled = true, _selected = false;
  final _completed = <String>{};
  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  void _toast(String text) => AcademyToastHost.show(context, text);
  @override
  Widget build(BuildContext context) {
    final theme = AcademyTheme.of(context);
    final children = switch (widget.section) {
      CatalogSection.buttons => <Widget>[
        example(
          'Основная',
          AcademyButton(
            label: 'Выполнить действие',
            onPressed: () => _toast('Готово'),
          ),
        ),
        example(
          'Вторичная',
          AcademyButton(
            label: 'Дополнительное действие',
            secondary: true,
            onPressed: () => _toast('Выбрано'),
          ),
        ),
        example('Недоступная', const AcademyButton(label: 'Недоступно')),
        example(
          'Ожидание',
          const AcademyButton(label: 'Сохранение…', pending: true),
        ),
        AcademyTextButton(
          label: 'Текстовая кнопка',
          onPressed: () => _toast('Нажато'),
        ),
        Wrap(
          spacing: 16,
          children: [
            AcademyIconButton(
              icon: AcademySymbols.plus,
              label: 'Добавить',
              onPressed: () => _toast('Добавлено'),
            ),
            AcademyInfoButton(onPressed: () => _toast('Информация')),
            AcademyCompactIconButton(onPressed: () => _toast('Закрыто')),
          ],
        ),
      ],
      CatalogSection.input => <Widget>[
        const AcademyField(label: 'Название', help: 'Обычное поле'),
        const AcademyField(label: 'Ошибка', error: 'Заполните поле'),
        const AcademyField(label: 'Недоступное поле', enabled: false),
        example(
          'Поиск',
          AcademySearchBar(controller: _search, onCancel: _search.clear),
        ),
        AcademyRow(
          title: 'Количество: $_count',
          trailing: AcademyStepper(
            value: _count,
            onChanged: (i) => setState(() => _count = i),
          ),
        ),
        AcademyRow(
          title: 'Переключатель',
          trailing: CupertinoSwitch(
            value: _enabled,
            onChanged: (v) => setState(() => _enabled = v),
          ),
        ),
        AcademyRow(
          title: 'Выбор',
          trailing: AcademyCheckmark(selected: _selected),
          onPressed: () => setState(() => _selected = !_selected),
        ),
      ],
      CatalogSection.lists => <Widget>[
        AcademyButton(
          label: 'Таблица, меню и перетаскивание',
          onPressed: () => Navigator.of(context).push(
            CupertinoPageRoute<void>(builder: (_) => const TableMenuExamples()),
          ),
        ),
        const SizedBox(height: 24),
        AcademyGroupedTable(
          sections: [
            AcademyTableSection(
              title: 'Секция',
              footer: 'Подпись секции',
              rows: [
                AcademyRow(
                  title: 'Строка с иконкой',
                  subtitle: 'Описание',
                  icon: AcademySymbols.book,
                  onPressed: () => _toast('Строка'),
                ),
                const AcademyRow(title: 'Строка без действия'),
                AcademyOptionMenu(
                  label: 'Выбор',
                  value: 'Первый',
                  options: const ['Первый', 'Второй'],
                  onSelected: _toast,
                ),
              ],
            ),
          ],
        ),
        const AcademyDivider(),
        example(
          'Поверхность',
          const AcademySurface(
            child: Text(
              'Карточка остаётся непрозрачной при любом оформлении навигации.',
            ),
          ),
        ),
        example(
          'Изображение · без данных',
          const AcademyImage(label: 'Заглушка изображения'),
        ),
      ],
      CatalogSection.navigation => <Widget>[
        for (final style in AcademyChromeStyle.values)
          example(
            style.label,
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: AcademyChromeGroup(
                style: style,
                actions: [
                  AcademyChromeAction(
                    AcademySymbols.book,
                    'Книга',
                    () => _toast('Книга'),
                  ),
                  AcademyChromeAction(
                    AcademySymbols.search,
                    'Поиск',
                    () => _toast('Поиск'),
                  ),
                ],
              ),
            ),
          ),
        AcademyChromeCapsule(child: const Text('Навигационная капсула')),
        AcademyChromeMenu(
          label: 'Меню навигации',
          value: 'Первый',
          options: const ['Первый', 'Второй'],
          onSelected: _toast,
        ),
        AcademyLazyMenu(
          items: (_) => [
            AcademyMenuItem(
              title: 'Ленивое меню',
              onPressed: () => _toast('Выбрано'),
            ),
          ],
          builder: (_, open) =>
              AcademyTextButton(label: 'Открыть ленивое меню', onPressed: open),
        ),
        const AcademyChevron(),
        const SizedBox(height: 16),
        AcademyFloatingTabBar(
          tabs: [
            AcademyTab(
              label: 'Один',
              icon: AcademySymbols.book,
              builder: (_) => const SizedBox(),
            ),
            AcademyTab(
              label: 'Два',
              icon: AcademySymbols.gear,
              builder: (_) => const SizedBox(),
            ),
          ],
          index: _selected ? 1 : 0,
          onChanged: (i) => setState(() => _selected = i == 1),
        ),
      ],
      CatalogSection.feedback => <Widget>[
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final tone in AcademyTone.values)
              AcademyStatus(label: tone.name, tone: tone),
          ],
        ),
        for (final kind in AcademyFeedbackKind.values)
          AcademyFeedback(
            kind: kind,
            title: switch (kind) {
              AcademyFeedbackKind.loading => 'Загрузка',
              AcademyFeedbackKind.empty => 'Пока ничего нет',
              AcademyFeedbackKind.error => 'Ошибка загрузки',
            },
            message: 'Пример состояния интерфейса',
            onRetry: kind == AcademyFeedbackKind.error
                ? () => _toast('Повторная попытка')
                : null,
          ),
        for (final position in AcademyToastPosition.values)
          example(
            position == AcademyToastPosition.top ? 'Тост сверху' : 'Тост снизу',
            AcademyButton(
              label: 'Показать и смахнуть',
              onPressed: () => AcademyToastHost.show(
                context,
                'Сообщение сохранено',
                position: position,
                leadingIcon: AcademySymbols.gear,
                trailingIcon: AcademySymbols.checkmark,
              ),
            ),
          ),
      ],
      CatalogSection.progress => <Widget>[
        Row(
          children: [
            AcademyRingProgress(value: _count / 10),
            const SizedBox(width: 20),
            AcademyStepper(
              value: _count,
              onChanged: (i) => setState(() => _count = i),
            ),
          ],
        ),
        const SizedBox(height: 24),
        AcademyChecklist(
          title: 'Проверка компонентов',
          items: [
            for (final id in ['Тема', 'Модалки', 'Клавиатура'])
              AcademyChecklistEntry(
                id: id,
                title: id,
                completed: _completed.contains(id),
              ),
          ],
          onChanged: (id, done) =>
              setState(() => done ? _completed.add(id) : _completed.remove(id)),
        ),
        const SizedBox(height: 24),
        AcademyGuideStep(
          title: 'Демонстрация шага',
          description: 'Состояние шага хранит приложение.',
          step: _step,
          total: 3,
          onNext: () => setState(() => _step = _step == 3 ? 1 : _step + 1),
          onPrevious: _step == 1 ? null : () => setState(() => _step--),
        ),
      ],
      CatalogSection.foundations => <Widget>[
        Text('Заголовок', style: theme.textTheme.titleLarge),
        Text('Основной текст · Inter', style: theme.textTheme.bodyLarge),
        Text(
          'Подпись и дополнительный текст',
          style: theme.textTheme.bodySmall,
        ),
        const SizedBox(height: 24),
        for (final (label, color) in [
          ('Основной', theme.colorScheme.primary),
          ('Поверхность', theme.colorScheme.surface),
          ('Поле', theme.colorScheme.surfaceContainerHighest),
          ('Ошибка', theme.colorScheme.error),
        ])
          AcademyRow(
            title: label,
            trailing: Container(
              width: 48,
              height: 32,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        const SizedBox(height: 24),
        Wrap(
          spacing: 16,
          runSpacing: 16,
          children: [
            for (final icon in [
              AcademySymbols.book,
              AcademySymbols.search,
              AcademySymbols.gear,
              AcademySymbols.sun,
              AcademySymbols.moon,
              AcademySymbols.upDown,
              AcademySymbols.rotate,
              AcademySymbols.checkmark,
            ])
              AcademySfImage(icon, foreground: theme.colorScheme.primary),
          ],
        ),
      ],
      CatalogSection.motion => <Widget>[
        const LoadingDotsLabel(text: 'Загрузка'),
        const SizedBox(height: 24),
        SoftFadeSwitcher(
          child: Text(
            _selected ? 'Второе состояние' : 'Первое состояние',
            key: ValueKey(_selected),
          ),
        ),
        AcademyButton(
          label: 'Сменить состояние',
          onPressed: () => setState(() => _selected = !_selected),
        ),
        const SizedBox(height: 24),
        PressScale(
          child: AcademyButton(
            key: _tipTarget,
            label: 'Кнопка с откликом',
            onPressed: () => _toast('Нажато'),
          ),
        ),
        AcademyTextButton(
          label: 'Показать подсказку',
          onPressed: () => showAcademyTips(context, [
            AcademyTip(
              target: _tipTarget,
              title: 'Подсказка',
              message: 'Пример подсказки к элементу интерфейса.',
            ),
          ]),
        ),
      ],
    };
    return catalogPage(context, widget.section.title, children);
  }
}

class AppearancePage extends StatelessWidget {
  const AppearancePage({
    super.key,
    required this.controller,
    this.customColors = false,
    this.onCustomColorsChanged,
  });
  final AcademyAppearanceController controller;
  final bool customColors;
  final ValueChanged<bool>? onCustomColorsChanged;
  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: controller,
    builder: (context, _) {
      final value = controller.value;
      return catalogPage(context, 'Оформление', [
        AcademyOptionMenu(
          label: 'Палитра',
          value: customColors ? 'Пример клиента' : 'По умолчанию',
          options: const ['По умолчанию', 'Пример клиента'],
          onSelected: (value) =>
              onCustomColorsChanged?.call(value == 'Пример клиента'),
        ),
        const Text(
          'Цвета задаёт приложение: можно заменить любую роль для светлой и тёмной темы. Пример палитры действует до перезапуска каталога.',
        ),
        AcademyGroupedTable(
          sections: [
            AcademyTableSection(
              rows: [
                AcademyOptionMenu(
                  label: 'Тема',
                  value: value.mode.name,
                  options: AcademyAppearanceMode.values
                      .map((e) => e.name)
                      .toList(),
                  onSelected: (mode) => controller.update(
                    value.copyWith(
                      mode: AcademyAppearanceMode.values.byName(mode),
                    ),
                  ),
                ),
                AcademyOptionMenu(
                  label: 'Навигация',
                  value: value.chromeStyle.label,
                  options: AcademyChromeStyle.values
                      .map((e) => e.label)
                      .toList(),
                  onSelected: (style) => controller.update(
                    value.copyWith(
                      chromeStyle: AcademyChromeStyle.values.firstWhere(
                        (e) => e.label == style,
                      ),
                    ),
                  ),
                ),
                const AcademyRow(
                  title: 'Blur 20',
                  subtitle: 'Только элементы навигации',
                ),
                AcademyOptionMenu(
                  label: 'Пропорции таббара',
                  value: value.tabBarDensity.label,
                  options: AcademyTabBarDensity.values
                      .map((e) => e.label)
                      .toList(),
                  onSelected: (label) => controller.update(
                    value.copyWith(
                      tabBarDensity: AcademyTabBarDensity.values.firstWhere(
                        (e) => e.label == label,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        const Text('Акцент'),
        Wrap(
          spacing: 8,
          children: [
            for (final color in const [
              Color(0xff263e59),
              Color(0xff137f73),
              Color(0xff7163b5),
              Color(0xffa84c43),
              Color(0xff54684c),
            ])
              CupertinoButton(
                onPressed: controller.isLoading
                    ? null
                    : () => controller.update(value.copyWith(accent: color)),
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
          ],
        ),
        const AcademySurface(
          child: Text(
            'Настройки сохраняются и применяются ко всем разделам, включая уже открытые модалки.',
          ),
        ),
        if (controller.isLoading) const Text('Восстановление настроек…'),
        if (controller.persistenceError != null)
          const Text('Не удалось сохранить настройки'),
      ], tab: true);
    },
  );
}
