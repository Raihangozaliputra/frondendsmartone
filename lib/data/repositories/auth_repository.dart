abstract class AuthRepository {
  Future<String?> login(String email, String password);
  Future<void> logout();
  Future<bool> isLoggedIn();
  Future<String?> getCurrentUserToken();
}
