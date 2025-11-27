import 'package:spotify_insights/models/playlist_overlap.dart';

class AnalyticsSnapshot {
  final List<TrackFrequency> mostCommonTracks;
  final List<PlaylistSize> longestPlaylists;
  final List<MonthlyAdditions> additionsTimeline;
  final List<PlaylistOverlap> topOverlaps;

  const AnalyticsSnapshot({
    required this.mostCommonTracks,
    required this.longestPlaylists,
    required this.additionsTimeline,
    required this.topOverlaps,
  });

  static const empty = AnalyticsSnapshot(
    mostCommonTracks: [],
    longestPlaylists: [],
    additionsTimeline: [],
    topOverlaps: [],
  );

  bool get isEmpty =>
      mostCommonTracks.isEmpty &&
      longestPlaylists.isEmpty &&
      additionsTimeline.isEmpty &&
      topOverlaps.isEmpty;
}

class TrackFrequency {
  final String trackId;
  final String trackName;
  final String artists;
  final int playlistCount;
  final List<String> playlistNames;

  const TrackFrequency({
    required this.trackId,
    required this.trackName,
    required this.artists,
    required this.playlistCount,
    required this.playlistNames,
  });
}

class PlaylistSize {
  final String playlistId;
  final String playlistName;
  final int trackCount;
  final Duration totalDuration;

  const PlaylistSize({
    required this.playlistId,
    required this.playlistName,
    required this.trackCount,
    required this.totalDuration,
  });

  String get durationDisplay {
    final hours = totalDuration.inHours;
    final minutes = totalDuration.inMinutes % 60;
    if (hours > 0) return '${hours}h ${minutes}m';
    return '${minutes}m';
  }
}

class MonthlyAdditions {
  final DateTime month;
  final int trackCount;

  const MonthlyAdditions({
    required this.month,
    required this.trackCount,
  });

  String get monthLabel {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${months[month.month - 1]} ${month.year}';
  }
}

