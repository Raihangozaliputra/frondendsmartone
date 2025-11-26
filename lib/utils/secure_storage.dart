import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorage {
  static const _storage = FlutterSecureStorage();

  // Keys
  static const String _tokenKey = 'auth_token';
  static const String _userIdKey = 'user_id';
  static const String _userRoleKey = 'user_role';

  // Write token
  static Future<void> saveToken(String token) async {
    await _storage.write(key: _tokenKey, value: token);
  }

  // Read token
  static Future<String?> getToken() async {
    return await _storage.read(key: _tokenKey);
  }

  // Delete token
  static Future<void> deleteToken() async {
    await _storage.delete(key: _tokenKey);
  }

  // Save user data
  static Future<void> saveUserData(String userId, String userRole) async {
    await _storage.write(key: _userIdKey, value: userId);
    await _storage.write(key: _userRoleKey, value: userRole);
  }

  // Get user ID
  static Future<String?> getUserId() async {
    return await _storage.read(key: _userIdKey);
  }

  // Get user role
  static Future<String?> getUserRole() async {
    return await _storage.read(key: _userRoleKey);
  }

  // Clear all data
  static Future<void> clearAll() async {
    await _storage.deleteAll();
  }
}
