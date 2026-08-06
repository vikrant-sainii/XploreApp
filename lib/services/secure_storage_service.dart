import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageService {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  static const String _tokenKey = 'jwt_token';
  static const String _roleKey = 'user_role';

  // In-memory fallback for pure Dart CLI/test environments
  static final Map<String, String> _mockStorage = {};
  static bool _useMockFallback = false;

  Future<void> _write(String key, String value) async {
    if (_useMockFallback) {
      _mockStorage[key] = value;
      return;
    }
    try {
      await _storage.write(key: key, value: value);
    } catch (_) {
      _useMockFallback = true;
      _mockStorage[key] = value;
    }
  }

  Future<String?> _read(String key) async {
    if (_useMockFallback) {
      return _mockStorage[key];
    }
    try {
      return await _storage.read(key: key);
    } catch (_) {
      _useMockFallback = true;
      return _mockStorage[key];
    }
  }

  Future<void> _delete(String key) async {
    if (_useMockFallback) {
      _mockStorage.remove(key);
      return;
    }
    try {
      await _storage.delete(key: key);
    } catch (_) {
      _useMockFallback = true;
      _mockStorage.remove(key);
    }
  }

  Future<void> _deleteAll() async {
    if (_useMockFallback) {
      _mockStorage.clear();
      return;
    }
    try {
      await _storage.deleteAll();
    } catch (_) {
      _useMockFallback = true;
      _mockStorage.clear();
    }
  }

  // Save Token
  Future<void> saveToken(String token) async {
    await _write(_tokenKey, token);
  }

  // Get Token
  Future<String?> getToken() async {
    return await _read(_tokenKey);
  }

  // Delete Token
  Future<void> deleteToken() async {
    await _delete(_tokenKey);
  }

  // Save Role
  Future<void> saveRole(String role) async {
    await _write(_roleKey, role);
  }

  // Get Role
  Future<String?> getRole() async {
    return await _read(_roleKey);
  }

  // Delete Role
  Future<void> deleteRole() async {
    await _delete(_roleKey);
  }

  // Clear All
  Future<void> deleteAll() async {
    await _deleteAll();
  }
}
