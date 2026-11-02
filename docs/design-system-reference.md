# Справочник дизайн-системы Academy UI

Актуальные контракты с исправлениями ревью 5 октября 2026 года. Нормы Apple и проверенный
UIKit-эталон описаны в [APPLE_HIG.md](frontend/APPLE_HIG.md). Эти категории —
организация библиотеки, а не требование Apple.

## Канонические категории и выбор

Справочный [реестр](../apps/academy_ui_catalog/lib/component_registry.dart)
описывает категории, имена API, связанные компоненты и сценарии. Он относится
к альтернативным справочным страницам, которые не подключены к текущему
`CatalogApp`. Работающее приложение использует четыре вкладки «Каталог»,
«Quran», «Модалки», «Оформление» и разделы `CatalogSection`/
`AdvancedCatalogSection`. Добавление записи в реестр само по себе не добавляет
компонент на главный экран: нужен пример в действующем разделе каталога.
Одна справочная запись может описывать несколько тесно связанных вариантов;
отдельное имя класса не означает отдельную независимую реализацию.

| Задача | Выбор и отличие |
| --- | --- |
| Одна команда | Button; ActionButton при описании, PillButton для компактного действия; IconButton требует понятной подписи |
| Текст | TextField — редактор; Field — подпись/помощь; FloatingTextField — плавающая подпись; TextFormField — интеграция Form |
| Свой ввод | TextInput отвечает за редактирование/focus/accessories; FieldDecoration добавляет подпись/ошибку; FormField проверяет управляемое значение |
| Поиск | SearchBar постоянно виден; ExpandingSearch заменяет заголовок навигации. Основа редактирования общая |
| Варианты | Select ограничивает значение, MultiSelect — набор; Autocomplete разрешает свободный текст |
| Короткий выбор строки | OptionMenu; Select при проверке формы, поиске, группах или внешней загрузке |
| Числа | Stepper — дискретное значение, Slider — диапазон; это ввод, а не индикаторы прогресса |
| Небольшой набор | SegmentedControl; компактный вариант — `AcademySegmentedControl.compact` |
| День или диапазон | Calendar / RangeCalendar; LineCalendar — лента; DateField / TimeField — trigger с подтверждением; Picker — колесо |
| Короткие настройки | GroupedTable / TableBody / Row / ValueRow; Surface для произвольного контента; DisclosureCard для раскрытия |
| Переходы | Page, Chrome, таббар; меню команды остаётся в «Меню и наложения» |
| Команды | MenuButton — готовая кнопка, MenuAnchor — собственный trigger, LazyMenu — данные при открытии; MenuRow — композиция строки |
| Отдельная задача | Modal / Sheet / Confirmation; вложенный Navigator и typed result принадлежат потоку |
| Панель у элемента | Popover с фокусом/закрытием; Tooltip для пояснения, Tips для последовательности помощи — группа «Подсказки» |
| Данные | StatGroup — метаданные, Timeline — события. Эти компоненты не зависят от поездок |
| Обратная связь | Status — метка, Feedback — состояние области с retry, Toast — временное сообщение, RingProgress — доля |
| Задачи и шаги | JourneyProgress отдельно от Checklist; GuideStep — управляемый шаг |
| Медиа | Image с fallback, SfImage/SfIcon, Symbols; InfoButton находится в действиях |

Профиль/поездки, Quran, формы с загрузкой, дата/настройки, меню в таблице,
модальные потоки и помощь — сценарии композиции. Текущий каталог открывает
эти примеры через свои разделы и вкладки; инструменты снимков сохранены.

В альтернативной справочной карточке доступны наследование темы/направления, явная светлая/тёмная
тема, LTR/RTL и масштаб 2×. Перечень состояний относится только к применимым
вариантам. Disabled, pending, error/read-only представлены там, где поддерживаются;
загрузка/retry Select и validation/reset формы доступны в связанном сценарии.
Инфраструктуре достаточно рецепта композиции. Эти примеры не заменяют проверку
VoiceOver, клавиатуры и плавности на физическом устройстве.

## Уровни публичного API

| Уровень | Контракты | Как использовать |
| --- | --- | --- |
| Готовые компоненты | Кнопки, поля, Select, таблицы, навигация, feedback, медиа, шаги | Основной импорт `package:academy_ui/academy_ui.dart`; данные и callbacks передаёт приложение |
| Модели и настройки | SelectOption, DateRange, Time, TimelineItem, Stat, ChecklistEntry, Tab, Theme, Colors, Radii, Paddings, TypographySettings | Значения и снимки коллекций; внешние контроллеры принадлежат клиенту |
| Композиция формы | TextInput, FieldDecoration, FormField, PickerTrigger | Собственный редактор/trigger без копирования поведения готового поля |
| Композиция меню | MenuAnchor, Menu/MenuRow/MenuDisplay/MenuSeparator, PopoverController | Собственный trigger и row-композиция; владение overlay/focus остаётся в API |
| Геометрия таблицы | TableRowGeometry, TableRowLayout, TableRowScope; TableSectionView, drag-модели | Сообщить inset строки через интерфейс или wrapper; таблица не знает конкретные виды меню |
| Поверхность и модальный механизм | ModalSheetSurfaceScope, RoundedSurface, MaskedFill; route/detents/insets | Низкий уровень для собственной композиции. Реализация маски в foundation, старый путь совместим |
| Взаимодействие | Tappable, FocusOutline, PressScale, motion-примитивы | Tappable владеет событиями. PressEffect — внутренний эффект отрисовки стандартных кнопок; вторую tap-обёртку не добавлять |

Публичный экспорт не означает, что всё следует выбирать как готовый виджет.
Resolver визуального состояния кнопок и OptionResults остаются внутренними.
Не импортируйте реализацию resolver в приложении.

## Роли темы

Текущий состав: **50 цветовых, 25 текстовых, 26 радиусов, 37 отступов**.
Каталог перечисляет значения через `.values`; число и список не поддерживаются
вручную на экране. Тема задаёт семантические роли, параметры виджета — локальное
явное переопределение.

`table`, `surface`, `disclosure` независимы; defaults — **24/14/14**.
Прежнее переопределение surface больше не переопределяет таблицу и раскрытие:
при необходимости задавайте каждую роль явно. `pillButton` имеет радиус **30**,
отступы horizontal **16**, vertical **4**. Для таблеток используйте собственную
роль вместо menuButton. `pillIconExtent = 15`, `actionIconExtent = 24` не связаны
с tableIcon/timeline. Старые значения остальных ролей не удалены.

### Полная таблица типографики

Все 25 ролей поддерживают **независимый** `withStyle`. Сходство размера/веса
не делает роли алиасами. Канонические специализированные роли применяются
по назначению; bodyLarge/Medium/Small и прежние title/label остаются публичными
общими стилями, а не молча перенаправляются на новые роли. «auto» означает
высоту Flutter/TextStyle, не фиксированную строку из шкалы HIG.

| Роль | Размер / вес / строка | Назначение | Текущие потребители | Независимый override |
| --- | --- | --- | --- | --- |
| `bodyRow` | 17 / 400 / 22 | Строки таблиц, значения и текстовые действия | `row`, `table`, `value_row` | Да |
| `bodyStrong` | 17 / 600 / 22 | Обычный заголовок таблицы и название этапа | `table`, `timeline` | Да |
| `bodyDetail` | 15 / 400 / 20 | Описание этапа | `timeline` | Да |
| `caption` | 12 / 400 / 16 | Подпись метаданных | `stat_group` | Да |
| `footnote` | 13 / 400 / 18 | Пояснение действия и дата этапа | `action_button`, `timeline` | Да |
| `labelMedium` | 15 / 600 / 20 | Таблетка и значение статистики | `pill_button`, `stat_group` | Да |
| `actionTitle` | 16 / 600 / 21 | Название крупного действия | `action_button` | Да |
| `bodyLarge` | 17 / 400 / auto | Основной текст, редактор и строки меню; базовый Cupertino Body | `calendar`, `confirmation`, `journey_components`, `menu`, `menu_button`, `menu_item`, `option_results`, `picker_fields`, `popover`, `select`, `text_input`, `theme` | Да |
| `bodyMedium` | 15 / 400 / auto | Дополнительное описание строки и feedback; значения календаря | `calendar`, `chrome`, `feedback`, `option_results`, `row` | Да |
| `bodySmall` | 13 / 400 / auto | Помощь/ошибка формы, подписи и вторичный мелкий текст | `calendar`, `chrome`, `chrome_metrics`, `draggable_table`, `field_decoration`, `image`, `journey_components`, `menu_button`, `menu_item`, `option_results`, `slider`, `table`, `text_input`, `tooltip` | Да |
| `sectionLabel` | 12 / 400 / auto | Прежний малый заголовок секции; не обычный header таблицы | Доступна клиенту, прямых внутренних вызовов нет | Да |
| `sectionHeading` | 20 / 700 / 25 | Prominent-заголовок таблицы | `table` | Да |
| `labelLarge` | 17 / 600 / auto | Надпись стандартной кнопки | `button` | Да |
| `titleSmall` | 17 / 600 / auto | Название раскрывающейся карточки | `disclosure_card` | Да |
| `titleMedium` | 17 / 600 / auto | Заголовок навигации и месяца | `calendar`, `chrome`, `chrome_metrics`, `theme` | Да |
| `titleLarge` | 22 / 600 / auto | Заголовок составного блока задач и шага | `journey_components` | Да |
| `headlineMedium` | 28 / 700 / auto | Крупный заголовок клиента | Доступна клиенту, прямых внутренних вызовов нет | Да |
| `displaySmall` | 32 / 700 / auto | Большой заголовок Cupertino-навигации | `theme` | Да |
| `tableBadge` | 12 / 500 / auto | Короткая метка таблицы | `table` | Да |
| `status` | 13 / 600 / auto | Подпись статуса | `status` | Да |
| `feedbackTitle` | 20 / 700 / auto | Заголовок состояния области | `feedback` | Да |
| `segmentLabel` | 13 / 600 / auto | Надпись сегмента | `segmented_control` | Да |
| `toast` | 15 / 600 / auto | Текст временного сообщения | `toast` | Да |
| `tabLabel` | 11 / 400 / auto | Подпись стандартной вкладки | `tabs` | Да |
| `compactTabLabel` | 10 / 600 / auto | Подпись компактной вкладки | `tabs` | Да |

Потребители указаны по файлам реализации; косвенная ссылка через другой стиль
или CupertinoTheme не равна отсутствию использования. Семейство и tracking
берутся из `AcademyTypographySettings`/платформы. Табличный основной текст всех
вариантов теперь использует bodyRow, overrides применяются согласованно.

## Совместимость и миграция

Удалений внешнего API нет. Отсутствие внутреннего вызова не доказывает отсутствие
клиентов. Миграция перед удалением: проверить приложения, обозначить замену,
дать период перехода, затем отдельным решением изменить экспорт.

| Сохранённый контракт | Для нового кода | Статус |
| --- | --- | --- |
| `AcademyTokens.radius/controlRadius/fieldRadius` | `theme.radii.surface/button/field` | Legacy-константы не учитывают локальные overrides |
| `AcademyTokens.tableInset` | `theme.paddings.tableRow` и геометрия строк | Историческая метрика; не новая роль таблицы |
| `AcademyTokens.action/canvas/ink/muted/border` | Семантические роли theme.colorScheme | Цветовые константы сохранены, не подходят для живой темы |
| `chromeBlurTintOpacity`, `blurTintOpacity` | `chromeBlurToneStrength`, `blurToneStrength` | Алиасы силы коррекции, не альфы цветного слоя; новое имя приоритетнее |
| `blurTintOf` | `blurBackgroundOf` для результата фильтра на равномерном фоне | Старый метод возвращает transparent |
| `AcademyCompactSegment` | `AcademySegmentedControl` с тем же `style` | Совместимая обёртка общей реализации; исторический default — `pill`. Для компактного вида явно задайте `style: compact` или используйте `.compact` |
| `AcademyButton(secondary: true)` | `style: AcademyButtonStyle.tinted` | Совместимый параметр |
| `AcademyToastHost.show(icon:)` | `leadingIcon:` / `trailingIcon:` | icon остаётся синонимом leadingIcon |
| appearance enum `.label` | `.labelFor(context)` | Старый getter сохраняет русский текст |
| `AcademyPaddingRole.searchLoading` | Применять только в своей композиции, если нужна эта роль | Публичная роль сохранена; отсутствие внутреннего вызова не основание удаления |
| Старые `src`-пути | Основной barrel `academy_ui.dart` | Файлы переэкспорта удалены 2026-11-02 (см. ниже) |
| `widgets/icon/academy_accessories.dart` для InfoButton | `widgets/button/academy_info_button.dart` либо barrel | Старый файл переэкспортирует перемещённую кнопку |
| `widgets/modal/modal_sheet_corner_mask.dart` | `foundation/surface/academy_surface_mask.dart` либо barrel | Файл удалён вместе с остальными переэкспортами |

### Удалённые файлы переэкспорта

2026-11-02 из `lib/src` удалены 39 файлов, содержавшие только `export` старых путей
(`src/academy_*.dart`, `src/chrome/`, `src/modal/`, `src/motion/`,
`src/widgets/modal/modal_sheet_corner_mask.dart`). Проверка: скрипт разрешил
относительные и `package:`-импорты во всём пакете, тестах и каталоге и не нашёл ни
одного пользователя; `grep "package:academy_ui/src/"` по Quran, Zikro и Yalla тоже
пуст. Публичный API — только `package:academy_ui/academy_ui.dart` (и
`quran_compat/...` для Quran); импорт `src/` не поддерживается.

## Короткие и длинные таблицы

GroupedTable оптимален для настроек и коротких форм. `scrollable: true` ленив
по секциям; `TableBody` создаёт все rows секции в Column, а `rows` — готовый
список виджетов. Одна секция на тысячи строк не получает row virtualization.
Для реального большого списка используйте builder/sliver с визуальными
компонентами строки и измеряйте layout/scroll на целевом устройстве. Новое API
вводится после такого сценария и измерения; объединять короткие таблицы с
универсальным движком заранее не требуется.
