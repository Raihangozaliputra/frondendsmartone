import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smartone/ui/screens/splash_screen.dart';
import 'package:smartone/ui/screens/login_screen.dart';
import 'package:smartone/ui/screens/camera_screen.dart';
import 'package:smartone/ui/screens/attendance_screen.dart';
import 'package:smartone/ui/screens/dashboard_screen.dart';
import 'package:smartone/ui/screens/student_details_screen.dart';
import 'package:smartone/ui/screens/settings_screen.dart';
import 'package:smartone/ui/screens/student_list_screen.dart';
import 'package:smartone/ui/screens/welcome_screen.dart';
import 'package:smartone/data/services/auth_service.dart';
import 'package:smartone/data/models/user.dart';
import 'package:smartone/presentation/providers/theme_provider.dart';
import 'package:smartone/presentation/providers/language_provider.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => ThemeProvider()),
        ChangeNotifierProvider(create: (context) => LanguageProvider()),
      ],
      child: Consumer2<ThemeProvider, LanguageProvider>(
        builder: (context, themeProvider, languageProvider, child) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            theme: themeProvider.themeData,
            initialRoute: '/',
            routes: {
              '/': (context) => const SplashScreen(),
              '/welcome': (context) => const WelcomeScreen(),
              '/login': (context) => const LoginScreen(),
              '/home': (context) => const HomeScreen(),
              '/camera': (context) => const CameraScreen(),
              '/attendance': (context) => const AttendanceScreen(),
              '/dashboard': (context) => const DashboardScreen(),
              '/student_list': (context) => const StudentListScreen(),
              '/student_details': (context) => const StudentDetailsScreen(
                name: 'John Doe',
                studentId: 'STU001',
                email: 'john.doe@example.com',
                profileImageUrl: '',
                className: 'Class 10A',
                attendanceRate: 85,
                totalClasses: 20,
                attendedClasses: 17,
              ),
              '/settings': (context) => const SettingsScreen(),
            },
            onGenerateRoute: (settings) {
              if (settings.name == '/student_details') {
                final args = settings.arguments as Map<String, dynamic>?;
                if (args != null) {
                  return MaterialPageRoute(
                    builder: (context) => StudentDetailsScreen(
                      name: args['name'] as String,
                      studentId: args['studentId'] as String,
                      email: args['email'] as String,
                      profileImageUrl: args['profileImageUrl'] as String,
                      className: args['className'] as String,
                      attendanceRate: args['attendanceRate'] as int,
                      totalClasses: args['totalClasses'] as int,
                      attendedClasses: args['attendedClasses'] as int,
                    ),
                  );
                }
              }
              return null;
            },
          );
        },
      ),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  User? _currentUser;

  @override
  void initState() {
    super.initState();
    _loadCurrentUser();
  }

  Future<void> _loadCurrentUser() async {
    final user = await AuthService().getCurrentUser();
    setState(() {
      _currentUser = user;
    });
  }

  @override
  Widget build(BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(languageProvider.translate('home')),
        actions: [
          IconButton(
            icon: Icon(Icons.settings),
            onPressed: () {
              Navigator.pushNamed(context, '/settings');
            },
          ),
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () async {
              await AuthService().logout();
              if (mounted) {
                Navigator.pushReplacementNamed(context, '/login');
              }
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (_currentUser != null) ...[
              Text(
                '${languageProvider.translate('welcome')}, ${_currentUser!.name}!',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              Text(
                '${languageProvider.translate('role')}: ${_currentUser!.role}',
                style: TextStyle(fontSize: 16, color: Colors.grey[600]),
              ),
              SizedBox(height: 20),
            ],
            Text(languageProvider.translate('smart_presence_system')),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/camera');
              },
              child: Text(languageProvider.translate('open_camera')),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/attendance');
              },
              child: Text(languageProvider.translate('attendance')),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/dashboard');
              },
              child: Text(languageProvider.translate('dashboard')),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/student_list');
              },
              child: Text(languageProvider.translate('student_management')),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/student_details');
              },
              child: Text(languageProvider.translate('student_details')),
            ),
          ],
        ),
      ),
    );
  }
}
