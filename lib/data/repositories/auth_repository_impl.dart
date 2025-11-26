import 'package:smartone/data/repositories/auth_repository.dart';
import 'package:smartone/utils/secure_storage.dart';

class AuthRepositoryImpl implements AuthRepository {
  @override
  Future<String?> login(String email, String password) async {
    // Simulate API call
    await Future.delayed(Duration(seconds: 2));

    // For demo purposes, we'll assume login is successful
    // In a real app, you would call your API here
    String token = 'demo_auth_token_${DateTime.now().millisecondsSinceEpoch}';

    // Save token securely
    await SecureStorage.saveToken(token);

    // Save user data (in a real app, you would get this from the API response)
    await SecureStorage.saveUserData('user123', 'student');

    return token;
  }

  @override
  Future<void> logout() async {
    await SecureStorage.clearAll();
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
