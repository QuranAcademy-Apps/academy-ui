# Дополнение Academy UI компонентами Quran

Запрос: объединённые кнопки, disclosure-список, меню с leading/trailing и
необязательной галочкой, маленькие сегменты и кнопки, двойной шеврон,
раскрываемый поиск. Тост: смахивание, иконки с обеих сторон, top/bottom.

Источники: `docs/project.md`, README библиотеки; Quran
`lib/design_system/widgets/chrome/app_chrome_bar_controls.dart`,
`app_chrome_page_scaffold.dart`, `app_chrome_search_bar.dart`,
`lib/core/widgets/app_menu_anchor.dart`, `app_menu_checkmark.dart`,
`lib/shared/widgets/grouped_table/menu_indicator.dart`,
`lib/screens/quran_reading/container/widgets/quick_settings/reader_quick_settings_segmented_control.dart`,
`lib/screens/settings/screens/tajweed_rules/tajweed_rules_widgets.dart`.
Сравнены overlay-тосты Quran и Dirham с текущим тостом Yalla в библиотеке.
Навык: `/Users/ayub/.codex/skills/flutter-scalable-app/SKILL.md` — lifecycle и владение.

Владение: disclosure и сегмент controlled, значения принадлежат приложению.
MenuAnchor владеет только overlay; выбранное значение приходит извне. Поиск
владеет локальным состоянием раскрытия и фокусом, TextEditingController внешний.
ToastHost владеет анимацией, таймером, свайпом; содержимое передаёт приложение.
Визуальные размеры и поведение берём из Quran, цвета из AcademyTheme; Blur 20
только в навигации, список и поиск непрозрачные. Исходные приложения не меняем.

- [x] Сопоставить картинки с исходниками.
- [x] Добавить/дополнить компоненты, без дубликата имеющегося ChromeGroup.
- [x] Каталог со всеми вариантами, включая раскрытие поиска и тосты.
- [x] Проверки меню, раскрытия, сегментов, поиска, свайпа и жизненного цикла.
- [x] Изображения реальных виджетов и обновлённое руководство.

Нативная клавиатура, VoiceOver и профиль на устройстве не проверяются в widget harness.

Проверено: 22 теста библиотеки (7 новых контрактов), тест каталога, рендер двух
PNG из реальных компонентов с Inter/SF fonts, Flutter analyzer без замечаний,
web release build. Источники и исходные хеши дописаны в SOURCE_MANIFEST.
Тост Yalla расширен свайпом в обеих осях и trailingIcon; общий host доступен
из modal routes. Коммит/push и запуск приложений-доноров не выполнялись.
