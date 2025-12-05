import 'dart:io';
import 'package:dio/dio.dart';
import 'package:smartone/data/models/attendance.dart';
import 'package:smartone/data/models/user.dart';
import 'package:smartone/utils/date_utils.dart';
import 'package:smartone/utils/local_database.dart';
import 'package:smartone/utils/location_service.dart';
import 'package:smartone/data/providers/api_client.dart';
import 'package:smartone/data/services/sync_service.dart';
import 'package:smartone/data/services/attendance_reminder_service.dart';
import 'package:uuid/uuid.dart';

class AttendanceService {
  static final AttendanceService _instance = AttendanceService._internal();
  factory AttendanceService() => _instance;
  AttendanceService._internal();

  final ApiClient _apiClient = ApiClient();
  final SyncService _syncService = SyncService();
  final Uuid _uuid = Uuid();

  /// Create a new attendance record for check-in
  Future<Attendance> createCheckInAttendance({
    required User user,
    required double latitude,
    required double longitude,
    File? faceImage,
  }) async {
    try {
      final data = {
        'user_id': user.id,
        'latitude': latitude,
        'longitude': longitude,
        'status': 'present',
      };

      final response = await _apiClient.dio.post('/attendances', data: data);

      if (response.statusCode == 200 || response.statusCode == 201) {
        final attendanceData = response.data['data'];
        final attendance = Attendance.fromJson(attendanceData);

        // Save to local database
        await LocalDatabase().saveAttendance(attendance);

        // Add sync record
        await _syncService.addAttendanceSyncRecord(attendance, 'create');

        // Show confirmation notification
        await AttendanceReminderService().showAttendanceConfirmation(
          'check-in',
        );

        return attendance;
      } else {
        throw Exception('Failed to create attendance record');
      }
    } on DioException catch (e) {
      // Jika offline, simpan ke database lokal saja
      final attendance = Attendance(
        id: _uuid.v4(),
        userId: user.id,
        checkInTime: DateTime.now(),
        latitude: latitude,
        longitude: longitude,
        status: 'present',
      );

      // Save to local database
      await LocalDatabase().saveAttendance(attendance);

      // Add sync record
      await _syncService.addAttendanceSyncRecord(attendance, 'create');

      // Show confirmation notification
      await AttendanceReminderService().showAttendanceConfirmation('check-in');

      return attendance;
    } catch (e) {
      throw Exception('Check-in failed: $e');
    }
  }

  /// Update an attendance record for check-out
  Future<Attendance?> createCheckOutAttendance(String attendanceId) async {
    try {
      final response = await _apiClient.dio.put(
        '/attendances/$attendanceId',
        data: {'check_out_time': DateTime.now().toIso8601String()},
      );

      if (response.statusCode == 200) {
        final attendanceData = response.data['data'];
        final attendance = Attendance.fromJson(attendanceData);

        // Update in local database
        await LocalDatabase().saveAttendance(attendance);

        // Add sync record
        await _syncService.addAttendanceSyncRecord(attendance, 'update');

        // Show confirmation notification
        await AttendanceReminderService().showAttendanceConfirmation(
          'check-out',
        );

        return attendance;
      } else {
        throw Exception('Failed to update attendance record');
      }
    } on DioException catch (e) {
      // Jika offline, update di database lokal saja
      final localAttendance = LocalDatabase().getAttendance(attendanceId);
      if (localAttendance != null) {
        final updatedAttendance = localAttendance.copyWith(
          checkOutTime: DateTime.now(),
        );

        // Update in local database
        await LocalDatabase().saveAttendance(updatedAttendance);

        // Add sync record
        await _syncService.addAttendanceSyncRecord(updatedAttendance, 'update');

        // Show confirmation notification
        await AttendanceReminderService().showAttendanceConfirmation(
          'check-out',
        );

        return updatedAttendance;
      }

      throw Exception('Attendance record not found');
    } catch (e) {
      throw Exception('Check-out failed: $e');
    }
  }

  /// Mark a student as absent
  Future<Attendance> markAsAbsent({required User user, String? reason}) async {
    try {
      final data = {
        'user_id': user.id,
        'latitude': 0.0,
        'longitude': 0.0,
        'status': 'absent',
        if (reason != null) 'reason': reason,
      };

      final response = await _apiClient.dio.post('/attendances', data: data);

      if (response.statusCode == 200 || response.statusCode == 201) {
        final attendanceData = response.data['data'];
        final attendance = Attendance.fromJson(attendanceData);

        // Save to local database
        await LocalDatabase().saveAttendance(attendance);

        // Add sync record
        await _syncService.addAttendanceSyncRecord(attendance, 'create');

        // Show confirmation notification
        await AttendanceReminderService().showAttendanceConfirmation('absent');

        return attendance;
      } else {
        throw Exception('Failed to mark as absent');
      }
    } on DioException catch (e) {
      // Jika offline, simpan ke database lokal saja
      final attendance = Attendance(
        id: _uuid.v4(),
        userId: user.id,
        checkInTime: DateTime.now(),
        latitude: 0.0,
        longitude: 0.0,
        status: 'absent',
      );

      // Save to local database
      await LocalDatabase().saveAttendance(attendance);

      // Add sync record
      await _syncService.addAttendanceSyncRecord(attendance, 'create');

      // Show confirmation notification
      await AttendanceReminderService().showAttendanceConfirmation('absent');

      return attendance;
    } catch (e) {
      throw Exception('Mark absent failed: $e');
    }
  }

  /// Get today's attendance for a user
  Future<Attendance?> getTodaysAttendance(User user) async {
    try {
      final response = await _apiClient.dio.get('/attendances/today');

      if (response.statusCode == 200) {
        if (response.data['data'] != null) {
          return Attendance.fromJson(response.data['data']);
        }
        return null;
      } else {
        throw Exception('Failed to fetch today\'s attendance');
      }
    } on DioException catch (e) {
      // Fallback to local database
      final allAttendances = LocalDatabase().getAllAttendances();
      final todaysAttendances = allAttendances.where((attendance) {
        return attendance.userId == user.id &&
            DateUtils.isSameDay(
              attendance.checkInTime,
              DateUtils.getLocalTime(),
            );
      }).toList();

      return todaysAttendances.isEmpty ? null : todaysAttendances.first;
    } catch (e) {
      // Fallback to local database
      final allAttendances = LocalDatabase().getAllAttendances();
      final todaysAttendances = allAttendances.where((attendance) {
        return attendance.userId == user.id &&
            DateUtils.isSameDay(
              attendance.checkInTime,
              DateUtils.getLocalTime(),
            );
      }).toList();

      return todaysAttendances.isEmpty ? null : todaysAttendances.first;
    }
  }

  /// Get attendance records for a user within a date range
  Future<List<Attendance>> getAttendanceInRange({
    required User user,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      final response = await _apiClient.dio.get(
        '/attendances',
        queryParameters: {
          'start_date': startDate.toIso8601String(),
          'end_date': endDate.toIso8601String(),
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> attendanceData = response.data['data'];
        return attendanceData.map((data) => Attendance.fromJson(data)).toList();
      } else {
        throw Exception('Failed to fetch attendance records');
      }
    } on DioException catch (e) {
      // Fallback to local database
      final allAttendances = LocalDatabase().getAllAttendances();
      return allAttendances.where((attendance) {
        return attendance.userId == user.id &&
            attendance.checkInTime.isAfter(startDate) &&
            attendance.checkInTime.isBefore(endDate);
      }).toList();
    } catch (e) {
      // Fallback to local database
      final allAttendances = LocalDatabase().getAllAttendances();
      return allAttendances.where((attendance) {
        return attendance.userId == user.id &&
            attendance.checkInTime.isAfter(startDate) &&
            attendance.checkInTime.isBefore(endDate);
      }).toList();
    }
  }

  /// Get attendance statistics for a user
  Future<AttendanceStatistics> getAttendanceStatistics(User user) async {
    try {
      final response = await _apiClient.dio.get(
        '/attendances/statistics/${user.id}',
      );

      if (response.statusCode == 200) {
        final stats = response.data['data'];
        return AttendanceStatistics(
          total: stats['total'] as int,
          present: stats['present'] as int,
          absent: stats['absent'] as int,
          late: stats['late'] as int,
          rate: (stats['rate'] as num).toDouble(),
        );
      } else {
        throw Exception('Failed to fetch attendance statistics');
      }
    } on DioException catch (e) {
      // Fallback to local statistics
      return _getLocalAttendanceStatistics(user);
    } catch (e) {
      // Fallback to local statistics
      return _getLocalAttendanceStatistics(user);
    }
  }

  /// Get attendance statistics from local database
  AttendanceStatistics _getLocalAttendanceStatistics(User user) {
    final allAttendances = LocalDatabase().getAllAttendances();

    // Filter attendances for the user
    final userAttendances = allAttendances
        .where((attendance) => attendance.userId == user.id)
        .toList();

    final total = userAttendances.length;
    final present = userAttendances
        .where((attendance) => attendance.status == 'present')
        .length;
    final absent = userAttendances
        .where((attendance) => attendance.status == 'absent')
        .length;
    final late = userAttendances
        .where((attendance) => attendance.status == 'late')
        .length;

    final rate = total > 0 ? ((present + late) / total * 100).toDouble() : 0.0;

    return AttendanceStatistics(
      total: total,
      present: present,
      absent: absent,
      late: late,
      rate: rate,
    );
  }

  /// Sync local attendance records with the server
  Future<void> syncWithServer() async {
    try {
      // Get all local attendance records
      final localAttendances = LocalDatabase().getAllAttendances();

      // Sync each attendance record
      for (final attendance in localAttendances) {
        try {
          await _apiClient.dio.post('/attendances', data: attendance.toJson());
        } catch (e) {
          print('Failed to sync attendance ${attendance.id}: $e');
        }
      }

      print(
        'Successfully synced ${localAttendances.length} attendance records with server',
      );
    } catch (e) {
      print('Failed to sync attendance records with server: $e');
      // In a real app, you might want to retry or store failed records
    }
  }

  /// Sync with server in background (non-blocking)
  void _syncWithServerInBackground() {
    // Run sync in background without waiting for completion
    syncWithServer().catchError((error) {
      print('Background sync failed: $error');
    });
  }
}

class AttendanceStatistics {
  final int total;
  final int present;
  final int absent;
  final int late;
  final double rate;

  AttendanceStatistics({
    required this.total,
    required this.present,
    required this.absent,
    required this.late,
    required this.rate,
  });
}
