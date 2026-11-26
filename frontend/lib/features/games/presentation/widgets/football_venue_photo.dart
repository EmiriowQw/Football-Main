import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'package:basketvibe/core/l10n/app_localizations.dart';
import 'package:basketvibe/features/games/domain/entities/football_game.dart';

enum FootballVenue {
  kfu(Rect.fromLTWH(33, 935, 536, 190), '7+1', 1000, [
    ([5], '20:00–22:00, 22:00–00:00', false),
  ]),
  arenaIndoor(Rect.fromLTWH(600, 934, 537, 151), '5+1', 300, [
    ([6, 7], '18:00–20:00, 20:00–22:00, 22:00–00:00', false),
    ([7], '23:00–01:00', true),
  ]),
  apshyr(Rect.fromLTWH(33, 1373, 536, 158), '5+1', 300, [
    ([1, 2, 4, 5, 6], '22:00–00:00', false),
  ]),
  arenaOutdoor(Rect.fromLTWH(600, 1373, 537, 149), '4+1', 300, [
    ([1, 2, 4, 5, 6], '20:00–22:00', false),
  ]),
  goin(Rect.fromLTWH(33, 1757, 536, 131), '4+1', 300, [
    ([3, 4], '22:00–00:00', false),
  ]),
  novotel(Rect.fromLTWH(600, 1757, 537, 126), '4+1', 350, [
    ([2], '20:00–22:00', false),
  ]);

  const FootballVenue(this.photo, this.format, this.fee, this.slots);
  final Rect photo;
  final String format;
  final int fee;
  final List<(List<int>, String, bool)> slots;

  static FootballVenue? forPitch(PitchPreset pitch) => switch (pitch.id) {
    'pitch1' => arenaIndoor,
    'pitch2' => apshyr,
    'pitch3' => arenaOutdoor,
    _ => null,
  };

  String label(AppLocalizations l) => switch (this) {
    kfu => l.fdVenueKfu,
    arenaIndoor => l.fdVenueIndoor,
    apshyr => l.fdVenueApshyr,
    arenaOutdoor => l.fdVenueOutdoor,
    goin => l.fdVenueGoin,
    novotel => l.fdVenueNovotel,
  };

  String location(AppLocalizations l) => switch (this) {
    kfu => l.fdVenueKfuAddress,
    apshyr => l.fdVenueApshyrAddress,
    goin => l.fdVenueGoinAddress,
    novotel => l.fdVenueNovotelAddress,
    _ => l.fdVenueUnknownAddress,
  };
}

class FootballVenuePhoto extends StatelessWidget {
  const FootballVenuePhoto(this.venue, {super.key});
  final FootballVenue venue;

  @override
  Widget build(BuildContext context) => ClipRect(
    child: LayoutBuilder(
      builder: (context, size) {
        final crop = venue.photo;
        final scale = math.max(
          size.maxWidth / crop.width,
          size.maxHeight / crop.height,
        );
        return Stack(
          children: [
            Positioned(
              left:
                  (size.maxWidth - crop.width * scale) / 2 - crop.left * scale,
              top:
                  (size.maxHeight - crop.height * scale) / 2 - crop.top * scale,
              width: 1170 * scale,
              height: 2532 * scale,
              child: Image.asset(
                'assets/venues/football_day_poster.png',
                fit: BoxFit.fill,
                excludeFromSemantics: true,
              ),
            ),
          ],
        );
      },
    ),
  );
}
