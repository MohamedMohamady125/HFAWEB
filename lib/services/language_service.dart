// Create this file: lib/services/language_service.dart

import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';

class LanguageService extends ChangeNotifier {
  static const String _languageKey = 'selected_language';
  bool _isArabic = false;

  bool get isArabic => _isArabic;

  // Singleton pattern
  static final LanguageService _instance = LanguageService._internal();
  factory LanguageService() => _instance;
  LanguageService._internal();

  // Initialize language from storage
  Future<void> initializeLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    _isArabic = prefs.getBool(_languageKey) ?? false;
    notifyListeners();
  }

  // Toggle language and save to storage
  Future<void> toggleLanguage() async {
    _isArabic = !_isArabic;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_languageKey, _isArabic);
    notifyListeners();
  }

  // Get localized text
  String getLocalizedText(String english, String arabic) {
    return _isArabic ? arabic : english;
  }

  // Get text direction
  TextDirection get textDirection =>
      _isArabic ? TextDirection.rtl : TextDirection.ltr;
}
