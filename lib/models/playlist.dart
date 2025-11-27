import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:spotify_insights/models/playlist_track.dart';
import 'package:spotify_insights/models/spotify_user.dart';
import 'package:spotify_insights/models/track.dart';

part 'playlist.freezed.dart';
part 'playlist.g.dart';

@freezed
abstract class Playlist with _$Playlist {
  const factory Playlist({
    required String id,
    required String name,
    @Default('') String description,
    @JsonKey(name: 'snapshot_id') required String snapshotId,
    required SpotifyUser owner,
    @JsonKey(name: 'track_count') required int trackCount,
    @JsonKey(name: 'image_url') String? imageUrl,
    @Default([]) List<PlaylistTrack> tracks,
    @JsonKey(name: 'last_synced_at') DateTime? lastSyncedAt,
  }) = _Playlist;

  factory Playlist.fromJson(Map<String, dynamic> json) =>
      _$PlaylistFromJson(json);

  factory Playlist.fromSpotifyJson(Map<String, dynamic> json) {
    final ownerJson = json['owner'] as Map<String, dynamic>;
    final images = json['images'] as List<dynamic>?;
    final tracksObj = json['tracks'] as Map<String, dynamic>?;
    
    return Playlist(
      id: json['id'] as String,
      name: json['name'] as String? ?? 'Untitled',
      description: json['description'] as String? ?? '',
      snapshotId: json['snapshot_id'] as String? ?? '',
      owner: SpotifyUser(
        id: ownerJson['id'] as String,
        displayName: ownerJson['display_name'] as String? ?? 'Unknown',
      ),
      trackCount: tracksObj?['total'] as int? ?? 0,
      imageUrl: images?.isNotEmpty == true 
          ? images!.first['url'] as String? 
          : null,
    );
  }
}

extension PlaylistExtensions on Playlist {
  Duration get totalDuration => tracks.fold(
    Duration.zero,
    (sum, pt) => sum + pt.track.duration,
  );

  String get totalDurationDisplay {
    final hours = totalDuration.inHours;
    final minutes = totalDuration.inMinutes % 60;
    if (hours > 0) return '${hours}h ${minutes}m';
    return '${minutes}m';
  }

  Set<String> get trackIds => tracks.map((pt) => pt.track.id).toSet();

  bool get hasTracks => tracks.isNotEmpty;
}

