import 'dart:async';
import 'package:basketvibe/features/games/domain/entities/football_game.dart';
import 'package:basketvibe/features/games/domain/repositories/football_repository.dart';

class FootballRepositoryFake implements FootballRepository {
  final changes = StreamController<List<FootballGame>>.broadcast();
  List<FootballGame> games = [];
  Booking? saved;
  BookingFailure? failWith;
  @override
  Stream<List<FootballGame>> watchDay(DateTime date) {
    if (games.isEmpty) games = FootballSchedule.forDay(date);
    return Stream.multi((controller) {
      controller.add(games);
      final subscription = changes.stream.listen(
        controller.add,
        onError: controller.addError,
        onDone: controller.close,
      );
      controller.onCancel = subscription.cancel;
    });
  }

  @override
  Future<void> save(FootballGame game, Booking booking) async {
    if (failWith != null) throw BookingException(failWith!);
    saved = booking;
    games = games
        .map((g) => g.id == game.id ? g.save(booking, DateTime.now()) : g)
        .toList();
    changes.add(games);
  }

  @override
  Future<void> cancel(FootballGame game, String uid) async {
    games = games
        .map((g) => g.id == game.id ? g.cancel(uid, DateTime.now()) : g)
        .toList();
    changes.add(games);
  }

  @override
  Future<bool> hasFutureBooking(String uid) async =>
      games.any((g) => g.bookings.containsKey(uid));
}
