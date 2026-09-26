# Academy UI

Общая Flutter-библиотека для приложений QuranAcademy. Основа оформления — Yalla;
маршруты, detents, работа с фокусом и геометрия модалок — quran_flutter.
Пакет работает самостоятельно: шрифт, иконки и исправленный sheet-пакет входят
в зависимости и дерево библиотеки. Импортов исходных проектов нет.

## Подключение

Flutter >= 3.47.2, Dart ^3.13.2. Основной импорт:

```dart
import 'package:academy_ui/academy_ui.dart';
```

Соседнее приложение подключает пакет через относительный путь:

```yaml
dependencies:
  academy_ui:
    path: ../academy-ui/packages/academy_ui
```

Подключение из GitHub:

```yaml
dependencies:
  academy_ui:
    git:
      url: git@github.com:QuranAcademy-Apps/academy-ui.git
      ref: main # В релизном приложении закрепите проверенный commit/tag.
      path: packages/academy_ui
```

Локальная зависимость `third_party/stupid_simple_sheet` разрешается внутри
библиотеки. Публикация на pub.dev отключена (`publish_to: none`).

## Состав

| Область | Компоненты |
| --- | --- |
| Оформление Yalla | `AcademyTheme`, палитра, токены, system/light/dark, акцент, flat/gradient/blur; системная типографика Quran |
| Действия | `AcademyButton` (primary/secondary/disabled/pending), `AcademyTextButton`, `AcademyIconButton` |
| Ввод и выбор | `AcademyField`, `AcademySearchBar`, `AcademyStepper`, `AcademyCheckmark`, `AcademyOptionMenu`, `AcademyLazyMenu` |
| Данные | `AcademyGroupedTable`, `AcademyTableSection`, `AcademyRow`, `AcademySurface`, `AcademyDivider` |
| Навигация | `AcademyPage`, chrome bar/button/menu/group/capsule, `AcademyFloatingTabBar`, `AcademyTabScaffold` |
| Состояния | `AcademyStatus`, `AcademyFeedback`, `AcademyToastHost`, `AcademyRingProgress`, `AcademyImage` |
| Общие блоки | `AcademyChecklist`, `AcademyJourneyProgress`, `AcademyGuideStep`, tips, motion-примитивы |
| Дополнения Quran | `AcademyDisclosureCard`, `AcademyMenuAnchor`, `AcademyMenuItem`, `AcademyMenuButton`, `AcademyCompactSegment`, `AcademyCompactIconButton`, `AcademySettingsSquareButton`, `AcademyExpandingSearch` |
| Модалки Quran | modal route, detents, focus expansion, scroll insets, landscape frame, nested Navigator, masked fills |
| Готовые сценарии | контентный шит, форма, поиск, подтверждение, вложенный экран, последовательность подсказок |

Предметные формы Quran/Yalla, данные, сетевые сервисы и авторизация не перенесены.
Приложение передаёт данные и callbacks. Схема состояния/DI приложения не навязывается.

## Тема и прозрачность

`AcademyApp` — необязательная оболочка `CupertinoApp`: размещает тему над Navigator,
реагирует на системную тему и обновляет уже открытые модалки. Настройки задаются через
`AcademyAppearanceController`. Если он передан извне, приложение само его освобождает.

```dart
final appearance = AcademyAppearanceController(
  initial: const AcademyAppearance(chromeStyle: AcademyChromeStyle.blur),
  store: myAppearanceStore,
);
await appearance.ready;
runApp(AcademyApp(appearance: appearance, home: const MyScreen()));
```

Постоянное хранение подключается через `AcademyAppearanceStore.read/write`.
Пример содержит реализацию на SharedPreferences. Библиотека хранит настройки
последовательно; ошибки доступны в `persistenceError`; новые изменения не принимаются
до завершения `ready`, чтобы восстановление не перезаписало выбор пользователя.
Перед завершением приложения можно дождаться `flushed`.

Blur sigma **20** — значение стандартного оформления. Блюр наследуют только
навигационные элементы: кнопки chrome, капсулы, таббар. Таблицы, карточки, поля,
обычный и модальный поиск, модальное содержимое и тосты остаются непрозрачными.
Навигационный `AcademyExpandingSearch` наследует выбранный эффект вместе с кнопкой.
Поиск имеет собственный `surfaceContainerHighest` и placeholder `onSurfaceVariant`.
Низкоуровневый `AcademyChrome` предназначен для навигации; не оборачивайте им таблицы.

SF Symbols задаются через `AcademySymbols` или `flutter_sficon`, не через Material Icons.
Типографика перенесена из Quran `AppTypography`: CupertinoSystemText/Display,
размеры 17/15/13/12 и оптический tracking на Apple-платформах. Системные SF-семейства
разрешаются платформой; веб использует доступный Flutter fallback, если SF недоступен.
Для своей оболочки приложения
используйте `academyTheme`, `AcademyTheme`, `AcademyChromeTheme` над Navigator
и `AcademyScrollBehavior`.

## Модалки и клавиатура

```dart
final result = await showAcademyModal<String>(
  context,
  title: 'Название',
  builder: (modalContext) => AcademyModalListView(children: [
    AcademyField(label: 'Название', onChanged: (value) => draft = value),
    AcademyButton(
      label: 'Сохранить',
      onPressed: () => closeAcademyModal(modalContext, draft),
    ),
  ]),
);
```

Маршрут поднимает шит над клавиатурой и поглощает `viewInsets.bottom`.
Фокус внутри формы раскрывает модалку; после снятия фокуса она возвращается
к начальной высоте. Геометрия пересчитывается при появлении/скрытии клавиатуры
и повороте экрана. Повторный keyboard padding добавлять не нужно.

Для прокрутки используйте `AcademyModalListView` / `AcademyModalScrollView`:
они добавляют нижний отступ невидимой части полноразмерного содержимого.
Для своего scroll view добавляйте `ModalSheetScrollInsets.of(context)` к нижнему
padding на уровне самого списка. Фиксированный footer использует
`ModalSheetScrollInsets.pinnedBottomOf(context)`.

`AcademyModalSearch(controller: ..., child: ...)` удерживает шит раскрытым,
пока запрос не пуст, даже после снятия фокуса. Контроллер поиска принадлежит приложению.

Вложенный поток открывайте с `nestedNavigation: true`, затем используйте
`pushAcademyModalPage`. Кнопка назад возвращает предыдущий экран внутри модалки;
`closeAcademyModal` закрывает весь поток и возвращает typed result приложению.
Поворот не пересоздаёт вложенный стек.

Доступны `initialDetent`, `detents`, `autoHeight`, `initiallyExpanded`, `dismissible`
и `useRootNavigator`. Поверх живого видео задавайте
`backgroundSnapshotMode: RouteSnapshotMode.never`; по умолчанию фон замораживается
на время движения шита и прокрутки. Reduce Motion отключает длительность движения.

Скругление шита рисует непрозрачная поверхность, без rounded clip над списком.
Для собственного непрозрачного содержимого у верхних углов используйте
`ModalSheetMaskedFill`; стандартные таблицы/карточки уже делают это.

## Страницы и таббар

`AcademyPage` и `AcademyTabScaffold` размещают навигацию поверх содержимого.
Список читает `AcademyPageInsets.topOf(context)` **внутри** `AcademyPage`.
Нижний padding равен `AcademyFloatingTabBar.bottomObstructionOf(context)` плюс
нужный зазор, чтобы последний элемент был доступен. Пример показывает оба отступа.

## Дополнительные элементы Quran

- Объединённые кнопки с разделителем: `AcademyChromeGroup(actions: [...])`.
- Раскрывающийся список: `AcademyDisclosureCard(expanded: ..., onToggle: ..., child: ...)`.
  Состояние хранит приложение; свернутое содержимое не принимает фокус.
- Pull-down меню: `AcademyMenuAnchor` + `AcademyMenuItem`. У строки есть
  `leadingIcon`, `trailingIcon`, независимый `checked`, `subtitle`, `destructive`;
  `onPressed: null` отключает строку. Текстовые стороны следуют RTL.
- Двойной шеврон: `AcademyMenuButton(title: ..., subtitle: ..., items: [...])`.
  `chevronOnLeading: true` переносит индикатор в начало, `style` задаёт фон кнопки.
  Внутри модалки меню автоматически использует root overlay и не обрезается её detent.
- `AcademyCompactSegment<T>`: `pill` для иконок/quick settings, `compact` для
  маленьких текстовых сегментов. Визуальная высота 32/31, взаимодействие минимум 44;
  выбранный пункт и callbacks принадлежат приложению, RTL и Reduce Motion учтены.
- `AcademyCompactIconButton`: визуальный кружок 28 с областью нажатия 44.
  `AcademySettingsSquareButton`: кнопка быстрых настроек 68×68; поддерживает
  отдельный цвет и long press. Для соседнего поля темы у `AcademyMenuButton`
  задайте `minimumHeight: 68, expand: true`.
- `AcademyExpandingSearch`: лупа раскрывает поле с выбранным эффектом навигации, получает фокус
  и превращается в крестик. Крестик снимает фокус, очищает запрос и сворачивает поле.
  Внешний `controller` не освобождается библиотекой; `resting` задаёт обычное содержимое
  строки, `onOpenChanged` позволяет связать раскрытие с экраном/модалкой.

## Тосты

`AcademyApp` устанавливает общий `AcademyToastHost` над Navigator: тосты работают
из обычных и модальных экранов. Для своей оболочки используйте `AcademyToastHost`
над Navigator. При необходимости задайте `toastBottomObstruction` в AcademyApp
или `bottomObstruction` в отдельном host, чтобы учесть нижнюю панель.

```dart
AcademyToastHost.show(
  context,
  'Настройки сохранены',
  position: AcademyToastPosition.top, // либо bottom
  leadingIcon: AcademySymbols.gear,
  trailingIcon: AcademySymbols.checkmark,
  duration: const Duration(seconds: 3),
);
```

Тост адаптирован из Yalla. Его можно смахнуть горизонтально или вертикально,
либо закрыть нажатием/действием доступности. При удержании таймер приостанавливается;
короткий drag возвращает тост на место. Замена сообщения и удаление host освобождают
таймер/анимацию. Иконки могут быть только слева, только справа, с обеих сторон или
отсутствовать; прежний `icon` остаётся синонимом `leadingIcon`. Тост непрозрачный,
учитывает клавиатуру и safe area.

Изображения реальных виджетов: [компоненты](../../docs/previews/quran-controls.png),
[раскрытое меню, поиск и тост](../../docs/previews/quran-interactions.png).
Повторить рендер можно командой `flutter test tool/capture_controls_test.dart --no-pub`.

## Проверка и источники

Из каталога можно проверить тему, акцент, оформление навигации, клавиатуру,
поиск, подтверждения и вложенные страницы: [запуск](../../apps/academy_ui_catalog/README.md).

```sh
flutter pub get
flutter analyze --no-pub
flutter test --no-pub
flutter test third_party/stupid_simple_sheet/test --no-pub
cd ../../apps/academy_ui_catalog
flutter test --no-pub
flutter build web --no-pub
```

Происхождение файлов и исходные хеши: [SOURCE_MANIFEST.json](SOURCE_MANIFEST.json).
У Yalla использована текущая рабочая копия, включая незакоммиченные DS-файлы.
Лицензии и локальные исправления: [THIRD_PARTY_NOTICES.md](THIRD_PARTY_NOTICES.md).
Автотесты проверяют имитированные метрики клавиатуры; проверка нативной клавиатуры,
VoiceOver, SF Symbols и плавности на физическом устройстве пока не выполнена.

## Цвета клиента

`AcademyColors` — интерфейс всех цветов, которыми управляет библиотека, аналог iOS `ThemeColors`. `AcademyPalette` задаёт значения по умолчанию. `AcademyColorsData` — неизменяемая палитра; `copyWith` позволяет заменить любую роль и любой статус, сохранив остальные значения.

```dart
AcademyApp(
  colorsBuilder: (brightness, accent) => AcademyPalette(brightness, accent).copyWith(
    surface: brightness == Brightness.dark
        ? const Color(0xFF24342C)
        : const Color(0xFFFFFAEF),
    scaffoldBackground: const Color(0xFFF0EADD),
    segmentBackground: const Color(0xFFD3DDCD),
    segmentSelected: const Color(0xFFFFFAEF),
    toneContainers: {AcademyTone.success: const Color(0xFFD9ECD2)},
  ),
  home: const MyHome(),
);
```

Без `colorsBuilder` применяется стандартная палитра. Для полной замены клиент может реализовать `AcademyColors` или создать `AcademyColorsData`. При самостоятельном `AcademyTheme` передайте палитру в `academyTheme(..., colors: palette)`.

Контракт включает текст и поверхности, акценты, рамки, все статусы, фон/выбранное состояние/тень сегментов, подсветку меню, цвет иконки на цветной плашке, затемнение модалки и цвета навигационных эффектов. Пользовательские значения применяются точно; библиотека не исправляет их автоматически. Производные роли можно переопределить отдельно — `copyWith` сохраняет уже вычисленные значения остальных ролей.

Выбор палитры и её хранение принадлежат приложению клиента. `colorsBuilder` получает текущую яркость и акцент, поэтому открытые меню и содержимое модалок обновляются вместе с темой. Цвет затемнения маршрута выбирается при открытии модалки.

В каталоге «Оформление → Палитра» демонстрирует стандартную и клиентскую палитры; этот демонстрационный выбор сбрасывается при перезапуске.

### AcademyField: focus and clearing

The trailing clear action appears when an enabled field contains text. Its 44px slot is reserved so text geometry remains stable. Clearing sends onChanged('') once and keeps keyboard focus. Focus/blur interpolate the border color over 180ms with constant 1.5px width; Reduced Motion disables transitions.

An optional external TextEditingController remains client-owned; omitting it uses a controller owned and disposed by the field. Clear button colors come from the supplied palette.

## Menu and table composition

Floating tab bars accept `density: AcademyTabBarDensity.standard`, `.compact` or `.telegram`.
The appearance's `tabBarDensity` supplies the inherited default and can be persisted
by the client store. Standard retains 60px height, 22px icons, 11px labels and 6px
insets. Compact is Academy's smaller content-sized profile: 56px height,
4px insets, 22px SF glyphs in a 30px frame (32px paint extent), 10px semibold
labels and measured content width plus 16px padding per side. All items reserve
this padding so the bar stays the same width when selection changes. Its width is capped
at the same 416px/available width as standard and does not stretch to fill spare space.
Telegram is a separate source-based profile: 64px height, 56px item height,
4px insets, 10px semibold labels anchored 8px above the item bottom and a
500px/available-width cap. Labels are measured with 10px padding per side:
use equal widths when all fit, otherwise weighted widths. Narrow layouts retain
44px tap targets where space permits and labels ellipsize. For narrow items,
selection widens to 1.2 times item height, bounded by the panel.
Static icons start 3px below the item top. Telegram uses each image's intrinsic
size; Academy's SF icons retain 24px type in a 32px paint frame to avoid clipping.
The scaffold's side inset is 20px, or 12px when the bottom safe inset exceeds 28px.
All profiles grow with text scaling, preserve directional selection and update bottom
content/toast obstruction through `AcademyFloatingTabBar.bottomObstructionOf`.

Source: [Telegram TabBarComponent, pinned revision](https://github.com/TelegramMessenger/Telegram-iOS/blob/6ad963e5b62d354da79040f388ae2b9132fb17b8/submodules/TelegramUI/Components/TabBarComponent/Sources/TabBarComponent.swift#L651).
Standard and compact are Academy UI's own profiles; telegram adapts the source dimensions
with Flutter text scaling and a minimum touch target. These are not Apple tokens.
`compact` here is unrelated to UIKit's compact size class or scroll-minimized
tab bar. The current Flutter chrome uses a fill/gradient or Gaussian blur;
it does not implement Apple's Liquid Glass refraction and adaptive contrast.
For the source comparison and outstanding patterns, see
[`iOS 26 tab bar review`](../../docs/tasks/2026-09-26-ios26-tabbar-research.md).

`AcademyMenu` is independent of any row: provide `items` and a trigger `builder(context, toggle)`. Configure width/maxHeight, root overlay, safe overlay padding, long-press opening, swipe selection and open/close callbacks. An optional controller enables programmatic opening/closing; position specifies an opening point relative to the anchor's top-left corner. `AcademyMenuDisplay` is the passive value plus double chevron.

`AcademyMenuRow` supports `AcademyMenuActivation.row` (whole cell) and `.accessory` (only value/chevron). In accessory mode `onRowPressed` is an independent optional cell action. `AcademyOptionMenu` uses the same contract for string options.

`AcademyMenuItem` supports leading/trailing icons or custom widgets; title/subtitle widgets; selection on the left, right or hidden; disabled/destructive states; item padding/minimum height; accessory widths; and closeOnSelect. `AcademyMenuSeparator` adds an explicit separator. All fills and text/icon colors use the client palette.

```dart
AcademyMenuRow(
  label: 'Theme', value: 'Light',
  activation: AcademyMenuActivation.accessory,
  items: [
    AcademyMenuItem(title: 'Light', checked: true, onPressed: () {}),
    AcademyMenuItem(title: 'Dark', onPressed: () {}),
  ],
);
```

Table parts are individually usable: `AcademyTableHeader` (uppercase/style/custom trailing action), `AcademyTableFooter`, `AcademyTableSeparator`, `AcademyTableBody` and `AcademyTableSectionView`. `AcademyTableSection` accepts custom header/footer widgets, header action, text styles, radius and separator builder. `AcademyGroupedTable` can be inline or scrolling, accepts padding/section spacing/controller/physics, hides empty sections by default and optionally animates section resizing. Existing default inline embedding remains supported.

`AcademyRow` supports leading icon or custom leading widget, custom title/subtitle, title badge, arbitrary accessory, disabled state, tap/long press and adjustable minimum height/padding.

`AcademyDraggableTableSection<T>` follows Quran's controlled handle-only drag pattern. The feature owns items, stable IDs, order and persistence. Provide a rowBuilder, onMove callback, optional acceptance filter, inside-card header and outside footer. Moves work within a section, across sections, into empty sections and after the last item. onMove receives a destination index **after source removal**; do not decrement it again. The source remains visible and dimmed; a full-row preview follows the handle. Set editing and onRemove to replace handles with delete buttons. IDs must be unique and stable. rowBuilder must not reuse a GlobalKey between the row and its drag preview.

Catalogue: Tables and cards → Table, menu and dragging (Russian labels in the UI).
