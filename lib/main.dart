import 'package:flutter/material.dart';
import 'package:smartone/app.dart';
import 'package:smartone/utils/local_database.dart';
import 'package:smartone/utils/notification_service.dart';
import 'package:smartone/data/services/attendance_reminder_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize services
  await LocalDatabase().init();
  await NotificationService().init();

  // Initialize attendance reminder service
  await AttendanceReminderService().rescheduleAllReminders();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const App();
  }
}
