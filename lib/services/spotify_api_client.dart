import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:http/http.dart' as http;
import 'package:spotify_insights/models/playlist.dart';
import 'package:spotify_insights/models/playlist_track.dart';
import 'package:spotify_insights/models/spotify_user.dart';

class SpotifyApiClient {
  static const _baseUrl = 'https://api.spotify.com/v1';
  static const _authUrl = 'https://accounts.spotify.com';
  static const _scopes = [
    'playlist-read-private',
    'playlist-read-collaborative',
    'user-read-private',
    'user-read-email',
    'user-top-read',
  ];

  final String clientId;
  String? _accessToken;

  SpotifyApiClient({required this.clientId});

  void setAccessToken(String token) => _accessToken = token;

  Uri buildAuthorizationUrl({
    required String codeVerifier,
    required String redirectUri,
  }) {
    final codeChallenge = generateCodeChallenge(codeVerifier);
    return Uri.parse('$_authUrl/authorize').replace(
      queryParameters: {
        'client_id': clientId,
        'response_type': 'code',
        'redirect_uri': redirectUri,
        'scope': _scopes.join(' '),
        'code_challenge_method': 'S256',
        'code_challenge': codeChallenge,
      },
    );
  }

  String generateCodeChallenge(String verifier) =>
      base64Url.encode(sha256.convert(utf8.encode(verifier)).bytes).replaceAll('=', '');

  Future<Map<String, dynamic>> exchangeCodeForTokens({
    required String code,
    required String codeVerifier,
    required String redirectUri,
  }) async {
    final response = await http.post(
      Uri.parse('$_authUrl/api/token'),
      headers: {'Content-Type': 'application/x-www-form-urlencoded'},
      body: {
        'grant_type': 'authorization_code',
        'code': code,
        'redirect_uri': redirectUri,
        'client_id': clientId,
        'code_verifier': codeVerifier,
      },
    );
    if (response.statusCode != 200) {
      throw SpotifyApiException('Token exchange failed: ${response.body}');
    }
    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> refreshAccessToken(String refreshToken) async {
    final response = await http.post(
      Uri.parse('$_authUrl/api/token'),
      headers: {'Content-Type': 'application/x-www-form-urlencoded'},
      body: {
        'grant_type': 'refresh_token',
        'refresh_token': refreshToken,
        'client_id': clientId,
      },
    );
    if (response.statusCode != 200) {
      throw SpotifyApiException('Token refresh failed: ${response.body}');
    }
    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  Future<SpotifyUser> getCurrentUser() async {
    final data = await _get('/me');
    return SpotifyUser.fromJson(data);
  }

  Future<List<Playlist>> getAllPlaylists() async {
    final playlists = <Playlist>[];
    String? nextUrl = '$_baseUrl/me/playlists?limit=50';

    while (nextUrl != null) {
      final response = await _getUrl(nextUrl);
      final items = response['items'] as List<dynamic>;
      playlists.addAll(
        items.map(
          (item) => Playlist.fromSpotifyJson(item as Map<String, dynamic>),
        ),
      );
      nextUrl = response['next'] as String?;
    }
    return playlists;
  }

  Future<List<PlaylistTrack>> getPlaylistTracks(String playlistId) async {
    final tracks = <PlaylistTrack>[];
    String? nextUrl = '$_baseUrl/playlists/$playlistId/tracks?limit=100';
    var position = 0;

    while (nextUrl != null) {
      final response = await _getUrl(nextUrl);
      final items = response['items'] as List<dynamic>;
      for (final item in items) {
        if (item['track'] != null) {
          tracks.add(
            PlaylistTrack.fromSpotifyJson(
              item as Map<String, dynamic>,
              position++,
            ),
          );
        }
      }
      nextUrl = response['next'] as String?;
    }
    return tracks;
  }

  Future<List<Map<String, dynamic>>> getTopArtists(String timeRange) async {
    final data = await _get('/me/top/artists?time_range=$timeRange&limit=50');
    return (data['items'] as List<dynamic>).cast<Map<String, dynamic>>();
  }

  Future<List<Map<String, dynamic>>> getTopTracks(String timeRange) async {
    final data = await _get('/me/top/tracks?time_range=$timeRange&limit=50');
    return (data['items'] as List<dynamic>).cast<Map<String, dynamic>>();
  }

  Future<Map<String, dynamic>> _get(String endpoint) async {
    return _getUrl('$_baseUrl$endpoint');
  }

  Future<Map<String, dynamic>> _getUrl(String url) async {
    if (_accessToken == null) {
      throw SpotifyApiException('No access token set');
    }
    final response = await http.get(
      Uri.parse(url),
      headers: {'Authorization': 'Bearer $_accessToken'},
    );
    if (response.statusCode == 401) {
      throw SpotifyApiException('Unauthorized - token may be expired');
    }
    if (response.statusCode == 429) {
      final retryAfter =
          int.tryParse(response.headers['retry-after'] ?? '1') ?? 1;
      await Future.delayed(Duration(seconds: retryAfter));
      return _getUrl(url);
    }
    if (response.statusCode != 200) {
      throw SpotifyApiException(
        'API error ${response.statusCode}: ${response.body}',
      );
    }
    return jsonDecode(response.body) as Map<String, dynamic>;
  }
}

class SpotifyApiException implements Exception {
  final String message;
  SpotifyApiException(this.message);
  @override
  String toString() => 'SpotifyApiException: $message';
}
