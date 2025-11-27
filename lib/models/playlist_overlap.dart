import 'package:freezed_annotation/freezed_annotation.dart';

part 'playlist_overlap.freezed.dart';
part 'playlist_overlap.g.dart';

@freezed
abstract class PlaylistOverlap with _$PlaylistOverlap {
  const factory PlaylistOverlap({
    required String playlistAId,
    required String playlistAName,
    required int playlistASize,
    required String playlistBId,
    required String playlistBName,
    required int playlistBSize,
    required Set<String> sharedTrackIds,
  }) = _PlaylistOverlap;

  factory PlaylistOverlap.fromJson(Map<String, dynamic> json) =>
      _$PlaylistOverlapFromJson(json);
}

extension PlaylistOverlapExtensions on PlaylistOverlap {
  int get sharedCount => sharedTrackIds.length;
  
  int get smallerPlaylistSize => 
      playlistASize < playlistBSize ? playlistASize : playlistBSize;
  
  double get overlapRatio => 
      smallerPlaylistSize > 0 ? sharedCount / smallerPlaylistSize : 0.0;
  
  String get overlapPercentDisplay => 
      '${(overlapRatio * 100).toStringAsFixed(1)}%';
}

