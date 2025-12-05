import 'package:flutter/foundation.dart';
import 'package:smartone/data/models/user.dart';
import 'package:smartone/data/services/user_management_service.dart';

class UserManagementProvider extends ChangeNotifier {
  UserManagementService _userManagementService = UserManagementService();

  List<User> _users = [];
  List<Map<String, dynamic>> _classrooms = [];
  List<Map<String, dynamic>> _schedules = [];
  bool _isLoading = false;
  String? _error;

  // Getters
  List<User> get users => _users;
  List<Map<String, dynamic>> get classrooms => _classrooms;
  List<Map<String, dynamic>> get schedules => _schedules;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Setters
  set userManagementService(UserManagementService service) {
    _userManagementService = service;
    notifyListeners();
  }

  Future<void> loadUsers() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _users = await _userManagementService.getAllUsers();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadClassrooms() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _classrooms = await _userManagementService.getAllClassrooms();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadSchedules() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _schedules = await _userManagementService.getAllSchedules();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<User?> createUser(Map<String, dynamic> userData) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final user = await _userManagementService.createUser(userData);
      await loadUsers(); // Refresh the list
      return user;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<User?> updateUser(String userId, Map<String, dynamic> userData) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final user = await _userManagementService.updateUser(userId, userData);
      await loadUsers(); // Refresh the list
      return user;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> deleteUser(String userId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _userManagementService.deleteUser(userId);
      await loadUsers(); // Refresh the list
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<Map<String, dynamic>?> createClassroom(
    Map<String, dynamic> classroomData,
  ) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final classroom = await _userManagementService.createClassroom(
        classroomData,
      );
      await loadClassrooms(); // Refresh the list
      return classroom;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<Map<String, dynamic>?> updateClassroom(
    String classroomId,
    Map<String, dynamic> classroomData,
  ) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final classroom = await _userManagementService.updateClassroom(
        classroomId,
        classroomData,
      );
      await loadClassrooms(); // Refresh the list
      return classroom;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> deleteClassroom(String classroomId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _userManagementService.deleteClassroom(classroomId);
      await loadClassrooms(); // Refresh the list
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
