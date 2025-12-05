import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smartone/presentation/providers/language_provider.dart';
import 'package:smartone/presentation/providers/theme_provider.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  @override
  Widget build(BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(
      context,
      listen: false,
    );
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);

    return Scaffold(
      body: Container(
        width: double.infinity,
        padding: EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.fingerprint,
              size: 80,
              color: Theme.of(context).primaryColor,
            ),
            SizedBox(height: 20),
            Text(
              'Smart Presence',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(
              languageProvider.translate('welcome_description'),
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
            SizedBox(height: 40),
            Text(
              languageProvider.translate('select_language'),
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            _buildLanguageOption(
              languageProvider,
              themeProvider,
              'English',
              'en',
              Icons.language,
            ),
            SizedBox(height: 16),
            _buildLanguageOption(
              languageProvider,
              themeProvider,
              'Bahasa Indonesia',
              'id',
              Icons.translate,
            ),
            SizedBox(height: 40),
            Text(
              languageProvider.translate('select_theme'),
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            _buildThemeOption(
              themeProvider,
              languageProvider.translate('light_mode'),
              Icons.light_mode,
              () => themeProvider.setLightMode(),
            ),
            SizedBox(height: 16),
            _buildThemeOption(
              themeProvider,
              languageProvider.translate('dark_mode'),
              Icons.dark_mode,
              () => themeProvider.setDarkMode(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageOption(
    LanguageProvider languageProvider,
    ThemeProvider themeProvider,
    String languageName,
    String languageCode,
    IconData icon,
  ) {
    final isSelected = languageProvider.currentLanguageCode == languageCode;

    return GestureDetector(
      onTap: () {
        if (languageCode == 'id') {
          languageProvider.setIndonesian();
        } else {
          languageProvider.setEnglish();
        }
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        decoration: BoxDecoration(
          color: isSelected
              ? Theme.of(context).primaryColor
              : Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isSelected
                  ? Colors.white
                  : Theme.of(context).iconTheme.color,
            ),
            SizedBox(width: 12),
            Text(
              languageName,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isSelected ? Colors.white : null,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildThemeOption(
    ThemeProvider themeProvider,
    String themeName,
    IconData icon,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Theme.of(context).iconTheme.color),
            SizedBox(width: 12),
            Text(
              themeName,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
