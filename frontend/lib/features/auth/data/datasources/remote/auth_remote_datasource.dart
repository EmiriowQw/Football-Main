import 'package:basketvibe/features/auth/data/models/auth_user_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class GoogleLoginResponse {
  final AuthUserModel user;

  const GoogleLoginResponse({required this.user});
}

class AuthRemoteDataSource {
  final FirebaseAuth _auth;

  AuthRemoteDataSource(this._auth);

  /// Currently signed-in Firebase user, or null.
  User? get currentUser => _auth.currentUser;

  /// Emits on sign-in/sign-out.
  Stream<User?> authStateChanges() => _auth.authStateChanges();

  /// Returns null if the user cancels the Google sign-in.
  Future<GoogleLoginResponse?> googleSignIn(
    Future<String?> Function() getIdToken,
  ) async {
    try {
      final UserCredential userCredential;
      if (kIsWeb) {
        userCredential = await _auth.signInWithPopup(GoogleAuthProvider());
      } else {
        final idToken = await getIdToken();
        if (idToken == null) return null;
        userCredential = await _auth.signInWithCredential(
          GoogleAuthProvider.credential(idToken: idToken),
        );
      }

      final user = userCredential.user;
      if (user == null) {
        throw Exception('Firebase sign-in returned no user');
      }

      return GoogleLoginResponse(
        user: AuthUserModel.fromFirebaseUser(
          user,
          isNew: userCredential.additionalUserInfo?.isNewUser ?? false,
        ),
      );
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'popup-closed-by-user':
        case 'cancelled-popup-request':
          return null;
        case 'invalid-credential':
          throw Exception('Invalid or expired Google token');
        case 'user-disabled':
          throw Exception('This account has been disabled');
        case 'network-request-failed':
          throw Exception('No internet connection');
        default:
          throw Exception(e.message ?? 'Login failed (${e.code})');
      }
    }
  }

  Future<void> signOut() => _auth.signOut();

  Future<bool> reauthenticateWithGoogle(
    User user,
    Future<String?> Function() getIdToken,
  ) async {
    try {
      if (kIsWeb) {
        await user.reauthenticateWithPopup(GoogleAuthProvider());
      } else {
        final idToken = await getIdToken();
        if (idToken == null) return false;
        await user.reauthenticateWithCredential(
          GoogleAuthProvider.credential(idToken: idToken),
        );
      }
      return true;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'popup-closed-by-user' ||
          e.code == 'cancelled-popup-request') {
        return false;
      }
      rethrow;
    }
  }
}
