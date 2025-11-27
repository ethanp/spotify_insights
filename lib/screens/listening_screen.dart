import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' show Divider;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spotify_insights/models/artist.dart';
import 'package:spotify_insights/models/top_track.dart';
import 'package:spotify_insights/providers/listening_provider.dart';
import 'package:spotify_insights/theme/app_theme.dart';
import 'package:spotify_insights/widgets/async_data_builder.dart';

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

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: AppSpacing.m),
      child: Container(
        decoration: AppComponents.card,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.all(AppSpacing.m),
              child: Text('Your Top Genres', style: AppTypography.headlineSmall),
            ),
            AsyncDataBuilder<List<GenreCount>>(
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
                  padding: EdgeInsets.fromLTRB(AppSpacing.m, 0, AppSpacing.m, AppSpacing.m),
                  child: Column(
                    children: genres.map((g) => _genreBar(g)).toList(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _genreBar(GenreCount genre) {
    return Padding(
      padding: EdgeInsets.only(bottom: AppSpacing.s),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  genre.genre,
                  style: AppTypography.labelMedium,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Text(
                '${genre.count}',
                style: AppTypography.caption,
              ),
            ],
          ),
          SizedBox(height: AppSpacing.xs),
          Stack(
            children: [
              Container(
                height: 6,
                decoration: BoxDecoration(
                  color: AppColors.backgroundDepth3,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
              AnimatedFractionallySizedBox(
                duration: AppAnimation.medium,
                curve: AppAnimation.curve,
                widthFactor: genre.fraction,
                child: Container(
                  height: 6,
                  decoration: BoxDecoration(
                    gradient: AppComponents.primaryGradient,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _topArtistsSection(WidgetRef ref) {
    final artistsAsync = ref.watch(topArtistsProvider);

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: AppSpacing.m),
      child: Container(
        decoration: AppComponents.card,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.all(AppSpacing.m),
              child: Text('Your Top Artists', style: AppTypography.headlineSmall),
            ),
            AsyncDataBuilder<List<Artist>>(
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
                  separatorBuilder: (_, __) => Divider(
                    height: 1,
                    color: AppColors.borderDepth1,
                  ),
                  itemBuilder: (context, index) => _artistRow(artists[index], index + 1),
                );
              },
            ),
            SizedBox(height: AppSpacing.s),
          ],
        ),
      ),
    );
  }

  Widget _artistRow(Artist artist, int rank) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: AppSpacing.m, vertical: AppSpacing.s + 4),
      child: Row(
        children: [
          SizedBox(
            width: 28,
            child: Text(
              '$rank',
              style: AppTypography.labelMedium.copyWith(color: AppColors.textColor3),
            ),
          ),
          _artistImage(artist.imageUrl),
          SizedBox(width: AppSpacing.s + 4),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  artist.name,
                  style: AppTypography.bodyMedium,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (artist.genres.isNotEmpty)
                  Text(
                    artist.genresDisplay,
                    style: AppTypography.caption,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _artistImage(String? imageUrl) {
    return ClipOval(
      child: Container(
        width: 48,
        height: 48,
        color: AppColors.backgroundDepth3,
        child: imageUrl != null
            ? Image.network(
                imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => _placeholderIcon(CupertinoIcons.person_fill),
              )
            : _placeholderIcon(CupertinoIcons.person_fill),
      ),
    );
  }

  Widget _topTracksSection(WidgetRef ref) {
    final tracksAsync = ref.watch(topTracksProvider);

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: AppSpacing.m),
      child: Container(
        decoration: AppComponents.card,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.all(AppSpacing.m),
              child: Text('Your Top Tracks', style: AppTypography.headlineSmall),
            ),
            AsyncDataBuilder<List<TopTrack>>(
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
                  separatorBuilder: (_, __) => Divider(
                    height: 1,
                    color: AppColors.borderDepth1,
                  ),
                  itemBuilder: (context, index) => _trackRow(tracks[index], index + 1),
                );
              },
            ),
            SizedBox(height: AppSpacing.s),
          ],
        ),
      ),
    );
  }

  Widget _trackRow(TopTrack track, int rank) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: AppSpacing.m, vertical: AppSpacing.s + 4),
      child: Row(
        children: [
          SizedBox(
            width: 28,
            child: Text(
              '$rank',
              style: AppTypography.labelMedium.copyWith(color: AppColors.textColor3),
            ),
          ),
          _albumImage(track.albumImageUrl),
          SizedBox(width: AppSpacing.s + 4),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  track.name,
                  style: AppTypography.bodyMedium,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  '${track.artistsDisplay} • ${track.album}',
                  style: AppTypography.caption,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _albumImage(String? imageUrl) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(4),
      child: Container(
        width: 48,
        height: 48,
        color: AppColors.backgroundDepth3,
        child: imageUrl != null
            ? Image.network(
                imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => _placeholderIcon(CupertinoIcons.music_note),
              )
            : _placeholderIcon(CupertinoIcons.music_note),
      ),
    );
  }

  Widget _placeholderIcon(IconData icon) {
    return Center(
      child: Icon(icon, size: 24, color: AppColors.textColor3),
    );
  }
}

class AnimatedFractionallySizedBox extends ImplicitlyAnimatedWidget {
  final double widthFactor;
  final Widget child;

  const AnimatedFractionallySizedBox({
    super.key,
    required this.widthFactor,
    required this.child,
    required super.duration,
    super.curve,
  });

  @override
  AnimatedFractionallySizedBoxState createState() => AnimatedFractionallySizedBoxState();
}

class AnimatedFractionallySizedBoxState extends AnimatedWidgetBaseState<AnimatedFractionallySizedBox> {
  Tween<double>? _widthFactor;

  @override
  void forEachTween(TweenVisitor<dynamic> visitor) {
    _widthFactor = visitor(
      _widthFactor,
      widget.widthFactor,
      (value) => Tween<double>(begin: value as double),
    ) as Tween<double>?;
  }

  @override
  Widget build(BuildContext context) {
    return FractionallySizedBox(
      alignment: Alignment.centerLeft,
      widthFactor: _widthFactor?.evaluate(animation) ?? widget.widthFactor,
      child: widget.child,
    );
  }
}

