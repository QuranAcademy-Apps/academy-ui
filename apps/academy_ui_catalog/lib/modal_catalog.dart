import 'package:academy_ui/academy_ui.dart';
import 'package:flutter/cupertino.dart';

import 'catalog_pages.dart';
import 'search_modal.dart';

class ModalCatalog extends StatelessWidget {
  const ModalCatalog({super.key, this.embedded = false});
  final bool embedded;

  void _content(
    BuildContext context,
    AcademyModalHeaderBehavior behavior,
  ) => showAcademySheet(
    context,
    title: 'Контент',
    height: 420,
    headerBehavior: behavior,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text('Прокрутите содержимое, чтобы увидеть переход под баром.'),
        const SizedBox(height: 16),
        for (var i = 1; i <= 20; i++)
          AcademyRow(
            title: 'Раздел $i',
            subtitle:
                'Содержимое движется, заголовок и закрытие остаются сверху.',
            icon: AcademySymbols.document,
          ),
      ],
    ),
  );
  Future<void> _form(BuildContext context) async {
    final result = await showAcademyModal<String>(
      context,
      title: 'Форма и клавиатура',
      detents: const [ModalSheetDetent.medium, ModalSheetDetent.full],
      builder: (context) => AcademyModalListView(
        children: [
          for (var i = 1; i <= 8; i++) AcademyField(label: 'Поле $i'),
          AcademyButton(
            label: 'Сохранить',
            onPressed: () => closeAcademyModal(context, 'Сохранено'),
          ),
        ],
      ),
    );
    if (context.mounted && result != null) {
      AcademyToastHost.show(context, result);
    }
  }

  @override
  Widget build(BuildContext context) {
    final children = <Widget>[
      const Text(
        'Проверьте открытие, перетаскивание, клавиатуру и возврат между вложенными экранами.',
      ),
      const SizedBox(height: 24),
      AcademyGroupedTable(
        sections: [
          AcademyTableSection(
            rows: [
              AcademyRow(
                title: 'Контентный шит',
                subtitle: 'Плавный фейд под верхним баром',
                onPressed: () =>
                    _content(context, AcademyModalHeaderBehavior.fade),
              ),
              AcademyRow(
                title: 'Контент · прозрачный бар',
                onPressed: () =>
                    _content(context, AcademyModalHeaderBehavior.overlay),
              ),
              AcademyRow(
                title: 'Контент · отдельно от бара',
                onPressed: () =>
                    _content(context, AcademyModalHeaderBehavior.separate),
              ),
              AcademyRow(
                title: 'Форма и клавиатура',
                onPressed: () => _form(context),
              ),
              AcademyRow(
                title: 'Поиск',
                onPressed: () => showAcademyModal<int>(
                  context,
                  title: 'Поиск',
                  builder: (_) => const SearchModal(),
                ),
              ),
              AcademyRow(
                title: 'Подтверждение',
                onPressed: () => showAcademyConfirmation(
                  context,
                  title: 'Продолжить?',
                  message: 'Подтверждение действия.',
                  confirmLabel: 'Продолжить',
                ),
              ),
              AcademyRow(
                title: 'Вложенные экраны',
                onPressed: () => showAcademyModal(
                  context,
                  title: 'Первый экран',
                  nestedNavigation: true,
                  headerBehavior: AcademyModalHeaderBehavior.fade,
                  builder: (context) => AcademyModalListView(
                    children: [
                      AcademyButton(
                        label: 'Следующий экран',
                        onPressed: () => pushAcademyModalPage(
                          context,
                          title: 'Второй экран',
                          builder: (context) => AcademyModalListView(
                            children: [
                              const AcademyField(label: 'Название'),
                              AcademyButton(
                                label: 'Закрыть весь поток',
                                onPressed: () => closeAcademyModal(context),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              AcademyRow(
                title: 'Начальная высота 300',
                onPressed: () => showAcademyModal(
                  context,
                  title: 'Своя высота',
                  initialDetent: ModalSheetDetent.auto,
                  autoHeight: 300,
                  detents: const [ModalSheetDetent.auto, ModalSheetDetent.full],
                  builder: (_) => const AcademyModalListView(
                    children: [
                      AcademyField(label: 'Нажмите для ввода'),
                      Text('После снятия фокуса возвращается заданная высота.'),
                    ],
                  ),
                ),
              ),
              AcademyRow(
                title: 'Длинный список · detents',
                onPressed: () => showAcademyModal(
                  context,
                  title: 'Список',
                  detents: const [
                    ModalSheetDetent.medium,
                    ModalSheetDetent.large,
                  ],
                  builder: (_) => AcademyModalListView(
                    children: [
                      for (var i = 1; i <= 60; i++)
                        AcademyRow(title: 'Пункт $i'),
                    ],
                  ),
                ),
              ),
              AcademyRow(
                title: 'Полная высота',
                onPressed: () => showAcademyModal(
                  context,
                  title: 'Полный экран',
                  initiallyExpanded: true,
                  builder: (_) => const AcademyModalListView(
                    children: [Text('Начальная высота — full.')],
                  ),
                ),
              ),
              AcademyRow(
                title: 'Тост внутри модалки',
                onPressed: () => showAcademyModal(
                  context,
                  title: 'Тост',
                  builder: (context) => AcademyModalListView(
                    children: [
                      AcademyButton(
                        label: 'Показать сверху',
                        onPressed: () => AcademyToastHost.show(
                          context,
                          'Сообщение над модалкой',
                          position: AcademyToastPosition.top,
                          leadingIcon: AcademySymbols.info,
                          trailingIcon: AcademySymbols.checkmark,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    ];
    return embedded
        ? Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: children,
          )
        : catalogPage(context, 'Модалки', children);
  }
}
