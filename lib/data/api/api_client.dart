import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:logger/logger.dart';

class ApiClient {
  static const String baseUrl = 'https://your-api-url.com/api';
  
  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      responseType: ResponseType.json,
    ),
  );

  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  final Logger _logger = Logger();

  ApiClient() {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // Add authorization token if exists
          final token = await _secureStorage.read(key: 'auth_token');
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          
          // Log request
          _logger.i('${options.method} ${options.uri}');
          if (options.data != null) {
            _logger.d('Request data: ${options.data}');
          }
          
          return handler.next(options);
        },
        onResponse: (response, handler) {
          _logger.d('Response: ${response.statusCode} ${response.requestOptions.uri}');
          return handler.next(response);
        },
        onError: (DioException e, handler) async {
          _logger.e('Error: ${e.message}');
          
          // Handle 401 Unauthorized
          if (e.response?.statusCode == 401) {
            // TODO: Implement token refresh logic
          }
          
          return handler.next(e);
        },
      ),
    );
  }

  // Authentication
  Future<Response> login(String email, String password) async {
    return _dio.post(
      '/login',
      data: {
        'email': email,
        'password': password,
        'device_name': 'mobile',
      },
    );
  }

  Future<Response> register(Map<String, dynamic> userData) async {
    return _dio.post(
      '/register',
      data: userData,
    );
  }

  Future<Response> logout() async {
    try {
      final response = await _dio.post('/logout');
      await _secureStorage.delete(key: 'auth_token');
      return response;
    } catch (e) {
      // Even if logout fails on server, clear local token
      await _secureStorage.delete(key: 'auth_token');
      rethrow;
    }
  }

  // Attendance
  Future<Response> checkIn(Map<String, dynamic> data) async {
    return _dio.post(
      '/attendance/check-in',
      data: data,
    );
  }

  Future<Response> checkOut(int attendanceId, Map<String, dynamic> data) async {
    return _dio.post(
      '/attendance/$attendanceId/check-out',
      data: data,
    );
  }

  Future<Response> getAttendanceHistory({
    DateTime? startDate,
    DateTime? endDate,
    int? userId,
  }) async {
    final params = <String, dynamic>{};
    if (startDate != null) params['start_date'] = startDate.toIso8601String();
    if (endDate != null) params['end_date'] = endDate.toIso8601String();
    if (userId != null) params['user_id'] = userId;

    return _dio.get(
      '/attendances',
      queryParameters: params,
    );
  }

  // Face Recognition
  Future<Response> uploadFaceImage(FormData formData) async {
    return _dio.post(
      '/face/upload',
      data: formData,
      options: Options(
        headers: {
          'Content-Type': 'multipart/form-data',
        },
      ),
    );
  }

  Future<Response> processFaceRecognition(FormData formData) async {
    return _dio.post(
      '/attendance/process',
      data: formData,
      options: Options(
        headers: {
          'Content-Type': 'multipart/form-data',
        },
      ),
    );
  }

  // Reports
  Future<Response> getDailyReport(DateTime date) async {
    return _dio.get(
      '/reports/daily',
      queryParameters: {
        'date': date.toIso8601String().split('T')[0],
      },
    );
  }

  Future<Response> getMonthlyReport(int year, int month) async {
    return _dio.get(
      '/reports/monthly',
      queryParameters: {
        'year': year,
        'month': month,
      },
    );
  }

  Future<Response> getLateReport(DateTime date) async {
    return _dio.get(
      '/reports/late',
      queryParameters: {
        'date': date.toIso8601String().split('T')[0],
      },
    );
  }

  // Classrooms
  Future<Response> getClassrooms() async {
    return _dio.get('/classrooms');
  }

  // Users
  Future<Response> getUsers({String? role}) async {
    return _dio.get(
      '/users',
      queryParameters: role != null ? {'role': role} : null,
    );
  }

  // Schedules
  Future<Response> getSchedules() async {
    return _dio.get('/schedules');
  }
}
