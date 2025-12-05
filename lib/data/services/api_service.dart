import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:smartone/utils/api_exception.dart';
import 'package:smartone/utils/secure_storage.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;

  final Dio _dio;
  static const String _baseUrl = 'https://api.smartpresence.example.com';
  static const Duration _timeout = Duration(seconds: 30);

  ApiService._internal() : _dio = Dio() {
    _dio.options.baseUrl = _baseUrl;
    _dio.options.connectTimeout = _timeout;
    _dio.options.receiveTimeout = _timeout;

    // Add interceptor for adding auth token to requests
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await SecureStorage.getToken();
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
        onResponse: (response, handler) {
          return handler.next(response);
        },
        onError: (DioException e, handler) {
          // Handle common error cases
          if (e.response?.statusCode == 401) {
            return handler.reject(
              DioException(
                error: UnauthorizedException(),
                requestOptions: e.requestOptions,
              ),
            );
          }
          return handler.next(e);
        },
      ),
    );
  }

  /// Generic GET request
  Future<dynamic> get(
    String endpoint, {
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final response = await _dio.get(
        endpoint,
        queryParameters: queryParameters,
      );
      return response.data;
    } on DioException catch (e) {
      _handleDioError(e);
    }
  }

  /// Generic POST request
  Future<dynamic> post(
    String endpoint, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final response = await _dio.post(
        endpoint,
        data: data,
        queryParameters: queryParameters,
      );
      return response.data;
    } on DioException catch (e) {
      _handleDioError(e);
    }
  }

  /// Generic PUT request
  Future<dynamic> put(
    String endpoint, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final response = await _dio.put(
        endpoint,
        data: data,
        queryParameters: queryParameters,
      );
      return response.data;
    } on DioException catch (e) {
      _handleDioError(e);
    }
  }

  /// Generic DELETE request
  Future<dynamic> delete(
    String endpoint, {
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final response = await _dio.delete(
        endpoint,
        queryParameters: queryParameters,
      );
      return response.data;
    } on DioException catch (e) {
      _handleDioError(e);
    }
  }

  /// Handle Dio errors and convert them to appropriate exceptions
  void _handleDioError(DioException error) {
    if (error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.receiveTimeout ||
        error.type == DioExceptionType.sendTimeout) {
      throw NetworkException('Connection timeout');
    }

    if (error.response != null) {
      final statusCode = error.response!.statusCode;
      final data = error.response!.data;

      String message = 'Unknown error';
      if (data is Map<String, dynamic>) {
        message = data['message'] ?? data['error'] ?? message;
      } else if (data is String) {
        try {
          final jsonData = json.decode(data);
          if (jsonData is Map<String, dynamic>) {
            message = jsonData['message'] ?? jsonData['error'] ?? message;
          }
        } catch (e) {
          message = data;
        }
      }

      switch (statusCode) {
        case 400:
          throw ApiException(message, statusCode: 400);
        case 401:
          throw UnauthorizedException(message: message);
        case 404:
          throw NotFoundException(message: message);
        case 500:
          throw ServerException(message: message);
        default:
          throw ApiException(message, statusCode: statusCode);
      }
    }

    throw NetworkException('Network error occurred');
  }

  /// Sync attendance records with the server
  Future<void> syncAttendanceRecords(
    List<Map<String, dynamic>> attendanceRecords,
  ) async {
    await post('/attendance/bulk', data: {'records': attendanceRecords});
  }

  /// Get user profile
  Future<Map<String, dynamic>> getUserProfile(String userId) async {
    return await get('/users/$userId');
  }

  /// Update user profile
  Future<Map<String, dynamic>> updateUserProfile(
    String userId,
    Map<String, dynamic> data,
  ) async {
    return await put('/users/$userId', data: data);
  }

  /// Get attendance statistics
  Future<Map<String, dynamic>> getAttendanceStatistics(
    String userId, {
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final queryParameters = <String, dynamic>{};

    if (startDate != null) {
      queryParameters['startDate'] = startDate.toIso8601String();
    }

    if (endDate != null) {
      queryParameters['endDate'] = endDate.toIso8601String();
    }

    return await get(
      '/attendance/statistics/$userId',
      queryParameters: queryParameters,
    );
  }
}
