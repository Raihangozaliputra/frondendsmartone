import 'dart:convert';
import 'package:smartone/data/models/user.dart';
import 'package:smartone/utils/secure_storage.dart';
import 'package:smartone/utils/local_database.dart';
import 'package:smartone/data/providers/api_client.dart';
import 'package:dio/dio.dart';
import 'package:uuid/uuid.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  final ApiClient _apiClient = ApiClient();
  final Uuid _uuid = Uuid();

  /// Authenticate user with email and password
  Future<User?> authenticate(String email, String password) async {
    try {
      final response = await _apiClient.dio.post(
        '/login',
        data: {'email': email, 'password': password},
      );

      if (response.statusCode == 200 && response.data['success']) {
        final token = response.data['token'];
        final userData = response.data['user'];

        // Save token securely
        await SecureStorage.saveToken(token);

        // Create user object from API response
        final user = User(
          id: userData['id'].toString(),
          name: userData['name'],
          email: userData['email'],
          role: userData['role'],
        );

        // Save user data to local database
        await LocalDatabase().saveUser(user);

        // Save user data to secure storage
        await SecureStorage.saveUserData(user.id, user.role);

        return user;
      } else {
        throw Exception(response.data['message'] ?? 'Login failed');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw Exception('Invalid credentials');
      } else {
        throw Exception('Network error: ${e.message}');
      }
    } catch (e) {
      throw Exception('Login failed: $e');
    }
  }

  /// Register a new user
  Future<User> register({
    required String name,
    required String email,
    required String password,
    String role = 'student',
  }) async {
    try {
      final response = await _apiClient.dio.post(
        '/register',
        data: {
          'name': name,
          'email': email,
          'password': password,
          'role': role,
        },
      );

      if (response.statusCode == 200 && response.data['success']) {
        final token = response.data['token'];
        final userData = response.data['user'];

        // Save token securely
        await SecureStorage.saveToken(token);

        // Create user object from API response
        final user = User(
          id: userData['id'].toString(),
          name: userData['name'],
          email: userData['email'],
          role: userData['role'],
        );

        // Save to local database
        await LocalDatabase().saveUser(user);

        // Save user data to secure storage
        await SecureStorage.saveUserData(user.id, user.role);

        return user;
      } else {
        throw Exception(response.data['message'] ?? 'Registration failed');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 422) {
        throw Exception('Validation error: ${e.response?.data['message']}');
      } else {
        throw Exception('Network error: ${e.message}');
      }
    } catch (e) {
      throw Exception('Registration failed: $e');
    }
  }

  /// Get current authenticated user
  Future<User?> getCurrentUser() async {
    final userId = await SecureStorage.getUserId();

    if (userId != null) {
      return LocalDatabase().getUser(userId);
    }

    return null;
  }

  /// Logout current user
  Future<void> logout() async {
    try {
      final token = await SecureStorage.getToken();
      if (token != null) {
        await _apiClient.dio.post('/logout');
      }
    } catch (e) {
      // Ignore logout errors
      print('Logout error: $e');
    } finally {
      await SecureStorage.clearAll();
    }
  }

  /// Check if user is authenticated
  Future<bool> isAuthenticated() async {
    final userId = await SecureStorage.getUserId();
    return userId != null;
  }
}
