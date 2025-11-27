import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:spotify_insights/models/track.dart';

part 'playlist_track.freezed.dart';
part 'playlist_track.g.dart';

@freezed
abstract class PlaylistTrack with _$PlaylistTrack {
  const factory PlaylistTrack({
    required Track track,
    @JsonKey(name: 'added_at') required DateTime addedAt,
    @Default(0) int position,
  }) = _PlaylistTrack;

  factory PlaylistTrack.fromJson(Map<String, dynamic> json) =>
      _$PlaylistTrackFromJson(json);

  factory PlaylistTrack.fromSpotifyJson(Map<String, dynamic> json, int position) {
    final addedAtStr = json['added_at'] as String?;
    final addedAt = addedAtStr != null 
        ? DateTime.tryParse(addedAtStr) ?? DateTime.now()
        : DateTime.now();
    
    return PlaylistTrack(
      track: Track.fromSpotifyJson(json),
      addedAt: addedAt,
      position: position,
    );
  }
}

