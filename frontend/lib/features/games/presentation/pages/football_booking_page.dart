import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:basketvibe/core/app/demo_mode.dart';
import 'package:basketvibe/core/l10n/app_localizations.dart';
import 'package:basketvibe/features/games/domain/entities/football_game.dart';
import 'package:basketvibe/features/games/presentation/cubit/football_cubit.dart';
import 'package:basketvibe/features/games/presentation/widgets/football_arena.dart';
import 'package:basketvibe/features/games/presentation/widgets/football_formation.dart';
import 'package:basketvibe/features/games/presentation/widgets/football_labels.dart';

class FootballBookingPage extends StatefulWidget {
  const FootballBookingPage({
    super.key,
    required this.gameId,
    required this.uid,
    required this.bookerName,
    this.onSignIn,
    this.signingIn = false,
  });

  final String gameId;
  final String? uid;
  final String bookerName;
  final VoidCallback? onSignIn;
  final bool signingIn;

  @override
  State<FootballBookingPage> createState() => _FootballBookingPageState();
}

class _FootballBookingPageState extends State<FootballBookingPage> {
  FootballTeam? _team;
  FootballPosition _position = FootballPosition.any;
  int _places = 1;
  int _formationPlayer = 0;
  bool _initialized = false;
  BookingFailure? _failure;
  Booking? _confirmed;
  final _friends = List.generate(5, (_) => TextEditingController());
  final _friendPositions = List.filled(5, FootballPosition.any);

  @override
  void dispose() {
    for (final friend in _friends) {
      friend.dispose();
    }
    super.dispose();
  }

  void _initialize(Booking? mine) {
    if (_initialized) return;
    _initialized = true;
    if (mine == null) return;
    _team = mine.team;
    _places = mine.places;
    _position = mine.position;
    for (var i = 0; i < mine.places - 1; i++) {
      if (i < mine.friendNames.length) _friends[i].text = mine.friendNames[i];
      _friendPositions[i] = mine.positionForFriend(i);
    }
  }

  Future<void> _save(FootballGame game, {required bool editing}) async {
    final uid = widget.uid;
    final team = _team;
    if (uid == null || team == null) return;
    final booking = Booking(
      userId: uid,
      team: team,
      places: _places,
      bookerName: widget.bookerName,
      position: _position,
      friendNames: _friends
          .take(_places - 1)
          .map((friend) => friend.text.trim())
          .toList(),
      friendPositions: _friendPositions.take(_places - 1).toList(),
    );
    FocusManager.instance.primaryFocus?.unfocus();
    final failure = await context.read<FootballCubit>().save(game, booking);
    if (!mounted) return;
    if (failure != null) {
      setState(() => _failure = failure);
    } else if (editing) {
      Navigator.of(context).pop('saved');
    } else {
      setState(() => _confirmed = booking);
    }
  }

  Future<void> _cancel(FootballGame game) async {
    final uid = widget.uid;
    if (uid == null) return;
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
    if (!mounted || confirmed != true) return;
    final failure = await context.read<FootballCubit>().cancel(game, uid);
    if (!mounted) return;
    if (failure == null) {
      Navigator.of(context).pop('cancelled');
    } else {
      setState(() => _failure = failure);
    }
  }

  @override
  Widget build(BuildContext context) => Theme(
    data: FootballArena.theme(Theme.of(context)),
    child: BlocBuilder<FootballCubit, FootballState>(builder: _buildPage),
  );

  Widget _buildPage(BuildContext context, FootballState state) {
    final l = AppLocalizations.of(context);
    final game = state.games
        .where((game) => game.id == widget.gameId)
        .firstOrNull;
    if (game == null) {
      return Scaffold(
        appBar: AppBar(title: Text(l.fdBookingTitle)),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: state.loading
                ? const CircularProgressIndicator()
                : Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(l.fdNetworkError, textAlign: TextAlign.center),
                      TextButton(
                        onPressed: () => context
                            .read<FootballCubit>()
                            .selectDate(state.date),
                        child: Text(l.retry),
                      ),
                    ],
                  ),
          ),
        ),
      );
    }
    final mine = game.bookings[widget.uid];
    _initialize(mine);
    final past = game.isPast(DateTime.now());
    final guest = widget.uid == null;
    final locked = past || state.saving || game.fromCache || guest;
    final available = _team == null || guest
        ? 0
        : game.editablePlaces(_team!, widget.uid!);
    final canSave = !locked && _team != null && _places <= available;
    final confirmed = _confirmed;
    final date = DateFormat.yMMMEd(
      l.localeName,
    ).format(FootballSchedule.bishkekTime(game.startTime));

    return PopScope(
      canPop: !state.saving,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            confirmed != null
                ? l.fdSaved
                : mine == null
                ? l.fdBookingTitle
                : l.fdYourBooking,
          ),
        ),
        bottomNavigationBar: !past || confirmed != null
            ? SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(18, 8, 18, 12),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (confirmed == null &&
                          (_failure != null ||
                              (_team != null && _places > available)))
                        Padding(
                          padding: const EdgeInsets.only(bottom: 6),
                          child: Text(
                            _failure != null
                                ? bookingError(l, _failure!)
                                : l.fdFullError,
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.error,
                              fontSize: 12,
                            ),
                            semanticsLabel: _failure != null
                                ? bookingError(l, _failure!)
                                : l.fdFullError,
                          ),
                        ),
                      FilledButton(
                        onPressed: confirmed != null
                            ? () => Navigator.of(context).pop('saved')
                            : guest
                            ? widget.onSignIn
                            : canSave
                            ? () => _save(game, editing: mine != null)
                            : null,
                        child: Text(
                          confirmed != null
                              ? l.done
                              : guest
                              ? (widget.signingIn
                                    ? l.fdSaving
                                    : demoMode
                                    ? l.fdDemoSignIn
                                    : l.fdSignIn)
                              : state.saving
                              ? l.fdSaving
                              : mine == null
                              ? l.fdBook
                              : l.save,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            : null,
        body: SafeArea(
          bottom: past,
          child: SingleChildScrollView(
            key: ValueKey(confirmed != null),
            padding: const EdgeInsets.fromLTRB(18, 4, 18, 24),
            child: ArenaSwitch(
              child: confirmed != null
                  ? _BookingTicket(
                      key: const ValueKey('ticket'),
                      game: game,
                      date: date,
                      booking: confirmed,
                    )
                  : Column(
                      key: const ValueKey('form'),
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        ArenaScoreboard(
                          game: game,
                          caption: date.toUpperCase(),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          l.fdFee(game.pitch.feeKgs),
                          style: const TextStyle(color: FootballArena.muted),
                        ),
                        if (past) const SizedBox(height: 10),
                        if (past)
                          Text(
                            l.fdReadOnly,
                            style: const TextStyle(color: FootballArena.accent),
                          ),
                        if (game.fromCache) ...[
                          const SizedBox(height: 10),
                          Text(
                            l.fdOffline,
                            style: const TextStyle(color: FootballArena.muted),
                          ),
                        ],
                        const SizedBox(height: 18),
                        if (!past) ...[
                          _SectionLabel(l.fdChooseTeam),
                          const SizedBox(height: 8),
                          _TeamGrid(
                            game: game,
                            selected: _team,
                            mine: mine,
                            onSelect: locked
                                ? null
                                : (team) {
                                    HapticFeedback.selectionClick();
                                    setState(() {
                                      _team = team;
                                      _places = _places.clamp(
                                        1,
                                        game.editablePlaces(team, widget.uid!),
                                      );
                                      if (_formationPlayer >= _places) {
                                        _formationPlayer = 0;
                                      }
                                      _failure = null;
                                    });
                                  },
                          ),
                          if (mine != null) ...[
                            const SizedBox(height: 8),
                            Text(
                              l.fdChangeTeamHint,
                              style: const TextStyle(
                                color: FootballArena.muted,
                                fontSize: 12,
                              ),
                            ),
                          ],
                          if (!guest) ...[
                            const SizedBox(height: 16),
                            _placesPanel(
                              context,
                              available: available,
                              locked: locked || _team == null,
                            ),
                            const SizedBox(height: 16),
                            _formationPanel(
                              context,
                              game.pitch,
                              locked: locked,
                            ),
                            AnimatedSize(
                              alignment: Alignment.topCenter,
                              duration: FootballArena.motion(context, 220),
                              child: _places == 1
                                  ? const SizedBox.shrink()
                                  : _friendFields(context, locked: locked),
                            ),
                          ] else ...[
                            const SizedBox(height: 14),
                            Text(
                              l.fdLoginNotice,
                              style: const TextStyle(
                                color: FootballArena.muted,
                              ),
                            ),
                            const SizedBox(height: 16),
                            _formationPanel(context, game.pitch, locked: true),
                          ],
                        ],
                        const SizedBox(height: 16),
                        _Roster(game: game, initiallyExpanded: past),
                        if (mine != null && !past)
                          TextButton(
                            onPressed: locked ? null : () => _cancel(game),
                            child: Text(l.fdCancelBooking),
                          ),
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _placesPanel(
    BuildContext context, {
    required int available,
    required bool locked,
  }) {
    final l = AppLocalizations.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: FootballArena.surface,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 9, 12, 2),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(child: _SectionLabel(l.fdPlacesLabel)),
                IconButton(
                  tooltip: l.fdFewer,
                  onPressed: locked || _places <= 1
                      ? null
                      : () => setState(() {
                          _places--;
                          if (_formationPlayer >= _places) {
                            _formationPlayer = 0;
                          }
                          _failure = null;
                        }),
                  icon: const Icon(Icons.remove_circle_outline),
                ),
                ArenaSwitch(
                  child: Text(
                    '$_places',
                    key: ValueKey(_places),
                    style: const TextStyle(
                      color: FootballArena.accent,
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                IconButton(
                  tooltip: l.fdMore,
                  onPressed: locked || _places >= available
                      ? null
                      : () => setState(() {
                          _places++;
                          _failure = null;
                        }),
                  icon: const Icon(Icons.add_circle_outline),
                ),
              ],
            ),
            Align(
              alignment: AlignmentDirectional.centerEnd,
              child: TextButton(
                onPressed: locked || available < 1
                    ? null
                    : () => setState(() {
                        _places = available;
                        if (_formationPlayer >= _places) {
                          _formationPlayer = 0;
                        }
                        _failure = null;
                      }),
                child: Text(l.fdWholeTeam),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _formationPanel(
    BuildContext context,
    PitchPreset pitch, {
    required bool locked,
  }) {
    final l = AppLocalizations.of(context);
    final guest = widget.uid == null;
    final player = _formationPlayer;
    final position = player == 0 ? _position : _friendPositions[player - 1];
    void select(FootballPosition value) {
      HapticFeedback.selectionClick();
      setState(() {
        if (player == 0) {
          _position = value;
        } else {
          _friendPositions[player - 1] = value;
        }
        _failure = null;
      });
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(child: _SectionLabel(l.fdFormation)),
            Text(
              pitch.format,
              style: const TextStyle(
                color: FootballArena.accent,
                fontSize: 16,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
        if (!guest) ...[
          const SizedBox(height: 4),
          Text(
            l.fdPositionHint,
            style: const TextStyle(color: FootballArena.muted, fontSize: 12),
          ),
          if (_places > 1)
            Wrap(
              spacing: 6,
              children: [
                for (var i = 0; i < _places; i++)
                  ChoiceChip(
                    key: ValueKey('formation-player-$i'),
                    label: Text(i == 0 ? l.fdFormationYou : l.fdFriend(i)),
                    selected: player == i,
                    onSelected: locked
                        ? null
                        : (_) => setState(() => _formationPlayer = i),
                  ),
              ],
            ),
        ],
        const SizedBox(height: 8),
        FootballFormation(
          pitch: pitch,
          position: position,
          onChanged: locked ? null : select,
        ),
        if (!guest)
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  positionLabel(l, position),
                  key: const ValueKey('formation-selected-position'),
                  style: const TextStyle(
                    color: FootballArena.ink,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              if (position != FootballPosition.any)
                TextButton(
                  onPressed: locked ? null : () => select(FootballPosition.any),
                  child: Text(l.fdPositionAny),
                ),
            ],
          ),
      ],
    );
  }

  Widget _friendFields(BuildContext context, {required bool locked}) {
    final l = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 16),
        Text(
          l.fdFriendsHint,
          style: const TextStyle(color: FootballArena.muted),
        ),
        for (var i = 0; i < _places - 1; i++) ...[
          const SizedBox(height: 12),
          TextField(
            key: ValueKey('friend-$i'),
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
        ],
      ],
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.label);
  final String label;

  @override
  Widget build(BuildContext context) => Text(
    label,
    style: Theme.of(
      context,
    ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
  );
}

class _TeamGrid extends StatelessWidget {
  const _TeamGrid({
    required this.game,
    required this.selected,
    required this.mine,
    required this.onSelect,
  });

  final FootballGame game;
  final FootballTeam? selected;
  final Booking? mine;
  final ValueChanged<FootballTeam>? onSelect;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns =
            constraints.maxWidth >= 294 &&
                MediaQuery.textScalerOf(context).scale(14) <= 19
            ? 2
            : 1;
        final width = (constraints.maxWidth - (columns - 1) * 8) / columns;
        return Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final team in FootballTeam.values)
              SizedBox(
                width: width,
                child: _TeamTile(
                  color: teamColor(team),
                  label: teamLabel(l, team),
                  selected: selected == team,
                  availability: game.fromCache
                      ? l.fdAvailabilityUnknown
                      : game.freePlaces(team) == 0
                      ? l.fdFull
                      : l.fdPlaces(game.freePlaces(team), game.pitch.capacity),
                  onPressed:
                      onSelect == null ||
                          (mine == null && game.freePlaces(team) == 0) ||
                          (mine != null && mine!.team != team)
                      ? null
                      : () => onSelect!(team),
                ),
              ),
          ],
        );
      },
    );
  }
}

class _TeamTile extends StatelessWidget {
  const _TeamTile({
    required this.color,
    required this.label,
    required this.selected,
    required this.availability,
    required this.onPressed,
  });

  final Color color;
  final String label;
  final bool selected;
  final String availability;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) => Semantics(
    selected: selected,
    child: AnimatedContainer(
      duration: FootballArena.motion(context, 200),
      decoration: BoxDecoration(
        color: selected
            ? Color.alphaBlend(color.withAlpha(38), FootballArena.surface)
            : FootballArena.surface,
        border: Border.all(color: selected ? color : FootballArena.line),
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextButton(
        onPressed: onPressed,
        style: TextButton.styleFrom(
          minimumSize: const Size(0, 62),
          foregroundColor: FootballArena.ink,
          disabledForegroundColor: FootballArena.muted,
          padding: const EdgeInsets.all(8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Row(
          children: [
            AnimatedScale(
              scale: selected ? 1.17 : 1,
              duration: FootballArena.motion(context, 210),
              curve: Curves.easeOutBack,
              child: CustomPaint(
                size: const Size(23, 24),
                painter: _Jersey(color),
              ),
            ),
            const SizedBox(width: 9),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                  Text(
                    availability,
                    style: const TextStyle(
                      color: FootballArena.muted,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
            if (selected)
              const Icon(
                Icons.check_circle_outline,
                size: 16,
                color: FootballArena.accent,
              ),
          ],
        ),
      ),
    ),
  );
}

class _Jersey extends CustomPainter {
  const _Jersey(this.color);
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.scale(size.width / 24, size.height / 24);
    final shape = Path()
      ..moveTo(3, 3)
      ..lineTo(8, 1)
      ..quadraticBezierTo(12, 6, 16, 1)
      ..lineTo(21, 3)
      ..lineTo(24, 8)
      ..lineTo(19, 11)
      ..lineTo(18, 9)
      ..lineTo(18, 23)
      ..lineTo(6, 23)
      ..lineTo(6, 9)
      ..lineTo(5, 11)
      ..lineTo(0, 8)
      ..close();
    canvas.drawPath(shape, Paint()..color = color);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _Jersey oldDelegate) =>
      oldDelegate.color != color;
}

class _Roster extends StatelessWidget {
  const _Roster({required this.game, required this.initiallyExpanded});

  final FootballGame game;
  final bool initiallyExpanded;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return ExpansionTile(
      title: Text(l.fdViewRoster),
      initiallyExpanded: initiallyExpanded,
      tilePadding: EdgeInsets.zero,
      childrenPadding: EdgeInsets.zero,
      children: [
        if (game.bookings.isEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Text(l.fdEmptyRoster),
          ),
        for (final team in FootballTeam.values)
          if (game.bookings.values.any((booking) => booking.team == team))
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    teamLabel(l, team),
                    style: TextStyle(
                      color: teamColor(team),
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  for (final booking in game.bookings.values.where(
                    (booking) => booking.team == team,
                  )) ...[
                    Text(_player(l, booking.bookerName, booking.position)),
                    for (var i = 0; i < booking.places - 1; i++)
                      Text(
                        _player(
                          l,
                          i < booking.friendNames.length &&
                                  booking.friendNames[i].isNotEmpty
                              ? booking.friendNames[i]
                              : l.fdGuest(booking.bookerName),
                          booking.positionForFriend(i),
                        ),
                      ),
                  ],
                ],
              ),
            ),
      ],
    );
  }

  String _player(AppLocalizations l, String name, FootballPosition position) =>
      position == FootballPosition.any
      ? name
      : '$name · ${positionLabel(l, position)}';
}

class _BookingTicket extends StatelessWidget {
  const _BookingTicket({
    super.key,
    required this.game,
    required this.date,
    required this.booking,
  });
  final FootballGame game;
  final String date;
  final Booking booking;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return TweenAnimationBuilder<double>(
      duration: FootballArena.motion(context, 360),
      curve: Curves.easeOutCubic,
      tween: Tween(begin: .92, end: 1),
      builder: (context, value, child) =>
          Transform.scale(scale: value, child: child),
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(19),
          color: FootballArena.surface,
          border: Border.all(color: FootballArena.accent),
        ),
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Align(
                alignment: AlignmentDirectional.centerStart,
                child: Icon(
                  Icons.confirmation_number_outlined,
                  color: FootballArena.accent,
                  size: 31,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                l.fdInTheGame,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 15),
              ArenaScoreboard(game: game, caption: date.toUpperCase()),
              const SizedBox(height: 15),
              Text(
                '${teamLabel(l, booking.team)} · ${l.fdTicketPlaces(booking.places)}',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              if (booking.position != FootballPosition.any)
                Text(positionLabel(l, booking.position)),
            ],
          ),
        ),
      ),
    );
  }
}
