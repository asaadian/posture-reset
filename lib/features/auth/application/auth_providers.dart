// lib/features/auth/application/auth_providers.dart

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/config/app_env.dart';

class AuthService {
  AuthService(this._client);

  final SupabaseClient _client;

  Future<void>? _googleInitialization;

  static const String oauthRedirectUrl = 'posturereset://auth/callback';

  Stream<AuthState> authStateChanges() => _client.auth.onAuthStateChange;

  Session? get currentSession => _client.auth.currentSession;
  User? get currentUser => _client.auth.currentUser;

  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) {
    return _client.auth.signInWithPassword(
      email: email.trim(),
      password: password,
    );
  }

  Future<AuthResponse> signUp({
    required String email,
    required String password,
  }) {
    return _client.auth.signUp(
      email: email.trim(),
      password: password,
      emailRedirectTo: kIsWeb ? null : oauthRedirectUrl,
    );
  }

  Future<bool> signInWithGoogle() async {
    if (kIsWeb) {
      return _client.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: null,
        authScreenLaunchMode: LaunchMode.platformDefault,
      );
    }

    final serverClientId = AppEnv.googleWebClientId.trim();
    if (serverClientId.isEmpty) {
      throw AuthException(
        'Google Sign-In is not configured. Missing GOOGLE_WEB_CLIENT_ID.',
      );
    }

    _googleInitialization ??= GoogleSignIn.instance.initialize(
      serverClientId: serverClientId,
    );
    await _googleInitialization;

    final googleUser = await GoogleSignIn.instance.authenticate();
    final idToken = googleUser.authentication.idToken;

    if (idToken == null || idToken.isEmpty) {
      throw AuthException('Google Sign-In did not return an ID token.');
    }

    await _client.auth.signInWithIdToken(
      provider: OAuthProvider.google,
      idToken: idToken,
    );

    return true;
  }

  Future<void> resetPasswordForEmail({
    required String email,
  }) {
    return _client.auth.resetPasswordForEmail(
      email.trim(),
      redirectTo: kIsWeb ? null : oauthRedirectUrl,
    );
  }

  Future<void> signOut() async {
    await _client.auth.signOut();

    if (!kIsWeb && _googleInitialization != null) {
      try {
        await GoogleSignIn.instance.signOut();
      } on GoogleSignInException {
        // Supabase sign-out already succeeded; native Google cleanup is best-effort.
      }
    }
  }
}

final authSupabaseClientProvider = Provider<SupabaseClient>((ref) {
  return Supabase.instance.client;
});

final authServiceProvider = Provider<AuthService>((ref) {
  final client = ref.watch(authSupabaseClientProvider);
  return AuthService(client);
});

final authStateChangesProvider = StreamProvider<AuthState>((ref) {
  final service = ref.watch(authServiceProvider);
  return service.authStateChanges();
});

final currentSessionProvider = Provider<Session?>((ref) {
  final service = ref.watch(authServiceProvider);
  final authState = ref.watch(authStateChangesProvider);

  return authState.maybeWhen(
    data: (state) => state.session ?? service.currentSession,
    orElse: () => service.currentSession,
  );
});

final currentUserProvider = Provider<User?>((ref) {
  final service = ref.watch(authServiceProvider);
  final session = ref.watch(currentSessionProvider);
  return session?.user ?? service.currentUser;
});

final isAuthenticatedProvider = Provider<bool>((ref) {
  return ref.watch(currentUserProvider) != null;
});
