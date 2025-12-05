import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smartone/presentation/widgets/attendance_chart.dart';
import 'package:smartone/presentation/widgets/attendance_stats_card.dart';
import 'package:smartone/data/services/auth_service.dart';
import 'package:smartone/data/services/attendance_service.dart';
import 'package:smartone/data/models/user.dart';
import 'package:smartone/utils/secure_storage.dart';
import 'package:dio/dio.dart';
import 'package:smartone/data/providers/api_client.dart';
import 'package:smartone/presentation/providers/language_provider.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  User? _currentUser;
  String? _userRole;
  bool _isLoading = true;
  final ApiClient _apiClient = ApiClient();

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final user = await AuthService().getCurrentUser();
      final role = await SecureStorage.getUserRole();
      setState(() {
        _currentUser = user;
        _userRole = role;
      });
    } catch (e) {
      print('Error loading user: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<Map<String, dynamic>> _loadTeacherDashboardData() async {
    try {
      final response = await _apiClient.dio.get('/teacher/dashboard');
      if (response.statusCode == 200) {
        return response.data['data'];
      } else {
        throw Exception('Failed to load teacher dashboard data');
      }
    } on DioException catch (e) {
      throw Exception('Network error: ${e.message}');
    }
  }

  Future<Map<String, dynamic>> _loadAdminDashboardData() async {
    try {
      final response = await _apiClient.dio.get('/admin/dashboard');
      if (response.statusCode == 200) {
        return response.data['data'];
      } else {
        throw Exception('Failed to load admin dashboard data');
      }
    } on DioException catch (e) {
      throw Exception('Network error: ${e.message}');
    }
  }

  @override
  Widget build(BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(context);

    // Sample data for the chart - in a real app, this would come from the backend
    final List<double> attendanceData = [75.0, 82.0, 90.0, 85.0, 78.0];
    final List<String> weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri'];

    if (_isLoading) {
      return Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_currentUser == null) {
      return Scaffold(
        body: Center(
          child: Text(languageProvider.translate('unable_to_load_user_data')),
        ),
      );
    }

    // Build dashboard based on user role
    Widget dashboardContent;

    if (_userRole == 'teacher') {
      dashboardContent = _buildTeacherDashboard(
        attendanceData,
        weekdays,
        languageProvider,
      );
    } else if (_userRole == 'admin') {
      dashboardContent = _buildAdminDashboard(
        attendanceData,
        weekdays,
        languageProvider,
      );
    } else {
      // Default student dashboard
      dashboardContent = _buildStudentDashboard(
        attendanceData,
        weekdays,
        languageProvider,
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          '${_userRole?.toUpperCase() ?? 'USER'} ${languageProvider.translate('dashboard')}',
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.notifications),
            onPressed: () {
              // Handle notifications
            },
          ),
          IconButton(
            icon: Icon(Icons.settings),
            onPressed: () {
              Navigator.pushNamed(context, '/settings');
            },
          ),
        ],
      ),
      body: Padding(padding: EdgeInsets.all(16.0), child: dashboardContent),
    );
  }

  Widget _buildStudentDashboard(
    List<double> attendanceData,
    List<String> weekdays,
    LanguageProvider languageProvider,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          languageProvider.translate('my_overview'),
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 20),
        // Stats cards with real data
        FutureBuilder<AttendanceStatistics>(
          future: AttendanceService().getAttendanceStatistics(_currentUser!),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError || snapshot.data == null) {
              // Fallback to sample data
              return AttendanceStatsCard(
                totalStudents: 1,
                presentCount: 0,
                absentCount: 0,
                lateCount: 0,
              );
            }

            final stats = snapshot.data!;
            return AttendanceStatsCard(
              totalStudents: stats.total,
              presentCount: stats.present,
              absentCount: stats.absent,
              lateCount: stats.late,
            );
          },
        ),
        SizedBox(height: 20),
        Text(
          languageProvider.translate('weekly_attendance'),
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 10),
        Card(
          child: AttendanceChart(
            attendanceData: attendanceData,
            weekdays: weekdays,
          ),
        ),
        SizedBox(height: 20),
        Text(
          languageProvider.translate('recent_activity'),
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 10),
        Expanded(
          child: ListView(
            children: [
              ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.green,
                  child: Icon(Icons.check, color: Colors.white),
                ),
                title: Text(languageProvider.translate('you')),
                subtitle: Text(
                  '${languageProvider.translate('checked_in_at')} 08:15 AM',
                ),
                trailing: Text(languageProvider.translate('today')),
              ),
              ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.orange,
                  child: Icon(Icons.access_time, color: Colors.white),
                ),
                title: Text(languageProvider.translate('you')),
                subtitle: Text(languageProvider.translate('late_arrival')),
                trailing: Text(languageProvider.translate('yesterday')),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTeacherDashboard(
    List<double> attendanceData,
    List<String> weekdays,
    LanguageProvider languageProvider,
  ) {
    return FutureBuilder<Map<String, dynamic>>(
      future: _loadTeacherDashboardData(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  languageProvider.translate('failed_to_load_dashboard_data'),
                ),
                SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _isLoading = true;
                    });
                    _loadUserData();
                  },
                  child: Text(languageProvider.translate('retry')),
                ),
              ],
            ),
          );
        }

        final data = snapshot.data ?? {};
        final studentCount = data['student_count'] as int? ?? 0;
        final classCount = data['class_count'] as int? ?? 0;
        final attendanceRate = data['attendance_rate'] as double? ?? 0.0;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              languageProvider.translate('teacher_overview'),
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            // Teacher stats cards
            Row(
              children: [
                Expanded(
                  child: Card(
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          Text(
                            '$studentCount',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 5),
                          Text(languageProvider.translate('students')),
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: Card(
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          Text(
                            '$classCount',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 5),
                          Text(languageProvider.translate('classes')),
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: Card(
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          Text(
                            '${(attendanceRate * 100).toStringAsFixed(1)}%',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 5),
                          Text(languageProvider.translate('attendance')),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
            Text(
              languageProvider.translate('class_attendance'),
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Card(
              child: AttendanceChart(
                attendanceData: attendanceData,
                weekdays: weekdays,
              ),
            ),
            SizedBox(height: 20),
            Text(
              languageProvider.translate('recent_students'),
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Expanded(
              child: FutureBuilder<Response>(
                future: _apiClient.dio.get('/teacher/students'),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError || snapshot.data == null) {
                    return Center(
                      child: Text(
                        languageProvider.translate('failed_to_load_students'),
                      ),
                    );
                  }

                  final List<dynamic> students =
                      snapshot.data!.data['data'] ?? [];

                  return ListView.builder(
                    itemCount: students.length,
                    itemBuilder: (context, index) {
                      final student = students[index];
                      return ListTile(
                        leading: CircleAvatar(
                          child: Text(student['name']?.toString()[0] ?? '?'),
                        ),
                        title: Text(
                          student['name']?.toString() ??
                              languageProvider.translate('unknown'),
                        ),
                        subtitle: Text(
                          '${languageProvider.translate('id')}: ${student['id']}',
                        ),
                        trailing: Text(
                          student['attendance_status']?.toString() ?? '',
                          style: TextStyle(
                            color: _getStatusColor(
                              student['attendance_status']?.toString(),
                            ),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildAdminDashboard(
    List<double> attendanceData,
    List<String> weekdays,
    LanguageProvider languageProvider,
  ) {
    return FutureBuilder<Map<String, dynamic>>(
      future: _loadAdminDashboardData(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  languageProvider.translate('failed_to_load_dashboard_data'),
                ),
                SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _isLoading = true;
                    });
                    _loadUserData();
                  },
                  child: Text(languageProvider.translate('retry')),
                ),
              ],
            ),
          );
        }

        final data = snapshot.data ?? {};
        final userCount = data['user_count'] as int? ?? 0;
        final classCount = data['class_count'] as int? ?? 0;
        final attendanceRate = data['attendance_rate'] as double? ?? 0.0;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              languageProvider.translate('admin_overview'),
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            // Admin stats cards
            Row(
              children: [
                Expanded(
                  child: Card(
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          Text(
                            '$userCount',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 5),
                          Text(languageProvider.translate('users')),
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: Card(
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          Text(
                            '$classCount',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 5),
                          Text(languageProvider.translate('classes')),
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: Card(
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          Text(
                            '${(attendanceRate * 100).toStringAsFixed(1)}%',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 5),
                          Text(languageProvider.translate('attendance')),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
            Text(
              languageProvider.translate('system_overview'),
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Card(
              child: AttendanceChart(
                attendanceData: attendanceData,
                weekdays: weekdays,
              ),
            ),
            SizedBox(height: 20),
            Text(
              languageProvider.translate('recent_users'),
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Expanded(
              child: FutureBuilder<Response>(
                future: _apiClient.dio.get('/admin/users'),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError || snapshot.data == null) {
                    return Center(
                      child: Text(
                        languageProvider.translate('failed_to_load_users'),
                      ),
                    );
                  }

                  final List<dynamic> users = snapshot.data!.data['data'] ?? [];

                  return ListView.builder(
                    itemCount: users.length,
                    itemBuilder: (context, index) {
                      final user = users[index];
                      return ListTile(
                        leading: CircleAvatar(
                          child: Text(user['name']?.toString()[0] ?? '?'),
                        ),
                        title: Text(
                          user['name']?.toString() ??
                              languageProvider.translate('unknown'),
                        ),
                        subtitle: Text(
                          '${languageProvider.translate('role')}: ${user['role']}',
                        ),
                        trailing: Text(
                          user['status']?.toString() ?? '',
                          style: TextStyle(
                            color: _getStatusColor(user['status']?.toString()),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Color _getStatusColor(String? status) {
    switch (status?.toLowerCase()) {
      case 'present':
        return Colors.green;
      case 'late':
        return Colors.orange;
      case 'absent':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}
