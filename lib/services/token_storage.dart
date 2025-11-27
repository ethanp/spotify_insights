import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

class TokenStorage {
  static const _fileName = 'spotify_tokens.json';
  File? _file;

  Future<File> get _tokenFile async {
    if (_file != null) return _file!;
    final dir = await getApplicationSupportDirectory();
    _file = File('${dir.path}/$_fileName');
    return _file!;
  }

  Future<Map<String, dynamic>> _readTokens() async {
    try {
      final file = await _tokenFile;
      if (!await file.exists()) return {};
      final contents = await file.readAsString();
      return jsonDecode(contents) as Map<String, dynamic>;
    } catch (e) {
      return {};
    }
  }

  Future<void> _writeTokens(Map<String, dynamic> tokens) async {
    final file = await _tokenFile;
    await file.writeAsString(jsonEncode(tokens));
  }

  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
    required DateTime expiresAt,
  }) async {
    await _writeTokens({
      'access_token': accessToken,
      'refresh_token': refreshToken,
      'expires_at': expiresAt.toIso8601String(),
    });
  }

  Future<String?> get accessToken async {
    final tokens = await _readTokens();
    return tokens['access_token'] as String?;
  }

  Future<String?> get refreshToken async {
    final tokens = await _readTokens();
    return tokens['refresh_token'] as String?;
  }

  Future<DateTime?> get expiresAt async {
    final tokens = await _readTokens();
    final value = tokens['expires_at'] as String?;
    return value != null ? DateTime.tryParse(value) : null;
  }

  Future<bool> get hasValidToken async {
    final token = await accessToken;
    final expires = await expiresAt;
    if (token == null || expires == null) return false;
    return DateTime.now().isBefore(expires.subtract(const Duration(minutes: 5)));
  }

  Future<bool> get needsRefresh async {
    final token = await accessToken;
    final refresh = await refreshToken;
    final expires = await expiresAt;
    if (token == null || refresh == null || expires == null) return false;
    return DateTime.now().isAfter(expires.subtract(const Duration(minutes: 5)));
  }

  Future<void> clear() async {
    try {
      final file = await _tokenFile;
      if (await file.exists()) {
        await file.delete();
      }
    } catch (e) {
      // Ignore errors during clear
    }
  }
}
