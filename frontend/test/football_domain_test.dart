import 'package:flutter_test/flutter_test.dart';
import 'package:basketvibe/features/games/domain/entities/football_game.dart';

void main() {
  final date = DateTime.utc(2030, 6, 15);
  final now = date.subtract(const Duration(days: 1));
  Booking booking({
    String uid = 'alice',
    int places = 1,
    FootballTeam team = FootballTeam.red,
    List<String> friends = const [],
  }) => Booking(
    userId: uid,
    team: team,
    places: places,
    bookerName: 'Alice',
    friendNames: friends,
  );
  Matcher failure(BookingFailure value) =>
      throwsA(isA<BookingException>().having((e) => e.reason, 'reason', value));

  test(
    'six deterministic games with per-pitch capacities and Bishkek times',
    () {
      final games = FootballSchedule.forDay(date);
      expect(games.length, 6);
      expect(games.map((g) => g.id).toSet().length, 6);
      expect(games.map((g) => g.capacity), [24, 24, 20, 24, 24, 20]);
      expect(games.first.startTime, DateTime.utc(2030, 6, 15, 12));
      expect(FootballSchedule.bishkekTime(games.last.startTime).hour, 19);
      expect(FootballSchedule.forDay(date).first.id, games.first.id);
      expect(
        FootballSchedule.forDay(date.add(const Duration(days: 1))).first.id,
        isNot(games.first.id),
      );
    },
  );
  test('Bishkek calendar changes at 18:00 UTC, including year boundary', () {
    expect(
      FootballSchedule.today(DateTime.utc(2029, 12, 31, 17, 59)),
      DateTime.utc(2029, 12, 31),
    );
    expect(
      FootballSchedule.today(DateTime.utc(2029, 12, 31, 18)),
      DateTime.utc(2030),
    );
  });
  test('schedule opens tomorrow once the last Bishkek slot starts', () {
    expect(
      FootballSchedule.defaultDay(DateTime.utc(2030, 6, 15, 12, 59)),
      date,
    );
    expect(
      FootballSchedule.defaultDay(DateTime.utc(2030, 6, 15, 13)),
      date.add(const Duration(days: 1)),
    );
  });
  test('group takes one team; other teams stay available', () {
    final game = FootballSchedule.forDay(
      date,
    ).first.save(booking(places: 6), now);
    expect(game.freePlaces(FootballTeam.red), 0);
    expect(game.freePlaces(FootballTeam.blue), 6);
    expect(game.freeTotal, 18);
    expect(
      () => game.save(booking(uid: 'bob'), now),
      failure(BookingFailure.full),
    );
  });
  test('4+1 cannot accept six players', () {
    final game = FootballSchedule.forDay(date)[2];
    expect(
      () => game.save(booking(places: 6), now),
      failure(BookingFailure.full),
    );
    expect(game.save(booking(places: 5), now).freePlaces(FootballTeam.red), 0);
  });
  test(
    'edit reuses own places, keeps one booking, cancellation frees them',
    () {
      var game = FootballSchedule.forDay(
        date,
      ).first.save(booking(places: 4), now);
      game = game.save(booking(uid: 'bob', places: 2), now);
      expect(game.editablePlaces(FootballTeam.red, 'alice'), 4);
      game = game.save(booking(places: 2, friends: ['Friend']), now);
      expect(game.bookings.length, 2);
      expect(game.freePlaces(FootballTeam.red), 2);
      game = game.cancel('alice', now);
      expect(game.freePlaces(FootballTeam.red), 4);
      expect(game.bookings.containsKey('alice'), false);
    },
  );
  test('change team requires cancellation', () {
    var game = FootballSchedule.forDay(date).first.save(booking(), now);
    expect(
      () => game.save(booking(team: FootballTeam.blue), now),
      failure(BookingFailure.teamChange),
    );
    game = game
        .cancel('alice', now)
        .save(booking(team: FootballTeam.blue), now);
    expect(game.bookings['alice']!.team, FootballTeam.blue);
  });
  test('zero places and too many friends rejected; unnamed guests allowed', () {
    final game = FootballSchedule.forDay(date).first;
    expect(
      () => game.save(booking(places: 0), now),
      failure(BookingFailure.invalid),
    );
    expect(
      () => game.save(booking(friends: ['Friend']), now),
      failure(BookingFailure.invalid),
    );
    expect(
      game
          .save(booking(places: 3, friends: ['']), now)
          .bookings['alice']!
          .places,
      3,
    );
  });
  test('exact kickoff and past games disallow save and cancel', () {
    final game = FootballSchedule.forDay(date).first.save(booking(), now);
    expect(
      () => game.save(booking(), game.startTime),
      failure(BookingFailure.started),
    );
    expect(
      () => game.cancel('alice', game.startTime),
      failure(BookingFailure.started),
    );
    expect(
      () =>
          game.cancel('alice', game.startTime.add(const Duration(seconds: 1))),
      failure(BookingFailure.started),
    );
  });
  test('all four teams full means no remaining places', () {
    var game = FootballSchedule.forDay(date)[2];
    for (final team in FootballTeam.values) {
      game = game.save(booking(uid: team.name, team: team, places: 5), now);
    }
    expect(game.freeTotal, 0);
  });
}
