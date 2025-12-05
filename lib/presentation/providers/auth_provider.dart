import 'package:flutter/foundation.dart';
import 'package:smartone/data/repositories/auth_repository.dart';
import 'package:smartone/data/repositories/auth_repository_impl.dart';

class AuthProvider extends ChangeNotifier {
  AuthRepository _authRepository = AuthRepositoryImpl();

  bool _isLoggedIn = false;
  String? _token;
  String? _userId;
  String? _userRole;
  bool _isLoading = false;
  String? _error;

  // Getters
  bool get isLoggedIn => _isLoggedIn;
  String? get token => _token;
  String? get userId => _userId;
  String? get userRole => _userRole;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Setters
  set authRepository(AuthRepository repo) {
    _authRepository = repo;
    notifyListeners();
  }

  Future<void> login(String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final token = await _authRepository.login(email, password);
      if (token != null) {
        _isLoggedIn = true;
        _token = token;
      } else {
        _isLoggedIn = false;
        _error = 'Login failed';
      }
    } catch (e) {
      _isLoggedIn = false;
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    await _authRepository.logout();
    _isLoggedIn = false;
    _token = null;
    _userId = null;
    _userRole = null;
    notifyListeners();
  }

  Future<void> checkAuthStatus() async {
    final isLoggedIn = await _authRepository.isLoggedIn();
    if (isLoggedIn) {
      final token = await _authRepository.getCurrentUserToken();
      _isLoggedIn = true;
      _token = token;
    } else {
      _isLoggedIn = false;
      _token = null;
      _userId = null;
      _userRole = null;
    }
    notifyListeners();
  }
}
