import 'package:flutter/foundation.dart';
import 'dart:io';
import 'package:smartone/data/models/attendance.dart';
import 'package:smartone/data/models/user.dart';
import 'package:smartone/data/services/attendance_service.dart';

class AttendanceProvider extends ChangeNotifier {
  AttendanceService _attendanceService = AttendanceService();

  List<Attendance> _attendances = [];
  Attendance? _todaysAttendance;
  AttendanceStatistics? _statistics;
  bool _isLoading = false;
  String? _error;

  // Getters
  List<Attendance> get attendances => _attendances;
  Attendance? get todaysAttendance => _todaysAttendance;
  AttendanceStatistics? get statistics => _statistics;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Setters
  set attendanceService(AttendanceService service) {
    _attendanceService = service;
    notifyListeners();
  }

  Future<void> loadTodaysAttendance(User user) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _todaysAttendance = await _attendanceService.getTodaysAttendance(user);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadAttendanceHistory(
    User user,
    DateTime startDate,
    DateTime endDate,
  ) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _attendances = await _attendanceService.getAttendanceInRange(
        user: user,
        startDate: startDate,
        endDate: endDate,
      );
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadStatistics(User user) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _statistics = await _attendanceService.getAttendanceStatistics(user);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<Attendance?> createCheckInAttendance({
    required User user,
    required double latitude,
    required double longitude,
    required File? faceImage,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final attendance = await _attendanceService.createCheckInAttendance(
        user: user,
        latitude: latitude,
        longitude: longitude,
        faceImage: faceImage,
      );

      // Reload today's attendance
      await loadTodaysAttendance(user);

      return attendance;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<Attendance?> createCheckOutAttendance(
    User user,
    String attendanceId,
  ) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final attendance = await _attendanceService.createCheckOutAttendance(
        attendanceId,
      );

      // Reload today's attendance
      await loadTodaysAttendance(user);

      return attendance;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<Attendance> markAsAbsent({required User user, String? reason}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final attendance = await _attendanceService.markAsAbsent(
        user: user,
        reason: reason,
      );

      // Reload today's attendance
      await loadTodaysAttendance(user);

      return attendance;
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
