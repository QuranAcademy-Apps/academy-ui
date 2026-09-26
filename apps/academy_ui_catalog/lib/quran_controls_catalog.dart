import 'package:academy_ui/academy_ui.dart';
import 'package:flutter/cupertino.dart';

/// Interactive examples of the owner-requested Quran controls.
class QuranControlsCatalog extends StatefulWidget {
  const QuranControlsCatalog({super.key});
  @override
  State<QuranControlsCatalog> createState() => _QuranControlsCatalogState();
}

class _QuranControlsCatalogState extends State<QuranControlsCatalog> {
  final _search = TextEditingController();
  bool _expanded = false;
  int _segment = 0;
  String _theme = 'Классическая';
  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  List<Widget> get _themeItems => [
    for (final title in ['Классическая', 'Ночная', 'Системная'])
      AcademyMenuItem(
        title: title,
        checked: _theme == title,
        onPressed: () => setState(() => _theme = title),
      ),
  ];

  @override
  Widget build(BuildContext context) => AcademyPage(
    title: 'Элементы Quran',
    child: Builder(
      builder: (context) => ListView(
        padding: EdgeInsets.fromLTRB(
          16,
          AcademyPageInsets.topOf(context),
          16,
          AcademyFloatingTabBar.bottomObstructionOf(context) + 24,
        ),
        children: [
          const Text('Объединённые кнопки'),
          const SizedBox(height: 8),
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: AcademyChromeGroup(
              actions: [
                AcademyChromeAction(
                  AcademySymbols.book,
                  'Закладки',
                  () => AcademyToastHost.show(
                    context,
                    'Закладки',
                    leadingIcon: AcademySymbols.book,
                  ),
                ),
                AcademyChromeAction(
                  AcademySymbols.search,
                  'Поиск',
                  () => AcademyToastHost.show(
                    context,
                    'Поиск',
                    trailingIcon: AcademySymbols.search,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          AcademyDisclosureCard(
            title: 'Раскрывающийся список',
            expanded: _expanded,
            onToggle: () => setState(() => _expanded = !_expanded),
            child: const Column(
              children: [
                AcademyRow(
                  title: 'Первый пункт',
                  subtitle: 'Описание первого пункта',
                  icon: AcademySymbols.book,
                ),
                AcademyRow(
                  title: 'Второй пункт',
                  subtitle: 'Описание второго пункта',
                  icon: AcademySymbols.info,
                ),
                AcademyRow(
                  title: 'Третий пункт',
                  subtitle: 'Описание третьего пункта',
                  icon: AcademySymbols.checkmark,
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          const Text('Компактные сегменты и кнопки'),
          Row(
            children: [
              Expanded(
                child: AcademyCompactSegment<int>(
                  items: const [0, 1, 2],
                  value: _segment,
                  labelFor: (i) => ['Страница', 'Текст', 'Книга'][i],
                  iconFor: (i) => [
                    AcademySymbols.document,
                    AcademySymbols.checklist,
                    AcademySymbols.book,
                  ][i],
                  onChanged: (i) => setState(() => _segment = i),
                ),
              ),
              AcademyCompactIconButton(
                onPressed: () => AcademyToastHost.show(context, 'Закрыто'),
              ),
            ],
          ),
          Row(
            children: [
              Expanded(
                child: AcademyCompactSegment<int>(
                  items: const [0, 1, 2],
                  value: _segment,
                  labelFor: (i) => ['1×', '1.5×', '2×'][i],
                  style: AcademySegmentStyle.compact,
                  onChanged: (i) => setState(() => _segment = i),
                ),
              ),
              AcademyCompactIconButton(
                icon: AcademySymbols.plus,
                label: 'Увеличить',
                onPressed: () => setState(() => _segment = (_segment + 1) % 3),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              AcademySettingsSquareButton(
                icon: AcademySymbols.rotate,
                label: 'Повернуть',
                onPressed: () => AcademyToastHost.show(
                  context,
                  'Поворот',
                  leadingIcon: AcademySymbols.rotate,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: AcademyMenuButton(
                  title: 'Тема',
                  minimumHeight: 68,
                  expand: true,
                  subtitle: _theme,
                  style: AcademyChromeStyle.flat,
                  items: _themeItems,
                ),
              ),
              const SizedBox(width: 8),
              AcademySettingsSquareButton(
                icon: AcademySymbols.sun,
                label: 'Светлая тема',
                onPressed: () => AcademyToastHost.show(context, 'Светлая тема'),
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Text('Двойной шеврон и меню'),
          AcademyMenuButton(
            title: 'Uthmani 25',
            subtitle: 'Коран',
            chevronOnLeading: true,
            items: [
              AcademyMenuItem(
                title: 'Uthmani',
                checked: true,
                onPressed: () {},
              ),
              AcademyMenuItem(title: 'Old Mushaf', onPressed: () {}),
              AcademyMenuItem(title: 'New Mushaf', onPressed: () {}),
            ],
          ),
          AcademyMenuButton(
            title: 'Меню с иконками',
            items: [
              AcademyMenuItem(
                title: 'Начало',
                trailingIcon: AcademySymbols.play,
                onPressed: () {},
              ),
              AcademyMenuItem(
                title: 'Автопрокрутка',
                leadingIcon: AcademySymbols.upDown,
                onPressed: () {},
              ),
              AcademyMenuItem(
                title: 'Настройки',
                leadingIcon: AcademySymbols.gear,
                trailingIcon: AcademySymbols.forward,
                checked: true,
                onPressed: () {},
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Text('Лупа → поиск → крестик'),
          const SizedBox(height: 8),
          AcademyExpandingSearch(
            controller: _search,
            resting: const Text('Нажмите лупу'),
          ),
          const SizedBox(height: 20),
          const Text('Тосты — смахните в любую сторону'),
          AcademyButton(
            label: 'Сверху · иконка слева',
            onPressed: () => AcademyToastHost.show(
              context,
              'Сохранено',
              position: AcademyToastPosition.top,
              leadingIcon: AcademySymbols.checkmark,
            ),
          ),
          const SizedBox(height: 8),
          AcademyButton(
            label: 'Снизу · иконка справа',
            secondary: true,
            onPressed: () => AcademyToastHost.show(
              context,
              'Готово',
              trailingIcon: AcademySymbols.complete,
            ),
          ),
          const SizedBox(height: 8),
          AcademyButton(
            label: 'Иконки с двух сторон',
            secondary: true,
            onPressed: () => AcademyToastHost.show(
              context,
              'Настройки сохранены',
              leadingIcon: AcademySymbols.gear,
              trailingIcon: AcademySymbols.checkmark,
            ),
          ),
        ],
      ),
    ),
  );
}
