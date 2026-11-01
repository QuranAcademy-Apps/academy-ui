import 'package:academy_ui/academy_ui.dart';
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
        'Точки страниц: текущая и прочитанные',
        AcademyChromeCapsule(
          child: SizedBox(
            height: AcademyPageDots.height,
            child: AcademyPageDots(
              count: _pages,
              index: _page,
              isCompleted: _done.contains,
              onSelected: (page) => setState(() {
                _page = page;
                _count = _done.contains(page) ? _total : 0;
              }),
            ),
          ),
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
