class AppConstants {
  // API Endpoints
  static const String baseUrl = 'https://api.smartone.com/v1';
  static const String loginEndpoint = '/auth/login';
  static const String registerEndpoint = '/auth/register';
  static const String forgotPasswordEndpoint = '/auth/forgot-password';
  
  // Storage Keys
  static const String tokenKey = 'auth_token';
  static const String userDataKey = 'user_data';
  static const String isLoggedInKey = 'is_logged_in';
  static const String rememberMeKey = 'remember_me';
  
  // Validation Messages
  static const String emailRequired = 'Email is required';
  static const String invalidEmail = 'Please enter a valid email';
  static const String passwordRequired = 'Password is required';
  static const String passwordMinLength = 'Password must be at least 6 characters';
  static const String nameRequired = 'Name is required';
  static const String confirmPasswordRequired = 'Please confirm your password';
  static const String passwordsDontMatch = 'Passwords do not match';
  
  // App Info
  static const String appName = 'Smart One';
  static const String appVersion = '1.0.0';
  
  // Animation Durations
  static const Duration animationDuration = Duration(milliseconds: 300);
  static const Duration pageTransitionDuration = Duration(milliseconds: 250);
  
  // Default Padding
  static const double defaultPadding = 16.0;
  static const double defaultBorderRadius = 12.0;
  
  // Regex Patterns
  static final RegExp emailRegex = RegExp(
    r'^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?)*$',
  );
  
  // Error Messages
  static const String connectionError = 'No internet connection';
  static const String serverError = 'Server error occurred';
  static const String unknownError = 'Something went wrong';
  static const String unauthorizedError = 'Unauthorized access';
  static const String notFoundError = 'Resource not found';
  
  // Success Messages
  static const String loginSuccess = 'Logged in successfully';
  static const String registerSuccess = 'Account created successfully';
  static const String passwordResetSent = 'Password reset link sent to your email';
}
