import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageService {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  static const String _tokenKey = 'jwt_token';
  static const String _roleKey = 'user_role';

  // Save Token
  Future<void> saveToken(String token) async {
    await _storage.write(key: _tokenKey, value: token);
  }

  // Get Token
  Future<String?> getToken() async {
    return await _storage.read(key: _tokenKey);
  }

  // Delete Token
  Future<void> deleteToken() async {
    await _storage.delete(key: _tokenKey);
  }

  // Save Role
  Future<void> saveRole(String role) async {
    await _storage.write(key: _roleKey, value: role);
  }

  // Get Role
  Future<String?> getRole() async {
    return await _storage.read(key: _roleKey);
  }

  // Delete Role
  Future<void> deleteRole() async {
    await _storage.delete(key: _roleKey);
  }

  // Clear All
  Future<void> deleteAll() async {
    await _storage.deleteAll();
  }
}
