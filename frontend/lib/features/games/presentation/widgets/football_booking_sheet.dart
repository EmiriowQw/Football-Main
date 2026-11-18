import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:basketvibe/core/l10n/app_localizations.dart';
import 'package:basketvibe/core/styles/app_spacing.dart';
import 'package:basketvibe/features/games/domain/entities/football_game.dart';
import 'package:basketvibe/features/games/presentation/cubit/football_cubit.dart';
import 'package:basketvibe/features/games/presentation/widgets/football_labels.dart';

class FootballBookingSheet extends StatefulWidget {
  const FootballBookingSheet({
    super.key,
    required this.gameId,
    required this.uid,
    required this.bookerName,
  });
  final String gameId;
  final String uid;
  final String bookerName;

  @override
  State<FootballBookingSheet> createState() => _FootballBookingSheetState();
}

class _FootballBookingSheetState extends State<FootballBookingSheet> {
  FootballTeam? _team;
  int _places = 1;
  bool _initialized = false;
  BookingFailure? _failure;
  final _friends = List.generate(5, (_) => TextEditingController());

  @override
  void dispose() {
    for (final controller in _friends) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _submit(FootballGame game, {bool cancel = false}) async {
    final cubit = context.read<FootballCubit>();
    final result = cancel
        ? await cubit.cancel(game, widget.uid)
        : await cubit.save(
            game,
            Booking(
              userId: widget.uid,
              team: _team!,
              places: _places,
              bookerName: widget.bookerName,
              friendNames: _friends
                  .take(_places - 1)
                  .map((c) => c.text.trim())
                  .toList(),
            ),
          );
    if (!mounted) return;
    if (result == null) {
      Navigator.of(context).pop(cancel ? 'cancelled' : 'saved');
    } else {
      setState(() => _failure = result);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return BlocBuilder<FootballCubit, FootballState>(
      builder: (context, state) {
        final matches = state.games.where((g) => g.id == widget.gameId);
        if (matches.isEmpty) {
          return SafeArea(
            child: Padding(
              padding: AppSpacing.cardPadding,
              child: Text(l.fdNetworkError),
            ),
          );
        }
        final game = matches.first;
        final mine = game.bookings[widget.uid];
        if (!_initialized) {
          _initialized = true;
          _team = mine?.team;
          _places = mine?.places ?? 1;
          if (mine != null) {
            for (var i = 0; i < mine.friendNames.length; i++) {
              _friends[i].text = mine.friendNames[i];
            }
          }
        }
        final past = game.isPast(DateTime.now());
        final locked = past || state.saving || game.fromCache;
        final available = _team == null
            ? 0
            : game.editablePlaces(_team!, widget.uid);
        final canSave = !locked && _team != null && _places <= available;
        return SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(
              AppSpacing.xl,
              AppSpacing.lg,
              AppSpacing.xl,
              MediaQuery.viewInsetsOf(context).bottom + AppSpacing.xxl,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        mine == null ? l.fdChooseTeam : l.fdYourBooking,
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                    ),
                    IconButton(
                      onPressed: state.saving
                          ? null
                          : () => Navigator.pop(context),
                      tooltip: l.fdClose,
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
                Text(
                  '${l.fdPitch(game.pitch.number)} · ${game.pitch.format} · ${l.fdFee(game.pitch.feeKgs)}',
                ),
                AppSpacing.gapMD,
                if (past) Text(l.fdReadOnly),
                if (game.fromCache) Text(l.fdOffline),
                if (mine != null && !past) Text(l.fdChangeTeamHint),
                AppSpacing.gapMD,
                for (final team in FootballTeam.values)
                  Card(
                    child: Padding(
                      padding: AppSpacing.cardPadding,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.sports_soccer, color: teamColor(team)),
                              AppSpacing.rowGapSM,
                              Expanded(
                                child: Text(
                                  teamLabel(l, team),
                                  style: Theme.of(
                                    context,
                                  ).textTheme.titleMedium,
                                ),
                              ),
                              Text(
                                l.fdPlaces(
                                  game.freePlaces(team),
                                  game.pitch.capacity,
                                ),
                              ),
                            ],
                          ),
                          for (final booking in game.bookings.values.where(
                            (b) => b.team == team,
                          ))
                            Padding(
                              padding: const EdgeInsets.only(
                                top: AppSpacing.sm,
                              ),
                              child: Text(
                                [
                                  booking.bookerName,
                                  for (var i = 0; i < booking.places - 1; i++)
                                    i < booking.friendNames.length &&
                                            booking.friendNames[i].isNotEmpty
                                        ? booking.friendNames[i]
                                        : l.fdGuest(booking.bookerName),
                                ].join(', '),
                              ),
                            ),
                          if (!past)
                            Align(
                              alignment: Alignment.centerRight,
                              child: TextButton.icon(
                                onPressed:
                                    locked ||
                                        (mine != null && mine.team != team) ||
                                        game.editablePlaces(team, widget.uid) ==
                                            0
                                    ? null
                                    : () {
                                        setState(() {
                                          _team = team;
                                          _places = 1;
                                          _failure = null;
                                        });
                                      },
                                icon: Icon(
                                  _team == team
                                      ? Icons.check_circle
                                      : Icons.circle_outlined,
                                ),
                                label: Text(
                                  _team == team
                                      ? l.fdSelected
                                      : game.freePlaces(team) == 0
                                      ? l.fdFull
                                      : l.fdSelect,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                if (_team != null && !past) ...[
                  AppSpacing.gapLG,
                  Text(
                    l.fdPlacesLabel,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  Row(
                    children: [
                      IconButton(
                        tooltip: l.fdFewer,
                        onPressed: locked || _places <= 1
                            ? null
                            : () => setState(() => _places--),
                        icon: const Icon(Icons.remove_circle_outline),
                      ),
                      Text(
                        '$_places',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      IconButton(
                        tooltip: l.fdMore,
                        onPressed: locked || _places >= available
                            ? null
                            : () => setState(() => _places++),
                        icon: const Icon(Icons.add_circle_outline),
                      ),
                      Expanded(
                        child: TextButton(
                          onPressed: locked || available < 1
                              ? null
                              : () {
                                  setState(() => _places = available);
                                },
                          child: Text(l.fdWholeTeam),
                        ),
                      ),
                    ],
                  ),
                  Text(l.fdFriendsHint),
                  for (var i = 0; i < _places - 1; i++)
                    Padding(
                      padding: const EdgeInsets.only(top: AppSpacing.md),
                      child: TextField(
                        controller: _friends[i],
                        enabled: !locked,
                        maxLength: 80,
                        textCapitalization: TextCapitalization.words,
                        decoration: InputDecoration(
                          labelText: l.fdFriend(i + 1),
                          hintText: l.fdGuest(widget.bookerName),
                          counterText: '',
                        ),
                      ),
                    ),
                  if (_places > available)
                    Padding(
                      padding: AppSpacing.cardPadding,
                      child: Text(
                        l.fdFullError,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.error,
                        ),
                      ),
                    ),
                ],
                if (_failure != null)
                  Padding(
                    padding: AppSpacing.cardPadding,
                    child: Text(
                      bookingError(l, _failure!),
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                  ),
                if (!past) ...[
                  AppSpacing.gapLG,
                  FilledButton(
                    onPressed: canSave ? () => _submit(game) : null,
                    child: Text(
                      state.saving
                          ? l.fdSaving
                          : mine == null
                          ? l.fdBook
                          : l.save,
                    ),
                  ),
                  if (mine != null)
                    TextButton(
                      onPressed: locked ? null : () => _confirmCancel(game),
                      child: Text(l.fdCancelBooking),
                    ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _confirmCancel(FootballGame game) async {
    final l = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l.fdCancelBooking),
        content: Text(l.fdCancelConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l.fdKeep),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(l.fdCancelBooking),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted) await _submit(game, cancel: true);
  }
}
