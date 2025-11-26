import 'package:flutter_riverpod/flutter_riverpod.dart';

class AuthController extends StateNotifier<bool> {
  AuthController() : super(false);

  Future<void> login(String email, String password) async {
    // Simulate API call
    await Future.delayed(Duration(seconds: 2));

    // For demo purposes, we'll assume login is successful
    state = true;
  }

  Future<void> logout() async {
    state = false;
  }
}

final authControllerProvider = StateNotifierProvider<AuthController, bool>((
  ref,
) {
  return AuthController();
});
