import 'package:dio/dio.dart';
import 'package:smartone/data/providers/api_client.dart';
import 'package:smartone/data/models/user.dart';

class UserManagementService {
  static final UserManagementService _instance =
      UserManagementService._internal();
  factory UserManagementService() => _instance;
  UserManagementService._internal();

  final ApiClient _apiClient = ApiClient();

  /// Get all users
  Future<List<User>> getAllUsers() async {
    try {
      final response = await _apiClient.dio.get('/users');

      if (response.statusCode == 200) {
        final List<dynamic> userData = response.data['data'];
        return userData.map((data) => User.fromJson(data)).toList();
      } else {
        throw Exception('Failed to fetch users');
      }
    } on DioException catch (e) {
      throw Exception('Network error: ${e.message}');
    }
  }

  /// Get user by ID
  Future<User> getUserById(String userId) async {
    try {
      final response = await _apiClient.dio.get('/users/$userId');

      if (response.statusCode == 200) {
        return User.fromJson(response.data['data']);
      } else {
        throw Exception('Failed to fetch user');
      }
    } on DioException catch (e) {
      throw Exception('Network error: ${e.message}');
    }
  }

  /// Create a new user
  Future<User> createUser(Map<String, dynamic> userData) async {
    try {
      final response = await _apiClient.dio.post('/users', data: userData);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return User.fromJson(response.data['data']);
      } else {
        throw Exception('Failed to create user: ${response.data['message']}');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 422) {
        throw Exception('Validation error: ${e.response?.data['message']}');
      }
      throw Exception('Network error: ${e.message}');
    }
  }

  /// Update user
  Future<User> updateUser(String userId, Map<String, dynamic> userData) async {
    try {
      final response = await _apiClient.dio.put(
        '/users/$userId',
        data: userData,
      );

      if (response.statusCode == 200) {
        return User.fromJson(response.data['data']);
      } else {
        throw Exception('Failed to update user: ${response.data['message']}');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 422) {
        throw Exception('Validation error: ${e.response?.data['message']}');
      }
      throw Exception('Network error: ${e.message}');
    }
  }

  /// Delete user
  Future<void> deleteUser(String userId) async {
    try {
      final response = await _apiClient.dio.delete('/users/$userId');

      if (response.statusCode != 200) {
        throw Exception('Failed to delete user');
      }
    } on DioException catch (e) {
      throw Exception('Network error: ${e.message}');
    }
  }

  /// Get all classrooms
  Future<List<Map<String, dynamic>>> getAllClassrooms() async {
    try {
      final response = await _apiClient.dio.get('/classrooms');

      if (response.statusCode == 200) {
        return List<Map<String, dynamic>>.from(response.data['data']);
      } else {
        throw Exception('Failed to fetch classrooms');
      }
    } on DioException catch (e) {
      throw Exception('Network error: ${e.message}');
    }
  }

  /// Get classroom by ID
  Future<Map<String, dynamic>> getClassroomById(String classroomId) async {
    try {
      final response = await _apiClient.dio.get('/classrooms/$classroomId');

      if (response.statusCode == 200) {
        return response.data['data'];
      } else {
        throw Exception('Failed to fetch classroom');
      }
    } on DioException catch (e) {
      throw Exception('Network error: ${e.message}');
    }
  }

  /// Create a new classroom
  Future<Map<String, dynamic>> createClassroom(
    Map<String, dynamic> classroomData,
  ) async {
    try {
      final response = await _apiClient.dio.post(
        '/classrooms',
        data: classroomData,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return response.data['data'];
      } else {
        throw Exception(
          'Failed to create classroom: ${response.data['message']}',
        );
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 422) {
        throw Exception('Validation error: ${e.response?.data['message']}');
      }
      throw Exception('Network error: ${e.message}');
    }
  }

  /// Update classroom
  Future<Map<String, dynamic>> updateClassroom(
    String classroomId,
    Map<String, dynamic> classroomData,
  ) async {
    try {
      final response = await _apiClient.dio.put(
        '/classrooms/$classroomId',
        data: classroomData,
      );

      if (response.statusCode == 200) {
        return response.data['data'];
      } else {
        throw Exception(
          'Failed to update classroom: ${response.data['message']}',
        );
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 422) {
        throw Exception('Validation error: ${e.response?.data['message']}');
      }
      throw Exception('Network error: ${e.message}');
    }
  }

  /// Delete classroom
  Future<void> deleteClassroom(String classroomId) async {
    try {
      final response = await _apiClient.dio.delete('/classrooms/$classroomId');

      if (response.statusCode != 200) {
        throw Exception('Failed to delete classroom');
      }
    } on DioException catch (e) {
      throw Exception('Network error: ${e.message}');
    }
  }

  /// Get all schedules
  Future<List<Map<String, dynamic>>> getAllSchedules() async {
    try {
      final response = await _apiClient.dio.get('/schedules');

      if (response.statusCode == 200) {
        return List<Map<String, dynamic>>.from(response.data['data']);
      } else {
        throw Exception('Failed to fetch schedules');
      }
    } on DioException catch (e) {
      throw Exception('Network error: ${e.message}');
    }
  }

  /// Get schedule by ID
  Future<Map<String, dynamic>> getScheduleById(String scheduleId) async {
    try {
      final response = await _apiClient.dio.get('/schedules/$scheduleId');

      if (response.statusCode == 200) {
        return response.data['data'];
      } else {
        throw Exception('Failed to fetch schedule');
      }
    } on DioException catch (e) {
      throw Exception('Network error: ${e.message}');
    }
  }

  /// Create a new schedule
  Future<Map<String, dynamic>> createSchedule(
    Map<String, dynamic> scheduleData,
  ) async {
    try {
      final response = await _apiClient.dio.post(
        '/schedules',
        data: scheduleData,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return response.data['data'];
      } else {
        throw Exception(
          'Failed to create schedule: ${response.data['message']}',
        );
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 422) {
        throw Exception('Validation error: ${e.response?.data['message']}');
      }
      throw Exception('Network error: ${e.message}');
    }
  }

  /// Update schedule
  Future<Map<String, dynamic>> updateSchedule(
    String scheduleId,
    Map<String, dynamic> scheduleData,
  ) async {
    try {
      final response = await _apiClient.dio.put(
        '/schedules/$scheduleId',
        data: scheduleData,
      );

      if (response.statusCode == 200) {
        return response.data['data'];
      } else {
        throw Exception(
          'Failed to update schedule: ${response.data['message']}',
        );
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 422) {
        throw Exception('Validation error: ${e.response?.data['message']}');
      }
      throw Exception('Network error: ${e.message}');
    }
  }

  /// Delete schedule
  Future<void> deleteSchedule(String scheduleId) async {
    try {
      final response = await _apiClient.dio.delete('/schedules/$scheduleId');

      if (response.statusCode != 200) {
        throw Exception('Failed to delete schedule');
      }
    } on DioException catch (e) {
      throw Exception('Network error: ${e.message}');
    }
  }
}
