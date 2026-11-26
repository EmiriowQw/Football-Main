import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:basketvibe/core/l10n/app_localizations.dart';
import 'package:basketvibe/features/games/presentation/widgets/football_arena.dart';
import 'package:basketvibe/features/games/presentation/widgets/football_venue_photo.dart';

class FootballVenues extends StatelessWidget {
  const FootballVenues({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final weekday = DateFormat.E(l.localeName);
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 620),
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          children: [
            Text(l.fdVenues, style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 6),
            Text(
              l.fdVenuePosterNote,
              style: const TextStyle(color: FootballArena.muted),
            ),
            const SizedBox(height: 16),
            for (final venue in FootballVenue.values)
              Card(
                margin: const EdgeInsets.only(bottom: 12),
                color: FootballArena.surface,
                clipBehavior: Clip.antiAlias,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SizedBox(height: 114, child: FootballVenuePhoto(venue)),
                    Padding(
                      padding: const EdgeInsets.all(14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            venue.label(l),
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          Text(
                            venue.location(l),
                            style: const TextStyle(color: FootballArena.muted),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '${venue.format} · ${l.fdVenuePrice(venue.fee)}',
                            style: const TextStyle(
                              color: FootballArena.accent,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const Divider(),
                          for (final (days, time, secondPitch) in venue.slots)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 5),
                              child: Text(
                                '${days.map((day) => weekday.format(DateTime.utc(2026, 1, 4 + day))).join(', ')} · $time'
                                '${secondPitch ? ' · ${l.fdPitch(2)}' : ''}',
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            Text(
              l.fdVenuePosterServices,
              style: const TextStyle(color: FootballArena.muted),
            ),
          ],
        ),
      ),
    );
  }
}
