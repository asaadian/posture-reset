// lib/features/auth/application/auth_providers.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  AuthService(this._client);

  final SupabaseClient _client;

  Stream<AuthState> authStateChanges() => _client.auth.onAuthStateChange;

  Session? get currentSession => _client.auth.currentSession;
  User? get currentUser => _client.auth.currentUser;

  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) {
    return _client.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  Future<AuthResponse> signUp({
    required String email,
    required String password,
  }) {
    return _client.auth.signUp(
      email: email,
      password: password,
    );
  }

  Future<void> signOut() {
    return _client.auth.signOut();
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