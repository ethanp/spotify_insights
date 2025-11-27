import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spotify_insights/models/analytics_snapshot.dart';
import 'package:spotify_insights/providers/analytics_provider.dart';
import 'package:spotify_insights/providers/sync_provider.dart';
import 'package:spotify_insights/theme/app_theme.dart';
import 'package:spotify_insights/widgets/async_data_builder.dart';
import 'package:spotify_insights/widgets/overlap_chart.dart';
import 'package:spotify_insights/widgets/ranked_list_card.dart';
import 'package:spotify_insights/widgets/timeline_chart.dart';

class AnalyticsScreen extends ConsumerWidget {
  const AnalyticsScreen();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final analyticsAsync = ref.watch(analyticsProvider);
    final syncStatus = ref.watch(syncNotifierProvider);

    return CupertinoPageScaffold(
      backgroundColor: AppColors.backgroundDepth1,
      navigationBar: CupertinoNavigationBar(
        middle: Text('Analytics', style: AppTypography.navTitle),
        backgroundColor: AppColors.backgroundDepth2.withValues(alpha: 0.9),
        border: null,
        trailing: syncIndicator(syncStatus),
      ),
      child: SafeArea(
        child: AsyncDataBuilder<AnalyticsSnapshot>(
          value: analyticsAsync,
          loadingMessage: 'Computing analytics...',
          onRetry: () => ref.invalidate(analyticsProvider),
          builder: (analytics) => analytics.isEmpty
              ? emptyState(ref)
              : analyticsContent(context, analytics, ref),
        ),
      ),
    );
  }

  Widget syncIndicator(AsyncValue<SyncStatus> syncStatus) {
    return syncStatus.when(
      data: (status) {
        if (status.isSyncing) {
          return Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CupertinoActivityIndicator(radius: 10),
              const SizedBox(width: 8),
              Text(status.progressText, style: AppTypography.caption),
            ],
          );
        }
        return const SizedBox.shrink();
      },
      loading: () => const CupertinoActivityIndicator(radius: 10),
      error: (_, __) => Icon(
        CupertinoIcons.exclamationmark_triangle,
        color: AppColors.warning,
        size: 20,
      ),
    );
  }

  Widget emptyState(WidgetRef ref) {
    return EmptyState(
      title: 'No Analytics Yet',
      message: 'Sync your playlists to see insights about your music',
      icon: CupertinoIcons.chart_bar,
      action: CupertinoButton.filled(
        onPressed: () => ref.read(syncNotifierProvider.notifier).sync(),
        child: const Text('Sync Playlists'),
      ),
    );
  }

  Widget analyticsContent(
    BuildContext context,
    AnalyticsSnapshot analytics,
    WidgetRef ref,
  ) {
    return CustomScrollView(
      slivers: [
        CupertinoSliverRefreshControl(
          onRefresh: () => ref.read(syncNotifierProvider.notifier).sync(),
        ),
        SliverPadding(
          padding: const EdgeInsets.all(16),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              sectionHeader('Playlist Overlap'),
              const SizedBox(height: 8),
              OverlapChart(overlaps: analytics.topOverlaps),
              const SizedBox(height: 24),
              sectionHeader('Tracks Added Over Time'),
              const SizedBox(height: 8),
              TimelineChart(additions: analytics.additionsTimeline),
              const SizedBox(height: 24),
              sectionHeader('Songs on Most Playlists'),
              const SizedBox(height: 8),
              mostCommonTracksCard(context, analytics.mostCommonTracks),
              const SizedBox(height: 24),
              sectionHeader('Longest Playlists'),
              const SizedBox(height: 8),
              longestPlaylistsCard(analytics.longestPlaylists),
              const SizedBox(height: 32),
            ]),
          ),
        ),
      ],
    );
  }

  Widget sectionHeader(String title) {
    return Text(title, style: AppTypography.headlineSmall);
  }

  Widget mostCommonTracksCard(BuildContext context, List<TrackFrequency> tracks) {
    return RankedListCard<TrackFrequency>(
      title: 'Most Common Tracks',
      items: tracks,
      labelFor: (t) => t.trackName,
      subtitleFor: (t) => t.artists,
      valueFor: (t) => '${t.playlistCount} playlists',
      onItemTap: (track) => showTrackPlaylistsSheet(context, track),
    );
  }

  Widget longestPlaylistsCard(List<PlaylistSize> playlists) {
    return RankedListCard<PlaylistSize>(
      title: 'By Track Count',
      items: playlists,
      labelFor: (p) => p.playlistName,
      subtitleFor: (p) => p.durationDisplay,
      valueFor: (p) => '${p.trackCount} tracks',
    );
  }

  void showTrackPlaylistsSheet(BuildContext context, TrackFrequency track) {
    showCupertinoModalPopup(
      context: context,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.6,
        decoration: BoxDecoration(
          color: AppColors.backgroundDepth2,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(track.trackName, style: AppTypography.headlineSmall),
                        const SizedBox(height: 4),
                        Text(track.artists, style: AppTypography.bodySmall),
                      ],
                    ),
                  ),
                  CupertinoButton(
                    padding: EdgeInsets.zero,
                    onPressed: () => Navigator.pop(context),
                    child: const Icon(CupertinoIcons.xmark_circle_fill),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'Appears on ${track.playlistCount} playlists:',
                style: AppTypography.labelMedium,
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: track.playlistNames.length,
                itemBuilder: (context, index) {
                  final name = track.playlistNames[index];
                  return Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: AppColors.borderDepth1,
                          width: 0.5,
                        ),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          CupertinoIcons.music_albums,
                          size: 20,
                          color: AppColors.primary,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(name, style: AppTypography.bodyMedium),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
