enum FootballTeam { red, blue, yellow, green }

class PitchPreset {
  const PitchPreset(this.id, this.number, this.outfieldPlayers, this.feeKgs);
  final String id;
  final int number;
  final int outfieldPlayers;
  final int feeKgs;
  int get capacity => outfieldPlayers + 1;
  String get format => '$outfieldPlayers + 1';
}

class FootballSchedule {
  static const utcOffset = Duration(hours: 6);
  static const hours = [18, 19];
  // Placeholder names/formats/fee. Keep firestore.rules in sync with slots.
  static const pitches = [
    PitchPreset('pitch1', 1, 5, 300),
    PitchPreset('pitch2', 2, 5, 300),
    PitchPreset('pitch3', 3, 4, 300),
  ];

  static DateTime bishkekTime(DateTime instant) =>
      instant.toUtc().add(utcOffset);
  static DateTime today([DateTime? now]) {
    final local = bishkekTime(now ?? DateTime.now());
    return DateTime.utc(local.year, local.month, local.day);
  }

  static List<FootballGame> forDay(DateTime date) => [
    for (final hour in hours)
      for (final pitch in pitches)
        FootballGame(
          pitch: pitch,
          startTime: DateTime.utc(
            date.year,
            date.month,
            date.day,
            hour,
          ).subtract(utcOffset),
        ),
  ];
}

class Booking {
  Booking({
    required this.userId,
    required this.team,
    required this.places,
    required this.bookerName,
    List<String> friendNames = const [],
  }) : friendNames = List.unmodifiable(friendNames);
  final String userId;
  final FootballTeam team;
  final int places;
  final String bookerName;
  final List<String> friendNames;
}

enum BookingFailure { started, full, teamChange, invalid, unavailable, signIn }

class BookingException implements Exception {
  const BookingException(this.reason);
  final BookingFailure reason;
}

class FootballGame {
  FootballGame({
    required this.pitch,
    required this.startTime,
    Map<String, Booking> bookings = const {},
    this.fromCache = false,
  }) : bookings = Map.unmodifiable(bookings);
  final PitchPreset pitch;
  final DateTime startTime;
  final Map<String, Booking> bookings;
  final bool fromCache;
  String get id => '${startTime.millisecondsSinceEpoch ~/ 1000}_${pitch.id}';
  int get capacity => pitch.capacity * FootballTeam.values.length;
  int get freeTotal =>
      capacity - bookings.values.fold(0, (n, b) => n + b.places);
  bool isPast(DateTime now) => !now.isBefore(startTime);
  int used(FootballTeam team) => bookings.values
      .where((b) => b.team == team)
      .fold(0, (n, b) => n + b.places);
  int freePlaces(FootballTeam team) => pitch.capacity - used(team);
  int editablePlaces(FootballTeam team, String uid) =>
      freePlaces(team) +
      (bookings[uid]?.team == team ? bookings[uid]!.places : 0);

  FootballGame save(Booking booking, DateTime now) {
    if (isPast(now)) throw const BookingException(BookingFailure.started);
    final old = bookings[booking.userId];
    if (old != null && old.team != booking.team) {
      throw const BookingException(BookingFailure.teamChange);
    }
    if (booking.userId.isEmpty ||
        booking.places < 1 ||
        booking.bookerName.trim().isEmpty ||
        booking.bookerName.length > 80 ||
        booking.friendNames.length > booking.places - 1 ||
        booking.friendNames.any((name) => name.length > 80)) {
      throw const BookingException(BookingFailure.invalid);
    }
    if (booking.places > editablePlaces(booking.team, booking.userId)) {
      throw const BookingException(BookingFailure.full);
    }
    return FootballGame(
      pitch: pitch,
      startTime: startTime,
      bookings: {...bookings, booking.userId: booking},
    );
  }

  FootballGame cancel(String uid, DateTime now) {
    if (isPast(now)) throw const BookingException(BookingFailure.started);
    return FootballGame(
      pitch: pitch,
      startTime: startTime,
      bookings: Map.of(bookings)..remove(uid),
    );
  }
}
