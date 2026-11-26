import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:basketvibe/core/network/injection.dart';
import 'package:basketvibe/core/constants/route_constants.dart';
import 'package:basketvibe/features/auth/presentation/pages/login_page.dart';
import 'package:basketvibe/features/home/presentation/pages/home_page.dart';
import 'package:basketvibe/features/onboarding/presentation/bloc/onboarding_bloc.dart';
import 'package:basketvibe/features/onboarding/presentation/pages/onboarding_page.dart';

class AppRouter {
  AppRouter._();

  static final GoRouter router = GoRouter(
    initialLocation: RouteConstants.home,
    routes: [
      GoRoute(
        path: RouteConstants.splash,
        name: 'splash',
        redirect: (context, state) => RouteConstants.home,
      ),

      // Onboarding
      GoRoute(
        path: RouteConstants.onboarding,
        name: 'onboarding',
        builder: (context, state) => BlocProvider(
          create: (_) => getIt<OnboardingBloc>(),
          child: const OnboardingPage(),
        ),
      ),

      // Login
      GoRoute(
        path: RouteConstants.login,
        name: 'login',
        builder: (context, state) => const LoginPage(),
      ),

      // Home
      GoRoute(
        path: RouteConstants.home,
        name: 'home',
        builder: (context, state) => const HomePage(),
      ),

      // Games Overview
      GoRoute(
        path: RouteConstants.games,
        name: 'games',
        builder: (context, state) => const HomePage(),
      ),

      // Courts (Court Finder / Map)
      GoRoute(
        path: RouteConstants.courts,
        name: 'courts',
        redirect: (context, state) => RouteConstants.home,
      ),

      // Create Game
      GoRoute(
        path: RouteConstants.createGame,
        name: 'createGame',
        redirect: (context, state) => RouteConstants.home,
      ),
    ],
  );
}
