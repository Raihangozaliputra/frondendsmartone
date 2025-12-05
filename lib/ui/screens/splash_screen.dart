import 'package:flutter/material.dart';
import 'package:smartone/data/services/auth_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkAuthentication();
  }

  _checkAuthentication() async {
    await Future.delayed(Duration(milliseconds: 1500));

    final prefs = await SharedPreferences.getInstance();
    final isFirstLaunch = prefs.getBool('is_first_launch') ?? true;
    final isAuthenticated = await AuthService().isAuthenticated();

    if (mounted) {
      if (isFirstLaunch) {
        // Mark that the app has been launched
        await prefs.setBool('is_first_launch', false);
        Navigator.pushReplacementNamed(context, '/welcome');
      } else if (isAuthenticated) {
        Navigator.pushReplacementNamed(context, '/home');
      } else {
        Navigator.pushReplacementNamed(context, '/login');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.fingerprint, size: 80, color: Colors.blueAccent),
            SizedBox(height: 20),
            Text(
              'Smart Presence',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(
              'Absen Cerdas dengan Fitur AI',
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
            SizedBox(height: 30),
            CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}
