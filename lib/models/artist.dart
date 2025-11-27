import 'package:freezed_annotation/freezed_annotation.dart';

part 'artist.freezed.dart';
part 'artist.g.dart';

@freezed
abstract class Artist with _$Artist {
  const factory Artist({
    required String id,
    required String name,
    @Default([]) List<String> genres,
    @JsonKey(name: 'image_url') String? imageUrl,
    @Default(0) int popularity,
  }) = _Artist;

  factory Artist.fromJson(Map<String, dynamic> json) => _$ArtistFromJson(json);

  factory Artist.fromSpotifyJson(Map<String, dynamic> json) {
    final images = json['images'] as List<dynamic>?;
    final imageUrl = images?.isNotEmpty == true
        ? images!.first['url'] as String?
        : null;

    return Artist(
      id: json['id'] as String,
      name: json['name'] as String,
      genres: (json['genres'] as List<dynamic>?)
          ?.map((g) => g as String)
          .toList() ?? [],
      imageUrl: imageUrl,
      popularity: json['popularity'] as int? ?? 0,
    );
  }
}

extension ArtistExtensions on Artist {
  String get genresDisplay => genres.take(3).join(', ');
}

