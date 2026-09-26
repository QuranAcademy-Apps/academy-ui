import 'package:academy_ui/academy_ui.dart';
import 'package:flutter/cupertino.dart';

import 'catalog_pages.dart';
import 'search_modal.dart';

class ModalCatalog extends StatelessWidget {
  const ModalCatalog({super.key});
  Future<void> _form(BuildContext context) async {
    final result = await showAcademyModal<String>(
      context,
      title: 'Форма и клавиатура',
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
  Widget build(BuildContext context) => catalogPage(context, 'Модалки', [
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
              onPressed: () => showAcademySheet(
                context,
                title: 'Контент',
                child: const Text('Обычное содержимое модалки.'),
              ),
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
                builder: (_) => AcademyModalListView(
                  children: [
                    for (var i = 1; i <= 60; i++) AcademyRow(title: 'Пункт $i'),
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
  ], tab: true);
}
