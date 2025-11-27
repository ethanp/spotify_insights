import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:spotify_insights/models/artist.dart';
import 'package:spotify_insights/models/top_track.dart';
import 'package:spotify_insights/providers/auth_provider.dart';

part 'listening_provider.g.dart';

enum TimeRange {
  shortTerm('short_term', '4 weeks'),
  mediumTerm('medium_term', '6 months'),
  longTerm('long_term', 'All time');

  final String apiValue;
  final String displayName;
  const TimeRange(this.apiValue, this.displayName);
}

@riverpod
class SelectedTimeRange extends _$SelectedTimeRange {
  @override
  TimeRange build() => TimeRange.mediumTerm;

  void select(TimeRange range) => state = range;
}

@riverpod
Future<List<Artist>> topArtists(Ref ref) async {
  final isAuth = await ref.watch(isAuthenticatedProvider.future);
  if (!isAuth) return [];

  final timeRange = ref.watch(selectedTimeRangeProvider);
  final apiClient = ref.watch(spotifyApiClientProvider);
  await ref.watch(authServiceProvider).ensureValidToken();

  final data = await apiClient.getTopArtists(timeRange.apiValue);
  return data.map((json) => Artist.fromSpotifyJson(json)).toList();
}

@riverpod
Future<List<TopTrack>> topTracks(Ref ref) async {
  final isAuth = await ref.watch(isAuthenticatedProvider.future);
  if (!isAuth) return [];

  final timeRange = ref.watch(selectedTimeRangeProvider);
  final apiClient = ref.watch(spotifyApiClientProvider);
  await ref.watch(authServiceProvider).ensureValidToken();

  final data = await apiClient.getTopTracks(timeRange.apiValue);
  return data.map((json) => TopTrack.fromSpotifyJson(json)).toList();
}

@riverpod
Future<List<GenreCount>> genreBreakdown(Ref ref) async {
  final artists = await ref.watch(topArtistsProvider.future);
  if (artists.isEmpty) return [];

  final genreCounts = <String, int>{};
  for (final artist in artists) {
    for (final genre in artist.genres) {
      genreCounts[genre] = (genreCounts[genre] ?? 0) + 1;
    }
  }

  final sorted = genreCounts.entries.toList()
    ..sort((a, b) => b.value.compareTo(a.value));

  final maxCount = sorted.isNotEmpty ? sorted.first.value : 1;

  return sorted
      .take(12)
      .map((e) => GenreCount(
            genre: e.key,
            count: e.value,
            fraction: e.value / maxCount,
          ))
      .toList();
}

class GenreCount {
  final String genre;
  final int count;
  final double fraction;

  const GenreCount({
    required this.genre,
    required this.count,
    required this.fraction,
  });
}

