import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:basketvibe/features/games/domain/entities/football_game.dart';
import 'package:basketvibe/features/games/domain/repositories/football_repository.dart';

class FirestoreFootballRepository implements FootballRepository {
  FirestoreFootballRepository(this._db);
  final FirebaseFirestore _db;
  CollectionReference<Map<String, dynamic>> get _collection =>
      _db.collection('footballBookings');

  FootballGame _decode(
    FootballGame preset,
    Map<String, dynamic>? data, {
    bool fromCache = false,
  }) {
    final entries = data?['bookings'] as Map<String, dynamic>? ?? {};
    return FootballGame(
      pitch: preset.pitch,
      startTime: preset.startTime,
      fromCache: fromCache,
      bookings: entries.map((uid, raw) {
        final b = Map<String, dynamic>.from(raw as Map);
        return MapEntry(
          uid,
          Booking(
            userId: uid,
            team: FootballTeam.values.byName(b['team'] as String),
            places: b['places'] as int,
            bookerName: b['bookerName'] as String,
            friendNames: List<String>.from(b['friendNames'] as List),
          ),
        );
      }),
    );
  }

  Map<String, dynamic> _encode(FootballGame game) => {
    'startTime': Timestamp.fromDate(game.startTime),
    'pitchId': game.pitch.id,
    'counts': {
      for (final team in FootballTeam.values) team.name: game.used(team),
    },
    'bookings': game.bookings.map(
      (uid, b) => MapEntry(uid, {
        'team': b.team.name,
        'places': b.places,
        'bookerName': b.bookerName,
        'friendNames': b.friendNames,
      }),
    ),
  };

  @override
  Stream<List<FootballGame>> watchDay(DateTime date) {
    final presets = FootballSchedule.forDay(date);
    return _collection
        .where(FieldPath.documentId, whereIn: presets.map((g) => g.id).toList())
        .snapshots(includeMetadataChanges: true)
        .map((snapshot) {
          final docs = {for (final doc in snapshot.docs) doc.id: doc.data()};
          return presets
              .map(
                (preset) => _decode(
                  preset,
                  docs[preset.id],
                  fromCache: snapshot.metadata.isFromCache,
                ),
              )
              .toList();
        });
  }

  @override
  Future<bool> hasFutureBooking(String uid) async {
    final snapshot = await _collection
        .where('startTime', isGreaterThan: Timestamp.now())
        .get(const GetOptions(source: Source.server));
    return snapshot.docs.any(
      (doc) =>
          (doc.data()['bookings'] as Map<String, dynamic>).containsKey(uid),
    );
  }

  @override
  Future<void> save(FootballGame game, Booking booking) =>
      _mutate(game, (current) => current.save(booking, DateTime.now().toUtc()));

  @override
  Future<void> cancel(FootballGame game, String uid) =>
      _mutate(game, (current) => current.cancel(uid, DateTime.now().toUtc()));

  Future<void> _mutate(
    FootballGame preset,
    FootballGame Function(FootballGame) update,
  ) async {
    try {
      await _db.runTransaction((transaction) async {
        final ref = _collection.doc(preset.id);
        final snapshot = await transaction.get(ref);
        final current = _decode(preset, snapshot.data());
        transaction.set(ref, _encode(update(current)));
      });
    } on FirebaseException catch (e) {
      if (e.code == 'permission-denied' && preset.isPast(DateTime.now())) {
        throw const BookingException(BookingFailure.started);
      }
      throw const BookingException(BookingFailure.unavailable);
    }
  }
}
