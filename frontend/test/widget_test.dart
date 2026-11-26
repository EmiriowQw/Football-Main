import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:basketvibe/core/l10n/app_localizations.dart';
import 'package:basketvibe/core/network/injection.dart';
import 'package:basketvibe/core/router/app_router.dart';
import 'package:basketvibe/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:basketvibe/features/auth/presentation/cubit/auth_state.dart';
import 'package:basketvibe/features/auth/presentation/pages/login_page.dart';
import 'package:basketvibe/features/games/domain/entities/football_game.dart';
import 'package:basketvibe/features/games/presentation/cubit/football_cubit.dart';
import 'package:basketvibe/features/games/presentation/pages/football_day_page.dart';
import 'package:basketvibe/features/games/presentation/pages/football_booking_page.dart';
import 'support/football_repository_fake.dart';

class TestAuthCubit extends MockCubit<AuthState> implements AuthCubit {}

void main() {
  setUpAll(() async {
    final font = File('C:/Windows/Fonts/arial.ttf');
    if (await font.exists()) {
      final loader = FontLoader('PreviewFont')
        ..addFont(font.readAsBytes().then((b) => ByteData.sublistView(b)));
      await loader.load();
    }
    final icons = File(
      'build/unit_test_assets/fonts/MaterialIcons-Regular.otf',
    );
    if (await icons.exists()) {
      await (FontLoader('MaterialIcons')
            ..addFont(icons.readAsBytes().then((b) => ByteData.sublistView(b))))
          .load();
    }
  });
  late FootballRepositoryFake repository;
  late FootballCubit cubit;
  late TestAuthCubit auth;
  setUp(() {
    repository = FootballRepositoryFake();
    repository.games = FootballSchedule.forDay(
      FootballSchedule.today().add(const Duration(days: 1)),
    );
    cubit = FootballCubit(repository);
    auth = TestAuthCubit();
    when(() => auth.state).thenReturn(const AuthUnauthenticated());
  });
  tearDown(() async {
    await cubit.close().timeout(const Duration(seconds: 3));
    await repository.changes.close().timeout(const Duration(seconds: 3));
    await auth.close().timeout(const Duration(seconds: 3));
  });
  Widget shell(
    Widget child, {
    Locale locale = const Locale('ru'),
    bool dark = false,
  }) => MultiBlocProvider(
    providers: [
      BlocProvider<FootballCubit>.value(value: cubit),
      BlocProvider<AuthCubit>.value(value: auth),
    ],
    child: MaterialApp(
      locale: locale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: 'PreviewFont',
        brightness: dark ? Brightness.dark : Brightness.light,
        colorSchemeSeed: const Color(0xff16834a),
      ),
      home: child,
    ),
  );

  testWidgets('app router opens the football schedule on launch', (
    tester,
  ) async {
    getIt.pushNewScope();
    getIt.registerFactory<FootballCubit>(() => FootballCubit(repository));
    addTearDown(getIt.popScope);

    await tester.pumpWidget(
      BlocProvider<AuthCubit>.value(
        value: auth,
        child: MaterialApp.router(
          routerConfig: AppRouter.router,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
        ),
      ),
    );
    await tester.pump();

    expect(find.byType(FootballDayView), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('login fits a narrow screen with large Russian text', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(360, 640);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      shell(
        const MediaQuery(
          data: MediaQueryData(
            size: Size(360, 640),
            textScaler: TextScaler.linear(1.5),
          ),
          child: LoginPage(),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Войти через Google'), findsOneWidget);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets(
    'guest sees football schedule, no creation action; renders preview',
    (tester) async {
      tester.view.physicalSize = const Size(400, 1000);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final key = GlobalKey();
      await tester.pumpWidget(
        shell(RepaintBoundary(key: key, child: const FootballDayView())),
      );
      await tester.pumpAndSettle();
      expect(find.text('FOOTBALL DAY'), findsOneWidget);
      expect(find.text('БЛИЖАЙШАЯ ИГРА'), findsOneWidget);
      expect(find.textContaining('Поле 1'), findsWidgets);
      expect(find.byType(FloatingActionButton), findsNothing);
      expect(tester.takeException(), isNull);
      final boundary =
          key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
      await tester.runAsync(() async {
        final image = await boundary.toImage(pixelRatio: 2);
        final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
        await Directory('build').create(recursive: true);
        await File(
          'build/football_day_preview.png',
        ).writeAsBytes(bytes!.buffer.asUint8List());
        image.dispose();
      });
      await tester.tap(find.text('Выбрать команду'));
      await tester.pumpAndSettle();
      expect(find.byType(FootballBookingPage), findsOneWidget);
      expect(find.text('Бронь поля'), findsOneWidget);
      expect(find.textContaining('Поле 1'), findsOneWidget);
      expect(find.text('Войти через Google'), findsOneWidget);
      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
      await tester.tap(find.text('Мои брони'));
      await tester.pumpAndSettle();
      expect(find.text('Войти через Google'), findsOneWidget);
      await tester.pumpWidget(const SizedBox());
    },
  );

  testWidgets('guest can preview the five spots on a narrow 4+1 pitch', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(360, 720);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      shell(
        FootballBookingPage(
          gameId: repository.games[2].id,
          uid: null,
          bookerName: '',
        ),
        locale: const Locale('en'),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byTooltip('Goalkeeper'), findsOneWidget);
    expect(find.byTooltip('Defender'), findsOneWidget);
    expect(find.byTooltip('Midfielder'), findsNWidgets(2));
    expect(find.byTooltip('Forward'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('whole-team booking includes booker and optional friends', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(400, 1800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      shell(
        Scaffold(
          body: FootballBookingPage(
            gameId: repository.games.first.id,
            uid: 'alice',
            bookerName: 'Alice',
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Красная').first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Все свободные места'));
    await tester.pumpAndSettle();
    expect(find.byType(TextField), findsNWidgets(5));
    expect(find.text('Без разницы'), findsOneWidget);
    expect(find.byTooltip('Защитник'), findsNWidgets(2));
    expect(find.byTooltip('Полузащитник'), findsNWidgets(2));
    final defender = find.byTooltip('Защитник').first;
    await tester.ensureVisible(defender);
    await tester.tap(defender);
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(TextButton, 'Без разницы'));
    await tester.pumpAndSettle();
    final selected = find.byKey(const ValueKey('formation-selected-position'));
    expect(tester.widget<Text>(selected).data, 'Без разницы');
    await tester.tap(defender);
    await tester.pumpAndSettle();
    final friendPosition = find.byKey(const ValueKey('formation-player-1'));
    await tester.ensureVisible(friendPosition);
    await tester.tap(friendPosition);
    await tester.pumpAndSettle();
    final goalkeeper = find.byTooltip('Вратарь');
    await tester.ensureVisible(goalkeeper);
    await tester.tap(goalkeeper);
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).first, 'Sam');
    await tester.ensureVisible(find.text('Забронировать'));
    await tester.tap(find.text('Забронировать'));
    await tester.pumpAndSettle();
    expect(repository.saved!.places, 6);
    expect(repository.saved!.team, FootballTeam.red);
    expect(repository.saved!.position, FootballPosition.defender);
    expect(repository.saved!.positionForFriend(0), FootballPosition.goalkeeper);
    expect(repository.saved!.positionForFriend(1), FootballPosition.any);
    expect(find.text('Ты в игре'), findsOneWidget);
    expect(repository.saved!.friendNames.first, 'Sam');
    expect(repository.saved!.friendNames.skip(1).every((n) => n.isEmpty), true);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('capacity conflict keeps editor and shows actionable error', (
    tester,
  ) async {
    repository.failWith = BookingFailure.full;
    await tester.pumpWidget(
      shell(
        Scaffold(
          body: FootballBookingPage(
            gameId: repository.games.first.id,
            uid: 'alice',
            bookerName: 'Alice',
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Красная').first);
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Забронировать'));
    await tester.tap(find.text('Забронировать'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Места уже заняли.'), findsOneWidget);
    expect(repository.saved, isNull);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('past roster is read-only and includes unnamed guests', (
    tester,
  ) async {
    final past = FootballSchedule.forDay(
      FootballSchedule.today().subtract(const Duration(days: 1)),
    ).first;
    repository.games = [
      FootballGame(
        pitch: past.pitch,
        startTime: past.startTime,
        bookings: {
          'alice': Booking(
            userId: 'alice',
            team: FootballTeam.red,
            places: 2,
            bookerName: 'Alice',
          ),
        },
      ),
    ];
    cubit.selectDate(
      FootballSchedule.today().subtract(const Duration(days: 1)),
    );
    await tester.pumpWidget(
      shell(
        Scaffold(
          body: FootballBookingPage(
            gameId: past.id,
            uid: 'alice',
            bookerName: 'Alice',
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.textContaining('Гость Alice'), findsOneWidget);
    expect(find.text('Забронировать'), findsNothing);
    expect(find.text('Отменить бронь'), findsNothing);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('narrow English dark schedule and large text do not overflow', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      shell(
        const MediaQuery(
          data: MediaQueryData(
            size: Size(360, 800),
            textScaler: TextScaler.linear(1.5),
          ),
          child: FootballDayView(),
        ),
        locale: const Locale('en'),
        dark: true,
      ),
    );
    await tester.pumpAndSettle();
    await tester.drag(find.byType(ListView), const Offset(0, -500));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox());
  });
}
