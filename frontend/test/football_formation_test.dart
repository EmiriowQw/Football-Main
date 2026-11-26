import 'package:basketvibe/core/l10n/app_localizations.dart';
import 'package:basketvibe/features/games/domain/entities/football_game.dart';
import 'package:basketvibe/features/games/presentation/widgets/football_formation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('selects only the tapped midfielder on either formation', (
    tester,
  ) async {
    for (final pitch in [
      FootballSchedule.pitches[0],
      FootballSchedule.pitches[2],
    ]) {
      var position = FootballPosition.any;
      var right = false;
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          home: Scaffold(
            body: StatefulBuilder(
              key: ValueKey(pitch.id),
              builder: (context, setState) => FootballFormation(
                pitch: pitch,
                position: position,
                right: right,
                onChanged: (role, side) => setState(() {
                  position = role;
                  right = side;
                }),
              ),
            ),
          ),
        ),
      );
      final midfielders = find.byTooltip('Midfielder');
      expect(midfielders, findsNWidgets(2));
      final active = find.byWidgetPredicate(
        (widget) => widget is Semantics && widget.properties.selected == true,
      );
      for (final target in [midfielders.last, midfielders.first]) {
        await tester.tap(target);
        await tester.pumpAndSettle();
        expect(active, findsOneWidget);
        expect(find.descendant(of: target, matching: active), findsOneWidget);
      }
    }
  });
}
