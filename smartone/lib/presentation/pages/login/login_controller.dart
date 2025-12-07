import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:smartone/core/constants/app_constants.dart';

class LoginController extends GetxController {
  final formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final rememberMe = false.obs;
  final isLoading = false.obs;
  final isPasswordVisible = false.obs;
  final storage = GetStorage();

  @override
  void onInit() {
    super.onInit();
    _checkRememberMe();
  }

  void _checkRememberMe() async {
    rememberMe.value = await storage.read(AppConstants.rememberMeKey) ?? false;
    if (rememberMe.value) {
      emailController.text = await storage.read('saved_email') ?? '';
      passwordController.text = await storage.read('saved_password') ?? '';
    }
  }

  void togglePasswordVisibility() {
    isPasswordVisible.value = !isPasswordVisible.value;
  }

  void toggleRememberMe(bool? value) {
    rememberMe.value = value ?? false;
    storage.write(AppConstants.rememberMeKey, rememberMe.value);
  }

  String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return AppConstants.emailRequired;
    } else if (!AppConstants.emailRegex.hasMatch(value)) {
      return AppConstants.invalidEmail;
    }
    return null;
  }

  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return AppConstants.passwordRequired;
    } else if (value.length < 6) {
      return AppConstants.passwordMinLength;
    }
    return null;
  }

  Future<void> login() async {
    if (!formKey.currentState!.validate()) return;

    isLoading.value = true;

    try {
      // TODO: Implement API call for login
      await Future.delayed(const Duration(seconds: 2)); // Simulate API call
      
      if (rememberMe.value) {
        await storage.write('saved_email', emailController.text);
        await storage.write('saved_password', passwordController.text);
      } else {
        await storage.remove('saved_email');
        await storage.remove('saved_password');
      }
      
      await storage.write(AppConstants.isLoggedInKey, true);
      // TODO: Navigate to home page after successful login
      // Get.offAllNamed(Routes.HOME);
      
      Get.snackbar(
        'Success',
        AppConstants.loginSuccess,
        backgroundColor: Colors.green,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        e.toString(),
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  void navigateToRegister() {
    Get.toNamed('/register');
  }

  void navigateToForgotPassword() {
    // TODO: Implement forgot password navigation
    Get.snackbar(
      'Info',
      'Forgot password feature coming soon!',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}
