import 'package:academy_ui/academy_ui.dart';
import 'package:flutter/cupertino.dart';

import 'catalog_pages.dart';

class TableMenuExamples extends StatefulWidget {
  const TableMenuExamples({super.key});
  @override
  State<TableMenuExamples> createState() => _TableMenuExamplesState();
}

class _TableMenuExamplesState extends State<TableMenuExamples> {
  String _theme = 'Светлая';
  bool _editing = false, _enabled = true;
  final _groups = <String, List<String>>{
    'list': ['Эльмир Кулиев', 'Абу Адель'],
    'card': ['Тафсир ас-Саади', 'Тафсир Ибн Касира', 'Тафсир ат-Табари'],
  };
  List<Widget> get _themes => [
    for (final title in ['Системная', 'Тёмная', 'Светлая'])
      AcademyMenuItem(
        title: title,
        checked: _theme == title,
        onPressed: () => setState(() => _theme = title),
      ),
  ];
  void _move(
    AcademyTableDragData<String> data,
    Object destination,
    int index,
  ) => setState(() {
    // Feature owns order; the library supplies an index after source removal.
    if (!_groups[data.sectionId]!.remove(data.item)) return;
    _groups[destination]!.insert(
      index.clamp(0, _groups[destination]!.length),
      data.item,
    );
  });
  @override
  Widget build(BuildContext context) => catalogPage(context, 'Таблица и меню', [
    AcademyGroupedTable(
      sections: [
        AcademyTableSection(
          title: 'Основные',
          footer: 'Меню открывается по всей строке.',
          rows: [
            AcademyMenuRow(label: 'Тема', value: _theme, items: _themes),
            const AcademyRow(
              title: 'Цветовая схема',
              subtitle: 'Строка с описанием',
              trailing: AcademyCheckmark(),
            ),
          ],
        ),
        AcademyTableSection(
          title: 'Только правый элемент',
          footer: 'Название не открывает меню. Нажмите значение с двойным шевроном.',
          rows: [
            AcademyMenuRow(
              label: 'Тема',
              value: _theme,
              items: _themes,
              activation: AcademyMenuActivation.accessory,
            ),
          ],
        ),
        AcademyTableSection(
          title: 'Настройка содержимого',
          rows: [
            AcademyMenuRow(
              label: 'Варианты пунктов',
              value: 'Открыть',
              items: [
                AcademyMenuItem(
                  title: 'Иконка слева',
                  leadingIcon: AcademySymbols.book,
                  onPressed: () {},
                ),
                AcademyMenuItem(
                  title: 'Иконка справа',
                  trailingIcon: AcademySymbols.play,
                  onPressed: () {},
                ),
                AcademyMenuItem(
                  title: 'Галочка слева',
                  checked: true,
                  selectionPosition: AcademyMenuSelectionPosition.leading,
                  onPressed: () {},
                ),
                const AcademyMenuSeparator(),
                AcademyMenuItem(
                  title: 'Описание',
                  subtitle: 'Без иконок',
                  onPressed: () {},
                ),
                AcademyMenuItem(
                  title: 'Без отметки',
                  checked: true,
                  selectionPosition: AcademyMenuSelectionPosition.none,
                  onPressed: () {},
                ),
                AcademyMenuItem(
                  title: 'Удалить',
                  leadingIcon: AcademySymbols.trash,
                  destructive: true,
                  onPressed: () {},
                ),
              ],
            ),
          ],
        ),
      ],
    ),
    const SizedBox(height: 24),
    AcademyTableHeader(
      title: 'Загруженные',
      padding: const EdgeInsets.fromLTRB(16, 0, 12, 8),
      style: AcademyTheme.of(context).textTheme.sectionLabel,
      trailing: CupertinoButton(
        padding: EdgeInsets.zero,
        minimumSize: Size.zero,
        onPressed: () => setState(() => _editing = !_editing),
        child: Text(
          _editing ? 'Готово' : 'Изменить',
          style: AcademyTheme.of(context).textTheme.bodySmall
              .copyWith(fontWeight: FontWeight.w600),
        ),
      ),
    ),
    for (final id in _groups.keys) ...[
      AcademyDraggableTableSection<String>(
        sectionId: id,
        items: _groups[id]!,
        itemId: (item) => item,
        labelForItem: (item) => item,
        moveTargets: [
          for (final destination in _groups.keys)
            AcademyTableMoveTarget<String>(
              sectionId: destination,
              label: destination == 'list'
                  ? 'При чтении аятов'
                  : 'При открытии аята',
              itemCount: _groups[destination]!.length,
              enabled: _enabled && !_editing,
            ),
        ],
        enabled: _enabled,
        editing: _editing,
        onMove: _move,
        onRemove: (item) => setState(() => _groups[id]!.remove(item)),
        header: AcademyTableHeader(
          title: id == 'list' ? 'При чтении аятов' : 'При открытии аята',
          padding: const EdgeInsets.fromLTRB(20, 10, 12, 10),
          style: AcademyTheme.of(context).textTheme.sectionLabel.copyWith(
            color: AcademyTheme.of(context).colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.w700,
          ),
          trailing: CupertinoSwitch(
            value: _enabled,
            activeTrackColor: AcademyTheme.of(context).colorScheme.primary,
            onChanged: (value) => setState(() => _enabled = value),
          ),
        ),
        rowBuilder: (context, item, accessory) => AcademyRow(
          title: item,
          horizontalPadding: 20,
          verticalPadding: 12,
          minHeight: 58,
          subtitleWidget: Wrap(
            spacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text(
                'Русский',
                style: AcademyTheme.of(context).textTheme.bodyMedium.copyWith(
                  color: AcademyTheme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              if (item.startsWith('Тафсир'))
                const AcademyTableBadge(label: 'Тафсир'),
            ],
          ),
          trailing: accessory,
        ),
      ),
      if (id != _groups.keys.last) const SizedBox(height: 12),
    ],
    const AcademyTableFooter(
      text: 'Перетащите строку за значок справа или нажмите на него, чтобы выбрать новое место. В режиме «Изменить» можно удалить строку.',
    ),
    const SizedBox(height: 24),
    const Text('Отдельные компоненты секции'),
    const SizedBox(height: 8),
    const AcademyTableHeader(title: 'Самостоятельный заголовок'),
    const AcademyTableBody(
      rows: [
        AcademyRow(title: 'Пользовательский контент'),
        AcademyRow(title: 'Отдельное тело секции'),
      ],
    ),
    const AcademyTableFooter(
      text: 'Самостоятельный футер. Разделители, радиус, заголовок и содержимое заменяются приложением.',
    ),
  ]);
}
