import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:basketvibe/core/app/demo_mode.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:basketvibe/core/constants/route_constants.dart';
import 'package:basketvibe/core/l10n/app_localizations.dart';
import 'package:basketvibe/core/network/injection.dart';
import 'package:basketvibe/core/styles/app_colors.dart';
import 'package:basketvibe/core/styles/app_spacing.dart';
import 'package:basketvibe/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:basketvibe/features/auth/presentation/cubit/auth_state.dart';
import 'package:basketvibe/features/games/domain/entities/football_game.dart';
import 'package:basketvibe/features/games/presentation/cubit/football_cubit.dart';
import 'package:basketvibe/features/games/presentation/widgets/football_booking_sheet.dart';
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
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, authState) {
        final user = authState is AuthAuthenticated
            ? getIt<FirebaseAuth>().currentUser
            : null;
        return Scaffold(
          appBar: AppBar(
            title: const Text('FOOTBALL DAY'),
            actions: [
              IconButton(
                tooltip: l.settingsTitle,
                icon: const Icon(Icons.settings_outlined),
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(builder: (_) => const SettingsPage()),
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
                icon: const Icon(Icons.sports_soccer),
                label: l.fdSchedule,
              ),
              NavigationDestination(
                icon: const Icon(Icons.confirmation_number_outlined),
                label: l.fdMyBookings,
              ),
            ],
          ),
          body: SafeArea(
            child: BlocBuilder<FootballCubit, FootballState>(
              builder: (context, state) {
                final today = FootballSchedule.today();
                final games = _tab == 0
                    ? state.games
                    : state.games
                          .where(
                            (g) =>
                                user != null &&
                                g.bookings.containsKey(user.uid),
                          )
                          .toList();
                return ListView(
                  padding: AppSpacing.cardPaddingLG,
                  children: [
                    if (_tab == 0)
                      Container(
                        padding: AppSpacing.cardPaddingLG,
                        decoration: BoxDecoration(
                          color: AppColors.primaryDark,
                          borderRadius: BorderRadius.circular(AppSpacing.xl),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(
                              Icons.sports_soccer,
                              color: Colors.white,
                              size: 40,
                            ),
                            AppSpacing.gapMD,
                            Text(
                              l.fdHero,
                              style: Theme.of(context).textTheme.headlineMedium
                                  ?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w800,
                                  ),
                            ),
                            AppSpacing.gapSM,
                            Text(
                              l.fdSubtitle,
                              style: const TextStyle(color: Colors.white),
                            ),
                          ],
                        ),
                      ),
                    AppSpacing.gapLG,
                    Text(
                      l.fdTimezone,
                      style: Theme.of(context).textTheme.labelLarge,
                    ),
                    Row(
                      children: [
                        IconButton(
                          tooltip: l.fdPreviousDay,
                          onPressed: state.saving
                              ? null
                              : () => context.read<FootballCubit>().selectDate(
                                  state.date.subtract(const Duration(days: 1)),
                                ),
                          icon: const Icon(Icons.chevron_left),
                        ),
                        Expanded(
                          child: Text(
                            DateFormat.yMMMMd(l.localeName).format(state.date),
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                        ),
                        IconButton(
                          tooltip: l.fdNextDay,
                          onPressed:
                              state.saving ||
                                  !state.date.isBefore(
                                    today.add(const Duration(days: 6)),
                                  )
                              ? null
                              : () => context.read<FootballCubit>().selectDate(
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
                              padding: const EdgeInsets.only(
                                right: AppSpacing.sm,
                              ),
                              child: ChoiceChip(
                                label: Text(
                                  i == 0
                                      ? l.fdToday
                                      : DateFormat(
                                          'EEE d',
                                          l.localeName,
                                        ).format(today.add(Duration(days: i))),
                                ),
                                selected:
                                    state.date == today.add(Duration(days: i)),
                                onSelected: state.saving
                                    ? null
                                    : (_) => context
                                          .read<FootballCubit>()
                                          .selectDate(
                                            today.add(Duration(days: i)),
                                          ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    AppSpacing.gapLG,
                    if (state.loading)
                      const Center(child: CircularProgressIndicator())
                    else if (state.error) ...[
                      Text(l.fdNetworkError),
                      OutlinedButton(
                        onPressed: () => context
                            .read<FootballCubit>()
                            .selectDate(state.date),
                        child: Text(l.retry),
                      ),
                    ] else ...[
                      if (state.games.any((g) => g.fromCache))
                        Padding(
                          padding: AppSpacing.cardPadding,
                          child: Text(l.fdOffline),
                        ),
                      if (_tab == 1 && user == null)
                        FilledButton(
                          onPressed: () => context.push(RouteConstants.login),
                          child: Text(demoMode ? l.fdDemoSignIn : l.fdSignIn),
                        )
                      else if (games.isEmpty)
                        Padding(
                          padding: AppSpacing.cardPadding,
                          child: Text(l.fdNoBookings),
                        ),
                      for (final game in games)
                        _GameCard(
                          game: game,
                          mine:
                              user != null &&
                              game.bookings.containsKey(user.uid),
                          onTap: () async {
                            if (user == null) {
                              context.push(RouteConstants.login);
                              return;
                            }
                            final cubit = context.read<FootballCubit>();
                            final result = await showModalBottomSheet<String>(
                              context: context,
                              isScrollControlled: true,
                              useSafeArea: true,
                              constraints: BoxConstraints(
                                maxHeight:
                                    MediaQuery.sizeOf(context).height * .94,
                              ),
                              builder: (_) => BlocProvider.value(
                                value: cubit,
                                child: FootballBookingSheet(
                                  gameId: game.id,
                                  uid: user.uid,
                                  bookerName:
                                      (user.displayName?.trim().isNotEmpty ??
                                          false)
                                      ? user.displayName!.trim().substring(
                                          0,
                                          user.displayName!.trim().length.clamp(
                                            0,
                                            80,
                                          ),
                                        )
                                      : l.fdPlayer,
                                ),
                              ),
                            );
                            if (context.mounted && result != null) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    result == 'saved'
                                        ? l.fdSaved
                                        : l.fdCancelled,
                                  ),
                                ),
                              );
                            }
                          },
                        ),
                    ],
                    AppSpacing.gapLG,
                    Text(
                      l.fdRules,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    AppSpacing.gapSM,
                    Text(
                      l.fdPlaceholder,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                );
              },
            ),
          ),
        );
      },
    );
  }
}

class _GameCard extends StatelessWidget {
  const _GameCard({
    required this.game,
    required this.mine,
    required this.onTap,
  });
  final FootballGame game;
  final bool mine;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final past = game.isPast(DateTime.now());
    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.lg),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSpacing.lg),
        child: Padding(
          padding: AppSpacing.cardPaddingLG,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                spacing: AppSpacing.lg,
                runSpacing: AppSpacing.sm,
                children: [
                  Text(
                    DateFormat.Hm().format(
                      FootballSchedule.bishkekTime(game.startTime),
                    ),
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    l.fdPitch(game.pitch.number),
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  Chip(label: Text(game.pitch.format)),
                ],
              ),
              Text(l.fdFee(game.pitch.feeKgs)),
              AppSpacing.gapMD,
              Wrap(
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.sm,
                children: [
                  for (final team in FootballTeam.values)
                    Chip(
                      avatar: Icon(
                        Icons.circle,
                        size: 12,
                        color: teamColor(team),
                      ),
                      label: Text(
                        '${teamLabel(l, team)} ${game.freePlaces(team)}/${game.pitch.capacity}',
                      ),
                    ),
                ],
              ),
              AppSpacing.gapSM,
              Text(
                past
                    ? l.fdReadOnly
                    : l.fdTotalFree(game.freeTotal, game.capacity),
              ),
              AppSpacing.gapMD,
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: onTap,
                  child: Text(
                    past
                        ? l.fdViewRoster
                        : mine
                        ? l.fdYourBooking
                        : game.freeTotal == 0
                        ? l.fdFull
                        : l.fdChooseTeam,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
