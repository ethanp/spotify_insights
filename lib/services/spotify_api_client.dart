import 'dart:convert';
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
    final codeChallenge = _generateCodeChallenge(codeVerifier);
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

  String _generateCodeChallenge(String verifier) {
    final bytes = utf8.encode(verifier);
    final digest = _sha256(bytes);
    return base64Url.encode(digest).replaceAll('=', '');
  }

  List<int> _sha256(List<int> input) {
    const k = [
      0x428a2f98,
      0x71374491,
      0xb5c0fbcf,
      0xe9b5dba5,
      0x3956c25b,
      0x59f111f1,
      0x923f82a4,
      0xab1c5ed5,
      0xd807aa98,
      0x12835b01,
      0x243185be,
      0x550c7dc3,
      0x72be5d74,
      0x80deb1fe,
      0x9bdc06a7,
      0xc19bf174,
      0xe49b69c1,
      0xefbe4786,
      0x0fc19dc6,
      0x240ca1cc,
      0x2de92c6f,
      0x4a7484aa,
      0x5cb0a9dc,
      0x76f988da,
      0x983e5152,
      0xa831c66d,
      0xb00327c8,
      0xbf597fc7,
      0xc6e00bf3,
      0xd5a79147,
      0x06ca6351,
      0x14292967,
      0x27b70a85,
      0x2e1b2138,
      0x4d2c6dfc,
      0x53380d13,
      0x650a7354,
      0x766a0abb,
      0x81c2c92e,
      0x92722c85,
      0xa2bfe8a1,
      0xa81a664b,
      0xc24b8b70,
      0xc76c51a3,
      0xd192e819,
      0xd6990624,
      0xf40e3585,
      0x106aa070,
      0x19a4c116,
      0x1e376c08,
      0x2748774c,
      0x34b0bcb5,
      0x391c0cb3,
      0x4ed8aa4a,
      0x5b9cca4f,
      0x682e6ff3,
      0x748f82ee,
      0x78a5636f,
      0x84c87814,
      0x8cc70208,
      0x90befffa,
      0xa4506ceb,
      0xbef9a3f7,
      0xc67178f2,
    ];
    var h0 = 0x6a09e667, h1 = 0xbb67ae85, h2 = 0x3c6ef372, h3 = 0xa54ff53a;
    var h4 = 0x510e527f, h5 = 0x9b05688c, h6 = 0x1f83d9ab, h7 = 0x5be0cd19;
    final ml = input.length * 8;
    final padded = [...input, 0x80];
    while ((padded.length + 8) % 64 != 0) padded.add(0);
    for (var i = 56; i >= 0; i -= 8) padded.add((ml >> i) & 0xff);
    for (var chunk = 0; chunk < padded.length; chunk += 64) {
      final w = List<int>.filled(64, 0);
      for (var i = 0; i < 16; i++) {
        w[i] =
            (padded[chunk + i * 4] << 24) |
            (padded[chunk + i * 4 + 1] << 16) |
            (padded[chunk + i * 4 + 2] << 8) |
            padded[chunk + i * 4 + 3];
      }
      for (var i = 16; i < 64; i++) {
        final s0 =
            _rotr(w[i - 15], 7) ^ _rotr(w[i - 15], 18) ^ (w[i - 15] >>> 3);
        final s1 =
            _rotr(w[i - 2], 17) ^ _rotr(w[i - 2], 19) ^ (w[i - 2] >>> 10);
        w[i] = (w[i - 16] + s0 + w[i - 7] + s1) & 0xffffffff;
      }
      var a = h0, b = h1, c = h2, d = h3, e = h4, f = h5, g = h6, h = h7;
      for (var i = 0; i < 64; i++) {
        final s1 = _rotr(e, 6) ^ _rotr(e, 11) ^ _rotr(e, 25);
        final ch = (e & f) ^ ((~e) & g);
        final t1 = (h + s1 + ch + k[i] + w[i]) & 0xffffffff;
        final s0 = _rotr(a, 2) ^ _rotr(a, 13) ^ _rotr(a, 22);
        final maj = (a & b) ^ (a & c) ^ (b & c);
        final t2 = (s0 + maj) & 0xffffffff;
        h = g;
        g = f;
        f = e;
        e = (d + t1) & 0xffffffff;
        d = c;
        c = b;
        b = a;
        a = (t1 + t2) & 0xffffffff;
      }
      h0 = (h0 + a) & 0xffffffff;
      h1 = (h1 + b) & 0xffffffff;
      h2 = (h2 + c) & 0xffffffff;
      h3 = (h3 + d) & 0xffffffff;
      h4 = (h4 + e) & 0xffffffff;
      h5 = (h5 + f) & 0xffffffff;
      h6 = (h6 + g) & 0xffffffff;
      h7 = (h7 + h) & 0xffffffff;
    }
    final result = <int>[];
    for (final val in [h0, h1, h2, h3, h4, h5, h6, h7]) {
      result.addAll([
        (val >> 24) & 0xff,
        (val >> 16) & 0xff,
        (val >> 8) & 0xff,
        val & 0xff,
      ]);
    }
    return result;
  }

  int _rotr(int x, int n) => ((x >>> n) | (x << (32 - n))) & 0xffffffff;

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
