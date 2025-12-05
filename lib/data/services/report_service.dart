import 'package:dio/dio.dart';
import 'package:smartone/data/providers/api_client.dart';

class ReportService {
  static final ReportService _instance = ReportService._internal();
  factory ReportService() => _instance;
  ReportService._internal();

  final ApiClient _apiClient = ApiClient();

  /// Get daily attendance report
  Future<Map<String, dynamic>> getDailyReport(DateTime date) async {
    try {
      final response = await _apiClient.dio.get(
        '/reports/daily',
        queryParameters: {'date': date.toIso8601String().split('T')[0]},
      );

      if (response.statusCode == 200) {
        return response.data['data'];
      } else {
        throw Exception('Failed to fetch daily report');
      }
    } on DioException catch (e) {
      throw Exception('Network error: ${e.message}');
    }
  }

  /// Get monthly attendance report
  Future<Map<String, dynamic>> getMonthlyReport(int year, int month) async {
    try {
      final response = await _apiClient.dio.get(
        '/reports/monthly',
        queryParameters: {'year': year, 'month': month},
      );

      if (response.statusCode == 200) {
        return response.data['data'];
      } else {
        throw Exception('Failed to fetch monthly report');
      }
    } on DioException catch (e) {
      throw Exception('Network error: ${e.message}');
    }
  }

  /// Get late attendance report
  Future<Map<String, dynamic>> getLateReport(
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      final response = await _apiClient.dio.get(
        '/reports/late',
        queryParameters: {
          'start_date': startDate.toIso8601String().split('T')[0],
          'end_date': endDate.toIso8601String().split('T')[0],
        },
      );

      if (response.statusCode == 200) {
        return response.data['data'];
      } else {
        throw Exception('Failed to fetch late report');
      }
    } on DioException catch (e) {
      throw Exception('Network error: ${e.message}');
    }
  }

  /// Get custom report
  Future<Map<String, dynamic>> getCustomReport({
    required DateTime startDate,
    required DateTime endDate,
    String? userId,
    String? classId,
  }) async {
    try {
      final queryParameters = {
        'start_date': startDate.toIso8601String().split('T')[0],
        'end_date': endDate.toIso8601String().split('T')[0],
      };

      if (userId != null) {
        queryParameters['user_id'] = userId;
      }

      if (classId != null) {
        queryParameters['class_id'] = classId;
      }

      final response = await _apiClient.dio.get(
        '/reports/custom',
        queryParameters: queryParameters,
      );

      if (response.statusCode == 200) {
        return response.data['data'];
      } else {
        throw Exception('Failed to fetch custom report');
      }
    } on DioException catch (e) {
      throw Exception('Network error: ${e.message}');
    }
  }
}
