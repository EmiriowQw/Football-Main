import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:basketvibe/core/l10n/app_localizations.dart';
import 'package:basketvibe/features/games/domain/entities/football_game.dart';
import 'package:basketvibe/features/games/presentation/widgets/football_venue_photo.dart';

class FootballArena {
  static const background = Color(0xff0d1711);
  static const surface = Color(0xff17271d);
  static const line = Color(0xff385043);
  static const accent = Color(0xffcffb72);
  static const ink = Color(0xffeff8ed);
  static const muted = Color(0xffb1c6b5);

  static ThemeData theme(ThemeData base) => ThemeData(
    brightness: Brightness.dark,
    useMaterial3: true,
    scaffoldBackgroundColor: background,
    textTheme: base.textTheme.apply(bodyColor: ink, displayColor: ink),
    colorScheme: const ColorScheme.dark(
      primary: accent,
      onPrimary: background,
      surface: surface,
      onSurface: ink,
      onSurfaceVariant: muted,
      outline: line,
      secondaryContainer: Color(0xff29482e),
      onSecondaryContainer: accent,
      surfaceContainerHighest: Color(0xff22372a),
      error: Color(0xffffaaa3),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: background,
      foregroundColor: ink,
      scrolledUnderElevation: 0,
      centerTitle: false,
    ),
    navigationBarTheme: const NavigationBarThemeData(
      backgroundColor: surface,
      indicatorColor: Color(0xff29482e),
      height: 66,
      elevation: 0,
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        minimumSize: const Size(0, 48),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle: base.textTheme.labelLarge?.copyWith(
          fontWeight: FontWeight.w800,
        ),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: background,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
    ),
    chipTheme: const ChipThemeData(side: BorderSide(color: line)),
  );

  static Duration motion(BuildContext context, int milliseconds) =>
      MediaQuery.disableAnimationsOf(context)
      ? Duration.zero
      : Duration(milliseconds: milliseconds);
}

String arenaGameTime(FootballGame game) =>
    DateFormat.Hm().format(FootballSchedule.bishkekTime(game.startTime));

class ArenaScoreboard extends StatelessWidget {
  const ArenaScoreboard({super.key, required this.game, required this.caption});

  final FootballGame game;
  final String caption;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final venue = FootballVenue.forPitch(game.pitch);
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(19),
        border: Border.all(color: FootballArena.line),
        gradient: const LinearGradient(
          colors: [Color(0xff15261c), Color(0xff254732), Color(0xff366144)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(19),
        child: Stack(
          children: [
            if (venue != null) ...[
              Positioned.fill(child: FootballVenuePhoto(venue)),
              const Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xf10d1711), Color(0x77101d15)],
                    ),
                  ),
                ),
              ),
            ],
            CustomPaint(
              painter: venue == null ? const _PitchLines() : null,
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      caption,
                      style: const TextStyle(
                        color: FootballArena.accent,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.1,
                      ),
                    ),
                    Text(
                      arenaGameTime(game),
                      style: Theme.of(context).textTheme.displayMedium
                          ?.copyWith(
                            fontWeight: FontWeight.w900,
                            letterSpacing: -3,
                            height: 1.05,
                          ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      '${venue?.label(l) ?? l.fdPitch(game.pitch.number)} · ${game.pitch.format}',
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                    if (venue != null) Text(venue.location(l)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ArenaAvailability extends StatelessWidget {
  const ArenaAvailability({super.key, required this.game});
  final FootballGame game;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          l.fdTotalFree(game.freeTotal, game.capacity),
          style: const TextStyle(
            color: FootballArena.muted,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        TweenAnimationBuilder<double>(
          tween: Tween(
            begin: 0,
            end: (game.capacity - game.freeTotal) / game.capacity,
          ),
          duration: FootballArena.motion(context, 320),
          curve: Curves.easeOutCubic,
          builder: (context, filled, child) => Row(
            children: List.generate(
              12,
              (index) => Expanded(
                child: Padding(
                  padding: EdgeInsets.only(right: index == 11 ? 0 : 4),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(3),
                    child: LinearProgressIndicator(
                      value: (filled * 12 - index).clamp(0.0, 1.0),
                      minHeight: 5,
                      backgroundColor: FootballArena.line,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class ArenaSwitch extends StatelessWidget {
  const ArenaSwitch({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) => AnimatedSwitcher(
    duration: FootballArena.motion(context, 240),
    layoutBuilder: (current, previous) => Stack(
      alignment: Alignment.topCenter,
      children: [
        for (final child in previous)
          IgnorePointer(child: ExcludeSemantics(child: child)),
        ?current,
      ],
    ),
    switchInCurve: Curves.easeOutCubic,
    transitionBuilder: (child, animation) => FadeTransition(
      opacity: animation,
      child: SlideTransition(
        position: Tween(
          begin: const Offset(0, 0.035),
          end: Offset.zero,
        ).animate(animation),
        child: child,
      ),
    ),
    child: child,
  );
}

class _PitchLines extends CustomPainter {
  const _PitchLines();

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.translate(size.width * .84, size.height * .56);
    canvas.rotate(-math.pi / 11);
    final w = size.width * .62;
    final h = size.height * .94;
    final field = Rect.fromCenter(center: Offset.zero, width: w, height: h);
    for (var i = 0; i < 8; i += 2) {
      canvas.drawRect(
        Rect.fromLTWH(field.left + w * i / 8, field.top, w / 8, h),
        Paint()..color = const Color(0x13d4fbd0),
      );
    }
    final paint = Paint()
      ..color = const Color(0x82c3e9c4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    canvas.drawRect(field, paint);
    canvas.drawLine(Offset(0, field.top), Offset(0, field.bottom), paint);
    canvas.drawCircle(Offset.zero, h * .19, paint);
    for (final x in [field.left, field.right - w * .17]) {
      canvas.drawRect(Rect.fromLTWH(x, -h * .25, w * .17, h * .50), paint);
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _PitchLines oldDelegate) => false;
}
