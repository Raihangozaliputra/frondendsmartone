import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smartone/data/services/auth_service.dart';
import 'package:smartone/data/models/user.dart';
import 'package:smartone/presentation/providers/language_provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;
  bool _isRegisterMode = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final user = await AuthService().authenticate(
        _emailController.text,
        _passwordController.text,
      );

      if (user != null) {
        // Navigate to home screen
        Navigator.pushReplacementNamed(context, '/home');
      }
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

  Future<void> _handleRegister() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final user = await AuthService().register(
        name: _nameController.text.isEmpty
            ? _emailController.text.split('@').first
            : _nameController.text,
        email: _emailController.text,
        password: _passwordController.text,
      );

      if (user != null) {
        // Navigate to home screen
        Navigator.pushReplacementNamed(context, '/home');
      }
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

  @override
  Widget build(BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          _isRegisterMode
              ? languageProvider.translate('register')
              : languageProvider.translate('login'),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.fingerprint, size: 80, color: Colors.blueAccent),
              SizedBox(height: 20),
              Text(
                'Smart Presence',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 30),
              if (_errorMessage != null) ...[
                Text(_errorMessage!, style: TextStyle(color: Colors.red)),
                SizedBox(height: 10),
              ],
              if (_isRegisterMode) ...[
                TextField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: languageProvider.translate('full_name'),
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 16),
              ],
              TextField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: languageProvider.translate('email'),
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              SizedBox(height: 16),
              TextField(
                controller: _passwordController,
                decoration: InputDecoration(
                  labelText: languageProvider.translate('password'),
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
              ),
              SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading
                      ? null
                      : (_isRegisterMode ? _handleRegister : _handleLogin),
                  child: _isLoading
                      ? CircularProgressIndicator()
                      : Text(
                          _isRegisterMode
                              ? languageProvider.translate('register')
                              : languageProvider.translate('login'),
                        ),
                ),
              ),
              SizedBox(height: 10),
              TextButton(
                onPressed: () {
                  setState(() {
                    _isRegisterMode = !_isRegisterMode;
                    _errorMessage = null;
                  });
                },
                child: Text(
                  _isRegisterMode
                      ? languageProvider.translate('already_have_account')
                      : languageProvider.translate('dont_have_account'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
