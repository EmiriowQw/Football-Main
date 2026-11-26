# Football Day

Ежедневный любительский футбол в Бишкеке. Выберите готовую игру, команду и забронируйте места для себя и друзей.

Для показа на Android-эмуляторе откройте `Start Football Day Demo.cmd`. Он запускает локальный Firebase и приложение с тестовым входом. `Start Football Day Google.cmd` открывает сборку с реальным Google-входом. Шаги показа и настройки описаны в [SETUP_AND_TESTING.md](prompts/SETUP_AND_TESTING.md).

Для показа на Windows скачайте `Football-Day-Demo-Windows.zip` из [GitHub Releases](https://github.com/EmiriowQw/Football-Main/releases), распакуйте архив целиком и откройте `Start Football Day Demo.cmd`. Нужен установленный Android SDK с настроенным виртуальным устройством (AVD). APK, Java и инструменты локального Firebase уже в архиве. ZIP из меню GitHub **Code → Download ZIP** содержит исходники для разработки.

## Что реализовано

- Расписание на каждый день: 18:00 и 19:00, три поля одновременно.
- Четыре команды; поля 1–2 играют 5 + 1 (24 места), поле 3 — 4 + 1 (20 мест).
- Вход через Google; гостям доступно расписание.
- Отдельный экран брони: от одного места до всего остатка команды, имена друзей и позиции игроков по желанию.
- Изменение количества, имён и позиций и отмена до начала игры, история по выбранной дате.
- Обновление состава в реальном времени, транзакции и серверные ограничения вместимости.
- Интерфейс RU/EN и дизайн «Ночная арена» для расписания и брони.

Игроки не создают игры. Нет организаторских аккаунтов, платежей, результатов и статистики. Стоимость справочная; названия полей и тариф пока демонстрационные.

## Стек

Flutter, flutter_bloc, GetIt, go_router, Firebase Auth, Google Sign-In, Cloud Firestore. Существующая структура сохранена. Внутреннее имя Dart-пакета `basketvibe` оставлено для совместимости. Каталог `backend` содержит прежний Django API; бронирование Football Day использует Firestore напрямую.

## Documentation

Актуальная документация находится в [prompts](prompts/README.md):

- [PROJECT_OVERVIEW.md](prompts/PROJECT_OVERVIEW.md) — назначение, стек, границы версии.
- [AI_INSTRUCTIONS.md](prompts/AI_INSTRUCTIONS.md) — правила разработки и работы AI.
- [ARCHITECTURE.md](prompts/ARCHITECTURE.md) — слои, данные и транзакции.
- [FOLDER_STRUCTURE.md](prompts/FOLDER_STRUCTURE.md) — реальные пути файлов.
- [UI_STYLE_GUIDE.md](prompts/UI_STYLE_GUIDE.md) — UI/UX, стили, доступность.
- [DOMAIN_MODELS.md](prompts/DOMAIN_MODELS.md) — модели и инварианты.
- [FEATURES_AND_RULES.md](prompts/FEATURES_AND_RULES.md) — функциональные правила и приёмка.
- [CONTEXT_ROUTER.md](prompts/CONTEXT_ROUTER.md) — выбор документации по задаче.
- [SETUP_AND_TESTING.md](prompts/SETUP_AND_TESTING.md) — настройка и проверки.
- [football-day-concept.md](prompts/football-day-concept.md) — исходная концепция.

Прежний путь `commands/` был неверным: старые документы находились в `frontend/commands`. Теперь они перенаправляют к актуальным инструкциям.

## Запуск

Из корня репозитория:

```powershell
cd frontend
Copy-Item .env.example .env  # только если .env ещё нет
flutter pub get
flutter gen-l10n
flutter run
```

Предварительно настройте Firebase и Google-вход для вашей платформы по [инструкции](prompts/SETUP_AND_TESTING.md). Рабочая база должна получить новые `firestore.rules`: одно изменение файла в проекте не публикует правила.

## Проверка

```powershell
cd frontend
flutter analyze
flutter test
cd rules-tests
npm ci
npm test
```

Для тестов правил нужны Node.js и Java 21+. Тесты используют отдельный локальный проект `demo-football-day`, не рабочую базу.
