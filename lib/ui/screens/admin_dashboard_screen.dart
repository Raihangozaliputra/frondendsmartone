import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smartone/presentation/widgets/attendance_chart.dart';
import 'package:smartone/data/services/auth_service.dart';
import 'package:smartone/data/models/user.dart';
import 'package:dio/dio.dart';
import 'package:smartone/data/providers/api_client.dart';
import 'package:smartone/presentation/providers/language_provider.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  User? _currentUser;
  bool _isLoading = true;
  final ApiClient _apiClient = ApiClient();
  Map<String, dynamic>? _dashboardData;

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
      setState(() {
        _currentUser = user;
      });

      // Load dashboard data
      await _loadDashboardData();
    } catch (e) {
      print('Error loading user: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _loadDashboardData() async {
    try {
      final response = await _apiClient.dio.get('/admin/dashboard');
      if (response.statusCode == 200) {
        setState(() {
          _dashboardData = response.data['data'];
        });
      }
    } catch (e) {
      print('Error loading dashboard data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(context);

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

    return Scaffold(
      appBar: AppBar(
        title: Text(
          '${languageProvider.translate('admin')} ${languageProvider.translate('dashboard')}',
        ),
      ),
      body: _dashboardData == null
          ? Center(child: Text(languageProvider.translate('no_data_available')))
          : Padding(
              padding: EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    languageProvider.translate('admin_overview'),
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 20),
                  // Admin stats cards
                  if (_dashboardData != null) ...[
                    Row(
                      children: [
                        Expanded(
                          child: Card(
                            child: Padding(
                              padding: EdgeInsets.all(16.0),
                              child: Column(
                                children: [
                                  Text(
                                    '${_dashboardData!['user_count'] ?? 0}',
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
                                    '${_dashboardData!['class_count'] ?? 0}',
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
                                    '${(_dashboardData!['attendance_rate'] != null ? (_dashboardData!['attendance_rate'] * 100).toStringAsFixed(1) : '0.0')}',
                                    style: TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(height: 5),
                                  Text(
                                    languageProvider.translate(
                                      'attendance_rate',
                                    ),
                                  ),
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
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 10),
                    Card(
                      child: AttendanceChart(
                        attendanceData: [75.0, 82.0, 90.0, 85.0, 78.0],
                        weekdays: ['Mon', 'Tue', 'Wed', 'Thu', 'Fri'],
                      ),
                    ),
                    SizedBox(height: 20),
                    Text(
                      languageProvider.translate('recent_users'),
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 10),
                    Expanded(
                      child: FutureBuilder<Response>(
                        future: _apiClient.dio.get('/admin/users'),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return Center(child: CircularProgressIndicator());
                          }

                          if (snapshot.hasError || snapshot.data == null) {
                            return Center(
                              child: Text(
                                languageProvider.translate(
                                  'failed_to_load_users',
                                ),
                              ),
                            );
                          }

                          final List<dynamic> users =
                              snapshot.data!.data['data'] ?? [];

                          return ListView.builder(
                            itemCount: users.length,
                            itemBuilder: (context, index) {
                              final user = users[index];
                              return ListTile(
                                leading: CircleAvatar(
                                  child: Text(
                                    user['name']?.toString()[0] ?? '?',
                                  ),
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
                                    color: _getStatusColor(
                                      user['status']?.toString(),
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
                ],
              ),
            ),
    );
  }

  Color _getStatusColor(String? status) {
    switch (status?.toLowerCase()) {
      case 'active':
        return Colors.green;
      case 'inactive':
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }
}
