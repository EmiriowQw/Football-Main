import 'package:flutter/material.dart';
import 'package:basketvibe/core/l10n/app_localizations.dart';
import 'package:basketvibe/core/styles/app_colors.dart';
import 'package:basketvibe/features/games/domain/entities/football_game.dart';

String teamLabel(AppLocalizations l, FootballTeam team) => switch (team) {
  FootballTeam.red => l.fdRed,
  FootballTeam.blue => l.fdBlue,
  FootballTeam.yellow => l.fdYellow,
  FootballTeam.green => l.fdGreen,
};

String positionLabel(AppLocalizations l, FootballPosition position) =>
    switch (position) {
      FootballPosition.any => l.fdPositionAny,
      FootballPosition.goalkeeper => l.fdPositionGoalkeeper,
      FootballPosition.defender => l.fdPositionDefender,
      FootballPosition.midfielder => l.fdPositionMidfielder,
      FootballPosition.forward => l.fdPositionForward,
    };

Color teamColor(FootballTeam team) => switch (team) {
  FootballTeam.red => AppColors.error,
  FootballTeam.blue => AppColors.info,
  FootballTeam.yellow => AppColors.warning,
  FootballTeam.green => AppColors.primary,
};

String bookingError(AppLocalizations l, BookingFailure failure) =>
    switch (failure) {
      BookingFailure.started => l.fdStartedError,
      BookingFailure.full => l.fdFullError,
      BookingFailure.teamChange => l.fdChangeTeamHint,
      BookingFailure.invalid => l.fdInvalidError,
      BookingFailure.unavailable => l.fdNetworkError,
      BookingFailure.signIn => l.fdSignIn,
    };
