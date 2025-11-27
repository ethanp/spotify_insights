import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:spotify_insights/models/playlist.dart';
import 'package:spotify_insights/providers/auth_provider.dart';
import 'package:spotify_insights/services/playlist_dao.dart';
import 'package:spotify_insights/services/playlist_repository.dart';

part 'playlists_provider.g.dart';

@riverpod
PlaylistDao playlistDao(Ref ref) {
  return PlaylistDao();
}

@riverpod
PlaylistRepository playlistRepository(Ref ref) {
  final apiClient = ref.watch(spotifyApiClientProvider);
  final dao = ref.watch(playlistDaoProvider);
  final authService = ref.watch(authServiceProvider);
  return PlaylistRepository(
    apiClient: apiClient,
    dao: dao,
    authService: authService,
  );
}

@riverpod
class PlaylistsNotifier extends _$PlaylistsNotifier {
  @override
  Future<List<Playlist>> build() async {
    final isAuth = await ref.watch(isAuthenticatedProvider.future);
    if (!isAuth) return [];
    
    final repository = ref.watch(playlistRepositoryProvider);
    return repository.getAll();
  }

  Future<void> refresh() async {
    ref.invalidateSelf();
  }
}

@riverpod
Future<Playlist?> playlistWithTracks(Ref ref, String playlistId) async {
  final repository = ref.watch(playlistRepositoryProvider);
  return repository.getWithTracks(playlistId);
}

