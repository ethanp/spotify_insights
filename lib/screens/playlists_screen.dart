import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spotify_insights/models/playlist.dart';
import 'package:spotify_insights/providers/auth_provider.dart';
import 'package:spotify_insights/providers/playlists_provider.dart';
import 'package:spotify_insights/providers/sync_provider.dart';
import 'package:spotify_insights/theme/app_theme.dart';
import 'package:spotify_insights/widgets/async_data_builder.dart';

class PlaylistsScreen extends ConsumerWidget {
  const PlaylistsScreen();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final playlistsAsync = ref.watch(playlistsNotifierProvider);
    final syncStatus = ref.watch(syncNotifierProvider);

    return CupertinoPageScaffold(
      backgroundColor: AppColors.backgroundDepth1,
      navigationBar: CupertinoNavigationBar(
        middle: Text('Playlists', style: AppTypography.navTitle),
        backgroundColor: AppColors.backgroundDepth2.withValues(alpha: 0.9),
        border: null,
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            syncStatusIndicator(syncStatus),
            CupertinoButton(
              padding: EdgeInsets.zero,
              onPressed: () => showSettingsSheet(context, ref),
              child: const Icon(CupertinoIcons.ellipsis_circle),
            ),
          ],
        ),
      ),
      child: SafeArea(
        child: AsyncDataBuilder<List<Playlist>>(
          value: playlistsAsync,
          loadingMessage: 'Loading playlists...',
          onRetry: () => ref.invalidate(playlistsNotifierProvider),
          builder: (playlists) => playlists.isEmpty
              ? emptyState(ref)
              : playlistList(playlists, ref),
        ),
      ),
    );
  }

  Widget syncStatusIndicator(AsyncValue<SyncStatus> syncStatus) {
    return syncStatus.when(
      data: (status) {
        if (status.isSyncing) {
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CupertinoActivityIndicator(radius: 8),
                const SizedBox(width: 4),
                Text(
                  '${status.currentPlaylist}/${status.totalPlaylists}',
                  style: AppTypography.caption,
                ),
              ],
            ),
          );
        }
        return const SizedBox.shrink();
      },
      loading: () => const CupertinoActivityIndicator(radius: 8),
      error: (_, __) => const SizedBox.shrink(),
    );
  }

  Widget emptyState(WidgetRef ref) {
    return EmptyState(
      title: 'No Playlists',
      message: 'Sync your Spotify account to see your playlists',
      icon: CupertinoIcons.music_albums,
      action: CupertinoButton.filled(
        onPressed: () => ref.read(syncNotifierProvider.notifier).sync(),
        child: const Text('Sync Now'),
      ),
    );
  }

  Widget playlistList(List<Playlist> playlists, WidgetRef ref) {
    return CustomScrollView(
      slivers: [
        CupertinoSliverRefreshControl(
          onRefresh: () => ref.read(syncNotifierProvider.notifier).sync(),
        ),
        SliverPadding(
          padding: const EdgeInsets.all(16),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) => playlistCard(playlists[index]),
              childCount: playlists.length,
            ),
          ),
        ),
      ],
    );
  }

  Widget playlistCard(Playlist playlist) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: AppComponents.card,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            playlistImage(playlist),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    playlist.name,
                    style: AppTypography.labelLarge,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${playlist.tracks.length} tracks • ${playlist.totalDurationDisplay}',
                    style: AppTypography.caption,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    playlist.owner.displayName,
                    style: AppTypography.caption.copyWith(
                      color: AppColors.textColor4,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget playlistImage(Playlist playlist) {
    if (playlist.imageUrl != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.network(
          playlist.imageUrl!,
          width: 56,
          height: 56,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => placeholderImage(),
        ),
      );
    }
    return placeholderImage();
  }

  Widget placeholderImage() {
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        color: AppColors.backgroundDepth3,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(
        CupertinoIcons.music_note_list,
        color: AppColors.textColor3,
        size: 24,
      ),
    );
  }

  void showSettingsSheet(BuildContext context, WidgetRef ref) {
    showCupertinoModalPopup(
      context: context,
      builder: (context) => CupertinoActionSheet(
        actions: [
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(context);
              ref.read(syncNotifierProvider.notifier).sync();
            },
            child: const Text('Sync Playlists'),
          ),
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(context);
              ref.read(syncNotifierProvider.notifier).clearAndSync();
            },
            child: const Text('Clear Cache & Sync'),
          ),
          CupertinoActionSheetAction(
            isDestructiveAction: true,
            onPressed: () {
              Navigator.pop(context);
              ref.read(authNotifierProvider.notifier).signOut();
            },
            child: const Text('Sign Out'),
          ),
        ],
        cancelButton: CupertinoActionSheetAction(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
      ),
    );
  }
}

