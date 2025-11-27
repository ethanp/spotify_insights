import 'dart:convert';
import 'package:sqflite/sqflite.dart';
import 'package:spotify_insights/models/playlist.dart';
import 'package:spotify_insights/models/playlist_track.dart';
import 'package:spotify_insights/models/spotify_user.dart';
import 'package:spotify_insights/models/track.dart';
import 'package:spotify_insights/services/local_database.dart';

class PlaylistDao {
  Future<Database> get _db => LocalDatabase.database;

  Future<void> upsertPlaylist(Playlist playlist) async {
    final db = await _db;
    await db.insert('playlists', {
      'id': playlist.id,
      'name': playlist.name,
      'description': playlist.description,
      'snapshot_id': playlist.snapshotId,
      'owner_id': playlist.owner.id,
      'owner_name': playlist.owner.displayName,
      'track_count': playlist.trackCount,
      'image_url': playlist.imageUrl,
      'last_synced_at': playlist.lastSyncedAt?.toIso8601String(),
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> upsertPlaylistWithTracks(Playlist playlist) async {
    final db = await _db;
    await db.transaction((txn) async {
      await txn.insert('playlists', {
        'id': playlist.id,
        'name': playlist.name,
        'description': playlist.description,
        'snapshot_id': playlist.snapshotId,
        'owner_id': playlist.owner.id,
        'owner_name': playlist.owner.displayName,
        'track_count': playlist.tracks.length,
        'image_url': playlist.imageUrl,
        'last_synced_at': DateTime.now().toIso8601String(),
      }, conflictAlgorithm: ConflictAlgorithm.replace);

      await txn.delete(
        'playlist_tracks',
        where: 'playlist_id = ?',
        whereArgs: [playlist.id],
      );

      for (final pt in playlist.tracks) {
        await txn.insert('tracks', {
          'id': pt.track.id,
          'name': pt.track.name,
          'artists': jsonEncode(pt.track.artists),
          'album': pt.track.album,
          'duration_ms': pt.track.durationMs,
          'album_image_url': pt.track.albumImageUrl,
        }, conflictAlgorithm: ConflictAlgorithm.replace);

        await txn.insert('playlist_tracks', {
          'playlist_id': playlist.id,
          'track_id': pt.track.id,
          'added_at': pt.addedAt.toIso8601String(),
          'position': pt.position,
        }, conflictAlgorithm: ConflictAlgorithm.replace);
      }
    });
  }

  Future<List<Playlist>> getAllPlaylists() async {
    final db = await _db;
    final rows = await db.query('playlists', orderBy: 'name COLLATE NOCASE');
    return rows.map(_playlistFromRow).toList();
  }

  Future<Playlist?> getPlaylistWithTracks(String playlistId) async {
    final db = await _db;
    final playlistRows = await db.query(
      'playlists',
      where: 'id = ?',
      whereArgs: [playlistId],
    );
    if (playlistRows.isEmpty) return null;

    final playlist = _playlistFromRow(playlistRows.first);

    final trackRows = await db.rawQuery(
      '''
      SELECT t.*, pt.added_at, pt.position
      FROM tracks t
      JOIN playlist_tracks pt ON t.id = pt.track_id
      WHERE pt.playlist_id = ?
      ORDER BY pt.position
    ''',
      [playlistId],
    );

    final tracks = trackRows.map((row) {
      final artistsJson = row['artists'] as String;
      final artists = (jsonDecode(artistsJson) as List<dynamic>)
          .map((e) => e as String)
          .toList();

      return PlaylistTrack(
        track: Track(
          id: row['id'] as String,
          name: row['name'] as String,
          artists: artists,
          album: row['album'] as String,
          durationMs: row['duration_ms'] as int,
          albumImageUrl: row['album_image_url'] as String?,
        ),
        addedAt: DateTime.parse(row['added_at'] as String),
        position: row['position'] as int,
      );
    }).toList();

    return playlist.copyWith(tracks: tracks);
  }

  Future<List<Playlist>> getAllPlaylistsWithTracks() async {
    final playlists = await getAllPlaylists();
    final result = <Playlist>[];
    for (final p in playlists) {
      final withTracks = await getPlaylistWithTracks(p.id);
      if (withTracks != null) result.add(withTracks);
    }
    return result;
  }

  Future<void> deletePlaylist(String playlistId) async {
    final db = await _db;
    await db.delete('playlists', where: 'id = ?', whereArgs: [playlistId]);
  }

  Future<void> clearAll() async {
    final db = await _db;
    await db.transaction((txn) async {
      await txn.delete('playlist_tracks');
      await txn.delete('tracks');
      await txn.delete('playlists');
    });
  }

  Future<DateTime?> getLastSyncTime() async {
    final db = await _db;
    final rows = await db.query(
      'sync_metadata',
      where: 'key = ?',
      whereArgs: ['last_full_sync'],
    );
    if (rows.isEmpty) return null;
    return DateTime.tryParse(rows.first['value'] as String);
  }

  Future<void> setLastSyncTime(DateTime time) async {
    final db = await _db;
    await db.insert('sync_metadata', {
      'key': 'last_full_sync',
      'value': time.toIso8601String(),
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Playlist _playlistFromRow(Map<String, dynamic> row) {
    return Playlist(
      id: row['id'] as String,
      name: row['name'] as String,
      description: row['description'] as String? ?? '',
      snapshotId: row['snapshot_id'] as String,
      owner: SpotifyUser(
        id: row['owner_id'] as String,
        displayName: row['owner_name'] as String,
      ),
      trackCount: row['track_count'] as int,
      imageUrl: row['image_url'] as String?,
      lastSyncedAt: row['last_synced_at'] != null
          ? DateTime.tryParse(row['last_synced_at'] as String)
          : null,
    );
  }
}
