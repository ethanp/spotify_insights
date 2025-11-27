import 'package:freezed_annotation/freezed_annotation.dart';

part 'top_track.freezed.dart';
part 'top_track.g.dart';

@freezed
abstract class TopTrack with _$TopTrack {
  const factory TopTrack({
    required String id,
    required String name,
    required List<String> artists,
    required String album,
    @JsonKey(name: 'album_image_url') String? albumImageUrl,
    @Default(0) int popularity,
  }) = _TopTrack;

  factory TopTrack.fromJson(Map<String, dynamic> json) =>
      _$TopTrackFromJson(json);

  factory TopTrack.fromSpotifyJson(Map<String, dynamic> json) {
    final artistsList = (json['artists'] as List<dynamic>?)
        ?.map((a) => a['name'] as String)
        .toList() ?? [];

    final albumData = json['album'] as Map<String, dynamic>?;
    final albumName = albumData?['name'] as String? ?? 'Unknown';
    final images = albumData?['images'] as List<dynamic>?;
    final imageUrl = images?.isNotEmpty == true
        ? images!.first['url'] as String?
        : null;

    return TopTrack(
      id: json['id'] as String,
      name: json['name'] as String,
      artists: artistsList,
      album: albumName,
      albumImageUrl: imageUrl,
      popularity: json['popularity'] as int? ?? 0,
    );
  }
}

extension TopTrackExtensions on TopTrack {
  String get artistsDisplay => artists.join(', ');
}

