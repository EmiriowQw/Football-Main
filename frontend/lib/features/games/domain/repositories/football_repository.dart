import 'package:basketvibe/features/games/domain/entities/football_game.dart';

abstract class FootballRepository {
  Stream<List<FootballGame>> watchDay(DateTime date);
  Future<void> save(FootballGame game, Booking booking);
  Future<void> cancel(FootballGame game, String uid);
  Future<bool> hasFutureBooking(String uid);
}
