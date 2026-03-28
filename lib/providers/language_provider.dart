import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageProvider extends ChangeNotifier {
  Locale _currentLocale = const Locale('en');
  bool _isHinglish = false;

  Locale get currentLocale => _currentLocale;
  bool get isHinglish => _isHinglish;

  LanguageProvider() {
    _loadLanguage();
  }

  void setLanguage(String languageCode) {
    _currentLocale = Locale(languageCode);
    _isHinglish = false;
    _saveLanguage(languageCode, false);
    notifyListeners();
  }

  void setHinglish(bool val) {
    _isHinglish = val;
    if (val) {
      _currentLocale = const Locale('en'); // Use en as base for Hinglish
    }
    _saveLanguage(_currentLocale.languageCode, val);
    notifyListeners();
  }

  void _loadLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    final langCode = prefs.getString('languageCode');
    final hinglish = prefs.getBool('isHinglish') ?? false;
    
    if (langCode != null) {
      _currentLocale = Locale(langCode);
    }
    _isHinglish = hinglish;
    notifyListeners();
  }

  void _saveLanguage(String languageCode, bool hinglish) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('languageCode', languageCode);
    prefs.setBool('isHinglish', hinglish);
  }
}
