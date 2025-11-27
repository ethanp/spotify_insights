import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class LocalDatabase {
  static Database? _database;

  static Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  static Future<Database> _initDatabase() async {
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, 'spotify_insights.db');

    return openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  static Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE playlists (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        description TEXT,
        snapshot_id TEXT NOT NULL,
        owner_id TEXT NOT NULL,
        owner_name TEXT NOT NULL,
        track_count INTEGER NOT NULL,
        image_url TEXT,
        last_synced_at TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE tracks (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        artists TEXT NOT NULL,
        album TEXT NOT NULL,
        duration_ms INTEGER NOT NULL,
        album_image_url TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE playlist_tracks (
        playlist_id TEXT NOT NULL,
        track_id TEXT NOT NULL,
        added_at TEXT NOT NULL,
        position INTEGER NOT NULL,
        PRIMARY KEY (playlist_id, track_id),
        FOREIGN KEY (playlist_id) REFERENCES playlists(id) ON DELETE CASCADE,
        FOREIGN KEY (track_id) REFERENCES tracks(id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE INDEX idx_playlist_tracks_playlist ON playlist_tracks(playlist_id)
    ''');
    
    await db.execute('''
      CREATE INDEX idx_playlist_tracks_track ON playlist_tracks(track_id)
    ''');

    await db.execute('''
      CREATE TABLE sync_metadata (
        key TEXT PRIMARY KEY,
        value TEXT NOT NULL
      )
    ''');
  }

  static Future<void> close() async {
    final db = _database;
    if (db != null) {
      await db.close();
      _database = null;
    }
  }
}

