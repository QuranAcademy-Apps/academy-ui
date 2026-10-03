import 'package:academy_ui/academy_ui.dart';
import 'package:flutter/cupertino.dart';

import 'catalog_pages.dart';

class ProfileComponentsCatalog extends StatelessWidget {
  const ProfileComponentsCatalog({super.key});
  @override
  Widget build(BuildContext context) =>
      catalogPage(context, 'Профиль и поездки', [
        for (final variant in const [
          'Обычный размер',
          'Крупный шрифт',
          'Тёмная тема',
          'Справа налево',
        ])
          example(
            variant,
            Builder(
              builder: (context) {
                final dark = variant == 'Тёмная тема';
                final theme = dark
                    ? academyTheme(Brightness.dark)
                    : AcademyTheme.of(context);
                return AcademyTheme(
                  data: theme,
                  child: CupertinoTheme(
                    data: theme.cupertino,
                    child: MediaQuery(
                      data: MediaQuery.of(context).copyWith(
                        textScaler: variant == 'Крупный шрифт'
                            ? const TextScaler.linear(2)
                            : MediaQuery.textScalerOf(context),
                      ),
                      child: Directionality(
                        textDirection: variant == 'Справа налево'
                            ? TextDirection.rtl
                            : TextDirection.ltr,
                        child: ColoredBox(
                          color: theme.scaffoldBackgroundColor,
                          child: Padding(
                            padding: theme.paddings.tableRow,
                            child: const ProfileComponentExamples(),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
      ]);
}

/// Shared by the visible catalog and the reproducible visual capture.
class ProfileComponentExamples extends StatelessWidget {
  const ProfileComponentExamples({super.key});
  @override
  Widget build(BuildContext context) {
    void action() => AcademyToastHost.show(context, 'Действие выполнено');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AcademyTableHeader.action(
          title: 'Мои данные',
          action: 'Изменить',
          onPressed: action,
        ),
        AcademyTableBody(
          rows: [
            const AcademyValueRow(label: 'Имя', value: 'Амина Абдуллаева'),
            const AcademyValueRow(
              label: 'Номер участника',
              value: '1042',
              readOnly: true,
              subtitle: 'Подтверждённые данные',
            ),
            AcademyValueRow(label: 'Город', value: 'Москва', onPressed: action),
            AcademyRow.action(
              title: 'Данные не заполнены',
              action: 'Добавить',
              onPressed: action,
            ),
            AcademyRow(
              title: 'Удалить данные',
              icon: AcademySymbols.trash,
              tone: AcademyTone.error,
              showChevron: false,
              onPressed: action,
            ),
          ],
        ),
        const SizedBox(height: AcademyTokens.gutter),
        AcademyActionButton(
          title: 'Открыть информацию',
          subtitle: 'Всё необходимое под рукой',
          icon: AcademySymbols.info,
          onPressed: action,
        ),
        const SizedBox(height: AcademyTokens.space),
        AcademyActionButton(
          title: 'Связаться с организатором',
          subtitle: 'Помощь и поддержка',
          icon: AcademySymbols.phone,
          style: AcademyButtonStyle.tinted,
          onPressed: action,
        ),
        const SizedBox(height: AcademyTokens.space),
        const AcademyActionButton(
          title: 'Сохранение',
          subtitle: 'Подождите немного',
          icon: AcademySymbols.checkmark,
          pending: true,
        ),
        const SizedBox(height: AcademyTokens.space),
        const AcademyActionButton(
          title: 'Недоступное действие',
          icon: AcademySymbols.info,
        ),
        const SizedBox(height: AcademyTokens.space),
        Wrap(
          spacing: AcademyTokens.space,
          children: [
            AcademyPillButton(
              label: 'Карта',
              icon: AcademySymbols.location,
              onPressed: action,
            ),
            AcademyPillButton(
              label: 'Связаться',
              icon: AcademySymbols.person,
              onPressed: action,
            ),
            const AcademyPillButton(
              label: 'Недоступно',
              icon: AcademySymbols.close,
            ),
          ],
        ),
        const SizedBox(height: AcademyTokens.gutter),
        AcademyStatGroup(
          stats: const [
            AcademyStat(
              label: 'Начало',
              value: '12 октября',
              alignment: AcademyStatAlignment.start,
            ),
            AcademyStat(
              label: 'Длительность',
              value: '10 дней',
              alignment: AcademyStatAlignment.center,
            ),
            AcademyStat(
              label: 'Окончание',
              value: '22 октября',
              alignment: AcademyStatAlignment.end,
            ),
          ],
        ),
        const SizedBox(height: AcademyTokens.gutter),
        const AcademyTimeline(
          items: [
            AcademyTimelineItem(
              title: 'Подготовка',
              date: '10 октября',
              subtitle: 'Документы готовы',
              state: AcademyTimelineState.completed,
            ),
            AcademyTimelineItem(
              title: 'Начало поездки',
              date: '12 октября',
              subtitle: 'Встреча с группой',
              state: AcademyTimelineState.current,
            ),
            AcademyTimelineItem(title: 'Возвращение', date: '22 октября'),
          ],
        ),
        const SizedBox(height: AcademyTokens.gutter),
        AcademyTableHeader(title: 'Плитки иконок', uppercase: false),
        AcademyTableBody(
          rows: [
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
          ],
        ),
      ],
    );
  }
}
