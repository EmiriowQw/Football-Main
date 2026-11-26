# Структура файлов

```text
README.md                         точка входа
AGENTS.md                         правила для следующих AI-сессий
prompts/                          актуальная документация
PROMTS/football-day-concept.md     исходный концепт (сохранён)
frontend/
  lib/core/
    constants/                    константы приложения
    l10n/                         ARB RU/EN и генерируемые классы
    network/injection.dart        GetIt
    router/app_router.dart        доступные маршруты
    styles/                       цвета, отступы, тема
  lib/features/games/
    domain/entities/football_game.dart
    domain/repositories/football_repository.dart
    data/repositories/firestore_football_repository.dart
    presentation/cubit/football_cubit.dart
    presentation/pages/football_day_page.dart
    presentation/pages/football_booking_page.dart
    presentation/widgets/football_arena.dart
    presentation/widgets/football_formation.dart
  lib/features/auth/              существующий Google-вход
  lib/features/profile/           профиль и настройки
  test/                          unit/widget-тесты
  rules-tests/                   интеграционные тесты Firestore Rules
  firestore.rules                серверные ограничения
  firebase.json                  Firebase CLI
backend/                         прежний Django API
```

Файлы называть `snake_case`, классы `UpperCamelCase`. Новые правила и объяснения помещать в `prompts`, а не дублировать в `frontend/commands`. Старые модули игр/карт сохранены как исходный код, но не должны подключаться к футбольной навигации. Не менять native application ID или OAuth client ID ради изменения названия в интерфейсе.
