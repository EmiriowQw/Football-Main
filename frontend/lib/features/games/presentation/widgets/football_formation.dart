import 'package:flutter/material.dart';
import 'package:basketvibe/core/l10n/app_localizations.dart';
import 'package:basketvibe/features/games/domain/entities/football_game.dart';
import 'package:basketvibe/features/games/presentation/widgets/football_arena.dart';
import 'package:basketvibe/features/games/presentation/widgets/football_labels.dart';

class FootballFormation extends StatelessWidget {
  const FootballFormation({
    super.key,
    required this.pitch,
    required this.position,
    required this.onChanged,
  });

  final PitchPreset pitch;
  final FootballPosition position;
  final ValueChanged<FootballPosition>? onChanged;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final markers = [
      (FootballPosition.forward, const Offset(.50, .19), l.fdForwardShort),
      (FootballPosition.midfielder, const Offset(.31, .40), l.fdMidfieldShort),
      (FootballPosition.midfielder, const Offset(.69, .40), l.fdMidfieldShort),
      if (pitch.outfieldPlayers == 5) ...[
        (FootballPosition.defender, const Offset(.31, .62), l.fdDefenderShort),
        (FootballPosition.defender, const Offset(.69, .62), l.fdDefenderShort),
      ] else
        (FootballPosition.defender, const Offset(.50, .62), l.fdDefenderShort),
      (FootballPosition.goalkeeper, const Offset(.50, .82), l.fdKeeperShort),
    ];

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 360),
        child: SizedBox(
          height: 300,
          width: double.infinity,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(18),
            child: LayoutBuilder(
              builder: (context, constraints) => Stack(
                fit: StackFit.expand,
                children: [
                  const CustomPaint(painter: _PitchPainter()),
                  for (final (index, (role, point, short)) in markers.indexed)
                    Positioned(
                      left: point.dx * constraints.maxWidth - 24,
                      top: point.dy * constraints.maxHeight - 24,
                      width: 48,
                      height: 48,
                      child: _FormationMarker(
                        key: ValueKey('formation-${role.name}-$index'),
                        label: positionLabel(l, role),
                        short: short,
                        active: position == role,
                        onPressed: onChanged == null
                            ? null
                            : () => onChanged!(role),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _FormationMarker extends StatelessWidget {
  const _FormationMarker({
    super.key,
    required this.label,
    required this.short,
    required this.active,
    required this.onPressed,
  });

  final String label;
  final String short;
  final bool active;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) => Tooltip(
    message: label,
    excludeFromSemantics: true,
    child: Semantics(
      label: label,
      button: true,
      selected: active,
      enabled: onPressed != null,
      onTap: onPressed,
      excludeSemantics: true,
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          borderRadius: BorderRadius.circular(24),
          onTap: onPressed,
          child: Center(
            child: AnimatedContainer(
              width: active ? 44 : 39,
              height: active ? 44 : 39,
              duration: FootballArena.motion(context, 160),
              decoration: BoxDecoration(
                color: active ? FootballArena.accent : FootballArena.background,
                shape: BoxShape.circle,
                border: Border.all(
                  color: active ? FootballArena.ink : const Color(0xff729c80),
                  width: active ? 2 : 1,
                ),
              ),
              alignment: Alignment.center,
              padding: const EdgeInsets.all(5),
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  short,
                  style: TextStyle(
                    color: active
                        ? FootballArena.background
                        : FootballArena.ink,
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    ),
  );
}

class _PitchPainter extends CustomPainter {
  const _PitchPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final bounds = Offset.zero & size;
    canvas.drawRect(bounds, Paint()..color = const Color(0xff142b20));
    final turf = Rect.fromLTWH(14, 18, size.width - 28, size.height - 36);
    final stripe = Paint()..color = const Color(0xff1a3928);
    for (var i = 0; i < 8; i += 2) {
      canvas.drawRect(
        Rect.fromLTWH(
          turf.left,
          turf.top + turf.height * i / 8,
          turf.width,
          turf.height / 8,
        ),
        stripe,
      );
    }
    final lines = Paint()
      ..color = const Color(0xff6b9a78)
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke;
    canvas.drawRect(turf, lines);
    canvas.drawLine(turf.centerLeft, turf.centerRight, lines);
    canvas.drawCircle(turf.center, 28, lines);
    canvas.drawCircle(turf.center, 2, lines);

    for (final top in [true, false]) {
      final edge = top ? turf.top : turf.bottom;
      final boxWidth = turf.width * .49;
      canvas.drawRect(
        Rect.fromLTWH(
          turf.center.dx - boxWidth / 2,
          top ? edge : edge - 36,
          boxWidth,
          36,
        ),
        lines,
      );
      canvas.drawRect(
        Rect.fromLTWH(turf.center.dx - 23, top ? edge - 9 : edge, 46, 9),
        lines,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _PitchPainter oldDelegate) => false;
}
