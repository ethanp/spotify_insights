import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:spotify_insights/providers/auth_provider.dart';
import 'package:spotify_insights/providers/playlists_provider.dart';

part 'sync_provider.g.dart';

class SyncStatus {
  final bool isSyncing;
  final int currentPlaylist;
  final int totalPlaylists;
  final String? message;
  final DateTime? lastSyncTime;

  const SyncStatus({
    this.isSyncing = false,
    this.currentPlaylist = 0,
    this.totalPlaylists = 0,
    this.message,
    this.lastSyncTime,
  });

  SyncStatus copyWith({
    bool? isSyncing,
    int? currentPlaylist,
    int? totalPlaylists,
    String? message,
    DateTime? lastSyncTime,
  }) {
    return SyncStatus(
      isSyncing: isSyncing ?? this.isSyncing,
      currentPlaylist: currentPlaylist ?? this.currentPlaylist,
      totalPlaylists: totalPlaylists ?? this.totalPlaylists,
      message: message ?? this.message,
      lastSyncTime: lastSyncTime ?? this.lastSyncTime,
    );
  }

  String get progressText {
    if (!isSyncing) return '';
    if (totalPlaylists == 0) return 'Starting sync...';
    return 'Syncing playlist $currentPlaylist of $totalPlaylists';
  }

  double get progress {
    if (totalPlaylists == 0) return 0;
    return currentPlaylist / totalPlaylists;
  }
}

@riverpod
class SyncNotifier extends _$SyncNotifier {
  @override
  Future<SyncStatus> build() async {
    final repository = ref.watch(playlistRepositoryProvider);
    final lastSync = await repository.getLastSyncTime();
    return SyncStatus(lastSyncTime: lastSync);
  }

  Future<void> sync() async {
    final isAuth = await ref.read(isAuthenticatedProvider.future);
    if (!isAuth) return;

    state = AsyncValue.data(
      (state.valueOrNull ?? const SyncStatus()).copyWith(
        isSyncing: true,
        message: 'Starting sync...',
      ),
    );

    try {
      final repository = ref.read(playlistRepositoryProvider);
      await repository.syncAndGetAll(
        onProgress: (current, total) {
          state = AsyncValue.data(SyncStatus(
            isSyncing: true,
            currentPlaylist: current,
            totalPlaylists: total,
            message: 'Syncing playlists...',
          ));
        },
      );

      final lastSync = await repository.getLastSyncTime();
      state = AsyncValue.data(SyncStatus(
        isSyncing: false,
        lastSyncTime: lastSync,
        message: 'Sync complete',
      ));

      ref.invalidate(playlistsNotifierProvider);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> clearAndSync() async {
    final repository = ref.read(playlistRepositoryProvider);
    await repository.clearCache();
    ref.invalidate(playlistsNotifierProvider);
    await sync();
  }
}

@riverpod
Future<DateTime?> lastSyncTime(Ref ref) async {
  final syncStatus = await ref.watch(syncNotifierProvider.future);
  return syncStatus.lastSyncTime;
}

