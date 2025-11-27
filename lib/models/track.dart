import 'package:freezed_annotation/freezed_annotation.dart';

part 'track.freezed.dart';
part 'track.g.dart';

@freezed
abstract class Track with _$Track {
  const factory Track({
    required String id,
    required String name,
    required List<String> artists,
    required String album,
    @JsonKey(name: 'duration_ms') required int durationMs,
    @JsonKey(name: 'album_image_url') String? albumImageUrl,
  }) = _Track;

  factory Track.fromJson(Map<String, dynamic> json) => _$TrackFromJson(json);

  factory Track.fromSpotifyJson(Map<String, dynamic> json) {
    final track = json['track'] as Map<String, dynamic>?;
    if (track == null) {
      return Track(
        id: '',
        name: 'Unknown',
        artists: [],
        album: 'Unknown',
        durationMs: 0,
      );
    }

    final artistsList =
        (track['artists'] as List<dynamic>?)
            ?.map((a) => a['name'] as String)
            .toList() ??
        [];

    final albumData = track['album'] as Map<String, dynamic>?;
    final albumName = albumData?['name'] as String? ?? 'Unknown';
    final images = albumData?['images'] as List<dynamic>?;
    final imageUrl = images?.isNotEmpty == true
        ? images!.first['url'] as String?
        : null;

    return Track(
      id: track['id'] as String? ?? '',
      name: track['name'] as String? ?? 'Unknown',
      artists: artistsList,
      album: albumName,
      durationMs: track['duration_ms'] as int? ?? 0,
      albumImageUrl: imageUrl,
    );
  }
}

extension TrackExtensions on Track {
  String get artistsDisplay => artists.join(', ');

  Duration get duration => Duration(milliseconds: durationMs);

  String get durationDisplay {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }
}
