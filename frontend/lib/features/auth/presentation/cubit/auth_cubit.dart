import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:basketvibe/core/local_storage/local_storage_keys.dart';
import 'package:basketvibe/core/local_storage/local_storage_service.dart';
import 'package:basketvibe/features/auth/data/datasources/remote/auth_remote_datasource.dart';
import 'package:basketvibe/features/auth/data/datasources/remote/google_sign_in_datasource.dart';
import 'package:basketvibe/features/auth/data/datasources/remote/user_remote_datasource.dart';
import 'package:basketvibe/features/auth/presentation/cubit/auth_state.dart';
import 'package:basketvibe/features/games/domain/repositories/football_repository.dart';

class AuthCubit extends Cubit<AuthState> {
  AuthCubit(
    this._localStorage,
    this._remoteDataSource,
    this._userDataSource,
    this._googleSignIn,
    this._gameDataSource,
  ) : super(const AuthInitial()) {
    Future.microtask(() => checkAuthStatus());
  }

  final LocalStorageService _localStorage;
  final AuthRemoteDataSource _remoteDataSource;
  final UserRemoteDataSource _userDataSource;
  final GoogleSignInDatasource _googleSignIn;
  final FootballRepository _gameDataSource;

  Future<void> checkAuthStatus() async {
    final user = kIsWeb
        ? await _remoteDataSource.authStateChanges().first
        : _remoteDataSource.currentUser;
    if (isClosed || state is! AuthInitial) return;
    if (user != null) {
      emit(const AuthAuthenticated(isNewUser: false));
    } else {
      emit(const AuthUnauthenticated());
    }
  }

  Future<void> googleSignIn() async {
    try {
      emit(const AuthLoading());

      final result = await _remoteDataSource.googleSignIn(
        _googleSignIn.signInAndGetIdToken,
      );
      if (result == null) {
        emit(const AuthUnauthenticated());
        return;
      }

      await _userDataSource.ensureUserDocument(
        _remoteDataSource.currentUser!,
        isNew: result.user.isNew,
      );

      await _localStorage.setBool(LocalStorageKeys.isLoggedIn, true);
      await _localStorage.setString(LocalStorageKeys.userId, result.user.id);

      emit(AuthAuthenticated(isNewUser: result.user.isNew));
    } on Exception catch (e) {
      emit(AuthError(e.toString().replaceFirst('Exception: ', '')));
    }
  }

  Future<void> logout() async {
    await Future.wait([
      _remoteDataSource.signOut(),
      if (!kIsWeb) _googleSignIn.signOut(),
      _localStorage.setBool(LocalStorageKeys.isLoggedIn, false),
      _localStorage.remove(LocalStorageKeys.userId),
    ]);
    emit(const AuthUnauthenticated());
  }

  /// Deletes the user's account: re-authenticates (recent-login
  /// requirement), cleans up Firestore data (games + user doc) while
  /// still authenticated, then deletes the Firebase Auth user and clears
  /// the local session. Emits [AuthUnauthenticated] on success.
  Future<void> deleteAccount() async {
    final user = _remoteDataSource.currentUser;
    if (user == null) {
      emit(const AuthUnauthenticated());
      return;
    }

    emit(const AuthLoading());
    try {
      final reauthenticated = await _remoteDataSource.reauthenticateWithGoogle(
        user,
        _googleSignIn.signInAndGetIdToken,
      );
      if (!reauthenticated) {
        emit(const AuthAuthenticated(isNewUser: false));
        return;
      }

      // Never leave occupied future places behind when deleting an account.
      if (await _gameDataSource.hasFutureBooking(user.uid)) {
        emit(const AuthError('football-cancel-bookings-first'));
        emit(const AuthAuthenticated(isNewUser: false));
        return;
      }
      await _userDataSource.deleteUser(user.uid);
      await user.delete();

      // 4. Clear local session.
      await Future.wait([
        _localStorage.setBool(LocalStorageKeys.isLoggedIn, false),
        _localStorage.remove(LocalStorageKeys.userId),
        if (!kIsWeb) _googleSignIn.signOut(),
      ]);
      emit(const AuthUnauthenticated());
    } on FirebaseAuthException catch (e) {
      emit(AuthError(_authErrorMessage(e)));
      if (_remoteDataSource.currentUser != null) {
        emit(const AuthAuthenticated(isNewUser: false));
      }
    } on Exception catch (e) {
      emit(AuthError(e.toString().replaceFirst('Exception: ', '')));
      if (_remoteDataSource.currentUser != null) {
        emit(const AuthAuthenticated(isNewUser: false));
      }
    }
  }

  String _authErrorMessage(FirebaseAuthException e) {
    switch (e.code) {
      case 'requires-recent-login':
        return 'Please sign in again and retry deleting your account';
      case 'network-request-failed':
        return 'No internet connection';
      default:
        return e.message ?? 'Failed to delete account (${e.code})';
    }
  }
}
