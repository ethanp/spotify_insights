import 'package:spotify_insights/models/analytics_snapshot.dart';
import 'package:spotify_insights/models/playlist.dart';
import 'package:spotify_insights/models/playlist_overlap.dart';
import 'package:spotify_insights/models/track.dart';

class AnalyticsEngine {
  AnalyticsSnapshot computeAll(List<Playlist> playlists) {
    if (playlists.isEmpty) return AnalyticsSnapshot.empty;
    
    return AnalyticsSnapshot(
      mostCommonTracks: _computeTrackFrequencies(playlists),
      longestPlaylists: _computePlaylistSizes(playlists),
      additionsTimeline: _computeMonthlyAdditions(playlists),
      topOverlaps: _computeOverlaps(playlists),
    );
  }

  List<TrackFrequency> _computeTrackFrequencies(List<Playlist> playlists) {
    final trackToPlaylists = <String, _TrackInfo>{};
    
    for (final playlist in playlists) {
      for (final pt in playlist.tracks) {
        final trackId = pt.track.id;
        if (trackId.isEmpty) continue;
        
        trackToPlaylists.putIfAbsent(
          trackId,
          () => _TrackInfo(
            id: trackId,
            name: pt.track.name,
            artists: pt.track.artistsDisplay,
          ),
        ).playlistNames.add(playlist.name);
      }
    }

    final frequencies = trackToPlaylists.values
        .where((info) => info.playlistNames.length > 1)
        .map((info) => TrackFrequency(
              trackId: info.id,
              trackName: info.name,
              artists: info.artists,
              playlistCount: info.playlistNames.length,
              playlistNames: info.playlistNames.toList()..sort(),
            ))
        .toList()
      ..sort((a, b) => b.playlistCount.compareTo(a.playlistCount));

    return frequencies.take(50).toList();
  }

  List<PlaylistSize> _computePlaylistSizes(List<Playlist> playlists) {
    final sizes = playlists
        .where((p) => p.hasTracks)
        .map((p) => PlaylistSize(
              playlistId: p.id,
              playlistName: p.name,
              trackCount: p.tracks.length,
              totalDuration: p.totalDuration,
            ))
        .toList()
      ..sort((a, b) => b.trackCount.compareTo(a.trackCount));

    return sizes.take(20).toList();
  }

  List<MonthlyAdditions> _computeMonthlyAdditions(List<Playlist> playlists) {
    final monthCounts = <DateTime, int>{};
    
    for (final playlist in playlists) {
      for (final pt in playlist.tracks) {
        final month = DateTime(pt.addedAt.year, pt.addedAt.month);
        monthCounts[month] = (monthCounts[month] ?? 0) + 1;
      }
    }

    final additions = monthCounts.entries
        .map((e) => MonthlyAdditions(month: e.key, trackCount: e.value))
        .toList()
      ..sort((a, b) => a.month.compareTo(b.month));

    return additions;
  }

  List<PlaylistOverlap> _computeOverlaps(List<Playlist> playlists) {
    final playlistsWithTracks = playlists.where((p) => p.hasTracks).toList();
    final overlaps = <PlaylistOverlap>[];

    for (var i = 0; i < playlistsWithTracks.length; i++) {
      final a = playlistsWithTracks[i];
      final aIds = a.trackIds;

      for (var j = i + 1; j < playlistsWithTracks.length; j++) {
        final b = playlistsWithTracks[j];
        final bIds = b.trackIds;
        final shared = aIds.intersection(bIds);

        if (shared.isNotEmpty) {
          overlaps.add(PlaylistOverlap(
            playlistAId: a.id,
            playlistAName: a.name,
            playlistASize: a.tracks.length,
            playlistBId: b.id,
            playlistBName: b.name,
            playlistBSize: b.tracks.length,
            sharedTrackIds: shared,
          ));
        }
      }
    }

    overlaps.sort((a, b) => b.overlapRatio.compareTo(a.overlapRatio));
    return overlaps.take(30).toList();
  }
}

class _TrackInfo {
  final String id;
  final String name;
  final String artists;
  final Set<String> playlistNames = {};

  _TrackInfo({required this.id, required this.name, required this.artists});
}

