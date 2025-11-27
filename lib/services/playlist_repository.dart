import 'dart:async';
import 'package:spotify_insights/models/playlist.dart';
import 'package:spotify_insights/services/auth_service.dart';
import 'package:spotify_insights/services/playlist_dao.dart';
import 'package:spotify_insights/services/spotify_api_client.dart';

class PlaylistRepository {
  final SpotifyApiClient _apiClient;
  final PlaylistDao _dao;
  final AuthService _authService;

  final _playlistsController = StreamController<List<Playlist>>.broadcast();
  List<Playlist>? _cachedPlaylists;
  String? _currentUserId;

  PlaylistRepository({
    required SpotifyApiClient apiClient,
    required PlaylistDao dao,
    required AuthService authService,
  })  : _apiClient = apiClient,
        _dao = dao,
        _authService = authService;

  Stream<List<Playlist>> watchAll() {
    _loadFromDatabase();
    return _playlistsController.stream;
  }

  Future<List<Playlist>> getAll() async {
    if (_cachedPlaylists != null) return _cachedPlaylists!;
    return _dao.getAllPlaylistsWithTracks();
  }

  Future<Playlist?> getWithTracks(String playlistId) async {
    return _dao.getPlaylistWithTracks(playlistId);
  }

  Future<List<Playlist>> syncAndGetAll({
    void Function(int current, int total)? onProgress,
  }) async {
    await _authService.ensureValidToken();

    final currentUser = await _apiClient.getCurrentUser();
    _currentUserId = currentUser.id;

    final allPlaylists = await _apiClient.getAllPlaylists();

    final ownedPlaylists = allPlaylists
        .where((p) => p.owner.id == _currentUserId)
        .toList();

    final total = ownedPlaylists.length;
    var current = 0;

    final syncedPlaylists = <Playlist>[];
    for (final playlist in ownedPlaylists) {
      onProgress?.call(++current, total);

      final tracks = await _apiClient.getPlaylistTracks(playlist.id);
      final fullPlaylist = playlist.copyWith(
        tracks: tracks,
        lastSyncedAt: DateTime.now(),
      );

      await _dao.upsertPlaylistWithTracks(fullPlaylist);
      syncedPlaylists.add(fullPlaylist);
    }

    await _dao.setLastSyncTime(DateTime.now());
    _cachedPlaylists = syncedPlaylists;
    _playlistsController.add(syncedPlaylists);

    return syncedPlaylists;
  }

  Future<DateTime?> getLastSyncTime() => _dao.getLastSyncTime();

  Future<void> clearCache() async {
    await _dao.clearAll();
    _cachedPlaylists = null;
    _playlistsController.add([]);
  }

  Future<void> _loadFromDatabase() async {
    final playlists = await _dao.getAllPlaylistsWithTracks();
    _cachedPlaylists = playlists;
    _playlistsController.add(playlists);
  }

  void dispose() {
    _playlistsController.close();
  }
}
