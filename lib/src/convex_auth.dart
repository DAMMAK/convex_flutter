import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

class ConvexAuth {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  final String _tokenKey = 'convex_auth_token';

  Future<void> setToken(String token) async {
    await _storage.write(key: _tokenKey, value: token);
  }

  Future<String?> getToken() async {
    final token = await _storage.read(key: _tokenKey);
    if (token != null && JwtDecoder.isExpired(token)) {
      await clearToken();
      return null;
    }
    return token;
  }

  Future<void> clearToken() async {
    await _storage.delete(key: _tokenKey);
  }

  Future<bool> isAuthenticated() async {
    final token = await getToken();
    return token != null;
  }
}