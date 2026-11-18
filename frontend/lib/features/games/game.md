# Игры Football Day

Актуальная документация: [DOMAIN_MODELS](../../../../prompts/DOMAIN_MODELS.md), [ARCHITECTURE](../../../../prompts/ARCHITECTURE.md), [FEATURES_AND_RULES](../../../../prompts/FEATURES_AND_RULES.md).

Активный сценарий: FootballSchedule → FootballRepository → FootballCubit → FootballDayPage. Данные бронирований находятся в Firestore `footballBookings`; это не in-memory mock.

Старые классы GameEntity/GameCubit сохранены для совместимости исходников, но не подключены к футбольной навигации. Создание игр недоступно, запись в legacy-коллекцию закрыта правилами.
