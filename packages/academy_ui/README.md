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
      ref: academy_ui-v0.2.0 # Последняя версия — в CHANGELOG.md.
      path: packages/academy_ui
```

Локальная зависимость `third_party/stupid_simple_sheet` разрешается внутри
библиотеки. Публикация на pub.dev отключена (`publish_to: none`).

## Версии и обновление

Каждое приложение закрепляет свой тег и обновляется, когда готово само: выпуск новой
версии его не затрагивает. Не указывайте `ref: main` — иначе `flutter pub upgrade`
принесёт все изменения сразу. Что изменилось в каждой версии: [CHANGELOG.md](CHANGELOG.md).

**Какую часть версии поднимать.** Пока версия ниже 1.0:

- `0.X.0` — ломающее изменение: приложению может понадобиться что-то поменять.
  Удалён или переименован публичный API, изменилось значение по умолчанию или
  поведение, убрана зависимость. В `CHANGELOG.md` описывается, что именно поменять.
- `0.x.Y` — всё остальное, что доходит до приложений: исправления и новые необязательные
  возможности.

После 1.0 действует обычный SemVer: ломающее — `X.0.0`, новое — `x.Y.0`, исправление — `x.y.Z`.

**Выпуск версии.**

1. В PR поднимите `version` в `pubspec.yaml`, добавьте запись первой в `CHANGELOG.md`
   и выполните `flutter pub get` в `apps/academy_ui_catalog`, чтобы обновить его lock-файл.
   CI не пропустит PR, если изменились `lib`, `assets`, `third_party` или `pubspec.yaml`,
   а версия и запись нет. Для тестов и документации новая версия не нужна.
   Проверить заранее: `.github/scripts/check_package_version.sh origin/main`.
2. После слияния в `main` поставьте тег на коммит слияния:

   ```sh
   git tag academy_ui-v0.2.0 <коммит>
   git push origin academy_ui-v0.2.0
   ```

Выпущенный тег не переносится: исправление всегда выходит новой версией.

**Обновление приложения.** Прочитайте в `CHANGELOG.md` записи между текущей и новой версией,
поменяйте `ref`, выполните `flutter pub get` и проверьте приложение. Обновляться можно
постепенно, версия за версией.

**Исправление для старой версии.** Создайте от её тега ветку, например `release/0.1.x`,
и направьте PR в неё с новой патч-версией. Тег ставится на коммит этой ветки.

## Состав

| Основная категория | Канонические компоненты |
| --- | --- |
| Действия | `AcademyButton`, `AcademyTextButton`, `AcademyIconButton`, `AcademyInfoButton`, `AcademyCompactIconButton`, `AcademySettingsSquareButton`, `AcademyActionButton`, `AcademyPillButton` |
| Ввод и выбор | `AcademyTextField`, `AcademyField`, `AcademyFloatingInput`, `AcademyTextFormField`, `AcademySelect`, `AcademyMultiSelect`, `AcademyAutocomplete`, `AcademySearchBar`, `AcademyExpandingSearch`, `AcademyCalendar`, `AcademyRangeCalendar`, `AcademyLineCalendar`, `AcademyDateField`, `AcademyTimeField`, `AcademyPicker`, `AcademySlider`, `AcademyStepper`, `AcademySegmentedControl`, `AcademyCheckmark` |
| Таблицы и контейнеры | `AcademyGroupedTable`, `AcademyTableSection`, `AcademyTableHeader`, `AcademyTableBody`, `AcademyTableFooter`, `AcademyTableBadge`, `AcademyTableSeparator`, `AcademyTableSectionView`, `AcademyRow`, `AcademyValueRow`, `AcademyDivider`, `AcademyDraggableTableSection`, `AcademyDragHandle`, `AcademySurface`, `AcademyDisclosureCard` |
| Навигация | `AcademyPage`, `AcademyChrome`, `AcademyChromeBar`, `AcademyChromeButton`, `AcademyChromeGroup`, `AcademyChromeCapsule`, `AcademyChromePage`, `AcademyChromeModalHeader`, `AcademyChromeFade`, `AcademyFloatingTabBar`, `AcademyTabScaffold` |
| Меню и наложения | `AcademyMenuButton`, `AcademyInlineOptionMenu`, `AcademyChromeMenu`, `AcademyLazyMenu`, `AcademyMenuAnchor`, `AcademyMenu`, `AcademyMenuRow`, `AcademyMenuDisplay`, `AcademyMenuItem`, `AcademyMenuSeparator`, `AcademyPopover`, `showAcademyModal`, `showAcademySheet`, `showAcademyConfirmation`, `AcademyModalScaffold`, `AcademyModalSearch`, `AcademyModalListView`, `AcademyModalScrollView` |
| Данные и медиа | `AcademyStat`, `AcademyStatGroup`, `AcademyTimeline`, `AcademyTimelineItem`, `AcademyImage`, `AcademySfImage`, `AcademySfIcon`, `AcademySymbols`, `AcademyChevron` |
| Контекстная помощь | `AcademyTooltip`, `AcademyTip`, `showAcademyTips` |
| Состояния и обратная связь | `AcademyStatus`, `AcademyFeedback`, `AcademyToastHost`, `AcademyRingProgress`, `AcademyJourneyProgress`, `AcademyChecklist`, `AcademyGuideStep`, `AcademyCounterButton`, `AcademyProgressCard`, `AcademyProgressTile`, `AcademySearchScrim` |
| Оформление и взаимодействие | `AcademyApp`, `AcademyTheme`, `AcademyAppearanceController`, `AcademyColors`, `AcademyRadii`, `AcademyPaddings`, `AcademyTypographySettings`, `AcademyInteractionTheme`, `AcademyTappable`, `AcademyFocusOutline`, motion-примитивы |

В каталоге четыре вкладки: «Каталог», «Quran», «Модалки», «Оформление». Вкладка
«Каталог» открывает разделы с примерами; профиль и поездки — отдельный раздел.

[Руководство выбора, уровни API, все роли типографики и совместимость](../../docs/design-system-reference.md).
Исторические отчёты находятся в `docs/reviews`; они не заменяют актуальные контракты.

Предметные формы Quran/Yalla, данные, сетевые сервисы и авторизация не перенесены.
Приложение передаёт данные и callbacks. Схема состояния/DI приложения не навязывается.

## Настройка под приложение

У пакета есть значения по умолчанию, но приложение может заменить каждое из них.
Сначала идёт тема: она действует на всё приложение. Параметр конкретного виджета
имеет приоритет над темой.

```dart
AcademyApp(
  colorsBuilder: (brightness, accent) => AcademyPalette(brightness, accent)
      .copyWith(scrim: const Color(0x66102030), menuHighlight: myHighlight),
  radii: const AcademyRadii(field: 16, textBlock: 8),
  icons: const AcademyIcons(forward: MyIcons.next, close: MyIcons.cross),
  sizes: const AcademySizes(buttonHeight: 48, rowHeight: 56, rowIcon: 20),
  typography: const AcademyTypographySettings(
    fontFamily: 'MyFont',
    styles: {AcademyTextRole.fieldLabel: TextStyle(fontSize: 13)},
  ),
  rowIconColors: const {AcademyRowIcons.trip: Color(0xFF0A7A5C)},
  chromeColors: const AcademyChromeColors(glassFill: Color(0xFFF0EDE6)),
  home: const MyScreen(),
);
```

- **Цвета:** `AcademyColors` (роли, включая `scrim`, `chromeFade` и цвета просмотра
  фото), `AcademyChromeColors` (навигация и стекло), `rowIconColors` (плитки строк).
- **Иконки:** `AcademyIcons` — символы, которые пакет рисует сам. Подойдёт `IconData`
  из любого шрифта. Иконки, которые приложение передаёт в виджет, тема не меняет.
- **Размеры:** `AcademySizes` (`sizes:` в `AcademyApp`) — высоты кнопок, полей и строк, размеры символов.
- **Шрифты:** `AcademyTypographySettings`: семейство и стиль любой роли, включая `fieldLabel`, `fieldMessage`, `tabText`.
- **Формы и отступы:** `AcademyRadii`, `AcademyPaddings`.
- **Каркасы с плавающей панелью:** `AcademyChromePage.floating`, `AcademyModalScaffold.floating`, `AcademyChromeModalHeader.capsule`, `AcademyChromeFloatingBar`, `AcademyChromeSearchBar`; поиск в шапке задаёт `AcademyChromeSearch`.
- **Символы и мелкие элементы:** `AcademySfIcon.scaled`, `AcademySfImage.plain`, `AcademyIconButton.plain`, `academySymbolNamed` (символ по имени SF Symbols); `AcademySegmentedTheme` (`segmented:`) и `AcademySegmentedControl.fitted`; `inlineInfoColor`.
- **Кнопки панели:** `AcademyChromeButtonTheme` (`chromeButton:`) — символ, реакция на нажатие, разделитель группы, значок «назад», стили заголовка капсулы. Компоненты: `AcademyChromeButton`, `AcademyChromeGroup`, `AcademyChromeBackButton`, `AcademyChromeCircle`, `AcademyChromeCapsule.bar`, `AcademyChromeTitleCapsule`.
- **Панель и таб-бар:** `AcademyChromeMaterial` (`chromeMaterial:`) — заливка, обводка, тень и вид при уменьшенной прозрачности; `AcademyChromeColors` — цвета; `AcademyTabBarTheme` (`tabBar:`) — вид и положение таб-бара. Выбранной вкладкой снаружи управляет `AcademyTabController`.
- **Таблицы:** `AcademyTableTheme` (`table:`) — заголовки и стили строк, шеврон, отступы, отклик нажатия, разделители. У `AcademyRow` те же настройки есть параметрами; концевые элементы строк — `AcademyRowAccessory`, `AcademyRowDisclosure`, `AcademyRowTrailingText`.
- **Тосты:** `AcademyToastTheme` (`toast:`) — материал капсулы и нижний отступ `AcademyToastOverlay`.
- **Подписи:** свой `LocalizationsDelegate<AcademyLocalizations>`.

Без `AcademyApp` те же значения передаются в `academyTheme(...)`.

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
Материал blur обрабатывает само изображение позади панели: размытие sigma 20,
насыщенность 1.25 и коррекция светового диапазона. Цветной заливки поверх blur
нет. Светлая тема поднимает нижнюю границу яркости, тёмная ограничивает верхнюю;
оттенок берётся из проходящего под панелью контента. Параметры Academy не
являются рецептом нативного Apple Liquid Glass. Текст/символы — отдельный
foreground, к которому фильтры не применяются. Контраст подписей рассчитывается
относительно обработанного фона.

Сила коррекции задаётся через `AcademyApp(chromeBlurToneStrength: .54)`,
локально — `AcademyChrome(blurToneStrength: .54)` или `AcademyChromeTheme`.
`0` оставляет обычное размытие без цветовой коррекции, `1` сводит цветовой
диапазон к белому/чёрному. В стандарте сохраняется 46% диапазона движущегося
фона с усиленной насыщенностью. `surfaceOpacity` умножает силу коррекции для
blur; для остальных стилей продолжает управлять альфой заливки.
Старые имена `chromeBlurTintOpacity` / `blurTintOpacity` сохранены как алиасы
силы коррекции; они больше не означают альфу цветного слоя. Новый параметр
имеет приоритет, если переданы оба. `blurBackgroundOf` возвращает цвет
равномерного фона после фильтров; старый `blurTintOf` возвращает прозрачный
цвет, поскольку слоя больше нет.

`chromeSurface` задаёт обычные непрозрачные стили навигации и запасную заливку
при повышенном системном контрасте. В High Contrast фильтр отключается и
используется непрозрачная поверхность. Настройки inherited Chrome theme
сохраняются при capture/wrap оверлеев. При собственной силе коррекции клиент
проверяет читаемость на предполагаемом содержимом.

**Стекло** (`AcademyChromeStyle.glass`,
перенесено из Yalla, ADR-0006): почти непрозрачная тонированная заливка (.94),
слабый backdrop blur (sigma из темы), световой кант сверху/снизу и внешняя тень —
имитация навигации iOS 26 средствами Flutter, без преломления. Рисует
`AcademyGlassMaterial`; в High Contrast заменяется непрозрачной поверхностью.

Цвета навигации, отличные от палитры контента, задаёт
`AcademyChromeTheme(colors: AcademyChromeColors(...))`: символы кнопок,
подсветка выбранной вкладки, выбранный символ и подпись, невыбранные вкладки,
обводка и тень выбранной кнопки. Пустая роль сохраняет прежний цвет пакета.
Yalla использует нейтральные символы и подсветку с насыщенным выбранным символом.

`AcademyFloatingTabBar` дополнительно умеет текстовый вариант 44pt
(`showIcons: false`), прокрутку многих вкладок (`contentWidth`,
`scrollController`), `maxWidth` и `AcademyTab.key`; при крупном тексте подпись
перестаёт расти там, где не помещается, вместо многоточия (`academyFitTextScaler`).
`AcademyChromeModalHeader(closeOnLeading: true, trailing: AcademyTextButton(...))`
ставит закрытие слева, а текстовое действие при нехватке места — отдельной строкой.

Поиск по умолчанию использует оформление кнопки закрытия. При `chrome: false`
его активный фон — `textFieldBackground`. Цвет placeholder — `textFieldSecondaryForeground`.
Низкоуровневый `AcademyChrome` предназначен для навигации; не оборачивайте им таблицы.

SF Symbols задаются через `AcademySymbols` или `flutter_sficon`, не через Material Icons.
Типографика перенесена из Quran `AppTypography`: CupertinoSystemText/Display,
размеры 17/15/13/12 и оптический tracking на Apple-платформах. Системные SF-семейства
разрешаются платформой; веб использует доступный Flutter fallback, если SF недоступен.
Для своей оболочки приложения
используйте `academyTheme`, `AcademyTheme`, `AcademyChromeTheme` над Navigator
и `AcademyScrollBehavior`. `AcademyScrollBehavior.forEnvironment` включает перетаскивание
мышью только на нативных платформах Apple (передаётся в `AcademyApp.scrollBehavior`), а
`AcademySelectionSafeScrollBoundary` оставляет мыши выделение текста внутри своего поддерева.

## Отклик кнопок

Основные, тонированные, текстовые, иконочные и квадратные кнопки имеют общий
отклик на контакт: масштаб до 0.97, уменьшение длинной стороны не более чем на
5 логических пикселей. Нажатие — 100 мс (`easeOutQuart`), возврат — 100 мс
(`easeOutCubic`), по принципу [Forui FTappable](https://github.com/duobaseio/forui/blob/main/forui/lib/src/foundation/tappable/tappable.dart).

`foundation/motion/academy_press_effect.dart` меняет только отрисовку: размеры,
область нажатия, семантика и обработка действия остаются у CupertinoButton.
Прокрутка/отмена контакта возвращает кнопку в исходный размер. Отключённые кнопки,
ожидание и Reduce Motion не запускают масштабирование. Приложению не требуется
дополнительный `PressScale` вокруг стандартной кнопки.

Правило силы нажатия: кнопки, карточки и плитки сжимаются до 0.97, круглые кнопки
навигации — до 0.9. Значения задаются в `AcademyInteractionTheme` (`pressedScale`,
`chromePressedScale`). Прямой `PressScale` без параметра по-прежнему сжимает до 0.9.

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

По умолчанию модалка имеет одно положение (`medium`). `autoHeight` без
`initialDetent` выбирает одну заданную высоту, `initiallyExpanded` — одну полную.
Для длинного списка задавайте `detents: [medium, large]`, для раскрываемой формы —
`[medium, full]`. Дата/время и подтверждения используют компактную высоту по содержимому.
Редактирование может временно раскрыть форму; `expandOnFocus: false` отключает это
для коротких модалок. `showAcademySheet(height: ...)` задаёт высоту контентного шита.

`headerBehavior` управляет прокруткой под закреплённым верхним баром:

- `AcademyModalHeaderBehavior.separate` — отдельная область под баром;
- `fade` — контент проходит под баром с плавным переходом в цвет модалки;
- `overlay` — контент проходит под прозрачным баром без фейда.

`showAcademySheet` по умолчанию использует `fade`; `showAcademyModal` сохраняет
`separate` для форм и компактных picker. Длина перехода задаётся через
`headerFadeExtent` (24 по умолчанию). `pushAcademyModalPage` наследует настройки
корневой модалки, при необходимости их можно переопределить для страницы.

Контент под баром по умолчанию клипуется по скруглённым углам шита. Скруглённый
клип рендерит этот контент вне экрана на каждом кадре скролла, поэтому длинный
текстовый список может терять кадры. `clipContent: false` клипует только фейд;
непрозрачный контент тогда сам маскирует заливку через `ModalSheetMaskedFill`, как
уже делают таблицы и поверхности. Включайте после замера в `--profile` на устройстве.

`AcademyModalFit(minimumBottom: 8)` держит закреплённый низ над плоским краем экрана,
а `AcademyModalListView` и `AcademyModalScrollView` принимают `physics`.

Экран с тяжёлой загрузкой подмешивает `AcademyDeferredRouteInit` и выполняет её в
`onRouteTransitionComplete`, уже после анимации перехода и подъёма шита. Значения,
нужные первому кадру (например, у переключателя), читайте синхронно в `initState`.
Стандартные modal scroll views добавляют высоту бара к **контентному** верхнему
отступу, сохраняя начальное положение первой строки. Для собственного scroll view
добавляйте `AcademyModalContentInsets.topOf(context)` к верхнему padding списка.
Обычный непрокручиваемый builder в режиме underlap также должен учитывать этот
отступ. Фейд не перехватывает жесты, бар защищает скрытые под ним действия.

Модалка по умолчанию окрашена в `surface` — как ячейки таблиц. Если внутри
`AcademyGroupedTable` или карточки, передайте `grouped: true`: фон станет
`scaffoldBackground` (systemGroupedBackground), и секции будут читаться как
карточки, как в grouped sheet UIKit. `pushAcademyModalPage` наследует флаг.

```dart
showAcademyModal<void>(
  context,
  title: 'Содержимое',
  headerBehavior: AcademyModalHeaderBehavior.fade,
  headerFadeExtent: 32,
  builder: (_) => AcademyModalListView(children: rows),
);
```

Доступны `initialDetent`, `detents`, `autoHeight`, `initiallyExpanded`, `dismissible`
и `useRootNavigator`. Поверх живого видео задавайте
`backgroundSnapshotMode: RouteSnapshotMode.never`; по умолчанию фон замораживается
на время движения шита и прокрутки. Reduce Motion отключает длительность движения.

Скругление шита рисует непрозрачная поверхность. Режим `separate` не добавляет
rounded clip над списком; режимы под баром используют обычный shape clip без
`saveLayer`, чтобы контент и фейд не выступали за верхние углы шита.
Для собственного непрозрачного содержимого у верхних углов используйте
`ModalSheetMaskedFill`; стандартные таблицы/карточки уже делают это.

## Страницы и таббар

`AcademyPage` и `AcademyTabScaffold` размещают навигацию поверх содержимого.
Список читает `AcademyPageInsets.topOf(context)` **внутри** `AcademyPage`.
Нижний padding равен `AcademyFloatingTabBar.bottomObstructionOf(context)` плюс
нужный зазор, чтобы последний элемент был доступен. Пример показывает оба отступа.

`AcademyPageInsets.bottomOf(context)` отдаёт готовый нижний отступ: на странице с
`hasTabBar: true` он учитывает таббар, на остальных равен safe area (минимум 8) плюс
`bottomGap` (16 по умолчанию).

`AcademyPageRoute` — страница без затемнения предыдущей, с `instantPush` для появления
без анимации; `AcademyFadeRoute` — мягкое появление экрана поверх текущего, например поиска.

Для списка со своим `ScrollController` оберните его в `AcademyScrollToTop`: Flutter
сам обрабатывает тап по статус-бару только у `PrimaryScrollController`.
`AcademyStableTopInset` не даёт контенту прыгать, когда экран скрывает статус-бар;
чтобы отступ был верным с первого кадра, вызывайте
`AcademyTopInsetMemory.instance.observe(mediaQuery)` у корня приложения.

На Android задайте `chromeBottomInsetOf` темы через
`academyAndroidChromeBottomInset(mediaQuery, roundedCornerInset:, gestureNavigation:)`:
радиус углов и режим навигации приложение получает из своего нативного канала.
`academyNormalizedAndroidLandscape` выравнивает боковые инсеты в landscape; это
эвристика, проверяйте её на своих устройствах.

## Компактные контролы и меню

- Объединённые кнопки с разделителем: `AcademyChromeGroup(actions: [...])`.
- Раскрывающийся список: `AcademyDisclosureCard(expanded: ..., onToggle: ..., child: ...)`.
  Состояние хранит приложение; свернутое содержимое не принимает фокус.
- Pull-down меню: `AcademyMenuAnchor` + `AcademyMenuItem`. У строки есть
  `leadingIcon`, `trailingIcon`, независимый `checked`, `subtitle`, `destructive`;
  `onPressed: null` отключает строку. Текстовые стороны следуют RTL.
- Двойной шеврон: `AcademyMenuButton(title: ..., subtitle: ..., items: [...])`.
  `chevronOnLeading: true` переносит индикатор в начало, `style` задаёт фон кнопки.
  Внутри модалки меню автоматически использует root overlay и не обрезается её detent.
- `AcademySegmentedControl<T>`: `pill` для иконок/quick settings, `compact` для
  маленьких текстовых сегментов. Визуальная высота 32/31, взаимодействие минимум 44;
  выбранный пункт и callbacks принадлежат приложению, RTL и Reduce Motion учтены.
  `AcademySegmentedControl.compact` выбирает компактный вариант. `cornerRadius`
  и `selectionCornerRadius` задают скругления контейнера и выбранного сегмента.
  `AcademyCompactSegment` остаётся совместимым именем той же реализации.
- `AcademyCompactIconButton`: визуальный кружок 28 с областью нажатия 44.
  `AcademySettingsSquareButton`: кнопка быстрых настроек 68×68; поддерживает
  отдельный цвет и long press. Для соседнего поля темы у `AcademyMenuButton`
  задайте `minimumHeight: 68, expand: true`.
- `AcademyCounterButton(count:, total:, label:, onPressed:, onLongPress:)`: круглая
  chrome-кнопка счёта повторов (зикр, тасбих) с кольцом прогресса; по достижении
  `total` показывает галочку. Счёт, тактильный отклик и переход дальше — у приложения.
- `AcademyProgressCard`: непрозрачная карточка подборки с иконкой, подписью,
  кольцом прогресса (галочка при 100%) и `highlighted` для актуальной подборки.
- `AcademyCounterView(count:, total:, onPressed:)`: полноэкранный счётчик —
  вся область нажимается, большое кольцо; для длинных счётов (33, 100).
- `AcademyTextBlock(label:, text:, onCard:)`: блок перевода как в списке Quran
  (скруглённая подложка, жирная подпись, межстрочный 1.32).
- `AcademyProgressTile`: компактная плитка сетки «Каждый день» (иконка, название,
  «5/17», тонкая полоса прогресса, `highlighted` — рамка как у последней
  прочитанной суры в Quran). Долгое нажатие — оберните в
  `AcademyMenuAnchor(enableLongPressToOpen: true)`.
- `AcademyIndexBadge(n)`: номер строки в скруглённом квадрате (список сур) для
  `AcademyRow.leading`.
- `AcademyChromeMenuButton(label:, items:)`: круглая chrome-кнопка «…» с
  pull-down меню из `AcademyMenuItem` / `AcademyMenuSeparator`.
- `AcademySearchScrim(active:, results:, onDismiss:)`: состояние поиска iOS —
  затемняет страницу, пока поле открыто, и показывает `results` на
  непрозрачной поверхности при непустом запросе. Закрыть
  `AcademyExpandingSearch` снаружи: `GlobalKey<AcademyExpandingSearchState>`
  → `close()` (`open()`, `isOpen`).
- `AcademyChromeFade(solidExtent:, fadeExtent:)`: сплошная полоса под статус-баром
  и плавный переход в цвет страницы для собственных экранов с плавающим chrome.
- `AcademyExpandingSearch`: лупа раскрывает поле с выбранным эффектом навигации, получает фокус
  и превращается в крестик. Крестик снимает фокус, очищает запрос и сворачивает поле.
  Внешний `controller` не освобождается библиотекой; `resting` задаёт обычное содержимое
  строки, `onOpenChanged` позволяет связать раскрытие с экраном/модалкой.

## Тосты

`AcademyApp` устанавливает общий `AcademyToastHost` над Navigator: тосты работают
из обычных и модальных экранов. Для своей оболочки используйте `AcademyToastHost`
над Navigator. При необходимости задайте `toastBottomObstruction` в AcademyApp
или `bottomObstruction` в отдельном host, чтобы учесть нижнюю панель.
`AcademyToastTheme.topInsetOf` опускает верхний `AcademyToastOverlay` ниже навбара.

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

Тост адаптирован из Yalla. Верхний тост закрывается свайпом вверх, нижний — вниз;
горизонтальное движение и свайп в противоположную сторону не перемещают и не
закрывают его. Перемещение при удержании ограничено 96 пунктами по разрешённой
вертикали. Закрытие происходит после 48 пунктов либо короткого быстрого свайпа.
Нажатие и действие доступности также закрывают тост. При удержании таймер приостанавливается;
короткий медленный свайп возвращает тост на место. Замена сообщения и удаление host освобождают
таймер/анимацию. Иконки могут быть только слева, только справа, с обеих сторон или
отсутствовать; прежний `icon` остаётся синонимом `leadingIcon`. Тост непрозрачный,
учитывает клавиатуру и safe area.

Изображения реальных виджетов: [компоненты](../../docs/previews/quran-controls.png),
[раскрытое меню, поиск и тост](../../docs/previews/quran-interactions.png).
Повторить рендер можно командой `flutter test tool/capture_controls_test.dart --no-pub`.

## Подключение существующих приложений (Quran)

Подробный разбор проблем переноса и чек-лист: [docs/migrating-an-existing-app.md](../../docs/migrating-an-existing-app.md).

Параметры, которые позволяют приложению сохранить свой вид, не меняя умолчания:

- `AcademyTypographySettings.tracking` — своя кривая letter-spacing системного шрифта (в том числе для крупных заголовков).
- `AcademySfIcon(scaleWithText: true, mirrorInRtl: false)` — символ следует системному масштабу текста и не подменяет `back`/`forward` в RTL. По умолчанию размер фиксирован, стрелки подменяются.
- `AcademySwitch(value:, onChanged:, activeTrackColor:)` — переключатель 51 × 31; цвет по умолчанию — `accentFill`.
- `AcademyFeedback.compact(message:, onRetry:, retryLabel:)` — текст по центру и необязательная кнопка повтора; подпись приходит от приложения.
- `AcademyRingProgress.listenable(listenable:, color:)` — кольцо для частых обновлений: тик перерисовывает только его.
- `AcademyNetworkImage(autoCacheWidth: true)` и `AcademyImage(cacheWidth:)` — декодирование под размер показа.
- `AcademyRingProgress.fill(value:, color:)` — кольцо на всё место родителя (inset 1.5, дорожка 22 %, `easeOut`, без семантики).
- `AcademySegmentedControl(height:, backgroundColor:, selectedColor:, textColor:, selectionBorderColor:, selectionShadowColor:)` — точная высота (без 44 pt зоны) и цвета палитры хоста.
- `AcademySearchBar(onClear:)` — вызывается после очистки поля кнопкой.
- `AcademyInfoButton.inline(onPressed:, iconSize:, color:)` — символ «i» без круглой подложки.
- `AcademySlidingSegments<T>` — полноширинный селектор со скользящей плашкой (цвета передаются явно, `contentBuilder` рисует сегмент). Текстовый селектор 36 pt — это `AcademySegmentedControl(height: 36, …)`.
- `AcademyStepper.actions(onDecrease:, onIncrease:, color:)` — пилюля «− +» 94 × 32 с независимо отключаемыми половинами (каждая половина включена, если её колбэк не `null`).
- `AcademySymbols` содержит каталог символов приложения Quran (перенесён из `AppSfIcons`); дубли по глифу сведены к одному имени.

Библиотека построена на `package:flutter/cupertino.dart`. Исключение — четыре файла, которым нужен `package:cupertino_ui`: `academy_menu.dart`, `academy_menu_anchor.dart`, `academy_menu_item.dart` и `modal_sheet_detents.dart`; остальные виджеты `CupertinoButton` берут из SDK. Приложение, которое сидит на `package:cupertino_ui`, должно дополнительно предоставить тему Cupertino из SDK (`CupertinoTheme` из `flutter/cupertino.dart`), иначе динамические цвета и `CupertinoButton`/`CupertinoSwitch` внутри академических виджетов возьмут яркость системы, а не приложения.


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

При системном «Увеличить контраст» `AcademyApp` сам поднимает текст до 4.5:1 через
`academyHighContrastColors`; поверхности и разделители не меняются. Своей оболочке
приложения нужно вызвать эту функцию самой.

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

`AcademyMenuRow` supports `AcademyMenuActivation.row` (whole cell) and `.accessory` (only value/chevron). In accessory mode `onRowPressed` is an independent optional cell action. `AcademyInlineOptionMenu` uses the same contract for string options.

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

Table parts are individually usable: `AcademyTableHeader` (case-preserving grouped heading, optional `prominent`, style/custom trailing action), `AcademyTableFooter`, `AcademyTableSeparator`, `AcademyTableBody` and `AcademyTableSectionView`. `AcademyTableSection` accepts custom header/footer widgets, header action, text styles, radius and separator builder. `AcademyGroupedTable` can be inline or scrolling, accepts padding/section spacing/controller/physics, hides empty sections by default and optionally animates section resizing. Existing default inline embedding remains supported.

`AcademyRow` supports leading icon or custom leading widget, custom title/subtitle, title badge, arbitrary accessory, disabled state, tap/long press and adjustable minimum height/padding.

`AcademyDraggableTableSection<T>` follows Quran's controlled handle-only drag pattern. The feature owns items, stable IDs, order and persistence. Provide a rowBuilder, onMove callback, optional acceptance filter, inside-card header and outside footer. Moves work within a section, across sections, into empty sections and after the last item. onMove receives a destination index **after source removal**; do not decrement it again. The source remains visible and dimmed; a full-row preview follows the handle. Set editing and onRemove to replace handles with delete buttons. IDs must be unique and stable. rowBuilder must not reuse a GlobalKey between the row and its drag preview.

The handle also opens a keyboard-accessible menu and exposes screen-reader actions for moving up/down. Supply `labelForItem` for domain objects and `moveTargets` for every other section reachable by dragging. Each `AcademyTableMoveTarget` includes the destination's human-readable label, current item count, enabled state and the same acceptance rule as its drop target. Cross-section menu actions append at `itemCount`. Use unique destination labels. The host updates this metadata with the controlled items; it still owns ordering and persistence. `enabled: false` blocks all row content and deletion, while header/footer controls remain independently usable.

### Changes following the September 2026 design-system review

`AcademyApp` supports Russian, English and Arabic built-in wording and native Cupertino localization. Set `locale: Locale('en')` or `Locale('ar')`, or `locale: null` to follow the device; the compatibility default is Russian. An Arabic locale automatically uses RTL. Without `AcademyApp`, register `AcademyLocalizations.delegate`, the global Cupertino/Widgets delegates, and `AcademyLocalizations.supportedLocales` on your app. A custom `LocalizationsDelegate<AcademyLocalizations>` listed first can override wording by returning a subclass. Content titles and descriptions remain client-owned. Enum appearance labels use `labelFor(context)`; the old `label` getter retains Russian wording.

**Pages, fields and accessories (November 2026, from Yalla).** Moved from Yalla: `AcademyPage` (leading, subtitle, `softTopFade`, `maxContentWidth`, `headerBackgroundBuilder`), `AcademyLargeTitlePage`, inline fields `AcademyFloatingInput`, `AcademyReadOnlyField`, `AcademyPickerInput`, `AcademyDateInput`, `AcademyInlineOptionMenu` (value beside the label), `AcademyContentSkeleton`/`AcademySkeletonBlock`/`AcademySkeletonText`, `SoftFadeIn`/`SliverSoftFadeIn` and `AcademyLinkedText`. New options: `AcademyStepper(wide: true)` (112×44), `AcademyCheckmark.color`, `AcademySurface` padding/radius/`continuousCorners`, `AcademyStatus` icon/colours/`compact`, `AcademyFeedback.loadingIndicator`, `AcademyPillButton.accent`, `AcademyJourneyProgress` `showTitle` and bar styling, and the `labelTertiary` colour role (default: `onSurfaceVariant`). Contracts: `test/yalla_ported_components_test.dart`.

**Photo viewer and network image (November 2026, from Yalla).** `AcademyNetworkImage` shows plain HTTPS media with a skeleton while loading, a soft fade-in and the caller's `fallback` for invalid URLs and errors; pass `provider:` to plug in a disk cache (for example `CachedNetworkImageProvider`) — the package itself adds no cache dependency. `showAcademyPhotoViewer` opens a full-screen pager with pinch zoom up to 5× and swipe-down dismissal; image builders read `AcademyPhotoDecodeScope` (tiers from `academyPhotoDecodeWidth`) to decode for the viewport and ask for more detail after zooming. Contracts: `test/photo_viewer_network_image_test.dart`.

**Menus and toasts (November 2026, from Yalla).** `AcademyColors.menuSurface` is the resting fill of menu rows (default: `surface`); rows paint it opaquely in dark mode too (`BlendMode.srcOver`). `AcademyMenuItem(actsWhenChecked: false)` makes the current option of a single choice close the menu without repeating its action (`AcademyInlineOptionMenu` and `AcademyChromeMenu` do this). `AcademyToastHost(style:)` sets the toast material, for example the app's chrome style; the toast clears the side safe areas. Menu items are built on `cupertino_ui`: use them with `AcademyMenuAnchor`, not the SDK `CupertinoMenuAnchor`.

**Modals (November 2026, Yalla moved onto `showAcademyModal`).** New options: `header: false` (the content draws its own `AcademyChromeModalHeader`), `enableDrag: false` (picker wheels keep their gestures; the barrier still closes) and `moveAboveKeyboard: false` (the sheet stays where it rests and the content keeps the keyboard inset for a hand-made keyboard layout; use with `expandOnFocus: false`). Fixed: detents were ~7% short whenever the top safe area was non-zero (the content box was `screen − top` while detents and `ModalSheetScrollInsets` measure against the screen; `modalSheetRouteHeight` is now public), Reduce Motion asserted on a zero-length spring, a nested navigator's route focus expanded the sheet like a text field, the scroll inset kept the home-indicator gap under the keyboard, and `showAcademyConfirmation` measured its buttons with the wrong role and minimum. For content pinned to the bottom of a full-height sheet use `ModalSheetScrollInsets.of` (`pinnedBottomOf` is for a content box of `screen − top`). Regressions: `test/modal_regressions_test.dart`.

**Tables (from Yalla, November 2026).** `AcademyRow` adds `eyebrow`, `detail`, `titleStyle`/`subtitleStyle`, `subtitleMaxLines`, `subtitleTextAlign`, `crossAxisAlignment`, `selected`, `trailingSpacing`, `chevron`, `iconForeground`, `leadingExtent` (a wider leading column; symbols and tiles are centered at their natural height) and `pressedColor` (grouped-list highlight of the whole row instead of fading). `AcademyTableHeader` takes a `subtitle` and moves a trailing control under the heading at narrow widths or large text. `AcademyTableSection` takes `subtitle`, `spacingBefore`, header/body/footer paddings, `separatorStart`/`separatorEnd`, `insetCustomRows` (non-row content is inset and keeps its own width, centered) and `clip`. `AcademySliverGroupedTable` builds a long section lazily inside the enclosing `CustomScrollView`. Defaults keep the previous table.

**Buttons (from Yalla, November 2026).** `AcademyColors.actionFill`/`onActionFill` colour the primary call to action; they follow `accentFill` unless a client sets them, so a brand can use a companion CTA colour (Yalla: yellow) while switches and selection keep the accent. `AcademyButtonStyle.neutral` is a raised `surfaceContainerHighest` button with `onSurface` text and the `chromeBorder`; `plain` uses `surface` without a border. `AcademyButton` also accepts `content`, explicit fills (`backgroundColor`, `foregroundColor`, `borderColor`, disabled colours), `minimumHeight`, `radius` and `textStyle`. The primary label uses `AcademyTextRole.buttonLabel`, which follows `labelLarge` until a client styles it. Each button is its own accessibility element (`container: true`). `AcademyTextButton(textStyle:)` changes the label and its `measure`.

`AcademyButton(style: AcademyButtonStyle.tinted)` uses `secondaryContainer` for its fill and `secondary` for text/border. `secondary: true` remains a compatibility alias. `onSecondary` describes text on a solid `secondary` surface. Selected tabs use the new `onPrimaryContainer` foreground role; custom implementations of `AcademyColors` must provide it. `AcademyColorsData` can derive it from primary/container colors or accept an explicit override. Default small-text pairs meet 4.5:1 contrast across all six catalog accents in light/dark themes; clients own contrast for explicit color overrides.

`AcademyTokens.target` is the 44px Cupertino minimum, `largeTarget` is 48px, and `buttonHeight` is 52px. Shared control/field radii, table insets, spacing and motion durations are consumed by the primitives. Compact segments scroll horizontally when they cannot preserve 44px targets. SF symbols retain their own size under text scaling; navigation back/forward glyphs swap in RTL. Ordinary action buttons share the Flutter SDK Cupertino implementation and preserve a single named focus/action node.

Segment tracks and compact utility buttons share the opaque `segmentBackground` role (`#E1E3E7` light / `#3A3A3C` dark). Selected segments use `segmentSelected` (white / `#636366`). These control fills are independent of page/card surfaces, accent and Chrome style; changing `surface` must not redefine them. Client themes can override both roles explicitly. `test/compact_control_colors_test.dart` protects the default fills and their use during live theme/state changes.

`AcademyGuideStep` accepts `onDone` and `readOnly`. A completed step invokes `onDone ?? onNext`; with neither callback it omits the completion button. `readOnly: true` omits navigation actions. `AcademySearchBar(chrome: true)` follows the navigation background, border and blur style. Its default content variant stays opaque. Use `AcademyExpandingSearch` when search must expand from a navigation icon.

`test/design_system_regression_test.dart` verifies the review fixes, including pointer/keyboard/semantic disabled behavior, icon scaling/direction, narrow headers, color roles/contrast, action semantics, constrained segments, Reduced Motion, accessible moves, localization overrides and completion actions. The dated diagnostics in `docs/reviews` preserve the original defects and are historical evidence, not the current regression suite.

Catalogue: Tables and cards → Table, menu and dragging (Russian labels in the UI).

## Скругления, отступы и шрифты

Значения компонентов управляются четырьмя отдельными сущностями:

- `AcademyRadii` — 26 ролей скруглений компонентов: кнопки, поля, таблицы,
  сегменты, навигация, изображения, тосты, модалки. Значения по умолчанию
  определены только в `lib/src/theme/academy_radii.dart`.
- `AcademyPaddings` — 37 ролей внутренних/внешних отступов (`EdgeInsets`),
  определённых в `lib/src/theme/academy_paddings.dart`.
- `AcademyColors` / `AcademyPalette` — семантический контракт и значения
  светлой/тёмной палитры. Все исходные цвета находятся в `academy_palette.dart`;
  старые константы цветов `AcademyTokens` остаются совместимыми ссылками.
- `AcademyTypographySettings` — семейства и переопределения 25 текстовых ролей.
  Размеры, насыщенность и системный tracking находятся в `academy_typography.dart`.

```dart
AcademyApp(
  radii: const AcademyRadii(button: 12, table: 18, modal: 28),
  paddings: const AcademyPaddings(
    button: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
    tableRow: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
  ),
  typography: const AcademyTypographySettings(
    fontFamily: 'Inter',
    displayFontFamily: 'Inter',
    fontPackage: 'academy_ui',
    styles: {
      AcademyTextRole.bodyLarge: TextStyle(fontSize: 18),
      AcademyTextRole.labelLarge: TextStyle(fontWeight: FontWeight.w700),
    },
  ),
  home: const MyScreen(),
);
```

`copyWith` меняет отдельные параметры без изменения остальных. Для своей оболочки
эти же сущности передаются в `academyTheme`. Компоненты читают их через
`AcademyTheme.of(context)`: обновляется и содержимое уже открытых модалок.
Явный `cornerRadius`, `radius` или `padding` конкретного виджета имеет приоритет
над темой; без него используется соответствующая роль. Роль `tableRow` задаёт
горизонтальные отступы строк внутри таблицы; самостоятельные строки по-прежнему
не добавляют горизонтальные отступы. Отступы учитывают нижнюю скрытую часть шита.

Таббар по умолчанию имеет форму капсулы (`999`, ограничивается половиной высоты),
но его фон и выделение настраиваются отдельно. Нулевые отступы у внутренних
кнопок сохраняют геометрию их области нажатия. Геометрия системного popup-меню,
не предоставленная публичным API `cupertino_ui`, остаётся у этой зависимости;
отступ меню от краёв экрана настраивается через `menuOverlay`.

Для пользовательского шрифта объявите assets в приложении и задайте его семейства;
для шрифта приложения `fontPackage` не нужен. Для Inter библиотеки укажите
`fontPackage: 'academy_ui'`. SF Symbols используют собственный шрифт и не меняются
при смене типографики текста. Tracking SF применяется только к системным семействам.

Каталог использует стандартные значения библиотеки. Редакторы скруглений,
отступов, цветовых ролей и типографики удалены, прежние локальные переопределения
не применяются. В «Оформлении» остаются настройки темы, акцента и навигации.
Программное переопределение темы через `AcademyApp` доступно приложениям.

Подход сверялся с `quran_flutter/lib/theme`, `Dirham/Flutter/.../foundation`
и `Yalla/yalla-app/lib/shared/design_system`: отдельные палитры и типографика,
общая тема над Navigator, значения по умолчанию плюс переопределения клиента.

Скругление `AcademyRadii.table` общее для таблиц, `AcademySurface` и
`AcademyDisclosureCard`, включая блоки внутри модальных окон. `surface` и
`disclosure` сохранены как совместимые имена того же значения, а не отдельные
настройки. Если при создании заданы несколько имён, приоритет у `table`.

## Переиспользуемый ввод

`AcademyTextInput` — настраиваемая основа: контроллер, фокус, ввод, очистка,
скругление, отступы, `leading` и `trailing`. Три компонента используют эту основу:

- `AcademyTextField` — обычное поле без заголовка.
- `AcademySearchBar` — поиск с лупой, клавиатурным действием Search, загрузкой и
  прежней кнопкой отмены. По умолчанию фон, обводка и эффект совпадают с кнопкой
  закрытия и следуют оформлению навигации; `chrome: false` явно выбирает фон
  обычного поля. Фокус не меняет обводку поиска.
- `AcademyField(label: ...)` — поле с заголовком сверху и подсказкой/ошибкой снизу.

У поля и поиска радиус по умолчанию 12. `cornerRadius` позволяет переопределить
его в конкретном компоненте. `leading`/`trailing` принимают иконку, кнопку или
другой виджет; стороны следуют направлению текста. Внешние контроллеры и фокус
остаются собственностью приложения. `readOnly` и `enabled: false` отключают
очистку, а её место сохраняется, чтобы текст не прыгал.

```dart
AcademyTextField(
  placeholder: 'Введите значение',
  leading: const AcademySfIcon(AcademySymbols.book, size: 18),
  trailing: const AcademySfIcon(AcademySymbols.checkmark, size: 18),
);
AcademySearchBar(controller: searchController);
const AcademyField(label: 'Имя', placeholder: 'Введите имя');
```

## Формы, выбор и подсказки

```dart
// Внутри State экрана; language — String?, formKey — GlobalKey<FormState>.
Form(
  key: formKey,
  child: Column(children: [
    AcademyTextFormField(
      label: 'Имя',
      validator: (v) => v == null || v.trim().isEmpty ? 'Введите имя' : null,
      onSaved: (v) => name = v ?? '',
    ),
    AcademySelect<String>(
      label: 'Язык',
      value: language,
      options: const [
        AcademySelectOption(value: 'ru', label: 'Русский'),
        AcademySelectOption(value: 'ar', label: 'العربية'),
      ],
      presentation: AcademySelectPresentation.menu,
      onChanged: (v) => setState(() => language = v),
      validator: (v) => v == null ? 'Выберите язык' : null,
    ),
  ]),
);
// Перед сохранением: if (formKey.currentState!.validate()) {
//   formKey.currentState!.save();
// }
```

`AcademyMultiSelect` принимает `Set<T> values` и возвращает неизменяемый снимок.
В модалке изменения подтверждаются кнопкой «Готово», в popover применяются сразу.
`presentation: AcademySelectPresentation.menu` открывает обычное меню для локальных
вариантов без поиска. Множественный выбор применяется сразу, меню остаётся открытым.
При наличии `loader` используется popover с поиском.
`presentation` также позволяет явно выбрать `sheet` или `popover`. В режиме `adaptive`
выбор определяется `AcademyInteractionTheme.density`: `touch` (по умолчанию) или
`desktop`. Настройка передаётся через `AcademyApp(interaction: ...)` или тему.

`AcademyAutocomplete` принимает `options` либо `loader(query)`, поддерживает
свободный текст, `onChanged(String)` и `onSelected(T)`. Select/MultiSelect тоже
поддерживают `loader`; для выбранных удалённых значений задавайте `labelFor` либо
сохраняйте соответствующие варианты в `options`. Асинхронный источник получает
запрос с задержкой 200 мс; устаревшие ответы игнорируются. Загрузка, отсутствие
результатов, ошибка и повторная попытка отображаются компонентом.
`emptyMessage` и `emptyHint` задают текст пустого результата Autocomplete;
по умолчанию сообщение локализовано («Ничего не найдено»).

`AcademyPopover` связывает `builder(context, controller)` с
`contentBuilder(context, close)`. Панель остаётся в границах экрана и закрывается
по Escape/нажатию снаружи. `AcademyTooltip(message: ..., child: ...)` показывает
подсказку при наведении, фокусе дочернего контрола и удержании.
`placement` у Popover, Tooltip, Select/MultiSelect и Autocomplete задаёт сторону:
`auto`, `above`, `below`, `start`, `end`. Если места недостаточно, панель выбирает
доступную сторону, учитывая клавиатуру и безопасные области; `start`/`end` следуют RTL.

Select в режиме popover и Autocomplete используют `matchAnchorWidth: true`: панель совпадает с
фактической шириной поля, следует за изменением размеров и учитывает RTL.
Для сложного якоря можно передать `anchorKey`; Autocomplete привязывает его к
самому полю ввода, без заголовка, подсказки и наружных отступов.

Активные поля используют `textFieldBackground`, отключённые — `textFieldDisabledBackground`.
Отключённые поля дополнительно имеют видимую границу `textFieldDisabledBorder`. Очистка использует
SF Symbol `xmark.circle.fill` с зоной нажатия 44×44.
Все поля в покое имеют обводку `textFieldBorder`, поиск остаётся без обводки; фокус выделяется акцентом, а при
повышенном контрасте используется производный `textFieldControlBorder`. Подписи и
подсказки используют вторичный системный цвет с проверкой читаемости.
Popover имеет непрозрачную поверхность, тонкую границу и тень. Выбор обозначен
синей галочкой; между вариантами используются разделители в один физический пиксель.

Стандартная палитра использует роли Cupertino `systemGroupedBackground`,
`secondarySystemGroupedBackground`, `tertiarySystemGroupedBackground`, `label`
и `separator`. В светлой теме это нейтральный серый фон и белые поверхности,
в тёмной — чёрный фон и нейтральные серые поверхности. Стандартный акцент — синий.

## Даты и числовые значения

```dart
AcademyDateInput(
  label: 'Дата', value: date,
  firstDate: DateTime(2020), lastDate: DateTime(2035, 12, 31),
  onChanged: (v) => setState(() => date = v),
);
AcademyTimeField(
  label: 'Время', value: time, // AcademyTime?, например AcademyTime(9, 30)
  onChanged: (v) => setState(() => time = v),
);
AcademySlider(
  label: 'Размер текста', value: fontSize, min: 12, max: 32, divisions: 20,
  formatValue: (v) => '${v.round()} пт',
  onChanged: (v) => setState(() => fontSize = v),
);
```

`AcademyCalendar` выбирает день; `AcademyRangeCalendar` — `AcademyDateRange`;
`AcademyLineCalendar` показывает конечную горизонтальную ленту дней.
`AcademyPicker<T>` — управляемое колесо с `items`, `value`, `labelFor`, `onChanged`.
Календари григорианские, с понедельника; поля времени используют 24-часовой формат.

[Структура, владение состоянием и совместимость](../../docs/design-system-architecture.md).


### Семантические цвета полей и акцента

Фон полей задаётся отдельно от карточек и навигации: `textFieldBackground`,
`textFieldSecondaryBackground` (поиск внутри панели), `textFieldDisabledBackground`.
Текст, placeholder/подписи и отключённое значение используют
`textFieldForeground`, `textFieldSecondaryForeground`, `textFieldDisabledForeground`.
Границы: `textFieldBorder`, `textFieldDisabledBorder`, `textFieldFocusBorder`;
ошибка формы: `textFieldErrorForeground`. Обычные поля, Select, Autocomplete,
picker и SearchBar без Chrome используют эти общие роли.

`accentColor` сохраняет выбранный исходный оттенок; `accentFill` и `onAccentFill`
задают контрастную пару кнопки, `accentForeground` — цвет действий на нейтральном
фоне. Светлый акцент больше не затемняет все заливки ради читаемости ссылок.
`primary` остаётся прежней ролью foreground. При смене акцента используйте
`AcademyAppearance.accent`: `colorsBuilder` пересчитает семейство в обеих темах.
`copyWith` меняет разрешённую роль и сохраняет независимые роли; исключение —
автоматическая коррекция `onAccentFill` при явной смене `accentFill`.

```dart
colorsBuilder: (brightness, accent) => AcademyPalette(brightness, accent).copyWith(
  textFieldBackground: brightness == Brightness.dark
      ? const Color(0xFF1C1C1E) : const Color(0xFFFFFFFF),
  textFieldSecondaryBackground: brightness == Brightness.dark
      ? const Color(0xFF2C2C2E) : const Color(0xFFF2F2F7),
),
```

Клиенты, реализующие `AcademyColors`, должны предоставить новые роли. В
`AcademyColorsData` новые параметры необязательны для совместимости старого
конструктора; `from` и `copyWith` сохраняют независимые роли. Для явных клиентских
переопределений контраст задаёт клиент. Изменение `surface` или
`surfaceContainerHighest` не должно менять стандартную палитру полей.

### Поля с плавающим заголовком

`AcademyFloatingInput(label: 'Почта', help: 'Для входа в профиль')` —
дополнительный вариант поля; `AcademyTextFormField(floatingLabel: true)` использует его же. В пустом поле без
фокуса название находится на месте placeholder. При фокусе или вводе оно плавно
поднимается и уменьшается; после очистки и потери фокуса возвращается обратно.
Размер поля не меняется. Поддерживаются `controller`, `focusNode`, `help`, `error`,
`trailing`, `readOnly`, `enabled`, очистка и тип клавиатуры. Цвета и скругления
берутся из текущей темы; отключение анимаций системы учитывается.
Для Flutter Form используйте `AcademyTextFormField(label: 'Почта', floatingLabel: true)`.
Обычный стиль остаётся стандартным. Все варианты показаны в «Поля и выбор» каталога.


### Профиль, метаданные и этапы

Компоненты не хранят предметные данные: приложение передаёт строки, состояния
и callbacks. Импорт — `package:academy_ui/academy_ui.dart`.

| API | Назначение |
| --- | --- |
| `AcademyValueRow(label:, value:, subtitle:, readOnly:, onPressed:, enabled:)` | Подпись и значение с выравниванием по направлению текста. При узкой ширине или шрифте от 1.5× значение переносится ниже. `readOnly` показывает замок и отключает переход. |
| `AcademyRow(tone: AcademyTone.error)` | Семантический тон подписи и плитки иконки; foreground иконки учитывает контраст. Прежние вызовы не меняются. |
| `AcademyRow.action(title:, action:, onPressed:, enabled:)` | Акцентное текстовое действие, вся строка — одна кнопка. |
| `AcademyActionButton(title:, subtitle:, icon:, onPressed:, pending:, style:)` | Крупная двухстрочная кнопка с круглой иконкой, минимум 64 pt; стили `AcademyButtonStyle.primary/tinted`. `onPressed: null` отключает, `pending` блокирует действие и объявляет загрузку. |
| `AcademyPillButton(label:, icon:, onPressed:)` | Тонированная таблетка: заливка 36 pt, зона нажатия минимум 44×44. При крупном тексте растёт. `tinted: false` — тихое текстовое действие. |
| `AcademyTableHeader.action(title:, action:, onPressed:, icon:, uppercase:)` | Заголовок с текстовым действием справа. По умолчанию сохраняет регистр; действие остаётся в одной строке с названием, у края контента секции. |
| `AcademyTimeline(items:)` | Этапы `AcademyTimelineItem(title:, date:, subtitle:, state:)`, линия между точками; состояния `completed/current/upcoming`, порядок и состояние объявляются доступностью. Даты передаются готовыми строками. |
| `AcademyStatGroup(stats:, alignment:)` | 2–3 элемента `AcademyStat(label:, value:)`; `AcademyStatAlignment.start/center/end`, отдельно для элемента через `AcademyStat.alignment`. При узкой ширине или шрифте от 1.5× — вертикальный список. |
| `AcademyRowIcons` | Роли `person/trip/document/alert/calendar/settings/info/hotel/passport`. Использование: `AcademyRow(icon: AcademySymbols.person, iconColorRole: AcademyRowIcons.person)`. |

Цвета плиток сверены с макетом профиля Yalla: blue, orange, green, red, teal,
grey, indigo, purple, brown. `colorOf(context)` выбирает светлое/тёмное системное
значение по AcademyTheme. Явный `iconBackgroundColor` имеет приоритет над ролью,
а `tone` — над обоими. Деструктивная строка использует красную роль alert. Кнопки и обычный текст используют текущую клиентскую палитру.
Метрики находятся в AcademyTokens, отступы и радиусы — в текущей теме.
Кнопки используют общий AcademyPressEffect, учитывают Reduce Motion и имеют
один именованный action-узел; loading объявляется live region. Лента не анимируется.

Канонические примеры — «Действия» и «Данные и медиа»; составной пример — сценарий «Профиль и поездки».
[Обе темы](../../docs/previews/profile-components.png),
[2× и RTL](../../docs/previews/profile-components-large-rtl.png).


Типографика и композиция таблиц сверены с Apple HIG и стандартным UIKit
`UITableView(style: .insetGrouped)` на iOS 26.5. Все метрики доступны через тему:

| Роль | Размер / насыщенность / строка |
| --- | --- |
| `bodyStrong` | 17 / semibold / 22: обычный заголовок таблицы и название этапа |
| `sectionHeading` | 20 / bold / 25: заголовок таблицы при `prominent: true` |
| `bodyRow` | 17 / regular / 22: подпись, значение строки, «Изменить» и «Добавить» |
| `bodyDetail` | 15 / regular / 20: описание этапа |
| `labelMedium` | 15 / semibold / 20: таблетки и значения статистики |
| `actionTitle` | 16 / semibold / 21: заголовок крупной кнопки |
| `footnote` | 13 / regular / 18: пояснения кнопок и даты этапов |
| `caption` | 12 / regular / 16: подписи статистики |

Обычный заголовок сохраняет регистр и использует вторичный цвет текста;
`prominent: true` — основной цвет. Действие заголовка — текстовая кнопка
с зоной нажатия 44, без оформления таблетки. Строки имеют минимальную высоту
52 (`AcademyTokens.tableRowHeight`), у тела таблицы нет дополнительного
вертикального padding; радиус таблицы по умолчанию 24. Это визуальные настройки
современного inset-grouped оформления, а не обязательные числа из HIG.
Настройки поверхностей и disclosure-карточек сохраняют прежний радиус 14.
Переопределения `uppercase`, `style`, `padding`, `cornerRadius`, `minHeight`
и тема остаются доступными. При крупном тексте значения и действия переносятся
под подпись и сохраняют направленное выравнивание.

Клиент может переопределять роли через `AcademyTypographySettings.withStyle`.
Семейство в приложении системное CupertinoSystemText/Display; в capture на macOS
загружается локальный SF Pro, на других ОС используется Inter. Headless-снимки
не проверяют нативную растеризацию на iPhone.
[Эталон UIKit на iOS 26.5](../../docs/previews/apple-grouped-table-ios26.png).
