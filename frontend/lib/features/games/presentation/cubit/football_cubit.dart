import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:basketvibe/features/games/domain/entities/football_game.dart';
import 'package:basketvibe/features/games/domain/repositories/football_repository.dart';

class FootballState {
  const FootballState({
    required this.date,
    this.games = const [],
    this.loading = false,
    this.error = false,
    this.saving = false,
  });
  final DateTime date;
  final List<FootballGame> games;
  final bool loading;
  final bool error;
  final bool saving;
}

class FootballCubit extends Cubit<FootballState> {
  FootballCubit(this._repository)
    : super(FootballState(date: FootballSchedule.today())) {
    selectDate(state.date);
    _timer = Timer.periodic(const Duration(seconds: 15), (_) {
      if (!isClosed) _publish();
    });
  }
  final FootballRepository _repository;
  StreamSubscription<List<FootballGame>>? _subscription;
  Timer? _timer;
  int _generation = 0;

  void _publish({bool? saving}) => emit(
    FootballState(
      date: state.date,
      games: state.games,
      loading: state.loading,
      error: state.error,
      saving: saving ?? state.saving,
    ),
  );

  void selectDate(DateTime date) {
    final generation = ++_generation;
    _subscription?.cancel();
    emit(FootballState(date: date, loading: true, saving: state.saving));
    _subscription = _repository
        .watchDay(date)
        .listen(
          (games) {
            if (!isClosed && generation == _generation) {
              emit(
                FootballState(date: date, games: games, saving: state.saving),
              );
            }
          },
          onError: (Object error) {
            if (!isClosed && generation == _generation) {
              emit(
                FootballState(date: date, error: true, saving: state.saving),
              );
            }
          },
        );
  }

  Future<BookingFailure?> save(FootballGame game, Booking booking) =>
      _act(() => _repository.save(game, booking));
  Future<BookingFailure?> cancel(FootballGame game, String uid) =>
      _act(() => _repository.cancel(game, uid));

  Future<BookingFailure?> _act(Future<void> Function() action) async {
    if (state.saving) return BookingFailure.unavailable;
    _publish(saving: true);
    try {
      await action();
      return null;
    } on BookingException catch (e) {
      return e.reason;
    } catch (_) {
      return BookingFailure.unavailable;
    } finally {
      if (!isClosed) _publish(saving: false);
    }
  }

  @override
  Future<void> close() async {
    _timer?.cancel();
    await _subscription?.cancel();
    return super.close();
  }
}
