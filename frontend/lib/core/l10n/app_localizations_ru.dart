// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get settingsTitle => 'Настройки';

  @override
  String get darkTheme => 'Тёмная тема';

  @override
  String get language => 'Язык';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageRussian => 'Русский';

  @override
  String get cancel => 'Отмена';

  @override
  String get save => 'Сохранить';

  @override
  String get retry => 'Попробовать снова';

  @override
  String get login => 'Войти';

  @override
  String get loginRequiredTitle => 'Требуется вход';

  @override
  String get loginRequiredMessage => 'Войдите в аккаунт, чтобы продолжить.';

  @override
  String get createGameLoginMessage => 'Войдите, чтобы создать игру.';

  @override
  String get joinGameLoginMessage => 'Войдите, чтобы присоединиться.';

  @override
  String get authLockTitle => 'Войдите в аккаунт';

  @override
  String get authLockProfileMessage =>
      'Войдите, чтобы видеть профиль и историю игр.';

  @override
  String get profileMyProfile => 'Мой профиль';

  @override
  String get profileEdit => 'Редактировать профиль';

  @override
  String get profileName => 'Имя';

  @override
  String get profileCity => 'Город';

  @override
  String get profileSkillLevel => 'Уровень';

  @override
  String profileGamesPlayed(int count) {
    return 'Сыграно игр: $count';
  }

  @override
  String profileCityLine(String city) {
    return 'Город: $city';
  }

  @override
  String profileLevelLine(String level) {
    return 'Уровень: $level';
  }

  @override
  String get profileEnterName => 'Введите имя';

  @override
  String get profileNotSignedIn => 'Вы не вошли';

  @override
  String get skillBeginner => 'Новичок';

  @override
  String get skillIntermediate => 'Средний';

  @override
  String get skillAdvanced => 'Продвинутый';

  @override
  String get skillPro => 'Профи';

  @override
  String get profileHistory => 'История';

  @override
  String get profileOpenHistory => 'Открыть историю активности';

  @override
  String get logout => 'Выйти';

  @override
  String get deleteAccount => 'Удалить аккаунт';

  @override
  String get deleteAccountConfirm => 'Удалить аккаунт?';

  @override
  String get deleteAccountConfirmMessage =>
      'Аккаунт будет удалён. Сначала отмените будущие брони. Исторические составы сохраняются.';

  @override
  String get gamesTitle => 'Предстоящие игры';

  @override
  String get gamesEmptyTitle => 'Пока нет игр';

  @override
  String get gamesEmptySubtitle =>
      'Создайте игру и позовите игроков на площадку.';

  @override
  String get gamesCreate => 'Создать игру';

  @override
  String get gamesFull => 'Мест нет';

  @override
  String get courtsSectionTitle => 'Площадки для игры';

  @override
  String get courtsTitle => 'Площадки';

  @override
  String get courtsNotFound => 'Площадки не найдены';

  @override
  String get courtsFilterAll => 'Все';

  @override
  String get courtsFilterIndoor => 'Зал';

  @override
  String get courtsFilterOutdoor => 'Улица';

  @override
  String get courtsFilterFree => 'Бесплатно';

  @override
  String get courtsLoadError => 'Не удалось загрузить площадки';

  @override
  String get courtsOpenHours => 'Время работы';

  @override
  String get courtsWhatsappError => 'Не удалось открыть WhatsApp';

  @override
  String get done => 'Готово';

  @override
  String get createGameTitle => 'Создать игру';

  @override
  String get createGameTitleLabel => 'Название *';

  @override
  String get createGameTitleHint => 'напр. Вечерний ран, Турнир 3x3';

  @override
  String get createGameTitleError => 'Введите название';

  @override
  String get createGameDescription => 'Описание';

  @override
  String get createGameDescriptionHint =>
      'напр. 3x3, средний уровень, тёмная форма';

  @override
  String get createGameCourtLabel => 'Площадка *';

  @override
  String get createGameLoadingCourts => 'Загрузка площадок…';

  @override
  String get createGameChooseCourt => 'Выберите площадку';

  @override
  String get createGameLocationLabel => 'Локация *';

  @override
  String get createGameLocationHint => 'Вставьте ссылку на карту или адрес';

  @override
  String get createGameLocationError => 'Укажите локацию';

  @override
  String get createGameDate => 'Дата *';

  @override
  String get createGameTime => 'Время *';

  @override
  String get createGameMaxPlayers => 'Макс. игроков *';

  @override
  String get createGameMaxPlayersError => 'Введите число игроков';

  @override
  String get createGameMaxPlayersRange => 'От 2 до 20';

  @override
  String get createGameVisibility => 'Видимость';

  @override
  String get visibilityPublic => 'Публичная';

  @override
  String get visibilityPrivate => 'Приватная';

  @override
  String get visibilityPublicHint => 'Каждый может найти и присоединиться';

  @override
  String get visibilityPrivateHint => 'Только по ссылке';

  @override
  String get historyTitle => 'История';

  @override
  String get historyEmpty => 'Пока нет игр. Присоединитесь или создайте!';

  @override
  String get createGamePayment => 'Оплата';

  @override
  String get paymentOnline => 'Онлайн';

  @override
  String get paymentCash => 'Наличные';

  @override
  String get paymentFree => 'Бесплатно';

  @override
  String get inDevelopment => 'В разработке';

  @override
  String get createGameAmount => 'Сумма с собой';

  @override
  String get createGameAmountHint => 'напр. 500';

  @override
  String get createGameSubmit => 'Создать игру';

  @override
  String get createGameSelectDateTime => 'Выберите дату и время';

  @override
  String get createGameInvalidAmount => 'Введите корректную сумму';

  @override
  String get createGameSuccess => 'Ран создан успешно!';

  @override
  String get createGameYou => 'Вы';

  @override
  String get homeLocation => 'Бишкек, Кыргызстан';

  @override
  String get tickerMessage1 =>
      '12 игроков зачекинились на Восток-5... 3 места на 5x5 в Бишкек Арена в 19:00';

  @override
  String get tickerMessage2 => 'Новый ран в 18:30 на Спартак — 4/10 мест';

  @override
  String get tickerMessage3 =>
      'Восток-5 сейчас горячая точка — 8 человек на площадке';

  @override
  String gamesSpots(Object spots) {
    return 'Мест: $spots';
  }

  @override
  String get gamesJoin => 'Присоединиться';

  @override
  String get gamesLeave => 'Выйти из игры';

  @override
  String get fdRed => 'Красная';

  @override
  String get fdBlue => 'Синяя';

  @override
  String get fdYellow => 'Жёлтая';

  @override
  String get fdGreen => 'Зелёная';

  @override
  String get fdStartedError =>
      'Игра уже началась. Бронь доступна только для просмотра.';

  @override
  String get fdFullError =>
      'Места уже заняли. Проверьте обновлённый состав и уменьшите количество мест.';

  @override
  String get fdChangeTeamHint =>
      'Для смены команды отмените бронь и запишитесь заново.';

  @override
  String get fdInvalidError => 'Проверьте количество мест и имена друзей.';

  @override
  String get fdNetworkError =>
      'Не удалось подтвердить данные. Проверьте соединение и повторите попытку.';

  @override
  String get fdSignIn => 'Войти через Google';

  @override
  String get fdChooseTeam => 'Выбрать команду';

  @override
  String get fdYourBooking => 'Ваша бронь';

  @override
  String get fdClose => 'Закрыть';

  @override
  String get fdReadOnly => 'Игра началась · только просмотр';

  @override
  String get fdOffline =>
      'Нет подтверждения сервера. Данные могут быть устаревшими; запись станет доступна после подключения.';

  @override
  String get fdSelected => 'Выбрана';

  @override
  String get fdFull => 'Мест нет';

  @override
  String get fdSelect => 'Выбрать';

  @override
  String get fdPlacesLabel => 'Места, включая вас';

  @override
  String get fdFewer => 'Меньше мест';

  @override
  String get fdMore => 'Больше мест';

  @override
  String get fdWholeTeam => 'Все свободные места';

  @override
  String get fdFriendsHint =>
      'Имена друзей необязательны и видны в составе. Вы занимаете первое место; остальные без имени — ваши гости.';

  @override
  String get fdSaving => 'Сохраняем…';

  @override
  String get fdBook => 'Забронировать';

  @override
  String get fdCancelBooking => 'Отменить бронь';

  @override
  String get fdCancelConfirm =>
      'Все места вашей брони снова станут доступны другим игрокам.';

  @override
  String get fdKeep => 'Оставить бронь';

  @override
  String get fdSchedule => 'Расписание';

  @override
  String get fdMyBookings => 'Мои брони';

  @override
  String get fdHero => 'Выбери поле.\nСобери своих.';

  @override
  String get fdSubtitle =>
      'Каждый вечер · 3 поля · 4 команды\nФутбол начинается с тебя.';

  @override
  String get fdTimezone => 'Бишкек · время UTC+6';

  @override
  String get fdPreviousDay => 'Предыдущий день';

  @override
  String get fdNextDay => 'Следующий день';

  @override
  String get fdToday => 'Сегодня';

  @override
  String get fdNoBookings =>
      'На эту дату у вас пока нет броней. Выберите игру в расписании.';

  @override
  String get fdPlayer => 'Игрок';

  @override
  String get fdSaved => 'Бронь подтверждена';

  @override
  String get fdCancelled => 'Бронь отменена, места освобождены';

  @override
  String get fdRules =>
      '4 команды на каждом поле. Вратарь включён в формат. Вся группа играет в одной команде. Изменение и отмена — до начала игры. Оплаты в приложении нет.';

  @override
  String get fdPlaceholder =>
      'Названия полей и тариф демонстрационные. Адрес и условия уточняйте у Football Day.';

  @override
  String get fdViewRoster => 'Посмотреть состав';

  @override
  String fdPitch(int number) {
    return 'Поле $number';
  }

  @override
  String fdFee(int amount) {
    return '$amount сом за игрока · справочно';
  }

  @override
  String fdPlaces(int free, int capacity) {
    return '$free / $capacity свободно';
  }

  @override
  String fdTotalFree(int free, int capacity) {
    return 'Свободно $free из $capacity мест';
  }

  @override
  String fdGuest(String name) {
    return 'Гость $name';
  }

  @override
  String fdFriend(int number) {
    return 'Друг $number (необязательно)';
  }

  @override
  String get fdLoginTagline => 'Твой футбол. Каждый вечер.';

  @override
  String get fdBrowse => 'Посмотреть расписание без входа';

  @override
  String get fdLoginNotice =>
      'Google-вход нужен для бронирования мест. Расписание можно смотреть без аккаунта.';

  @override
  String get fdOnboardTitle1 => 'Выбери игру';

  @override
  String get fdOnboardBody1 =>
      'Готовое расписание каждый день: 18:00 и 19:00, три поля в Бишкеке.';

  @override
  String get fdOnboardTitle2 => 'Собери своих';

  @override
  String get fdOnboardBody2 =>
      'Выбери цвет команды и забронируй места для себя и друзей. Вся группа — в одной команде.';

  @override
  String get fdOnboardTitle3 => 'Выходи на поле';

  @override
  String get fdOnboardBody3 =>
      'Меняй количество мест и отменяй бронь до начала игры. Стоимость справочная, без оплаты в приложении.';

  @override
  String get fdSkip => 'Пропустить';

  @override
  String get fdNext => 'Далее';

  @override
  String get fdStart => 'Начать';

  @override
  String get fdCancelBeforeDelete =>
      'Сначала отмените будущие брони в разделе «Мои брони», затем повторите удаление аккаунта.';

  @override
  String get fdDemoSignIn => 'Войти как демо-игрок';

  @override
  String get fdDemoNotice =>
      'Локальное демо. Используется тестовый аккаунт и тестовые брони.';
}
