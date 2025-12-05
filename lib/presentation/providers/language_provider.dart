import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smartone/utils/translations.dart';

class LanguageProvider extends ChangeNotifier {
  static const String _languageKey = 'app_language';
  static const String _englishCode = 'en';
  static const String _indonesianCode = 'id';

  String _currentLanguageCode = _englishCode;

  String get currentLanguageCode => _currentLanguageCode;

  LanguageProvider() {
    _loadLanguage();
  }

  /// Toggle between English and Indonesian
  void toggleLanguage() {
    _currentLanguageCode = _currentLanguageCode == _englishCode
        ? _indonesianCode
        : _englishCode;
    _saveLanguage();
    notifyListeners();
  }

  /// Set language to English
  void setEnglish() {
    _currentLanguageCode = _englishCode;
    _saveLanguage();
    notifyListeners();
  }

  /// Set language to Indonesian
  void setIndonesian() {
    _currentLanguageCode = _indonesianCode;
    _saveLanguage();
    notifyListeners();
  }

  /// Get translated string for a key
  String translate(String key) {
    return Translations.translate(key, languageCode: _currentLanguageCode);
  }

  /// Load language preference from shared preferences
  Future<void> _loadLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    _currentLanguageCode = prefs.getString(_languageKey) ?? _englishCode;
    notifyListeners();
  }

  /// Save language preference to shared preferences
  Future<void> _saveLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_languageKey, _currentLanguageCode);
  }
}
