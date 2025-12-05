import 'package:smartone/utils/notification_service.dart';
import 'package:smartone/utils/date_utils.dart';

class AttendanceReminderService {
  static final AttendanceReminderService _instance =
      AttendanceReminderService._internal();
  factory AttendanceReminderService() => _instance;
  AttendanceReminderService._internal();

  static const int _checkInReminderId = 1;
  static const int _checkOutReminderId = 2;

  /// Schedule check-in reminder for the morning
  Future<void> scheduleCheckInReminder() async {
    final now = DateUtils.getLocalTime();
    final checkInTime = DateTime(now.year, now.month, now.day, 8, 0); // 8:00 AM

    // If the time has already passed today, schedule for tomorrow
    final scheduledTime = checkInTime.isBefore(now)
        ? checkInTime.add(Duration(days: 1))
        : checkInTime;

    await NotificationService().scheduleNotification(
      id: _checkInReminderId,
      title: 'Check-in Reminder',
      body: 'Don't forget to check in for today's attendance!',
      scheduledTime: scheduledTime,
      channel: 'attendance_channel_id',
    );
  }

  /// Schedule check-out reminder for the evening
  Future<void> scheduleCheckOutReminder() async {
    final now = DateUtils.getLocalTime();
    final checkOutTime = DateTime(
      now.year,
      now.month,
      now.day,
      17,
      0,
    ); // 5:00 PM

    // If the time has already passed today, schedule for tomorrow
    final scheduledTime = checkOutTime.isBefore(now)
        ? checkOutTime.add(Duration(days: 1))
        : checkOutTime;

    await NotificationService().scheduleNotification(
      id: _checkOutReminderId,
      title: 'Check-out Reminder',
      body: 'Don't forget to check out before leaving!',
      scheduledTime: scheduledTime,
      channel: 'attendance_channel_id',
    );
  }

  /// Cancel all attendance reminders
  Future<void> cancelAllReminders() async {
    await NotificationService().cancelNotification(_checkInReminderId);
    await NotificationService().cancelNotification(_checkOutReminderId);
  }

  /// Reschedule all reminders
  Future<void> rescheduleAllReminders() async {
    await cancelAllReminders();
    await scheduleCheckInReminder();
    await scheduleCheckOutReminder();
  }

  /// Show attendance confirmation notification
  Future<void> showAttendanceConfirmation(String status) async {
    await NotificationService().showAttendanceConfirmation(
      id: DateTime.now().millisecondsSinceEpoch % 100000,
      status: status,
    );
  }

  /// Show late arrival notification
  Future<void> showLateArrivalNotification(DateTime arrivalTime) async {
    await NotificationService().showLateArrivalNotification(
      id: DateTime.now().millisecondsSinceEpoch % 100000,
      arrivalTime: arrivalTime,
    );
  }
}
