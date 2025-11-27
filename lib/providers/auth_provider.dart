import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:spotify_insights/services/auth_service.dart';
import 'package:spotify_insights/services/spotify_api_client.dart';
import 'package:spotify_insights/services/token_storage.dart';

part 'auth_provider.g.dart';

@riverpod
SpotifyApiClient spotifyApiClient(Ref ref) {
  final clientId = dotenv.env['SPOTIFY_CLIENT_ID'] ?? '';
  return SpotifyApiClient(clientId: clientId);
}

@riverpod
TokenStorage tokenStorage(Ref ref) {
  return TokenStorage();
}

@riverpod
AuthService authService(Ref ref) {
  final apiClient = ref.watch(spotifyApiClientProvider);
  final tokenStorage = ref.watch(tokenStorageProvider);
  return AuthService(apiClient: apiClient, tokenStorage: tokenStorage);
}

@riverpod
class AuthNotifier extends _$AuthNotifier {
  @override
  Future<AuthState> build() async {
    final authService = ref.watch(authServiceProvider);
    return authService.checkAuthState();
  }

  Future<void> signIn() async {
    state = const AsyncValue.loading();
    try {
      final authService = ref.read(authServiceProvider);
      final success = await authService.startAuthFlow();
      if (success) {
        state = const AsyncValue.data(AuthState.authenticated);
      } else {
        state = const AsyncValue.data(AuthState.unauthenticated);
      }
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> signOut() async {
    final authService = ref.read(authServiceProvider);
    await authService.signOut();
    state = const AsyncValue.data(AuthState.unauthenticated);
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    try {
      final authService = ref.read(authServiceProvider);
      final authState = await authService.checkAuthState();
      state = AsyncValue.data(authState);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

@riverpod
Future<bool> isAuthenticated(Ref ref) async {
  final authState = await ref.watch(authNotifierProvider.future);
  return authState == AuthState.authenticated;
}
