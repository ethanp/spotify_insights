import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' show Divider;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spotify_insights/models/artist.dart';
import 'package:spotify_insights/models/top_track.dart';
import 'package:spotify_insights/providers/listening_provider.dart';
import 'package:spotify_insights/theme/app_theme.dart';
import 'package:spotify_insights/widgets/async_data_builder.dart';
import 'package:spotify_insights/widgets/media_row.dart';
import 'package:spotify_insights/widgets/progress_bar.dart';
import 'package:spotify_insights/widgets/section_card.dart';

class ListeningScreen extends ConsumerWidget {
  const ListeningScreen();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedRange = ref.watch(selectedTimeRangeProvider);

    return CupertinoPageScaffold(
      backgroundColor: AppColors.backgroundDepth1,
      navigationBar: CupertinoNavigationBar(
        middle: Text('Listening', style: AppTypography.navTitle),
        backgroundColor: AppColors.backgroundDepth1.withValues(alpha: 0.9),
        border: null,
      ),
      child: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(child: SizedBox(height: AppSpacing.m)),
            SliverToBoxAdapter(child: _timeRangeSelector(ref, selectedRange)),
            SliverToBoxAdapter(child: SizedBox(height: AppSpacing.l)),
            SliverToBoxAdapter(child: _genreBreakdownSection(ref)),
            SliverToBoxAdapter(child: SizedBox(height: AppSpacing.l)),
            SliverToBoxAdapter(child: _topArtistsSection(ref)),
            SliverToBoxAdapter(child: SizedBox(height: AppSpacing.l)),
            SliverToBoxAdapter(child: _topTracksSection(ref)),
            SliverToBoxAdapter(child: SizedBox(height: AppSpacing.xxl)),
          ],
        ),
      ),
    );
  }

  Widget _timeRangeSelector(WidgetRef ref, TimeRange selected) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: AppSpacing.m),
      child: CupertinoSlidingSegmentedControl<TimeRange>(
        groupValue: selected,
        backgroundColor: AppColors.backgroundDepth2,
        thumbColor: AppColors.backgroundDepth4,
        children: {
          for (final range in TimeRange.values)
            range: Padding(
              padding: EdgeInsets.symmetric(horizontal: AppSpacing.m, vertical: AppSpacing.s),
              child: Text(
                range.displayName,
                style: AppTypography.labelMedium.copyWith(
                  color: selected == range ? AppColors.textColor1 : AppColors.textColor2,
                ),
              ),
            ),
        },
        onValueChanged: (value) {
          if (value != null) {
            ref.read(selectedTimeRangeProvider.notifier).select(value);
          }
        },
      ),
    );
  }

  Widget _genreBreakdownSection(WidgetRef ref) {
    final genresAsync = ref.watch(genreBreakdownProvider);

    return SectionCard(
      title: 'Your Top Genres',
      child: AsyncDataBuilder<List<GenreCount>>(
        value: genresAsync,
        loadingMessage: 'Loading genres...',
        builder: (genres) {
          if (genres.isEmpty) {
            return Padding(
              padding: EdgeInsets.all(AppSpacing.m),
              child: Text('No genre data', style: AppTypography.bodySmall),
            );
          }
          return Padding(
            padding: EdgeInsets.fromLTRB(AppSpacing.m, 0, AppSpacing.m, AppSpacing.s),
            child: Column(
              children: genres
                  .map((g) => ProgressBar(
                        label: g.genre,
                        value: '${g.count}',
                        fraction: g.fraction,
                      ))
                  .toList(),
            ),
          );
        },
      ),
    );
  }

  Widget _topArtistsSection(WidgetRef ref) {
    final artistsAsync = ref.watch(topArtistsProvider);

    return SectionCard(
      title: 'Your Top Artists',
      child: AsyncDataBuilder<List<Artist>>(
        value: artistsAsync,
        loadingMessage: 'Loading artists...',
        builder: (artists) {
          if (artists.isEmpty) {
            return Padding(
              padding: EdgeInsets.all(AppSpacing.m),
              child: Text('No artist data', style: AppTypography.bodySmall),
            );
          }
          return ListView.separated(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: artists.take(20).length,
            separatorBuilder: (_, __) => Divider(height: 1, color: AppColors.borderDepth1),
            itemBuilder: (context, index) {
              final artist = artists[index];
              return MediaRow.artist(
                rank: index + 1,
                imageUrl: artist.imageUrl,
                title: artist.name,
                subtitle: artist.genres.isNotEmpty ? artist.genresDisplay : null,
              );
            },
          );
        },
      ),
    );
  }

  Widget _topTracksSection(WidgetRef ref) {
    final tracksAsync = ref.watch(topTracksProvider);

    return SectionCard(
      title: 'Your Top Tracks',
      child: AsyncDataBuilder<List<TopTrack>>(
        value: tracksAsync,
        loadingMessage: 'Loading tracks...',
        builder: (tracks) {
          if (tracks.isEmpty) {
            return Padding(
              padding: EdgeInsets.all(AppSpacing.m),
              child: Text('No track data', style: AppTypography.bodySmall),
            );
          }
          return ListView.separated(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: tracks.take(20).length,
            separatorBuilder: (_, __) => Divider(height: 1, color: AppColors.borderDepth1),
            itemBuilder: (context, index) {
              final track = tracks[index];
              return MediaRow.track(
                rank: index + 1,
                imageUrl: track.albumImageUrl,
                title: track.name,
                subtitle: '${track.artistsDisplay} • ${track.album}',
              );
            },
          );
        },
      ),
    );
  }
}
