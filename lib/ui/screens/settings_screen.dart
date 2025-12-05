import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smartone/data/services/attendance_reminder_service.dart';
import 'package:smartone/presentation/providers/theme_provider.dart';
import 'package:smartone/presentation/providers/language_provider.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = true;
  bool _faceRecognitionEnabled = true;
  bool _locationTrackingEnabled = true;
  bool _attendanceRemindersEnabled = true;
  String _selectedLanguage = 'English';
  String _selectedTheme = 'System Default';

  @override
  void initState() {
    super.initState();
    // Initialize reminder service
    _initializeReminders();
  }

  Future<void> _initializeReminders() async {
    // Schedule initial reminders
    await AttendanceReminderService().rescheduleAllReminders();
  }

  @override
  Widget build(BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(context);

    return Scaffold(
      appBar: AppBar(title: Text(languageProvider.translate('settings_title'))),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                languageProvider.translate('general'),
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              Card(
                child: Column(
                  children: [
                    SwitchListTile(
                      title: Text(languageProvider.translate('notifications')),
                      subtitle: Text(
                        languageProvider.translate('enable_push_notifications'),
                      ),
                      value: _notificationsEnabled,
                      onChanged: (bool value) {
                        setState(() {
                          _notificationsEnabled = value;
                        });
                      },
                    ),
                    Divider(height: 1),
                    SwitchListTile(
                      title: Text(
                        languageProvider.translate('face_recognition'),
                      ),
                      subtitle: Text(
                        languageProvider.translate('use_face_recognition'),
                      ),
                      value: _faceRecognitionEnabled,
                      onChanged: (bool value) {
                        setState(() {
                          _faceRecognitionEnabled = value;
                        });
                      },
                    ),
                    Divider(height: 1),
                    SwitchListTile(
                      title: Text(
                        languageProvider.translate('location_tracking'),
                      ),
                      subtitle: Text(
                        languageProvider.translate('track_location'),
                      ),
                      value: _locationTrackingEnabled,
                      onChanged: (bool value) {
                        setState(() {
                          _locationTrackingEnabled = value;
                        });
                      },
                    ),
                    Divider(height: 1),
                    SwitchListTile(
                      title: Text(
                        languageProvider.translate('attendance_reminders'),
                      ),
                      subtitle: Text(
                        languageProvider.translate('get_reminders'),
                      ),
                      value: _attendanceRemindersEnabled,
                      onChanged: (bool value) {
                        setState(() {
                          _attendanceRemindersEnabled = value;

                          // Enable or disable reminders
                          if (value) {
                            AttendanceReminderService()
                                .rescheduleAllReminders();
                          } else {
                            AttendanceReminderService().cancelAllReminders();
                          }
                        });
                      },
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20),
              Text(
                languageProvider.translate('preferences'),
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              Card(
                child: Column(
                  children: [
                    ListTile(
                      title: Text(languageProvider.translate('language')),
                      subtitle: Text(_selectedLanguage),
                      trailing: Icon(Icons.arrow_forward_ios),
                      onTap: () {
                        _showLanguageSelectionDialog();
                      },
                    ),
                    Divider(height: 1),
                    ListTile(
                      title: Text(languageProvider.translate('theme')),
                      subtitle: Text(_selectedTheme),
                      trailing: Icon(Icons.arrow_forward_ios),
                      onTap: () {
                        _showThemeSelectionDialog();
                      },
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20),
              Text(
                languageProvider.translate('account'),
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              Card(
                child: Column(
                  children: [
                    ListTile(
                      title: Text(
                        languageProvider.translate('change_password'),
                      ),
                      trailing: Icon(Icons.arrow_forward_ios),
                      onTap: () {
                        // Handle change password
                      },
                    ),
                    Divider(height: 1),
                    ListTile(
                      title: Text(languageProvider.translate('logout')),
                      textColor: Colors.red,
                      trailing: Icon(Icons.logout, color: Colors.red),
                      onTap: () {
                        _showLogoutConfirmationDialog();
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showLanguageSelectionDialog() {
    final languageProvider = Provider.of<LanguageProvider>(
      context,
      listen: false,
    );

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(languageProvider.translate('select_language')),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildLanguageOption(
                'English',
                'English',
                languageProvider: languageProvider,
                onTap: () {
                  languageProvider.setEnglish();
                  setState(() {
                    _selectedLanguage = 'English';
                  });
                },
              ),
              _buildLanguageOption(
                'Indonesian',
                'Bahasa Indonesia',
                languageProvider: languageProvider,
                onTap: () {
                  languageProvider.setIndonesian();
                  setState(() {
                    _selectedLanguage = 'Bahasa Indonesia';
                  });
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLanguageOption(
    String language,
    String code, {
    required LanguageProvider languageProvider,
    VoidCallback? onTap,
  }) {
    return RadioListTile<String>(
      title: Text(language),
      value: code,
      groupValue: _selectedLanguage,
      onChanged: (String? value) {
        if (value != null) {
          setState(() {
            _selectedLanguage = value;
          });

          // Call the onTap callback if provided
          if (onTap != null) {
            onTap();
          }

          Navigator.of(context).pop();
        }
      },
    );
  }

  void _showThemeSelectionDialog() {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    final languageProvider = Provider.of<LanguageProvider>(
      context,
      listen: false,
    );

    showDialog(
      context: context,
      builder: (BuildContext context) {
        final languageProvider = Provider.of<LanguageProvider>(
          context,
          listen: false,
        );

        return AlertDialog(
          title: Text(languageProvider.translate('select_theme')),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildThemeOption('System Default', 'System Default'),
              _buildThemeOption(
                'Light',
                'Light',
                onTap: () {
                  themeProvider.setLightMode();
                },
              ),
              _buildThemeOption(
                'Dark',
                'Dark',
                onTap: () {
                  themeProvider.setDarkMode();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildThemeOption(String theme, String value, {VoidCallback? onTap}) {
    return RadioListTile<String>(
      title: Text(theme),
      value: value,
      groupValue: _selectedTheme,
      onChanged: (String? newValue) {
        if (newValue != null) {
          setState(() {
            _selectedTheme = newValue;
          });

          // Call the onTap callback if provided
          if (onTap != null) {
            onTap();
          }

          Navigator.of(context).pop();
        }
      },
    );
  }

  void _showLogoutConfirmationDialog() {
    final languageProvider = Provider.of<LanguageProvider>(
      context,
      listen: false,
    );

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(languageProvider.translate('confirm_logout')),
          content: Text(languageProvider.translate('sure_logout')),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(languageProvider.translate('cancel')),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                // Handle logout
                Navigator.pushReplacementNamed(context, '/login');
              },
              child: Text(languageProvider.translate('logout')),
            ),
          ],
        );
      },
    );
  }
}
