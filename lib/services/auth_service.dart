import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'package:url_launcher/url_launcher.dart';
import 'package:spotify_insights/services/spotify_api_client.dart';
import 'package:spotify_insights/services/token_storage.dart';

enum AuthState { unknown, authenticated, unauthenticated }

class AuthService {
  final SpotifyApiClient _apiClient;
  final TokenStorage _tokenStorage;

  String? _pendingCodeVerifier;
  HttpServer? _callbackServer;
  final _authStateController = StreamController<AuthState>.broadcast();

  AuthService({
    required SpotifyApiClient apiClient,
    required TokenStorage tokenStorage,
  })  : _apiClient = apiClient,
        _tokenStorage = tokenStorage;

  Stream<AuthState> get authStateStream => _authStateController.stream;

  Future<AuthState> checkAuthState() async {
    if (await _tokenStorage.hasValidToken) {
      final token = await _tokenStorage.accessToken;
      if (token != null) {
        _apiClient.setAccessToken(token);
        _authStateController.add(AuthState.authenticated);
        return AuthState.authenticated;
      }
    }

    if (await _tokenStorage.needsRefresh) {
      final refreshed = await _tryRefreshToken();
      if (refreshed) {
        _authStateController.add(AuthState.authenticated);
        return AuthState.authenticated;
      }
    }

    _authStateController.add(AuthState.unauthenticated);
    return AuthState.unauthenticated;
  }

  static const _callbackPort = 8888;
  static const _redirectUri = 'http://localhost:$_callbackPort/callback';

  Future<bool> startAuthFlow() async {
    _pendingCodeVerifier = _generateCodeVerifier();

    try {
      _callbackServer = await HttpServer.bind(
        InternetAddress.loopbackIPv4,
        _callbackPort,
      );
    } catch (e) {
      throw AuthException(
        'Could not start callback server on port $_callbackPort. '
        'Is another instance running?',
      );
    }
    final redirectUri = _redirectUri;

    final authUrl = _apiClient.buildAuthorizationUrl(
      codeVerifier: _pendingCodeVerifier!,
      redirectUri: redirectUri,
    );

    if (!await canLaunchUrl(authUrl)) {
      await _callbackServer?.close();
      throw AuthException('Could not launch authorization URL');
    }

    await launchUrl(authUrl, mode: LaunchMode.externalApplication);

    try {
      await for (final request in _callbackServer!) {
        if (request.uri.path == '/callback') {
          final code = request.uri.queryParameters['code'];
          final error = request.uri.queryParameters['error'];

          if (error != null) {
            request.response
              ..statusCode = 200
              ..headers.contentType = ContentType.html
              ..write(_errorHtml(error))
              ..close();
            await _callbackServer?.close();
            throw AuthException('Authorization failed: $error');
          }

          if (code != null) {
            try {
              final tokens = await _apiClient.exchangeCodeForTokens(
                code: code,
                codeVerifier: _pendingCodeVerifier!,
                redirectUri: redirectUri,
              );
              await _saveTokens(tokens);

              request.response
                ..statusCode = 200
                ..headers.contentType = ContentType.html
                ..write(_successHtml())
                ..close();

              await _callbackServer?.close();
              _pendingCodeVerifier = null;
              _authStateController.add(AuthState.authenticated);
              return true;
            } catch (e) {
              request.response
                ..statusCode = 200
                ..headers.contentType = ContentType.html
                ..write(_errorHtml('Token exchange failed: $e'))
                ..close();
              await _callbackServer?.close();
              throw AuthException('Token exchange failed: $e');
            }
          }
        }
        request.response
          ..statusCode = 404
          ..close();
      }
    } catch (e) {
      await _callbackServer?.close();
      if (e is AuthException) rethrow;
      throw AuthException('Auth flow error: $e');
    }

    return false;
  }

  String _successHtml() => '''
<!DOCTYPE html>
<html>
<head>
  <title>Spotify Insights</title>
  <style>
    body { 
      font-family: -apple-system, system-ui, sans-serif;
      background: #121212; color: #fff;
      display: flex; justify-content: center; align-items: center;
      height: 100vh; margin: 0;
    }
    .container { text-align: center; }
    h1 { color: #1DB954; }
  </style>
</head>
<body>
  <div class="container">
    <h1>✓ Success!</h1>
    <p>You can close this window and return to Spotify Insights.</p>
  </div>
</body>
</html>
''';

  String _errorHtml(String error) => '''
<!DOCTYPE html>
<html>
<head>
  <title>Spotify Insights - Error</title>
  <style>
    body { 
      font-family: -apple-system, system-ui, sans-serif;
      background: #121212; color: #fff;
      display: flex; justify-content: center; align-items: center;
      height: 100vh; margin: 0;
    }
    .container { text-align: center; }
    h1 { color: #E57373; }
  </style>
</head>
<body>
  <div class="container">
    <h1>Error</h1>
    <p>$error</p>
    <p>Please close this window and try again.</p>
  </div>
</body>
</html>
''';

  Future<void> signOut() async {
    await _tokenStorage.clear();
    _authStateController.add(AuthState.unauthenticated);
  }

  Future<bool> ensureValidToken() async {
    if (await _tokenStorage.hasValidToken) {
      final token = await _tokenStorage.accessToken;
      if (token != null) {
        _apiClient.setAccessToken(token);
        return true;
      }
    }

    if (await _tokenStorage.needsRefresh) {
      return _tryRefreshToken();
    }

    return false;
  }

  Future<bool> _tryRefreshToken() async {
    final refreshToken = await _tokenStorage.refreshToken;
    if (refreshToken == null) return false;

    try {
      final tokens = await _apiClient.refreshAccessToken(refreshToken);
      await _saveTokens(tokens);
      return true;
    } catch (e) {
      await _tokenStorage.clear();
      return false;
    }
  }

  Future<void> _saveTokens(Map<String, dynamic> tokens) async {
    final accessToken = tokens['access_token'] as String;
    final refreshToken =
        tokens['refresh_token'] as String? ??
        await _tokenStorage.refreshToken ??
        '';
    final expiresIn = tokens['expires_in'] as int;
    final expiresAt = DateTime.now().add(Duration(seconds: expiresIn));

    await _tokenStorage.saveTokens(
      accessToken: accessToken,
      refreshToken: refreshToken,
      expiresAt: expiresAt,
    );

    _apiClient.setAccessToken(accessToken);
  }

  String _generateCodeVerifier() {
    final random = Random.secure();
    final values = List<int>.generate(64, (_) => random.nextInt(256));
    const chars =
        'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-._~';
    return values.map((v) => chars[v % chars.length]).join();
  }

  void dispose() {
    _callbackServer?.close();
    _authStateController.close();
  }
}

class AuthException implements Exception {
  final String message;
  AuthException(this.message);
  @override
  String toString() => 'AuthException: $message';
}
