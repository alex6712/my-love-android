import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

final secureStorageProvider = Provider<SecureStorage>((ref) {
  return SecureStorage();
});

class SecureStorage {
  final _storage = const FlutterSecureStorage();

  static const _accessTokenKey = 'ml_at';

  Future<String?> getAccessToken() => _storage.read(key: _accessTokenKey);
  Future<void> saveAccessToken(String token) =>
      _storage.write(key: _accessTokenKey, value: token);
  Future<void> deleteAccessToken() => _storage.delete(key: _accessTokenKey);
}
