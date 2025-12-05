import 'package:smartone/data/repositories/auth_repository.dart';
import 'package:smartone/utils/secure_storage.dart';
import 'package:smartone/data/providers/api_client.dart';
import 'package:dio/dio.dart';

class AuthRepositoryImpl implements AuthRepository {
  final ApiClient _apiClient = ApiClient();

  @override
  Future<String?> login(String email, String password) async {
    try {
      final response = await _apiClient.post(
        '/login',
        data: {'email': email, 'password': password},
      );

      if (response.statusCode == 200 && response.data['success']) {
        final token = response.data['token'];
        final user = response.data['user'];

        // Save token securely
        await SecureStorage.saveToken(token);

        // Save user data
        await SecureStorage.saveUserData(user['id'].toString(), user['role']);

        return token;
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

  @override
  Future<void> logout() async {
    try {
      final token = await SecureStorage.getToken();
      if (token != null) {
        await _apiClient.post('/logout');
      }
    } catch (e) {
      // Ignore logout errors
      print('Logout error: $e');
    } finally {
      await SecureStorage.clearAll();
    }
  }

  @override
  Future<bool> isLoggedIn() async {
    String? token = await SecureStorage.getToken();
    return token != null && token.isNotEmpty;
  }

  @override
  Future<String?> getCurrentUserToken() async {
    return await SecureStorage.getToken();
  }
}
