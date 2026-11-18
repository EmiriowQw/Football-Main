// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get settingsTitle => 'Settings';

  @override
  String get darkTheme => 'Dark theme';

  @override
  String get language => 'Language';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageRussian => 'Русский';

  @override
  String get cancel => 'Cancel';

  @override
  String get save => 'Save';

  @override
  String get retry => 'Try again';

  @override
  String get login => 'Log in';

  @override
  String get loginRequiredTitle => 'Sign in required';

  @override
  String get loginRequiredMessage => 'Sign in to your account to continue.';

  @override
  String get createGameLoginMessage => 'Sign in to create a game.';

  @override
  String get joinGameLoginMessage => 'Sign in to join.';

  @override
  String get authLockTitle => 'Sign in to your account';

  @override
  String get authLockProfileMessage =>
      'Sign in to see your profile and game history.';

  @override
  String get profileMyProfile => 'My profile';

  @override
  String get profileEdit => 'Edit profile';

  @override
  String get profileName => 'Name';

  @override
  String get profileCity => 'City';

  @override
  String get profileSkillLevel => 'Skill level';

  @override
  String profileGamesPlayed(int count) {
    return 'Games played: $count';
  }

  @override
  String profileCityLine(String city) {
    return 'City: $city';
  }

  @override
  String profileLevelLine(String level) {
    return 'Level: $level';
  }

  @override
  String get profileEnterName => 'Enter your name';

  @override
  String get profileNotSignedIn => 'Not signed in';

  @override
  String get skillBeginner => 'Beginner';

  @override
  String get skillIntermediate => 'Intermediate';

  @override
  String get skillAdvanced => 'Advanced';

  @override
  String get skillPro => 'Pro';

  @override
  String get profileHistory => 'History';

  @override
  String get profileOpenHistory => 'Open activity history';

  @override
  String get logout => 'Log out';

  @override
  String get deleteAccount => 'Delete account';

  @override
  String get deleteAccountConfirm => 'Delete account?';

  @override
  String get deleteAccountConfirmMessage =>
      'Your account will be deleted. Cancel future bookings first. Historical rosters are retained.';

  @override
  String get gamesTitle => 'Upcoming games';

  @override
  String get gamesEmptyTitle => 'No games yet';

  @override
  String get gamesEmptySubtitle =>
      'Create a game and call players to the court.';

  @override
  String get gamesCreate => 'Create game';

  @override
  String get gamesFull => 'Game is full';

  @override
  String get courtsSectionTitle => 'Places to play';

  @override
  String get courtsTitle => 'Courts';

  @override
  String get courtsNotFound => 'No courts found';

  @override
  String get courtsFilterAll => 'All';

  @override
  String get courtsFilterIndoor => 'Indoor';

  @override
  String get courtsFilterOutdoor => 'Outdoor';

  @override
  String get courtsFilterFree => 'Free';

  @override
  String get courtsLoadError => 'Failed to load courts';

  @override
  String get courtsOpenHours => 'Opening hours';

  @override
  String get courtsWhatsappError => 'Could not open WhatsApp';

  @override
  String get done => 'Done';

  @override
  String get createGameTitle => 'Host a game';

  @override
  String get createGameTitleLabel => 'Title *';

  @override
  String get createGameTitleHint => 'e.g. Evening Run, 3x3 Tournament';

  @override
  String get createGameTitleError => 'Enter a title';

  @override
  String get createGameDescription => 'Description';

  @override
  String get createGameDescriptionHint =>
      'e.g. 3x3, intermediate, bring dark tee';

  @override
  String get createGameCourtLabel => 'Court *';

  @override
  String get createGameLoadingCourts => 'Loading courts…';

  @override
  String get createGameChooseCourt => 'Choose a court';

  @override
  String get createGameLocationLabel => 'Location *';

  @override
  String get createGameLocationHint => 'Paste a map link or address';

  @override
  String get createGameLocationError => 'Enter a location';

  @override
  String get createGameDate => 'Date *';

  @override
  String get createGameTime => 'Time *';

  @override
  String get createGameMaxPlayers => 'Max players *';

  @override
  String get createGameMaxPlayersError => 'Enter number of players';

  @override
  String get createGameMaxPlayersRange => 'Between 2 and 20';

  @override
  String get createGameVisibility => 'Visibility';

  @override
  String get visibilityPublic => 'Public';

  @override
  String get visibilityPrivate => 'Private';

  @override
  String get visibilityPublicHint => 'Anyone can find and join';

  @override
  String get visibilityPrivateHint => 'Only people with the link';

  @override
  String get historyTitle => 'History';

  @override
  String get historyEmpty => 'No games yet. Join or host one!';

  @override
  String get createGamePayment => 'Payment';

  @override
  String get paymentOnline => 'Online';

  @override
  String get paymentCash => 'Cash';

  @override
  String get paymentFree => 'Free';

  @override
  String get inDevelopment => 'In development';

  @override
  String get createGameAmount => 'Amount to bring';

  @override
  String get createGameAmountHint => 'e.g. 500';

  @override
  String get createGameSubmit => 'Host game';

  @override
  String get createGameSelectDateTime => 'Select date and time';

  @override
  String get createGameInvalidAmount => 'Enter a valid amount';

  @override
  String get createGameSuccess => 'Run created successfully!';

  @override
  String get createGameYou => 'You';

  @override
  String get homeLocation => 'Bishkek, Kyrgyzstan';

  @override
  String get tickerMessage1 =>
      '12 players just checked into Vostok-5... 3 spots for 5v5 at Bishkek Arena at 19:00';

  @override
  String get tickerMessage2 => 'New run at 18:30 at Spartak — 4/10 spots';

  @override
  String get tickerMessage3 =>
      'Vostok-5 is hot right now — 8 people on the court';

  @override
  String gamesSpots(Object spots) {
    return 'Spots: $spots';
  }

  @override
  String get gamesJoin => 'Join';

  @override
  String get gamesLeave => 'Leave game';

  @override
  String get fdRed => 'Red';

  @override
  String get fdBlue => 'Blue';

  @override
  String get fdYellow => 'Yellow';

  @override
  String get fdGreen => 'Green';

  @override
  String get fdStartedError =>
      'The game has started. Your booking is read-only.';

  @override
  String get fdFullError =>
      'Those places were just taken. Check the updated roster and reduce your group size.';

  @override
  String get fdChangeTeamHint =>
      'To change teams, cancel your booking and book again.';

  @override
  String get fdInvalidError =>
      'Check the number of places and your friends’ names.';

  @override
  String get fdNetworkError =>
      'Could not confirm the data. Check your connection and try again.';

  @override
  String get fdSignIn => 'Sign in with Google';

  @override
  String get fdChooseTeam => 'Choose a team';

  @override
  String get fdYourBooking => 'Your booking';

  @override
  String get fdClose => 'Close';

  @override
  String get fdReadOnly => 'Game started · read-only';

  @override
  String get fdOffline =>
      'Waiting for the server. Availability may be outdated; booking resumes when connected.';

  @override
  String get fdSelected => 'Selected';

  @override
  String get fdFull => 'Full';

  @override
  String get fdSelect => 'Select';

  @override
  String get fdPlacesLabel => 'Places, including you';

  @override
  String get fdFewer => 'Fewer places';

  @override
  String get fdMore => 'More places';

  @override
  String get fdWholeTeam => 'All available places';

  @override
  String get fdFriendsHint =>
      'Friends’ names are optional and visible in the roster. You take the first place; unnamed friends appear as your guests.';

  @override
  String get fdSaving => 'Saving…';

  @override
  String get fdBook => 'Book places';

  @override
  String get fdCancelBooking => 'Cancel booking';

  @override
  String get fdCancelConfirm =>
      'All places in your booking will become available to other players.';

  @override
  String get fdKeep => 'Keep booking';

  @override
  String get fdSchedule => 'Schedule';

  @override
  String get fdMyBookings => 'My bookings';

  @override
  String get fdHero => 'Pick your pitch.\nBring your people.';

  @override
  String get fdSubtitle =>
      'Every evening · 3 pitches · 4 teams\nFootball starts with you.';

  @override
  String get fdTimezone => 'Bishkek · UTC+6 time';

  @override
  String get fdPreviousDay => 'Previous day';

  @override
  String get fdNextDay => 'Next day';

  @override
  String get fdToday => 'Today';

  @override
  String get fdNoBookings =>
      'You have no bookings for this date. Pick a game in the schedule.';

  @override
  String get fdPlayer => 'Player';

  @override
  String get fdSaved => 'Booking confirmed';

  @override
  String get fdCancelled => 'Booking cancelled, places released';

  @override
  String get fdRules =>
      '4 teams per pitch. The goalkeeper is included in the format. Groups stay on one team. Edit or cancel before kickoff. No in-app payments.';

  @override
  String get fdPlaceholder =>
      'Pitch names and fees are placeholders. Confirm the venue and details with Football Day.';

  @override
  String get fdViewRoster => 'View roster';

  @override
  String fdPitch(int number) {
    return 'Pitch $number';
  }

  @override
  String fdFee(int amount) {
    return '$amount KGS per player · information only';
  }

  @override
  String fdPlaces(int free, int capacity) {
    return '$free / $capacity free';
  }

  @override
  String fdTotalFree(int free, int capacity) {
    return '$free of $capacity places available';
  }

  @override
  String fdGuest(String name) {
    return 'Guest of $name';
  }

  @override
  String fdFriend(int number) {
    return 'Friend $number (optional)';
  }

  @override
  String get fdLoginTagline => 'Your football. Every evening.';

  @override
  String get fdBrowse => 'Browse without signing in';

  @override
  String get fdLoginNotice =>
      'Sign in with Google to book places. You can browse the schedule without an account.';

  @override
  String get fdOnboardTitle1 => 'Pick a game';

  @override
  String get fdOnboardBody1 =>
      'A ready schedule every day: 18:00 and 19:00, three pitches in Bishkek.';

  @override
  String get fdOnboardTitle2 => 'Bring your people';

  @override
  String get fdOnboardBody2 =>
      'Choose a team colour and book for yourself and friends. Your whole group stays together.';

  @override
  String get fdOnboardTitle3 => 'See you on the pitch';

  @override
  String get fdOnboardBody3 =>
      'Edit your group size or cancel before kickoff. Fees are informational; there are no in-app payments.';

  @override
  String get fdSkip => 'Skip';

  @override
  String get fdNext => 'Next';

  @override
  String get fdStart => 'Get started';

  @override
  String get fdCancelBeforeDelete =>
      'Cancel your upcoming bookings in My bookings before deleting your account.';

  @override
  String get fdDemoSignIn => 'Sign in as demo player';

  @override
  String get fdDemoNotice =>
      'Local demo. Uses a test account and test bookings.';
}
