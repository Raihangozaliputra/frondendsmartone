import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;

class NotificationService {
  static final NotificationService _notificationService =
      NotificationService._internal();
  factory NotificationService() => _notificationService;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    // Initialize timezone data
    tz.initializeTimeZones();

    // Android initialization settings
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    // iOS initialization settings
    final DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
          requestAlertPermission: true,
          requestBadgePermission: true,
          requestSoundPermission: true,
          notificationCategories: [
            DarwinNotificationCategory(
              'attendance_reminder',
              actions: <DarwinNotificationAction>[
                DarwinNotificationAction.plain('id_1', 'Check In'),
                DarwinNotificationAction.plain('id_2', 'Check Out'),
              ],
            ),
          ],
        );

    // Initialization settings for both platforms
    final InitializationSettings initializationSettings =
        InitializationSettings(
          android: initializationSettingsAndroid,
          iOS: initializationSettingsIOS,
        );

    // Initialize the plugin
    await _flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse:
          (NotificationResponse notificationResponse) async {},
    );

    // Create notification channels
    await _createNotificationChannels();
  }

  Future<void> _createNotificationChannels() async {
    // Create attendance channel
    const AndroidNotificationChannel attendanceChannel =
        AndroidNotificationChannel(
          'attendance_channel_id',
          'Attendance Notifications',
          description: 'Notifications for attendance reminders and updates',
          importance: Importance.high,
        );

    // Create general channel
    const AndroidNotificationChannel generalChannel =
        AndroidNotificationChannel(
          'general_channel_id',
          'General Notifications',
          description: 'General app notifications',
          importance: Importance.defaultImportance,
        );

    // Create channels
    await _flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(attendanceChannel);
    await _flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(generalChannel);
  }

  Future<void> showNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
    String channel = 'general_channel_id',
  }) async {
    // Android notification details
    final AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails(
          channel,
          'Smart Presence',
          channelDescription: 'Smart Presence notifications',
          importance: Importance.max,
          priority: Priority.high,
          ticker: 'ticker',
        );

    // iOS notification details
    const DarwinNotificationDetails iosNotificationDetails =
        DarwinNotificationDetails();

    // Notification details for both platforms
    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidNotificationDetails,
      iOS: iosNotificationDetails,
    );

    // Show the notification
    await _flutterLocalNotificationsPlugin.show(
      id,
      title,
      body,
      notificationDetails,
      payload: payload,
    );
  }

  Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledTime,
    String? channel,
    String? payload,
  }) async {
    final AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails(
      channel ?? 'default_channel',
      channel ?? 'Default Channel',
      channelDescription: 'Default notification channel',
      importance: Importance.max,
      priority: Priority.high,
      ticker: 'ticker',
      styleInformation: BigTextStyleInformation(''),
    );

    final DarwinNotificationDetails iOSPlatformChannelSpecifics =
        DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
      categoryIdentifier: 'attendance_reminder',
    );

    final NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidNotificationDetails,
      iOS: iOSPlatformChannelSpecifics,
    );

    await _flutterLocalNotificationsPlugin.zonedSchedule(
      id,
      title,
      body,
      tz.TZDateTime.from(scheduledTime, tz.local),
      platformChannelSpecifics,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
      payload: payload,
    );
  }

  // Show attendance reminder notification
  Future<void> showAttendanceReminder({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    await showNotification(
      id: id,
      title: title,
      body: body,
      payload: payload,
      channel: 'attendance_channel_id',
    );
  }

  // Show attendance confirmation notification
  Future<void> showAttendanceConfirmation({
    required int id,
    required String status,
    String? payload,
  }) async {
    await showNotification(
      id: id,
      title: 'Attendance Recorded',
      body: 'Your $status has been successfully recorded.',
      payload: payload,
      channel: 'attendance_channel_id',
    );
  }

  // Show late arrival notification
  Future<void> showLateArrivalNotification({
    required int id,
    required DateTime arrivalTime,
    String? payload,
  }) async {
    await showNotification(
      id: id,
      title: 'Late Arrival',
      body:
          'You arrived at ${arrivalTime.hour}:${arrivalTime.minute.toString().padLeft(2, '0')}. '
          'Please note that punctuality is important.',
      payload: payload,
      channel: 'attendance_channel_id',
    );
  }

  Future<void> cancelNotification(int id) async {
    await _flutterLocalNotificationsPlugin.cancel(id);
  }

  Future<void> cancelAllNotifications() async {
    await _flutterLocalNotificationsPlugin.cancelAll();
  }
}
