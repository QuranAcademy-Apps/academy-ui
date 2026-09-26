# Academy UI

Общая Flutter-библиотека интерфейса для приложений QuranAcademy и отдельное демо-приложение со всеми компонентами.

- [Academy UI: компоненты, модалки и подключение](packages/academy_ui/README.md).
- [Интерактивный каталог](apps/academy_ui_catalog/README.md).
- [План и источники переноса](docs/plans/design-system-migration.md).

Git remote: `git@github.com:QuranAcademy-Apps/academy-ui.git`.

Библиотека находится в `packages/academy_ui`, демо — в `apps/academy_ui_catalog`.
Другие приложения подключают библиотеку через Git, указывая `path: packages/academy_ui` и закрепляя проверенный commit или tag. Демо использует локальную зависимость на ту же библиотеку.
