import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:spotify_insights/models/analytics_snapshot.dart';
import 'package:spotify_insights/models/playlist_overlap.dart';
import 'package:spotify_insights/providers/playlists_provider.dart';
import 'package:spotify_insights/services/analytics_engine.dart';

part 'analytics_provider.g.dart';

@riverpod
AnalyticsEngine analyticsEngine(Ref ref) {
  return AnalyticsEngine();
}

@riverpod
Future<AnalyticsSnapshot> analytics(Ref ref) async {
  final playlists = await ref.watch(playlistsNotifierProvider.future);
  if (playlists.isEmpty) return AnalyticsSnapshot.empty;
  
  final engine = ref.watch(analyticsEngineProvider);
  return engine.computeAll(playlists);
}

@riverpod
Future<List<TrackFrequency>> mostCommonTracks(Ref ref) async {
  final analytics = await ref.watch(analyticsProvider.future);
  return analytics.mostCommonTracks;
}

@riverpod
Future<List<PlaylistSize>> longestPlaylists(Ref ref) async {
  final analytics = await ref.watch(analyticsProvider.future);
  return analytics.longestPlaylists;
}

@riverpod
Future<List<MonthlyAdditions>> additionsTimeline(Ref ref) async {
  final analytics = await ref.watch(analyticsProvider.future);
  return analytics.additionsTimeline;
}

@riverpod
Future<List<PlaylistOverlapView>> topOverlaps(Ref ref) async {
  final analytics = await ref.watch(analyticsProvider.future);
  return analytics.topOverlaps.map((o) => PlaylistOverlapView(
    playlistAName: o.playlistAName,
    playlistBName: o.playlistBName,
    sharedCount: o.sharedCount,
    overlapPercent: o.overlapRatio * 100,
    smallerPlaylistSize: o.smallerPlaylistSize,
  )).toList();
}

class PlaylistOverlapView {
  final String playlistAName;
  final String playlistBName;
  final int sharedCount;
  final double overlapPercent;
  final int smallerPlaylistSize;

  const PlaylistOverlapView({
    required this.playlistAName,
    required this.playlistBName,
    required this.sharedCount,
    required this.overlapPercent,
    required this.smallerPlaylistSize,
  });

  String get overlapDisplay => '${overlapPercent.toStringAsFixed(1)}%';
}

