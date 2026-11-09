import 'package:academy_ui/academy_ui.dart';
import 'product/product.dart';
import 'package:flutter/cupertino.dart';

import 'catalog_pages.dart';

/// Dhikr/tasbih counter, page dots and a collection progress card
/// (first used by Zikro's reader and home screen).
class CounterComponentsDemo extends StatefulWidget {
  const CounterComponentsDemo({super.key});

  @override
  State<CounterComponentsDemo> createState() => _CounterComponentsDemoState();
}

class _CounterComponentsDemoState extends State<CounterComponentsDemo> {
  static const _pages = 17;
  static const _total = 3;
  int _count = 0, _page = 2;
  final _done = <int>{0, 1};
  final _searchKey = GlobalKey<AcademyExpandingSearchState>();
  final _query = TextEditingController();
  bool _searchOpen = false;
  String _text = '';

  @override
  void dispose() {
    _query.dispose();
    super.dispose();
  }

  void _tap() => setState(() {
    if (_count < _total) {
      _count++;
      if (_count == _total) _done.add(_page);
    } else if (_page < _pages - 1) {
      _page++;
      _count = 0;
    }
  });

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      example(
        'Счётчик: нажатие считает, удержание сбрасывает',
        Row(
          children: [
            AcademyCounterButton(
              count: _count,
              total: _total,
              label: 'Счётчик',
              onPressed: _tap,
              onLongPress: () => setState(() {
                _count = 0;
                _done.remove(_page);
              }),
            ),
            const SizedBox(width: 16),
            const AcademyCounterButton(count: 33, total: 33, label: 'Готово'),
          ],
        ),
      ),
      example(
        'Плитки «Каждый день» (удержание — меню)',
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: AcademyMenuAnchor(
                  enableLongPressToOpen: true,
                  consumeOutsideTaps: true,
                  menuChildren: [
                    AcademyMenuItem(
                      title: 'Начать сначала',
                      leadingIcon: AcademySymbols.restart,
                      onPressed: () {},
                    ),
                    AcademyMenuItem(
                      title: 'Сбросить прогресс',
                      leadingIcon: AcademySymbols.trash,
                      destructive: true,
                      onPressed: () {},
                    ),
                  ],
                  child: AcademyProgressTile(
                    title: 'Утренние азкары',
                    caption: '${_done.length}/$_pages',
                    progress: _done.length / _pages,
                    icon: AcademySymbols.sunrise,
                    iconColor: AcademyRowIcons.trip.colorOf(context),
                    highlighted: true,
                    onPressed: () {},
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: AcademyProgressTile(
                  title: 'Вечерние азкары',
                  caption: '16/16',
                  progress: 1,
                  icon: AcademySymbols.sunset,
                  iconColor: AcademyRowIcons.info.colorOf(context),
                  onPressed: () {},
                ),
              ),
            ],
          ),
        ),
      ),
      example(
        'Компактные плитки',
        Row(
          children: [
            Expanded(
              child: AcademyProgressTile(
                title: 'Утренние',
                icon: AcademySymbols.sunrise,
                iconColor: AcademyRowIcons.trip.colorOf(context),
                compact: true,
                onPressed: () {},
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: AcademyProgressTile(
                title: 'Вечерние',
                icon: AcademySymbols.sunset,
                iconColor: AcademyRowIcons.info.colorOf(context),
                compact: true,
                onPressed: () {},
              ),
            ),
          ],
        ),
      ),
      example(
        'Нумерованный список и меню «…»',
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AcademyGroupedTable(
              sections: [
                AcademyTableSection(
                  rows: [
                    for (var i = 1; i <= 3; i++)
                      AcademyRow(
                        leading: AcademyIndexBadge(i * 37),
                        title: 'Глава ${i * 37}',
                        subtitle: '$i дуа',
                        onPressed: () {},
                      ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            Align(
              alignment: AlignmentDirectional.centerEnd,
              child: AcademyChromeMenuButton(
                label: 'Ещё',
                items: [
                  AcademyMenuItem(
                    title: 'Список',
                    leadingIcon: AcademySymbols.list,
                    onPressed: () {},
                  ),
                  const AcademyMenuSeparator(),
                  AcademyMenuItem(
                    title: 'Сбросить прогресс',
                    leadingIcon: AcademySymbols.trash,
                    destructive: true,
                    onPressed: () {},
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      example(
        'Состояние поиска: затемнение, затем результаты',
        SizedBox(
          height: 220,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Stack(
              children: [
                const Positioned.fill(
                  child: Center(child: Text('Содержимое страницы')),
                ),
                Positioned.fill(
                  child: AcademySearchScrim(
                    active: _searchOpen,
                    onDismiss: () => _searchKey.currentState?.close(),
                    results: _text.isEmpty
                        ? null
                        : Center(child: Text('Результаты: «$_text»')),
                  ),
                ),
                Positioned(
                  top: 8,
                  left: 8,
                  right: 8,
                  child: AcademyExpandingSearch(
                    key: _searchKey,
                    controller: _query,
                    resting: const Center(child: Text('Заголовок')),
                    onOpenChanged: (open) => setState(() => _searchOpen = open),
                    onChanged: (text) => setState(() => _text = text.trim()),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      example(
        'Полноэкранный счётчик (больше трёх повторов)',
        SizedBox(
          height: 300,
          child: AcademyCounterView(
            count: _count,
            total: 33,
            label: 'Счётчик',
            hint: 'Нажимайте в любом месте',
            onPressed: () => setState(() => _count = (_count + 1) % 34),
          ),
        ),
      ),
      example(
        'Блок перевода (как в Quran)',
        const Column(
          children: [
            AcademyTextBlock(
              label: 'Транслитерация',
              text: 'Субхана-Ллахи ва би-хамди-хи.',
            ),
            SizedBox(height: 8),
            AcademyTextBlock(
              label: 'Перевод',
              text: 'Слава Аллаху и хвала Ему.',
            ),
          ],
        ),
      ),
      example(
        'Карточка подборки',
        Column(
          children: [
            AcademyProgressCard(
              title: 'Утренние азкары',
              subtitle: 'Прочитано ${_done.length} из $_pages',
              badge: 'Сейчас',
              icon: AcademySymbols.sunrise,
              iconColor: AcademyRowIcons.trip.colorOf(context),
              highlighted: true,
              progress: _done.length / _pages,
              onPressed: () {},
            ),
            const SizedBox(height: 12),
            AcademyProgressCard(
              title: 'Вечерние азкары',
              subtitle: 'Прочитано полностью',
              icon: AcademySymbols.sunset,
              iconColor: AcademyRowIcons.info.colorOf(context),
              progress: 1,
              onPressed: () {},
            ),
          ],
        ),
      ),
    ],
  );
}
