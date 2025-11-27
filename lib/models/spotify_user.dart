import 'package:freezed_annotation/freezed_annotation.dart';

part 'spotify_user.freezed.dart';
part 'spotify_user.g.dart';

@freezed
abstract class SpotifyUser with _$SpotifyUser {
  const factory SpotifyUser({
    required String id,
    @JsonKey(name: 'display_name') required String displayName,
    String? email,
    @JsonKey(name: 'images') @Default([]) List<SpotifyImage> images,
  }) = _SpotifyUser;

  factory SpotifyUser.fromJson(Map<String, dynamic> json) =>
      _$SpotifyUserFromJson(json);
}

@freezed
abstract class SpotifyImage with _$SpotifyImage {
  const factory SpotifyImage({
    required String url,
    int? height,
    int? width,
  }) = _SpotifyImage;

  factory SpotifyImage.fromJson(Map<String, dynamic> json) =>
      _$SpotifyImageFromJson(json);
}

extension SpotifyUserExtensions on SpotifyUser {
  String? get imageUrl => images.isNotEmpty ? images.first.url : null;
}

