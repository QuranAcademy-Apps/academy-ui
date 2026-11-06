# История версий academy_ui

Правила версий и порядок выпуска: [README](README.md#версии-и-обновление).
Новая запись идёт первой; заголовок — номер версии из `pubspec.yaml`.

## 0.2.0

### Что поменять в приложении

- `AcademySizes.rowChevron` теперь 14 вместо 16. Чтобы вернуть прежний размер,
  задайте `sizes: const AcademySizes(rowChevron: 16)`.
- `AcademyTableSectionLayout.bodyVertical` теперь 0 вместо 4: это таблицы `.themed`.
  Чтобы вернуть прежний отступ, задайте
  `AcademyTableTheme(sectionLayout: AcademyTableSectionLayout(bodyVertical: 4))`.
- `AcademySliverGroupedTable.edgePadding` теперь `double?`: `null` означает отступ
  из темы. Код, который читает это поле как `double`, нужно поправить.
- Пустые секции таблиц `.themed` скрываются. Чтобы их показать, передайте
  `hideEmptySections: false`. Собственные отступы секции теперь важнее значений из layout.
- Шеврон строки по умолчанию теперь `AcademyChevron` цвета tertiary. Чтобы вернуть
  другой цвет или символ, задайте `chevronBuilder` в `AcademyTableTheme`.
- `AcademySegmentedControl.fitted` и `AcademySlidingSegments` занимают 44 pt высоты, а
  нажимаемый `AcademyRowAccessoryButton` получил область нажатия 44 pt. Проверьте
  плотные экраны: вёрстка могла сместиться.
- Повторяющиеся ключи строк внутри одной секции теперь вызывают ошибку Flutter.
  Сделайте ключи уникальными.
- Замена только `loader` больше не перезагружает варианты. Чтобы перезагрузить их,
  передайте новый `key`.
- `onSubmitted` в полях больше не снимает фокус принудительно: это решает
  `textInputAction`. Если фокус нужно снять, сделайте это в обработчике.

### Устарело

Старые имена пока работают, но будут удалены:

- `AcademyApp.chromeBlurTintOpacity` (параметр и геттер) и
  `AcademyTokens.chromeBlurTintOpacity` → `chromeBlurToneStrength`;
- `AcademyCompactSegment` → `AcademySegmentedControl.compact`.

### Новое

- `AcademyApp`: `switchColor`, `checkmarkColor`, `feedbackLoadingIndicator`, `reduceTransparency`.
- `AcademySegmentedControl.minimumHeight`, `AcademyToastContent.messageVerticalPadding`,
  `AcademyActionStepper.semanticValue`, `AcademyLocalizations.more`.
- `AcademyGroupedTable.themed`: `hideEmptySections` (по умолчанию `true`).
- `AcademyRowAccessory`: `toggleValue`, `mergesIntoRow`, `hasTallTarget`, `movesUnderTitle`.
- `AcademyRowTrailingText.styleOf`, `academyRowSeparatorStart`.

### Исправлено

- Действие «Далее» на клавиатуре переводит фокус на следующее поле.
- Строки таблицы с ключами сохраняют состояние при перестановке и вставке.
- Перестроение родителя не сбрасывает picker во время перетаскивания.
- Встроенные загрузчики и предикаты сохраняют результаты выбора и диапазон.
- Заголовок строки с темой сохраняет цвет своего тона.
- Завершённый счётчик реагирует на долгое нажатие.
- Ленивые таблицы и таблицы с темой учитывают настройки секций.
- Строка, брошенная на другую строку своей секции, занимает её место при любой высоте строк.
- Повторные тосты снова озвучиваются и правильно обходят клавиатуру.
- Трёхзначный `AcademyIndexBadge` остаётся в одну строку.
- `AcademyApp` передаёт оставшиеся значения темы и `reduceTransparency`.

### Интерфейс и доступность

- Действия степпера, тоста и аксессуаров строк подписаны для VoiceOver.
- Область нажатия тоста, аксессуаров строк и сегментов — 44 pt без роста строк.
- Исправлен RTL в ошибках полей и кнопке закрытия просмотра фото. `AcademyStepper.wide`
  и `.actions` в RTL прижимаются к концу строки, минус остаётся слева, плюс справа.
- При крупном тексте значение строки переходит под заголовок.
- Reduce Motion учитывается в прокрутке наверх, Increase Contrast — в навигации.
- В строках используется один шеврон.

## 0.1.0

Первая версия с тегом: состояние `main` на коммите `f94c887`, до исправлений
по итогам ревью. Отдельного списка изменений нет.
