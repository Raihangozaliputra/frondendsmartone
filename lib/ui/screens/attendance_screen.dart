import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smartone/data/models/user.dart';
import 'package:smartone/data/services/attendance_service.dart';
import 'package:smartone/utils/location_service.dart';
import 'package:smartone/data/models/attendance.dart';
import 'package:smartone/data/services/auth_service.dart';
import 'package:smartone/presentation/providers/language_provider.dart';

class AttendanceScreen extends StatefulWidget {
  const AttendanceScreen({super.key});

  @override
  State<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
  bool _isCheckedIn = false;
  DateTime? _checkInTime;
  String? _attendanceId;
  bool _isLoading = false;
  User? _currentUser;

  @override
  void initState() {
    super.initState();
    _loadCurrentUserAndAttendance();
  }

  Future<void> _loadCurrentUserAndAttendance() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Load current user
      final user = await AuthService().getCurrentUser();

      if (user != null) {
        setState(() {
          _currentUser = user;
        });

        // Load today's attendance if exists
        final attendance = await AttendanceService().getTodaysAttendance(user);

        if (attendance != null) {
          setState(() {
            _isCheckedIn = attendance.checkOutTime == null;
            _checkInTime = attendance.checkInTime;
            _attendanceId = attendance.id;
          });
        }
      }
    } catch (e) {
      // Handle error silently or show a message
      print('Error loading user or attendance: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _toggleAttendance() async {
    if (_currentUser == null) {
      // Handle case where user is not loaded
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      if (!_isCheckedIn) {
        // Check-in
        // Get current location
        final position = await LocationService().determinePosition();

        // Create attendance record
        final attendance = await AttendanceService().createCheckInAttendance(
          user: _currentUser!,
          latitude: position.latitude,
          longitude: position.longitude,
        );

        setState(() {
          _isCheckedIn = true;
          _checkInTime = attendance.checkInTime;
          _attendanceId = attendance.id;
        });

        if (mounted) {
          // Show success dialog
          showDialog(
            context: context,
            builder: (context) {
              final languageProvider = Provider.of<LanguageProvider>(
                context,
                listen: false,
              );
              return AlertDialog(
                title: Text(languageProvider.translate('success')),
                content: Text(
                  '${languageProvider.translate('check_in')} ${languageProvider.translate('success').toLowerCase()} at ${_checkInTime!.toLocal().toString().split('.').first}',
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: Text(languageProvider.translate('ok')),
                  ),
                ],
              );
            },
          );
        }
      } else {
        // Check-out
        if (_attendanceId != null) {
          final attendance = await AttendanceService().createCheckOutAttendance(
            _attendanceId!,
          );

          if (attendance != null && mounted) {
            // Show success dialog
            showDialog(
              context: context,
              builder: (context) {
                final languageProvider = Provider.of<LanguageProvider>(
                  context,
                  listen: false,
                );
                return AlertDialog(
                  title: Text(languageProvider.translate('success')),
                  content: Text(
                    '${languageProvider.translate('check_out')} ${languageProvider.translate('success').toLowerCase()}',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: Text(languageProvider.translate('ok')),
                    ),
                  ],
                );
              },
            );
          }
        }

        setState(() {
          _isCheckedIn = false;
          _checkInTime = null;
          _attendanceId = null;
        });
      }
    } catch (e) {
      if (mounted) {
        // Show error dialog
        showDialog(
          context: context,
          builder: (context) {
            final languageProvider = Provider.of<LanguageProvider>(
              context,
              listen: false,
            );
            return AlertDialog(
              title: Text(languageProvider.translate('error')),
              content: Text(
                '${languageProvider.translate('failed')} ${languageProvider.translate('attendance').toLowerCase()}: ${e.toString()}',
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text(languageProvider.translate('ok')),
                ),
              ],
            );
          },
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(context);

    return Scaffold(
      appBar: AppBar(title: Text(languageProvider.translate('attendance'))),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      languageProvider.translate('today_attendance'),
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(languageProvider.translate('status') + ':'),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: _isCheckedIn ? Colors.green : Colors.red,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            _isCheckedIn
                                ? languageProvider.translate('checked_in')
                                : languageProvider.translate('not_checked_in'),
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                    if (_checkInTime != null) ...[
                      SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            languageProvider.translate('check_in_time') + ':',
                          ),
                          Text(
                            _checkInTime!.toLocal().toString().split('.').first,
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),
            SizedBox(height: 20),
            Center(
              child: _isLoading
                  ? CircularProgressIndicator()
                  : _currentUser == null
                  ? Text(languageProvider.translate('loading'))
                  : ElevatedButton(
                      onPressed: _toggleAttendance,
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 16,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: Text(
                        _isCheckedIn
                            ? languageProvider.translate('check_out')
                            : languageProvider.translate('check_in'),
                        style: TextStyle(fontSize: 18),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
