import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:basketvibe/core/app/demo_mode.dart';
import 'package:basketvibe/core/constants/route_constants.dart';
import 'package:basketvibe/core/l10n/app_localizations.dart';
import 'package:basketvibe/core/network/injection.dart';
import 'package:basketvibe/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:basketvibe/features/auth/presentation/cubit/auth_state.dart';
import 'package:basketvibe/features/games/domain/entities/football_game.dart';
import 'package:basketvibe/features/games/presentation/cubit/football_cubit.dart';
import 'package:basketvibe/features/games/presentation/pages/football_booking_page.dart';
import 'package:basketvibe/features/games/presentation/widgets/football_arena.dart';
import 'package:basketvibe/features/games/presentation/widgets/football_labels.dart';
import 'package:basketvibe/features/profile/presentation/pages/settings_page.dart';

class FootballDayPage extends StatelessWidget {
  const FootballDayPage({super.key});

  @override
  Widget build(BuildContext context) => BlocProvider(
    create: (_) => getIt<FootballCubit>(),
    child: const FootballDayView(),
  );
}

class FootballDayView extends StatefulWidget {
  const FootballDayView({super.key});

  @override
  State<FootballDayView> createState() => _FootballDayViewState();
}

class _FootballDayViewState extends State<FootballDayView> {
  int _tab = 0;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Theme(
      data: FootballArena.theme(Theme.of(context)),
      child: BlocBuilder<AuthCubit, AuthState>(
        builder: (context, auth) {
          final user = auth is AuthAuthenticated
              ? getIt<FirebaseAuth>().currentUser
              : null;
          return Scaffold(
            appBar: AppBar(
              title: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.sports_soccer, color: FootballArena.accent),
                  const SizedBox(width: 10),
                  const Flexible(
                    child: Text(
                      'FOOTBALL DAY',
                      style: TextStyle(fontWeight: FontWeight.w900),
                    ),
                  ),
                ],
              ),
              actions: [
                IconButton(
                  tooltip: l.settingsTitle,
                  icon: const Icon(Icons.settings_outlined),
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => const SettingsPage(),
                    ),
                  ),
                ),
                if (user != null)
                  IconButton(
                    tooltip: l.logout,
                    icon: const Icon(Icons.logout),
                    onPressed: () => context.read<AuthCubit>().logout(),
                  ),
              ],
            ),
            bottomNavigationBar: NavigationBar(
              selectedIndex: _tab,
              onDestinationSelected: (index) => setState(() => _tab = index),
              destinations: [
                NavigationDestination(
                  icon: const Icon(Icons.calendar_month_outlined),
                  label: l.fdSchedule,
                ),
                NavigationDestination(
                  icon: const Icon(Icons.confirmation_number_outlined),
                  label: l.fdMyBookings,
                ),
              ],
            ),
            body: SafeArea(
              bottom: false,
              child: BlocBuilder<FootballCubit, FootballState>(
                builder: (context, state) => _Schedule(
                  key: ValueKey(_tab),
                  state: state,
                  uid: user?.uid,
                  mineOnly: _tab == 1,
                  openGame: (game) => _openGame(context, game),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> _openGame(BuildContext context, FootballGame game) async {
    final l = AppLocalizations.of(context);
    final cubit = context.read<FootballCubit>();
    final auth = context.read<AuthCubit>();
    final result = await Navigator.of(context).push<String>(
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: cubit,
          child: BlocProvider.value(
            value: auth,
            child: BlocConsumer<AuthCubit, AuthState>(
              listener: (context, state) {
                if (state is AuthError) {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text(state.message)));
                }
              },
              builder: (context, state) {
                final user = state is AuthAuthenticated
                    ? getIt<FirebaseAuth>().currentUser
                    : null;
                final name = user?.displayName?.trim() ?? '';
                return FootballBookingPage(
                  key: ValueKey(user?.uid),
                  gameId: game.id,
                  uid: user?.uid,
                  bookerName: name.isEmpty
                      ? l.fdPlayer
                      : name.characters.take(80).toString(),
                  onSignIn: state is AuthLoading ? null : auth.googleSignIn,
                  signingIn: state is AuthLoading,
                );
              },
            ),
          ),
        ),
      ),
    );
    if (context.mounted && result != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result == 'cancelled' ? l.fdCancelled : l.fdSaved),
        ),
      );
    }
  }
}

class _Schedule extends StatelessWidget {
  const _Schedule({
    super.key,
    required this.state,
    required this.uid,
    required this.mineOnly,
    required this.openGame,
  });
  final FootballState state;
  final String? uid;
  final bool mineOnly;
  final ValueChanged<FootballGame> openGame;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final now = DateTime.now();
    final games = [
      for (final game in state.games)
        if (!mineOnly || game.bookings.containsKey(uid)) game,
    ];
    final featured = mineOnly
        ? null
        : games
              .where(
                (game) =>
                    !game.isPast(now) && game.freeTotal > 0 && !game.fromCache,
              )
              .firstOrNull;
    final remaining = games.where((game) => game.id != featured?.id);
    final groups = <String, List<FootballGame>>{};
    for (final game in remaining) {
      groups.putIfAbsent(arenaGameTime(game), () => []).add(game);
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(18, 2, 18, 28),
      children: [
        _Dates(
          state: state,
          dateTitle: mineOnly ? l.fdMyBookings : l.fdSchedule,
        ),
        const SizedBox(height: 14),
        ArenaSwitch(
          child: Column(
            key: ValueKey((state.date, state.loading, state.error)),
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (state.loading)
                const Padding(
                  padding: EdgeInsets.all(36),
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (state.error) ...[
                Text(l.fdNetworkError),
                OutlinedButton(
                  onPressed: () =>
                      context.read<FootballCubit>().selectDate(state.date),
                  child: Text(l.retry),
                ),
              ] else ...[
                if (state.games.any((game) => game.fromCache))
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Text(l.fdOffline),
                  ),
                if (mineOnly && uid == null)
                  FilledButton(
                    onPressed: () => context.push(RouteConstants.login),
                    child: Text(demoMode ? l.fdDemoSignIn : l.fdSignIn),
                  )
                else if (games.isEmpty)
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(l.fdNoBookings),
                  ),
                if (featured != null) ...[
                  ArenaScoreboard(
                    game: featured,
                    caption: l.fdUpcomingGame.toUpperCase(),
                  ),
                  const SizedBox(height: 12),
                  ArenaAvailability(game: featured),
                  const SizedBox(height: 12),
                  FilledButton(
                    onPressed: () => openGame(featured),
                    child: Text(
                      featured.bookings.containsKey(uid)
                          ? l.fdYourBooking
                          : l.fdChooseTeam,
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
                for (final entry in groups.entries) ...[
                  Row(
                    children: [
                      Text(
                        entry.key,
                        style: const TextStyle(
                          color: FootballArena.accent,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(width: 10),
                      const Expanded(child: Divider(color: FootballArena.line)),
                    ],
                  ),
                  const SizedBox(height: 5),
                  for (final game in entry.value)
                    _PitchRow(
                      game: game,
                      booking: game.bookings[uid],
                      now: now,
                      onTap: () => openGame(game),
                    ),
                  const SizedBox(height: 10),
                ],
                if (!mineOnly) ...[
                  const SizedBox(height: 6),
                  Text(
                    l.fdPlaceholder,
                    style: const TextStyle(
                      color: FootballArena.muted,
                      fontSize: 12,
                    ),
                  ),
                ],
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _Dates extends StatelessWidget {
  const _Dates({required this.state, required this.dateTitle});
  final FootballState state;
  final String dateTitle;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final today = FootballSchedule.today();
    final cubit = context.read<FootballCubit>();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l.fdTimezone,
          style: const TextStyle(color: FootballArena.muted, fontSize: 12),
        ),
        const SizedBox(height: 5),
        Text(
          dateTitle,
          style: Theme.of(
            context,
          ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900),
        ),
        Row(
          children: [
            IconButton(
              tooltip: l.fdPreviousDay,
              onPressed: state.saving
                  ? null
                  : () => cubit.selectDate(
                      state.date.subtract(const Duration(days: 1)),
                    ),
              icon: const Icon(Icons.chevron_left),
            ),
            Expanded(
              child: Text(
                DateFormat.yMMMMd(l.localeName).format(state.date),
                textAlign: TextAlign.center,
              ),
            ),
            IconButton(
              tooltip: l.fdNextDay,
              onPressed:
                  state.saving ||
                      !state.date.isBefore(today.add(const Duration(days: 6)))
                  ? null
                  : () => cubit.selectDate(
                      state.date.add(const Duration(days: 1)),
                    ),
              icon: const Icon(Icons.chevron_right),
            ),
          ],
        ),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              for (var i = 0; i < 7; i++)
                Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: ChoiceChip(
                    showCheckmark: false,
                    label: Text(switch (i) {
                      0 => l.fdToday,
                      1 => l.fdTomorrow,
                      _ => DateFormat(
                        'EEE d',
                        l.localeName,
                      ).format(today.add(Duration(days: i))),
                    }),
                    selected: state.date == today.add(Duration(days: i)),
                    onSelected: state.saving
                        ? null
                        : (_) => cubit.selectDate(today.add(Duration(days: i))),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _PitchRow extends StatelessWidget {
  const _PitchRow({
    required this.game,
    required this.booking,
    required this.now,
    required this.onTap,
  });
  final FootballGame game;
  final Booking? booking;
  final DateTime now;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final past = game.isPast(now);
    final detail = booking != null
        ? '${teamLabel(l, booking!.team)} · ${l.fdTicketPlaces(booking!.places)}'
        : game.fromCache
        ? l.fdAvailabilityUnknown
        : past
        ? l.fdReadOnly
        : game.freeTotal == 0
        ? l.fdFull
        : l.fdTotalFree(game.freeTotal, game.capacity);
    return Padding(
      padding: const EdgeInsets.only(bottom: 5),
      child: Material(
        color: FootballArena.surface,
        borderRadius: BorderRadius.circular(13),
        child: ListTile(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(13),
          ),
          title: Text(
            '${l.fdPitch(game.pitch.number)}  /  ${game.pitch.format}',
            style: const TextStyle(fontWeight: FontWeight.w800),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (booking != null)
                Text(
                  l.fdYourBooking,
                  style: const TextStyle(
                    color: FootballArena.accent,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              Text(
                booking != null && booking!.position != FootballPosition.any
                    ? '$detail · ${positionLabel(l, booking!.position)}'
                    : detail,
              ),
            ],
          ),
          trailing: const Icon(Icons.chevron_right),
          onTap: onTap,
        ),
      ),
    );
  }
}
