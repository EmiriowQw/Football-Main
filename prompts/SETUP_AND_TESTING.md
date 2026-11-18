# Настройка и проверка Football Day

## Показ на Android без аккаунта Google

Для повторного показа откройте `Start Football Day Demo.cmd` в корне проекта. Из PowerShell можно запустить `./frontend/tool/run_demo.ps1`. Скрипт использует установленный Android-эмулятор, поднимает Firebase Auth и Firestore локально и открывает APK. На этой машине Java 21, зависимости Firebase CLI и Android Virtual Device уже подготовлены.

Сценарий показа: «Мои брони» → «Войти как демо-игрок» → «Пропустить» или пройти обучение → выбрать завтрашний день → поле → команда → два места и имя друга → «Забронировать». Затем «Мои брони» → «Ваша бронь» → изменить имя или число мест → «Сохранить» → «Отменить бронь».

Этот сценарий проверен на Android-эмуляторе интеграционным тестом `integration_test/football_demo_test.dart`: вход, создание брони, изменение имени друга и отмена.

Локальный режим использует Firebase-проект `demo-football-day`. Тестовая личность создаётся в Auth Emulator, а брони проходят через те же транзакции и правила Firestore. Этот вход не обращается к Google и доступен только в debug-сборке с `FOOTBALL_DEMO=true`. Данные демо хранятся в работающем локальном эмуляторе и сбрасываются при его перезапуске. Не останавливайте эмуляторы во время показа.

Для настоящего входа откройте `Start Football Day Google.cmd` или запустите `./frontend/tool/run_demo.ps1 -Cloud`. Обычная Android-сборка подключена к `football-day`, Google-провайдер включён, SHA-1 этой debug-подписи зарегистрирован и правила Firestore опубликованы. Настоящий вход потребует выбрать Google-аккаунт в Android. Если собираете другим ключом, зарегистрируйте его SHA-1. iOS в рамках Android-демо не перенастраивалась.

## Локальный запуск

Нужны Flutter со совместимым Dart (проект проверялся с Flutter 3.47.9 / Dart 3.13.7), Android SDK; для iOS — macOS/Xcode. Из корня:

```powershell
cd frontend
Copy-Item .env.example .env   # только если файла нет; существующий не перезаписывать
flutter pub get
flutter gen-l10n
flutter run
```

Необязательные публичные OAuth client ID задаются в `.env` по примеру. Android обычно получает конфигурацию Google из `android/app/google-services.json`; iOS требует соответствующую настройку клиента и URL scheme. `.env` попадает в приложение и не подходит для серверных секретов.

## Firebase

Android использует Firebase-проект `football-day` и зарегистрированный application ID `com.example.basketvibe`. Для другого проекта настройте платформенные приложения через FlutterFire, включите Google provider в Firebase Authentication, зарегистрируйте SHA fingerprints Android и настройте iOS URL scheme. Не коммитьте service-account keys.

Новая коллекция: `footballBookings`. Первичная загрузка или seed не требуются: приложение вычисляет расписание, а документ состава появляется при первой записи. Старые данные `/games` не мигрируются автоматически, старые клиенты больше не могут их изменять после публикации правил.

### Публикация правил

Файл `frontend/firestore.rules` нужно опубликовать в выбранный Firebase-проект перед проверкой реальных броней:

```powershell
cd frontend
firebase deploy --only firestore:rules --project YOUR_PROJECT_ID
```

Публикация не выполняется автоматически вместе с изменением кода. Проверьте целевой project ID перед командой: правила закрывают запись в старый `/games`. Специальный composite index для новых запросов не требуется (document ID / одно поле startTime).

## Android-сборка при неверной глобальной Java

Если Flutter ссылается на отсутствующий `jdk-dir`, можно выполнить сборку напрямую через Gradle с JDK 21, не изменяя глобальные настройки:

```powershell
cd frontend
./tool/build_android.ps1 -JavaHome 'C:\path\to\jdk-21'
```

Скрипт меняет JAVA_HOME только на время команды и восстанавливает окружение. В текущей сессии JDK размещена в `.tools/jdk21/jdk-21.0.13+9` в корне проекта (служебный игнорируемый каталог). Java 25 из установленной Android Studio не подходит для текущего Gradle 8.14.

## Настройка расписания и оформления

В `lib/features/games/domain/entities/football_game.dart` класс `FootballSchedule` содержит часы, поля, форматы и справочную цену. Менять вместе с `validSlot` / `capacity` в `firestore.rules`, локализацией подписей и тестами. Не менять вместимость уже забронированных слотов без отдельной миграции. UTC+6 используется явно; время телефона не меняет идентификатор игры.

Футбольный launcher построен из существующего Material-значка `sports_soccer`. Для повторного рендера: `flutter test tool/generate_football_icon.dart`, затем `dart run flutter_launcher_icons`. Исходный результат: `assets/logo/football_day_logo.png`.

## Автоматические проверки

```powershell
cd frontend
flutter gen-l10n
flutter analyze
flutter test
cd rules-tests
npm ci
npm test
```

Для `npm test`: Node.js 20+ и Java 21+ в PATH. Например, PowerShell:

```powershell
$env:JAVA_HOME = 'C:\Program Files\Android\Android Studio\jbr'
$env:PATH = $env:JAVA_HOME + '\bin;' + $env:PATH
npm test
```

`firebase.test.json` включает только локальный Firestore на порту 8088. Проект `demo-football-day` изолирован от рабочей базы. Ожидаемые сообщения PERMISSION_DENIED в негативных тестах не являются падением теста.

Сценарии эмулятора: публичное чтение/Google-запись, создание legacy-игр запрещено, редактирование и отмена, защита чужих броней и метаданных, подмена счётчиков, неверные слоты, валидация имён/вместимости, прошлые игры, конкуренция на последние места и live-обновление после отмены.

Flutter-тесты проверяют доменную модель и интерфейс. `build/football_day_preview.png` — техническое превью из widget-теста на тестовых данных; не снимок рабочей базы. Для читаемого превью тест при наличии использует системный Arial на Windows.

## Ручная проверка перед выпуском

- Google-вход на реальном устройстве и две независимые учётные записи.
- Запись/редактирование/отмена, восстановление соединения, конфликт последнего места.
- Изменение даты, открытый экран в момент начала, RU/EN и крупный шрифт.
- Настоящие адреса, тарифы и площадки согласовать с Football Day; начальные значения демонстрационные.
- Удаление аккаунта требует сначала отменить будущие брони. Исторические имена сохраняются; обезличивание требует отдельной серверной процедуры.

## Источники технических решений

- [Firestore transactions](https://firebase.google.com/docs/firestore/manage-data/transactions).
- [Проверка полей и изменений карты](https://firebase.google.com/docs/firestore/security/rules-fields).
- [Timestamp в Firestore Rules](https://firebase.google.com/docs/reference/rules/rules.Timestamp_): `toMillis()` используется для стабильного ID, а `time()` — для проверки часа.
