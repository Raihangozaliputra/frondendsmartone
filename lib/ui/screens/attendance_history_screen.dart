import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:smartone/data/models/attendance.dart';
import 'package:smartone/data/models/user.dart';
import 'package:smartone/data/services/attendance_service.dart';
import 'package:smartone/data/services/auth_service.dart';
import 'package:smartone/utils/date_utils.dart' as custom_date_utils;
import 'package:smartone/presentation/providers/language_provider.dart';

class AttendanceHistoryScreen extends StatefulWidget {
  const AttendanceHistoryScreen({super.key});

  @override
  State<AttendanceHistoryScreen> createState() =>
      _AttendanceHistoryScreenState();
}

class _AttendanceHistoryScreenState extends State<AttendanceHistoryScreen> {
  User? _currentUser;
  List<Attendance> _attendances = [];
  bool _isLoading = true;
  String? _errorMessage;
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      final user = await AuthService().getCurrentUser();
      setState(() {
        _currentUser = user;
      });

      // Load attendance history
      _loadAttendanceHistory();
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load user data: $e';
      });
    }
  }

  Future<void> _loadAttendanceHistory() async {
    if (_currentUser == null) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final attendances = await AttendanceService().getAttendanceInRange(
        user: _currentUser!,
        startDate: _selectedDate.subtract(Duration(days: 30)),
        endDate: _selectedDate,
      );

      setState(() {
        _attendances = attendances;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _loadAttendanceHistory();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(languageProvider.translate('attendance_history')),
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(16.0),
            child: Row(
              children: [
                Text('${languageProvider.translate('date')}: '),
                TextButton(
                  onPressed: () => _selectDate(context),
                  child: Text(DateFormat('yyyy-MM-dd').format(_selectedDate)),
                ),
              ],
            ),
          ),
          Expanded(
            child: _isLoading
                ? Center(child: CircularProgressIndicator())
                : _errorMessage != null
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(_errorMessage!),
                        SizedBox(height: 10),
                        ElevatedButton(
                          onPressed: _loadAttendanceHistory,
                          child: Text(languageProvider.translate('retry')),
                        ),
                      ],
                    ),
                  )
                : _attendances.isEmpty
                ? Center(
                    child: Text(
                      languageProvider.translate('no_attendance_records_found'),
                    ),
                  )
                : ListView.builder(
                    itemCount: _attendances.length,
                    itemBuilder: (context, index) {
                      final attendance = _attendances[index];
                      return Card(
                        margin: EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        child: ListTile(
                          title: Text(
                            '${languageProvider.translate('check_in')}: ${custom_date_utils.DateUtils.formatTime(attendance.checkInTime)}',
                          ),
                          subtitle: attendance.checkOutTime != null
                              ? Text(
                                  '${languageProvider.translate('check_out')}: ${custom_date_utils.DateUtils.formatTime(attendance.checkOutTime!)}',
                                )
                              : Text(
                                  languageProvider.translate(
                                    'not_checked_out_yet',
                                  ),
                                ),
                          trailing: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: _getStatusColor(
                                attendance.status ?? 'unknown',
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              attendance.status ?? 'Unknown',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
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
